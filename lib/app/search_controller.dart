import 'dart:async';

import 'package:brahma_core/brahma_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../domain/property_search.dart';
import '../domain/research.dart';
import '../domain/search_request.dart';
import '../domain/sources.dart';
import 'providers.dart';

/// The HTTP client the Search tab reads the sites with; tests replace it.
final searchHttpProvider = Provider<http.Client>((ref) {
  final c = http.Client();
  ref.onDispose(c.close);
  return c;
});

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
  });
  final SearchRequest? request;

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

  /// Reads [text] into a request and searches. [rent] is used when the words
  /// say neither rent nor buy.
  Future<void> search(String text, {bool rent = true}) => refine(readRequest(text, rent: rent));

  /// Searches again with [q], e.g. after a filter chip changed.
  Future<void> refine(SearchRequest q) async {
    final run = ++_run;
    _all.clear();
    if (q.isEmpty) {
      state = SearchState(request: q, centreNote: 'Say where: a town, area or postcode.');
      return;
    }
    final off = await ref.read(sourcesOffProvider.future);
    state = SearchState(
      request: q,
      sources: {
        for (final s in SourceId.values)
          s: off.contains(s) ? const SourceStatus(SourceState.off) : const SourceStatus(SourceState.waiting),
      },
    );
    final centre = await _centre(q);
    if (run != _run) return;
    state = SearchState(request: q, centre: centre.where, centreNote: centre.note, sources: state.sources);
    await Future.wait([
      for (final s in SourceId.values)
        if (!off.contains(s)) _read(run, s, 0),
    ]);
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
    state = SearchState(
      request: q,
      centre: c,
      centreNote: state.centreNote,
      sources: {
        ...state.sources,
        s: SourceStatus(SourceState.done, read: read, note: 'Read from the page you opened'),
      },
      homes: rankHomes(_all, q, centreLat: c?.lat, centreLon: c?.lon),
      read: _all.length,
    );
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

  void _set(SourceId s, SourceStatus status) {
    state = SearchState(
      request: state.request,
      centre: state.centre,
      centreNote: state.centreNote,
      sources: {...state.sources, s: status},
      homes: state.homes,
      read: state.read,
    );
  }

  Future<void> _read(int run, SourceId s, int page) async {
    final q = state.request;
    // A newer search started: this page belongs to the old one.
    if (q == null || run != _run) return;
    final before = state.sources[s]?.read ?? 0;
    _set(s, SourceStatus(SourceState.reading, read: before, page: page));
    try {
      final got = await _reader.search(s, q, page: page);
      if (run != _run) return;
      mergeListings(_all, got.items);
      final c = state.centre;
      final ranked = rankHomes(_all, q, centreLat: c?.lat, centreLon: c?.lon);
      state = SearchState(
        request: q,
        centre: c,
        centreNote: state.centreNote,
        sources: {
          ...state.sources,
          s: SourceStatus(
            got.more ? SourceState.more : SourceState.done,
            read: before + got.items.length,
            page: page + 1,
          ),
        },
        homes: ranked,
        read: _all.length,
      );
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
