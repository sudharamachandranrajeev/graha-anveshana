import 'dart:async';

import 'package:brahma_core/brahma_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../domain/area_checks.dart';
import '../domain/page_reader.dart';
import '../domain/property_search.dart';
import '../domain/research.dart';
import '../domain/search_request.dart';
import '../domain/sources.dart';
import '../domain/travel.dart';
import '../ui/browser_page.dart' show hiddenPageLoader;
import 'providers.dart';
import 'search_memory.dart';

/// The HTTP client the Search tab reads the sites with; tests replace it.
final searchHttpProvider = Provider<http.Client>((ref) {
  final c = http.Client();
  ref.onDispose(c.close);
  return c;
});

/// Travel times from the OSM community router, cached for the session;
/// tests replace it with one that does not wait between requests.
final travelTimesProvider = Provider<TravelTimes>((ref) => TravelTimes(ref.read(searchHttpProvider)));

/// Area checks (schools, building outline) from OpenStreetMap, cached for
/// the session.
final areaChecksProvider = Provider<AreaChecks>((ref) => AreaChecks(ref.read(searchHttpProvider)));

/// Loads a page in a hidden web view: its HTML and its advert cards
/// ([cardsScript]).
typedef PageLoader = Future<({String html, String cards})> Function(Uri url);

/// How Search reads the [SourceId.readInBrowser] sites; null where this
/// build has no web view (they then wait for the user to open them).
final pageLoaderProvider = Provider<PageLoader?>((ref) => hiddenPageLoader());

const _offKey = 'anveshana.search.off';

/// Sites the user switched off (Settings > Search sites). Local to the device.
final sourcesOffProvider = FutureProvider<Set<SourceId>>((ref) async {
  ref.watch(revisionProvider);
  final raw = await ref.watch(sessionProvider).db.localSetting(_offKey) ?? '';
  return {for (final k in raw.split(',')) ?SourceId.ofKey(k)};
});

Future<void> setSourceOff(WidgetRef ref, SourceId s, bool off) async {
  final now = {...await ref.read(sourcesOffProvider.future)};
  off ? now.add(s) : now.remove(s);
  await ref.read(sessionProvider).db.setLocalSetting(_offKey, [for (final x in now) x.key].join(','));
  ref.changed();
}

enum SourceState { waiting, reading, done, more, blocked, skipped, off }

/// How one site is doing for the current search.
class SourceStatus {
  const SourceStatus(this.state, {this.read = 0, this.note = '', this.url, this.page = 0});
  final SourceState state;

  /// Adverts read from it so far.
  final int read;
  final String note;

  /// The page to open in the browser when the site asks for a check.
  final Uri? url;

  /// The next page to read.
  final int page;
}

typedef Centre = ({double lat, double lon, String label});

class SearchState {
  const SearchState({
    this.request,
    this.centre,
    this.centreNote = '',
    this.sources = const {},
    this.homes = const [],
    this.read = 0,
    this.sort,
    this.travelNote = '',
  });
  final SearchRequest? request;

  /// Why travel times are missing (the router could not be reached).
  final String travelNote;

  /// The order the user chose; null: Best match, or For you once the
  /// taste is strong enough (see the Search page).
  final HomeSort? sort;

  /// Where distances are measured from.
  final Centre? centre;

  /// Why there is no centre, when there is none.
  final String centreNote;
  final Map<SourceId, SourceStatus> sources;

  /// The homes that answer the request, best first.
  final List<FoundHome> homes;

  /// Homes read in all, before filtering.
  final int read;

  bool get busy =>
      sources.values.any((s) => s.state == SourceState.reading || s.state == SourceState.waiting);
  bool get more => sources.values.any((s) => s.state == SourceState.more);
}

/// Runs searches across the sites: the first page of each at once, then
/// further pages as the list is scrolled. A new search drops the old one's
/// late answers.
class SearchController extends Notifier<SearchState> {
  late final SourceReader _reader = SourceReader(ref.read(searchHttpProvider));
  final _all = <FoundHome>[];
  var _run = 0;

  @override
  SearchState build() => const SearchState();

  /// The state with some parts changed; the request's own parts (centre,
  /// sort) carry over.
  SearchState _next({
    SearchRequest? request,
    Centre? centre,
    String? centreNote,
    Map<SourceId, SourceStatus>? sources,
    List<FoundHome>? homes,
    int? read,
    String? travelNote,
  }) => SearchState(
    request: request ?? state.request,
    centre: centre ?? state.centre,
    centreNote: centreNote ?? state.centreNote,
    sources: sources ?? state.sources,
    homes: homes ?? state.homes,
    read: read ?? state.read,
    sort: state.sort,
    travelNote: travelNote ?? state.travelNote,
  );

  /// Homes already sent to the router for this search.
  final _timed = <FoundHome>{};
  var _timingRun = -1;

  /// Times the homes read so far to the search's travel place, when it asks
  /// for a travel-time limit, then ranks again. Homes without a map point,
  /// or not yet timed, stay in the list.
  Future<void> _timeHomes(int run) async {
    final q = state.request;
    if (q == null || q.maxMinutes == null || _timingRun == run) return;
    final places = await ref.read(profilePlacesProvider.future);
    final to = places.where((p) => p.label == q.travelTo).firstOrNull ?? places.firstOrNull;
    if (to == null || run != _run) return;
    _timingRun = run;
    try {
      while (run == _run) {
        final todo = [
          for (final h in _all)
            if (h.lat != null && !_timed.contains(h)) h,
        ];
        if (todo.isEmpty) break;
        _timed.addAll(todo);
        final mins = await ref
            .read(travelTimesProvider)
            .minutes(
              TravelMode.of(q.travelMode),
              [for (final h in todo) (lat: h.lat!, lon: h.lon!)],
              (lat: to.lat, lon: to.lon),
            );
        if (run != _run) return;
        for (final (i, h) in todo.indexed) {
          h.minutes = mins[i];
        }
        final c = state.centre;
        state = _next(
          homes: rankHomes(_all, q, centreLat: c?.lat, centreLon: c?.lon),
          travelNote: '',
        );
      }
    } on TravelUnavailable catch (e) {
      if (run == _run) state = _next(travelNote: '$e Homes are not limited by travel time.');
    } finally {
      if (_timingRun == run) _timingRun = -1;
    }
  }

  /// Reads [text] into a request and searches. [rent] is used when the words
  /// say neither rent nor buy.
  Future<void> search(String text, {bool rent = true}) => refine(readRequest(text, rent: rent));

  /// Searches again with [q], e.g. after a filter chip changed. [sort], when
  /// given, is the order to show the results in (a saved search's).
  Future<void> refine(SearchRequest q, {HomeSort? sort}) async {
    final run = ++_run;
    _all.clear();
    _timed.clear();
    final order = sort ?? state.sort ?? await ref.read(searchSortProvider.future);
    if (q.isEmpty) {
      state = SearchState(request: q, centreNote: 'Say where: a town, area or postcode.', sort: order);
      return;
    }
    final off = await ref.read(sourcesOffProvider.future);
    state = SearchState(
      request: q,
      sort: order,
      sources: {
        for (final s in SourceId.values)
          s: off.contains(s) ? const SourceStatus(SourceState.off) : const SourceStatus(SourceState.waiting),
      },
    );
    await recordSearch(ref, q);
    final centre = await _centre(q);
    if (run != _run) return;
    state = SearchState(
      request: q,
      centre: centre.where,
      centreNote: centre.note,
      sources: state.sources,
      sort: state.sort,
    );
    await Future.wait([
      for (final s in SourceId.values)
        if (!off.contains(s)) _read(run, s, 0),
    ]);
  }

  /// Shows the results in [sort] order, and remembers it for next time.
  Future<void> setSort(HomeSort sort) async {
    state = SearchState(
      request: state.request,
      centre: state.centre,
      centreNote: state.centreNote,
      sources: state.sources,
      homes: state.homes,
      read: state.read,
      sort: sort,
      travelNote: state.travelNote,
    );
    await rememberSort(ref, sort);
  }

  /// Reads the next page of every site that has more.
  Future<void> more() async {
    final run = _run;
    await Future.wait([
      for (final MapEntry(:key, :value) in state.sources.entries)
        if (value.state == SourceState.more) _read(run, key, value.page),
    ]);
  }

  /// Tries one site again (after the user passed its check in the browser).
  Future<void> retry(SourceId s) => _read(_run, s, state.sources[s]?.page ?? 0);

  /// Adds the results the user read from [s]'s page in the in-app browser.
  /// Returns how many were new.
  int addFromPage(SourceId s, SourcePage page) {
    final q = state.request;
    if (q == null) return 0;
    final before = _all.length;
    mergeListings(_all, page.items);
    final c = state.centre;
    final read = (state.sources[s]?.read ?? 0) + page.items.length;
    state = _next(
      sources: {
        ...state.sources,
        s: SourceStatus(SourceState.done, read: read, note: 'Read from the page you opened'),
      },
      homes: rankHomes(_all, q, centreLat: c?.lat, centreLon: c?.lon),
      read: _all.length,
    );
    unawaited(_timeHomes(_run));
    return _all.length - before;
  }

  Future<({Centre? where, String note})> _centre(SearchRequest q) async {
    final place = q.near.isEmpty ? q.area : q.near;
    if (RegExp(r'^(?:home|my home|the home point)$', caseSensitive: false).hasMatch(place.trim())) {
      final home = await ref.read(homeProvider.future);
      if (home != null) return (where: (lat: home.lat, lon: home.lon, label: 'home'), note: '');
    }
    try {
      final where = await Research(client: ref.read(searchHttpProvider)).whereIs(place);
      if (where != null) return (where: where, note: '');
      if (q.near.isNotEmpty) {
        final area = await Research(client: ref.read(searchHttpProvider)).whereIs(q.area);
        if (area != null) {
          return (
            where: area,
            note: 'Could not find "${q.near}" on the map, so distances are from ${q.area}.',
          );
        }
      }
    } on Object {
      // Offline or the lookup failed: the search still runs, without distances.
    }
    return (where: null, note: 'Could not find "$place" on the map, so distances are not shown.');
  }

  void _set(SourceId s, SourceStatus status) => state = _next(sources: {...state.sources, s: status});

  /// Reads a [SourceId.readInBrowser] site's results page in a hidden web
  /// view. A page with no adverts is a robot check, a sign-in or an empty
  /// search: the user is offered the page to look at themselves.
  Future<SourcePage> _readInBrowser(SourceId s, SearchRequest q, int page) async {
    final url = browserSearchUrl(s, q, page: page);
    final load = ref.read(pageLoaderProvider);
    if (load == null) throw SourceBlocked(s, url);
    final ({String html, String cards}) got;
    try {
      got = await load(url);
    } on Object {
      throw SourceBlocked(s, url);
    }
    final read = readOpenPage(s, got.html, got.cards, rent: q.rent);
    if (read.items.isEmpty) throw SourceBlocked(s, url);
    return (items: read.items, more: browserHasMore(s, got.html, page));
  }

  Future<void> _read(int run, SourceId s, int page) async {
    final q = state.request;
    // A newer search started: this page belongs to the old one.
    if (q == null || run != _run) return;
    final before = state.sources[s]?.read ?? 0;
    _set(s, SourceStatus(SourceState.reading, read: before, page: page));
    try {
      final got = s.readInBrowser ? await _readInBrowser(s, q, page) : await _reader.search(s, q, page: page);
      if (run != _run) return;
      mergeListings(_all, got.items);
      final c = state.centre;
      state = _next(
        sources: {
          ...state.sources,
          s: SourceStatus(
            got.more ? SourceState.more : SourceState.done,
            read: before + got.items.length,
            page: page + 1,
          ),
        },
        homes: rankHomes(_all, q, centreLat: c?.lat, centreLon: c?.lon),
        read: _all.length,
      );
      unawaited(_timeHomes(run));
    } on SourceBlocked catch (e) {
      if (run == _run) {
        _set(s, SourceStatus(SourceState.blocked, read: before, url: e.url, page: page, note: '$e'));
      }
    } on SourceSkipped catch (e) {
      if (run == _run) _set(s, SourceStatus(SourceState.skipped, read: before, note: e.reason, page: page));
    } on Object catch (e) {
      if (run == _run) {
        _set(s, SourceStatus(SourceState.skipped, read: before, note: describeError(e), page: page));
      }
    }
  }
}

final searchProvider = NotifierProvider<SearchController, SearchState>(SearchController.new);
