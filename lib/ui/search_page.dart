import 'package:brahma_core/brahma_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../db/database.dart';
import '../app/search_controller.dart';
import '../app/search_memory.dart';
import '../domain/catalog.dart';
import '../domain/catalog_book.dart';
import '../domain/home_features.dart';
import '../domain/listing.dart';
import '../domain/more_sites.dart';
import '../domain/page_reader.dart';
import '../domain/pipeline.dart';
import '../domain/property_search.dart';
import '../domain/search_request.dart';
import '../domain/sources.dart';
import '../domain/taste.dart';
import '../domain/trash.dart';
import '../domain/travel.dart';
import 'advert_page.dart';
import 'browser_page.dart';
import 'common.dart';
import 'homes_map.dart';
import 'searches_page.dart';

/// Recent searches shown on the start screen.
const _recentShown = 8;

/// The taste for [q]'s kind, and how like it a home is.
Taste _tasteFor(WidgetRef ref, SearchRequest q) =>
    ref.watch(tasteProvider(q.rent ? 'rent' : 'buy')).value ?? Taste.none;

double _likeness(Taste t, FoundHome h) =>
    t.likeness(price: h.price, beds: h.beds, postcode: h.postcode, text: h.text);

/// How to show a past search: the words typed, unless filters were changed
/// after; then its label.
String named(SearchRequest q) =>
    q.text.isNotEmpty && q.sameAs(readRequest(q.text, rent: q.rent)) ? q.text : q.label;

/// The order results show in: the user's choice, else For you once the
/// taste has learnt from three kept homes, else Best match.
HomeSort effectiveSort(HomeSort? chosen, Taste taste) =>
    chosen ?? (taste.strong ? HomeSort.forYou : HomeSort.best);

const _examples = [
  '2 bed flat to rent in Leeds under £900 with parking',
  'house for sale in York under £250k with a garden',
  'studio to rent near Manchester Piccadilly within 2 miles',
  '3 bed to rent in Enniskillen, pets allowed, no students',
];

String _labels(Set<String> keys) => [for (final k in keys) SourceId.ofKey(k)?.label ?? k].join(' · ');

/// Saves [h] to the Hunt. Returns the property id.
Future<String?> saveToHunt(BuildContext context, WidgetRef ref, FoundHome h, {required bool rent}) async {
  String? id;
  final ok = await guarded(context, () async {
    final r = await ref.mutate(
      (s) => s.book.importListing(
        h.main,
        kind: rent ? PropertyKind.rent : PropertyKind.buy,
        others: h.copies.skip(1).toList(),
      ),
    );
    id = r.id;
    if (context.mounted) {
      showMessage(
        context,
        r.added ? 'Added to Shortlist.' : 'Already in Shortlist; its details are updated.',
      );
    }
  });
  return ok ? id : null;
}

/// Adds [h] to a collection's catalog the user picks, or to a new one made
/// from [q].
Future<void> saveToResearch(BuildContext context, WidgetRef ref, FoundHome h, SearchRequest q) async {
  final all = (await ref.read(researchesProvider.future)).where((r) => !r.archived).toList();
  final centre = ref.read(searchProvider).centre;
  if (!context.mounted) return;
  final pick = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          const ListTile(title: Text('Add to which research?')),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('A new collection for this search'),
            subtitle: Text(q.label),
            onTap: () => Navigator.pop(context, ''),
          ),
          for (final r in all)
            ListTile(
              leading: const Icon(Icons.collections_bookmark_outlined),
              title: Text(r.name),
              onTap: () => Navigator.pop(context, r.id),
            ),
        ],
      ),
    ),
  );
  if (pick == null || !context.mounted) return;
  await guarded(context, () async {
    final l = h.main;
    await ref.mutate((s) async {
      final id = pick.isNotEmpty
          ? pick
          : await s.book.createResearch(
              q.label,
              kind: q.rent ? 'rent' : 'buy',
              criteria: q.criteria(lat: centre?.lat, lon: centre?.lon),
            );
      await s.book.addItem(
        id,
        kind: 'link',
        title: l.address,
        url: l.url,
        source: l.source,
        sourceId: l.sourceId,
        fields: ItemFields.fromListing(l),
        body: l.description,
      );
    });
    if (context.mounted) showMessage(context, 'Added to the collection.');
  });
}

/// Opens [s]'s results in the in-app browser; the user can pass the site's
/// check or browse, then read the page into the results.
Future<void> openSourcePage(BuildContext context, WidgetRef ref, SourceId s, Uri url) async {
  final rent = ref.read(searchProvider).request?.rent ?? true;
  await openInApp(
    context,
    url,
    title: s.label,
    cardsScript: cardsScript,
    autoRead: true,
    read: (html, cards, at) async {
      // The town the user picked on Marketplace is used for it next time.
      final area = ref.read(searchProvider).request?.area ?? '';
      if (s == SourceId.facebook) await rememberMarketplacePlace(ref, area, at);
      final page = readOpenPage(s, html, cards, rent: rent);
      final links = '"id":'.allMatches(cards).length;
      if (page.items.isEmpty) {
        return links == 0
            ? 'No adverts found on this page. Open a results page first.'
            : 'Found $links adverts on this page but could not read them. Use More → Save this page, '
                  'and send it in, so the reading can be fixed.';
      }
      final added = ref.read(searchProvider.notifier).addFromPage(s, page);
      final ids = {for (final l in page.items) '${l.source}:${l.sourceId}'};
      final shown = ref
          .read(searchProvider)
          .homes
          .where((h) => h.copies.any((c) => ids.contains('${c.source}:${c.sourceId}')))
          .length;
      final hidden = page.items.length - shown;
      return 'Read ${page.items.length} adverts from ${s.label}; $added new to your results'
          '${hidden > 0 ? ', $hidden left out by your filters (price, bedrooms, furnishing, words)' : ''}.';
    },
  );
  await _retryIfBlocked(ref, s);
}

/// Searches [s] again when it is still blocked: a sign-in or robot check the
/// user just passed in the in-app browser now lets the hidden browser in.
Future<void> _retryIfBlocked(WidgetRef ref, SourceId s) async {
  if (!s.readInBrowser) return;
  if (ref.read(searchProvider).sources[s]?.state != SourceState.blocked) return;
  await ref.read(searchProvider.notifier).retry(s);
}

/// Connects the app to [s]: the user signs in on the site's own page in the
/// in-app browser, and Search's hidden browser then reads as them. The app
/// never sees the password; the web view keeps the site's cookies.
Future<void> connectSite(BuildContext context, WidgetRef ref, SourceId s) async {
  final signIn = signInFor(s);
  await openInApp(
    context,
    signIn.page,
    title: 'Connect ${s.label}',
    readLabel: "Done: I'm signed in",
    read: (_, _, _) async {
      if (await isSignedIn(s) == false) {
        return 'Not signed in to ${s.label} yet. Sign in on this page first.';
      }
      await markConnected(ref.read(sessionProvider).db, s, isoDate(DateTime.now()));
      ref.read(revisionProvider.notifier).bump();
      return '${s.label} connected. Close this page; Search reads it as you.';
    },
  );
  await _retryIfBlocked(ref, s);
}

/// What the user should know before connecting [s], or null.
String? siteRisk(SourceId s) => switch (s) {
  SourceId.facebook =>
    'Facebook does not allow apps to collect its pages. The app reads Marketplace only when you '
        'search, as you, but Facebook may still ask you to confirm it is you, or limit your account.',
  _ => null,
};

/// Disconnects [s]: signs out of it in the app and forgets the connection.
Future<void> disconnectSite(WidgetRef ref, SourceId s) async {
  await signOutOf(s);
  await markConnected(ref.read(sessionProvider).db, s, null);
  ref.read(revisionProvider.notifier).bump();
}

/// The Search tab: type what you want, see every site's homes that answer
/// it in one list, open any of them in the app.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  Future<void> _throwOut(FoundHome h) async {
    final t = TrashedHome.of(h, isoDate(DateTime.now()));
    final messenger = ScaffoldMessenger.of(context);
    await trashHome(ref, h);
    if (!mounted) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Thrown out. Profile > Trash brings it back.'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              if (mounted) restoreHome(ref, t);
            },
          ),
        ),
      );
  }

  final _text = TextEditingController();
  final _focus = FocusNode();
  var _rent = true;

  /// Results on a map instead of a list.
  var _onMap = false;

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _go([String? text]) async {
    if (text != null) _text.text = text;
    final words = _text.text.trim();
    if (words.isEmpty) return;
    await _run(readRequest(words, rent: _rent));
  }

  /// Runs a search made before or saved, filters and all.
  Future<void> _run(SearchRequest q, {HomeSort? sort}) async {
    _focus.unfocus();
    _text.text = named(q);
    setState(() => _rent = q.rent);
    await ref.read(searchProvider.notifier).refine(q, sort: sort);
  }

  Future<void> _save(BuildContext context, SearchRequest q, HomeSort? sort) async {
    final all = await ref.read(savedSearchesProvider.future);
    if (!context.mounted) return;
    final name = TextEditingController(
      text: all.where((s) => s.request.sameAs(q)).firstOrNull?.name ?? q.label,
    );
    await showFormDialog(
      context,
      title: 'Save this search',
      action: 'Save',
      fields: (_) => [Field(name, 'Name', autofocus: true)],
      onSave: () async {
        if (name.text.trim().isEmpty) return 'Enter a name.';
        await ref.mutate((s) => saveSearch(s.book, all, name.text.trim(), q, sort));
        return null;
      },
    );
    // The dialog's closing animation still reads the field, so the
    // controller is left to the garbage collector, as editSearch does.
  }

  bool _onScroll(ScrollNotification n) {
    final s = ref.read(searchProvider);
    if (n.metrics.extentAfter < 800 && s.more && !s.busy) ref.read(searchProvider.notifier).more();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(searchProvider);
    final q = s.request;
    final taste = q == null ? Taste.none : _tasteFor(ref, q);
    final sort = effectiveSort(s.sort, taste);
    // Homes thrown out of Search never show (Profile > Trash brings them back).
    final trash = ref.watch(trashProvider).value ?? const <TrashedHome>[];
    final kept = [
      for (final h in s.homes)
        if (!isTrashed(h, trash)) h,
    ];
    final homes = sortHomes(kept, sort, likeness: (h) => _likeness(taste, h));
    return PageScaffold(
      title: 'Search',
      actions: [
        IconButton(
          tooltip: 'Saved searches and alerts',
          icon: const Icon(Icons.saved_search),
          onPressed: () =>
              Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SearchesPage())),
        ),
      ],
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Readable(
                  child: SizedBox(width: double.infinity, child: _bar(context)),
                ),
              ),
            ),
            if (q == null)
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: Readable(
                    child: SizedBox(width: double.infinity, child: _start(context)),
                  ),
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Readable(
                    child: SizedBox(width: double.infinity, child: _filters(context, q)),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Readable(
                    child: SizedBox(width: double.infinity, child: _sites(context, s)),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                sliver: SliverToBoxAdapter(child: Readable(child: MoreSitesTile(q))),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Readable(
                    child: SizedBox(
                      width: double.infinity,
                      child: _summary(context, s, sort, taste, shown: kept.length),
                    ),
                  ),
                ),
              ),
              if (_onMap)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: SizedBox(
                      height: (MediaQuery.sizeOf(context).height * 0.65).clamp(320, 760),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: HomesMap(
                          key: ValueKey(q.toJson().toString()),
                          centre: s.centre == null ? null : (lat: s.centre!.lat, lon: s.centre!.lon),
                          centreLabel: s.centre?.label ?? '',
                          shape: q.shape,
                          onDraw: (shape) =>
                              ref.read(searchProvider.notifier).refine(q.copyWith(shape: shape)),
                          homes: [
                            for (final h in homes)
                              MapHome(
                                label: h.price == null
                                    ? (h.beds == null ? 'Home' : '${h.beds} bed')
                                    : gbp(h.price!),
                                lat: h.lat,
                                lon: h.lon,
                                postcode: h.postcode,
                                address: h.main.address,
                                onTap: () =>
                                    Navigator.of(context)
                                        .push(MaterialPageRoute<void>(builder: (_) => AdvertPage(h, q))),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  sliver: SliverList.builder(
                    itemCount: homes.length,
                    itemBuilder: (context, i) {
                      final card = Readable(
                        child: _HomeCard(
                          homes[i],
                          q,
                          onThrowOut: _throwOut,
                          first: i == 0,
                          likeYours: taste.strong && _likeness(taste, homes[i]) >= 0.75,
                        ),
                      );
                      return i == 0 ? TourTarget('search.result', child: card) : card;
                    },
                  ),
                ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 96 + MediaQuery.paddingOf(context).bottom),
                sliver: SliverToBoxAdapter(child: Center(child: _tail(s))),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _bar(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TourTarget(
        'search.bar',
        child: TextField(
          controller: _text,
          focusNode: _focus,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _go(),
          decoration: InputDecoration(
            hintText: 'e.g. 2 bed to rent in Leeds under £900 with parking',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(tooltip: 'Search', icon: const Icon(Icons.arrow_forward), onPressed: _go),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Align(
        alignment: Alignment.centerLeft,
        child: TourTarget(
          'search.kind',
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('To rent')),
              ButtonSegment(value: false, label: Text('For sale')),
            ],
            selected: {_rent},
            onSelectionChanged: (v) {
              setState(() => _rent = v.first);
              final q = ref.read(searchProvider).request;
              if (q != null && q.rent != _rent) {
                ref.read(searchProvider.notifier).refine(q.withRent(_rent));
              }
            },
          ),
        ),
      ),
    ],
  );

  Widget _start(BuildContext context) {
    final history = ref.watch(searchHistoryProvider).value ?? const [];
    final saved = ref.watch(savedSearchesProvider).value ?? const [];
    final last = history.firstOrNull;
    final usual = usualSearch(history);
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Say what you want in your own words: where, rent or buy, bedrooms, price, how far, and what it '
          'must or must not have. Graha Anveshana reads Rightmove, Zoopla, OnTheMarket, OpenRent, '
          'PropertyPal and Facebook Marketplace for you and shows every home that answers, in one list, '
          'inside the app.',
        ),
        if (last != null) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: () => _run(last),
                icon: const Icon(Icons.history),
                label: Text('Carry on: ${named(last)}'),
              ),
              if (usual != null && !usual.sameAs(last))
                OutlinedButton.icon(
                  onPressed: () => _run(usual),
                  icon: const Icon(Icons.repeat),
                  label: Text('Your usual: ${named(usual)}'),
                ),
            ],
          ),
        ],
        if (saved.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Saved', style: t.titleSmall),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in saved)
                InputChip(
                  avatar: const Icon(Icons.bookmark, size: 18),
                  label: Text(s.name),
                  tooltip: s.request.label,
                  onPressed: () => _run(s.request, sort: s.sort),
                  deleteButtonTooltipMessage: 'Forget this search',
                  onDeleted: () => ref.mutate((x) => removeSavedSearch(x.book, saved, s.id)),
                ),
            ],
          ),
        ],
        if (history.length > 1) ...[
          const SizedBox(height: 16),
          Text('Recent', style: t.titleSmall),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final r in history.skip(1).take(_recentShown))
                ActionChip(label: Text(named(r)), onPressed: () => _run(r)),
            ],
          ),
        ],
        const SizedBox(height: 16),
        Text('Try', style: t.titleSmall),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final e in _examples) ActionChip(label: Text(e), onPressed: () => _go(e))],
        ),
      ],
    );
  }

  Widget _filters(BuildContext context, SearchRequest q) {
    final c = ref.read(searchProvider.notifier);
    final beds = switch ((q.minBeds, q.maxBeds)) {
      (0, 0) => 'Studio',
      (final a?, final b?) when a == b => '$a bed',
      (final a?, final b?) => '$a–$b beds',
      (final a?, null) => '$a+ beds',
      (null, final b?) => 'Up to $b beds',
      _ => null,
    };
    final price = switch ((q.minPrice, q.maxPrice)) {
      (final a?, final b?) => '${gbp(a)}–${gbp(b)}',
      (null, final b?) => 'Up to ${gbp(b)}',
      (final a?, null) => 'From ${gbp(a)}',
      _ => null,
    };
    return TourTarget(
      'search.filters',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          InputChip(
            avatar: const Icon(Icons.place_outlined, size: 18),
            label: Text(
              q.area.isEmpty ? 'Say where' : (q.near.isEmpty ? q.area : '${q.area}, near ${q.near}'),
            ),
            onPressed: () => _edit(context, q),
          ),
          if (beds != null)
            InputChip(
              label: Text(beds),
              onPressed: () => _edit(context, q),
              onDeleted: () => c.refine(q.copyWith(minBeds: () => null, maxBeds: () => null)),
            ),
          if (price != null)
            InputChip(
              label: Text('$price${q.rent ? ' pcm' : ''}'),
              onPressed: () => _edit(context, q),
              onDeleted: () => c.refine(q.copyWith(minPrice: () => null, maxPrice: () => null)),
            ),
          if (q.minSqft != null)
            InputChip(
              label: Text('${q.minSqft}+ sq ft'),
              onPressed: () => _edit(context, q),
              onDeleted: () => c.refine(q.copyWith(minSqft: () => null)),
            ),
          if (q.radiusMiles != null)
            InputChip(
              label: Text('Within ${q.radiusMiles!.toStringAsFixed(q.radiusMiles! % 1 == 0 ? 0 : 1)} mi'),
              onPressed: () => _edit(context, q),
              onDeleted: () => c.refine(q.copyWith(radiusMiles: () => null)),
            ),
          for (final w in q.must)
            InputChip(
              avatar: const Icon(Icons.check, size: 18),
              label: Text(w),
              tooltip: 'Homes that mention "$w" come first',
              onDeleted: () => c.refine(q.copyWith(must: [...q.must]..remove(w))),
            ),
          for (final w in q.mustNot)
            InputChip(
              avatar: const Icon(Icons.block, size: 18),
              label: Text('No $w'),
              tooltip: 'Homes that mention "$w" are left out',
              onDeleted: () => c.refine(q.copyWith(mustNot: [...q.mustNot]..remove(w))),
            ),
          for (final f in q.has)
            InputChip(
              avatar: const Icon(Icons.check_box_outlined, size: 18),
              label: Text(f.label),
              tooltip: q.strict
                  ? 'Only homes whose advert says so'
                  : 'Homes whose advert says they lack it are left out',
              onPressed: () => _edit(context, q),
              onDeleted: () => c.refine(q.copyWith(has: [...q.has]..remove(f))),
            ),
          for (final f in q.never)
            InputChip(
              avatar: const Icon(Icons.block, size: 18),
              label: Text('No ${f.label.toLowerCase()}'),
              onPressed: () => _edit(context, q),
              onDeleted: () => c.refine(q.copyWith(never: [...q.never]..remove(f))),
            ),
          if (q.shape.isNotEmpty)
            InputChip(
              avatar: const Icon(Icons.draw_outlined, size: 18),
              label: const Text('Drawn area'),
              tooltip: 'Only homes inside the area you drew',
              onDeleted: () => c.refine(q.copyWith(shape: const [])),
            ),
          if (q.maxMinutes != null)
            InputChip(
              avatar: Icon(travelIcon(TravelMode.of(q.travelMode)), size: 18),
              label: Text('≤ ${q.maxMinutes} min to ${q.travelTo}'),
              tooltip: 'Travel time from the routing service; homes not yet timed stay',
              onPressed: () => _edit(context, q),
              onDeleted: () => c.refine(q.copyWith(maxMinutes: () => null)),
            ),
          FilterChip(
            label: Text(q.rent ? 'Show let agreed' : 'Show sold'),
            selected: q.includeGone,
            onSelected: (v) => c.refine(q.copyWith(includeGone: v)),
          ),
          ActionChip(
            avatar: const Icon(Icons.tune, size: 18),
            label: const Text('Change'),
            onPressed: () => _edit(context, q),
          ),
          ActionChip(
            avatar: const Icon(Icons.bookmark_add_outlined, size: 18),
            label: const Text('Save search'),
            onPressed: () => _save(context, q, ref.read(searchProvider).sort),
          ),
          // Readings worth a second look, with the search likely meant.
          for (final o in oddReadings(q))
            SizedBox(
              width: double.infinity,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  StatusLabel(Status.warning, o.text),
                  if (o.fix case final fix?)
                    TextButton(onPressed: () => c.refine(fix), child: Text('Search ${fix.label} instead')),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, SearchRequest q) async {
    final area = TextEditingController(text: q.area);
    final near = TextEditingController(text: q.near);
    final minBeds = TextEditingController(text: q.minBeds?.toString() ?? '');
    final maxBeds = TextEditingController(text: q.maxBeds?.toString() ?? '');
    final minPrice = TextEditingController(text: q.minPrice?.toString() ?? '');
    final maxPrice = TextEditingController(text: q.maxPrice?.toString() ?? '');
    final radius = TextEditingController(text: q.radiusMiles?.toString() ?? '');
    final size = TextEditingController(text: q.minSqft?.toString() ?? '');
    final must = TextEditingController(text: q.must.join(', '));
    final mustNot = TextEditingController(text: q.mustNot.join(', '));
    List<String> words(TextEditingController c) => [
      for (final w in c.text.split(','))
        if (w.trim().isNotEmpty) w.trim().toLowerCase(),
    ];
    final has = {...q.has}, never = {...q.never};
    var strict = q.strict;
    final minutes = TextEditingController(text: q.maxMinutes?.toString() ?? '');
    var mode = q.travelMode;
    final places = ref.read(profilePlacesProvider).value ?? const <NamedPoint>[];
    var to = places.any((p) => p.label == q.travelTo) ? q.travelTo : (places.firstOrNull?.label ?? '');
    Widget picks(StateSetter setState, Iterable<HomeFeature> all, Set<HomeFeature> chosen) => Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final f in all)
          FilterChip(
            label: Text(f.label),
            selected: chosen.contains(f),
            onSelected: (v) => setState(() => v ? chosen.add(f) : chosen.remove(f)),
          ),
      ],
    );
    SearchRequest? next;
    await showFormDialog(
      context,
      title: 'Change the search',
      action: 'Search',
      fields: (setState) => [
        Field(area, 'Where', hint: 'Town, area or postcode'),
        Field(near, 'Distances from', hint: 'A place or postcode; empty for the area itself'),
        Row(
          children: [
            Expanded(child: Field(minBeds, 'Beds from', number: true)),
            const SizedBox(width: 12),
            Expanded(child: Field(maxBeds, 'Beds to', number: true)),
          ],
        ),
        Row(
          children: [
            Expanded(child: Field(minPrice, 'Price from', number: true, prefix: '£')),
            const SizedBox(width: 12),
            Expanded(child: Field(maxPrice, 'Price to', number: true, prefix: '£')),
          ],
        ),
        Field(radius, 'Within', number: true, suffix: 'miles'),
        Field(size, 'At least', number: true, suffix: 'sq ft'),
        Field(must, 'Must mention', hint: 'parking, garden'),
        Field(mustNot, 'Must not mention', hint: 'students, shared'),
        const SizedBox(height: 12),
        Text('Must have', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        picks(setState, HomeFeature.mustHaves, has),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Also hide homes whose advert does not say'),
          subtitle: const Text('Off: only homes whose advert says they lack it are hidden'),
          value: strict,
          onChanged: (v) => setState(() => strict = v),
        ),
        Text('Never show', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        picks(setState, HomeFeature.neverShows, never),
        const SizedBox(height: 12),
        Text('Travel time', style: Theme.of(context).textTheme.titleSmall),
        if (places.isEmpty)
          const Text('Add a place in Profile (work, family) to limit homes by travel time to it.')
        else ...[
          Row(
            children: [
              Expanded(child: Field(minutes, 'At most', number: true, suffix: 'min')),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: mode,
                  decoration: const InputDecoration(labelText: 'By'),
                  items: [
                    for (final m in TravelMode.values) DropdownMenuItem(value: m.name, child: Text(m.label)),
                  ],
                  onChanged: (v) => setState(() => mode = v ?? mode),
                ),
              ),
            ],
          ),
          DropdownButtonFormField<String>(
            initialValue: to,
            decoration: const InputDecoration(labelText: 'To'),
            items: [for (final p in places) DropdownMenuItem(value: p.label, child: Text(p.label))],
            onChanged: (v) => setState(() => to = v ?? to),
          ),
        ],
      ],
      onSave: () async {
        if (area.text.trim().isEmpty) return 'Say where to search.';
        next = q.copyWith(
          area: area.text.trim(),
          near: near.text.trim(),
          minBeds: () => intIn(minBeds),
          maxBeds: () => intIn(maxBeds),
          minPrice: () => intIn(minPrice),
          maxPrice: () => intIn(maxPrice),
          radiusMiles: () => numberIn(radius)?.toDouble(),
          minSqft: () => intIn(size),
          must: words(must),
          mustNot: words(mustNot),
          has: [
            for (final f in HomeFeature.mustHaves)
              if (has.contains(f)) f,
          ],
          never: [
            for (final f in HomeFeature.neverShows)
              if (never.contains(f)) f,
          ],
          strict: strict,
          maxMinutes: () => places.isEmpty ? null : intIn(minutes),
          travelMode: mode,
          travelTo: to,
        );
        return null;
      },
    );
    // Not disposed here: the closing dialog still draws them. Nothing else
    // holds them, so they go with it.
    if (next != null) await ref.read(searchProvider.notifier).refine(next!);
  }

  Widget _sites(BuildContext context, SearchState s) {
    final scheme = Theme.of(context).colorScheme;
    return TourTarget(
      'search.sites',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final MapEntry(key: id, value: st) in s.sources.entries)
            switch (st.state) {
              SourceState.waiting || SourceState.reading => Chip(
                avatar: const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                label: Text(st.read == 0 ? id.label : '${id.label} ${st.read}'),
              ),
              SourceState.done || SourceState.more => Tooltip(
                message: st.note.isEmpty ? '${st.read} adverts read' : st.note,
                child: Chip(
                  avatar: Icon(Icons.check_circle, size: 18, color: StatusColors.good),
                  label: Text('${id.label} ${st.read}${st.state == SourceState.more ? '+' : ''}'),
                ),
              ),
              SourceState.blocked => ActionChip(
                avatar: Icon(Icons.open_in_browser, size: 18, color: scheme.primary),
                label: Text('Open ${id.label}'),
                tooltip: id.readInBrowser
                    ? '${id.label} showed no homes: it may want a robot check or a sign-in. Open it here; '
                          'its homes join your results as its pages load.'
                    : '${id.label} asked to check you are not a robot. Open it here, pass the check, then '
                          'add its homes to your results.',
                onPressed: st.url == null ? null : () => openSourcePage(context, ref, id, st.url!),
              ),
              SourceState.skipped => Tooltip(
                message: st.note,
                child: Chip(
                  avatar: Icon(Icons.remove_circle_outline, size: 18, color: scheme.onSurfaceVariant),
                  label: Text(id.label),
                ),
              ),
              SourceState.off => Tooltip(
                message: 'Switched off in Settings',
                child: Chip(
                  label: Text(id.label, style: TextStyle(color: scheme.onSurfaceVariant)),
                ),
              ),
            },
        ],
      ),
    );
  }

  Widget _summary(BuildContext context, SearchState s, HomeSort sort, Taste taste, {required int shown}) {
    final binned = s.homes.length - shown;
    final t = Theme.of(context).textTheme;
    final c = s.centre;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (s.centreNote.isNotEmpty) Text(s.centreNote, style: t.bodySmall),
        if (s.travelNote.isNotEmpty) Text(s.travelNote, style: t.bodySmall),
        Text(
          s.busy && s.homes.isEmpty
              ? 'Searching…'
              : [
                  '$shown ${shown == 1 ? 'home answers' : 'homes answer'}',
                  if (s.read > s.homes.length) 'of ${s.read} read',
                  if (binned > 0) '$binned in your Trash',
                  if (c != null) 'distances from ${c.label}',
                ].join(', '),
          style: t.titleSmall,
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            PopupMenuButton<HomeSort>(
              tooltip: 'Sort',
              initialValue: sort,
              onSelected: (v) => ref.read(searchProvider.notifier).setSort(v),
              itemBuilder: (_) => [
                for (final o in HomeSort.values)
                  if (switch (o) {
                    HomeSort.forYou => taste.count > 0,
                    HomeSort.soonest => s.request?.rent != false,
                    // Only when some results give it.
                    HomeSort.perSqft => s.homes.any((h) => h.sqft != null),
                    HomeSort.newest => s.homes.any((h) => h.listedOn != null),
                    _ => true,
                  })
                    PopupMenuItem(value: o, child: Text(o.label)),
              ],
              child: Chip(avatar: const Icon(Icons.sort, size: 18), label: Text('Sort: ${sort.label}')),
            ),
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: false, label: Text('List'), icon: Icon(Icons.view_list_outlined)),
                ButtonSegment(value: true, label: Text('Map'), icon: Icon(Icons.map_outlined)),
              ],
              selected: {_onMap},
              onSelectionChanged: (v) => setState(() => _onMap = v.first),
            ),
          ],
        ),
      ],
    );
  }

  Widget _tail(SearchState s) {
    if (s.busy) return const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator());
    if (s.more) {
      return OutlinedButton(
        onPressed: () => ref.read(searchProvider.notifier).more(),
        child: const Text('Show more'),
      );
    }
    if (s.homes.isEmpty && s.request?.isEmpty == false) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'Nothing answers that yet',
        message: 'Try a bigger distance, a higher price or fewer must-haves. Tap a filter to change it.',
      );
    }
    return const SizedBox();
  }
}

/// One home in the results.
class _HomeCard extends ConsumerWidget {
  const _HomeCard(this.h, this.q, {required this.onThrowOut, this.first = false, this.likeYours = false});
  final FoundHome h;
  final SearchRequest q;
  final bool first;

  /// Held by the page: the card is gone by the time Undo is pressed.
  final Future<void> Function(FoundHome h) onThrowOut;

  /// Close to the homes the user keeps (see Taste).
  final bool likeYours;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final l = h.main;
    final wide = MediaQuery.sizeOf(context).width > 600;
    final picture = h.image == null
        ? ColoredBox(
            color: scheme.surfaceContainerHighest,
            child: Icon(Icons.home_outlined, color: scheme.onSurfaceVariant),
          )
        : Image.network(
            h.image!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => ColoredBox(color: scheme.surfaceContainerHighest),
          );
    final facts = [
      if (h.beds != null) h.beds == 0 ? 'Studio' : '${h.beds} bed',
      if (l.style.isNotEmpty) l.style,
      if (l.furnished.isNotEmpty) l.furnished,
      if (h.sqft != null) '${h.sqft} sq ft',
      if (h.km != null) miles(h.km!),
    ].join(' · ');
    final market = marketLine(h.listedOn, h.reducedOn, today: DateTime.now());
    final places = ref.watch(profilePlacesProvider).value ?? const <NamedPoint>[];
    final asked = ref.watch(searchProvider.select((s) => s.request));
    final far = h.lat == null || h.lon == null
        ? ''
        : [
            if (h.minutes != null && asked != null)
              '${minutesText(h.minutes!)} by ${TravelMode.of(asked.travelMode).label.toLowerCase()} to ${asked.travelTo}',
            for (final p in places) '${miles(distanceKm(p.lat, p.lon, h.lat!, h.lon!))} from ${p.label}',
          ].join(' · ');
    // Already saved from one of this home's adverts.
    final savedAll = ref.watch(savedAdvertsProvider).value ?? const <String, Property>{};
    final saved = [for (final c in h.copies) ?savedAll['${c.source.toLowerCase()}:${c.sourceId}']]
        .firstOrNull;
    final bin = IconButton(
      tooltip: 'Throw out: never show this home again',
      icon: const Icon(Icons.delete_outline),
      onPressed: () => onThrowOut(h),
    );
    final save = PopupMenuButton<String>(
      tooltip: saved == null ? 'Save' : 'Saved: update it, or add to a collection',
      icon: Icon(saved == null ? Icons.bookmark_add_outlined : Icons.bookmark),
      onSelected: (v) =>
          v == 'hunt' ? saveToHunt(context, ref, h, rent: q.rent) : saveToResearch(context, ref, h, q),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'hunt',
          child: Text(saved == null ? 'Add to Shortlist' : 'Update it in your Shortlist'),
        ),
        const PopupMenuItem(value: 'research', child: Text('Add to a collection')),
      ],
    );
    final stage = saved == null ? null : Stage.of(saved.stage);
    final body = Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  h.price == null ? 'Price not shown' : '${gbp(h.price!)}${q.rent ? ' pcm' : ''}',
                  style: t.titleMedium,
                ),
              ),
              if (stage != null)
                StatusLabel(
                  stage.active ? Status.info : Status.warning,
                  'Shortlist: ${stage.label(PropertyKind.of(saved!.kind))}',
                )
              else if (likeYours)
                const StatusLabel(Status.good, 'Like ones you keep'),
              if (h.gone) StatusLabel(Status.warning, q.rent ? 'Let agreed' : 'Sold'),
              first ? TourTarget('search.save', child: save) : save,
              bin,
            ],
          ),
          Text(l.address, maxLines: 2, overflow: TextOverflow.ellipsis),
          if (facts.isNotEmpty) Text(facts, style: t.bodySmall),
          if (far.isNotEmpty) Text(far, style: t.bodySmall),
          if (market != null) Text(market, style: t.bodySmall),
          const SizedBox(height: 4),
          Text(_labels(h.sources), style: t.labelSmall?.copyWith(color: scheme.primary)),
          if (h.misses.isNotEmpty)
            Text(h.misses.join(' · '), style: t.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => AdvertPage(h, q))),
        child: wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 220, height: 150, child: picture),
                  Expanded(child: body),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AspectRatio(aspectRatio: 16 / 9, child: picture),
                  body,
                ],
              ),
      ),
    );
  }
}

/// Settings card: which sites Search reads, and signing out of them.
class SearchSitesCard extends ConsumerWidget {
  const SearchSitesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final off = ref.watch(sourcesOffProvider).value ?? const <SourceId>{};
    return SectionCard(
      title: 'Search sites',
      hint: 'settings.sites',
      child: Column(
        children: [
          for (final s in SourceId.values)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(s.label),
              subtitle: Text(switch (s) {
                SourceId.propertyPal => 'Northern Ireland',
                SourceId.openRent => 'Homes to rent from private landlords',
                SourceId.zoopla => 'All of the UK; read in a hidden browser, as it turns apps away',
                SourceId.facebook =>
                  'Homes from private landlords and sellers; read in a hidden browser. Connect it in Profile '
                      'to search as you',
                _ => 'All of the UK',
              }),
              value: !off.contains(s),
              onChanged: (v) => setSourceOff(ref, s, !v),
            ),
          if (hasWebView)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout),
              title: const Text('Sign out of all sites'),
              subtitle: const Text('Clears what sites you opened in the app keep: sign-ins and cookies.'),
              onTap: () async {
                final out = await guarded(context, () async {
                  await signOutOfSites();
                  for (final s in SourceId.values.where((s) => s.readInBrowser)) {
                    await markConnected(ref.read(sessionProvider).db, s, null);
                  }
                  ref.read(revisionProvider.notifier).bump();
                });
                if (out && context.mounted) {
                  showMessage(context, 'Signed out of every site.');
                }
              },
            ),
        ],
      ),
    );
  }
}

/// Whether the in-app browser still holds [s]'s sign-in (null: cannot tell).
final _signedInProvider = FutureProvider.family<bool?, SourceId>((ref, s) {
  ref.watch(revisionProvider);
  return isSignedIn(s);
});

/// Connect or disconnect one site Search reads in the hidden browser.
class SiteConnectTile extends ConsumerWidget {
  const SiteConnectTile(this.site, {super.key});
  final SourceId site;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final since = ref.watch(siteConnectionProvider(site)).value;
    final signedIn = ref.watch(_signedInProvider(site)).value;
    final connected = since != null && signedIn != false;
    // How the site did in this session's last search.
    final last = ref.watch(searchProvider.select((x) => x.request == null ? null : x.sources[site]));
    final status = switch (last?.state) {
      SourceState.done || SourceState.more => 'Last search: ${last!.read} read.',
      SourceState.blocked => 'Last search: it asked for a check. Open ${site.label} on Search to pass it.',
      SourceState.skipped => 'Last search: not read (${last!.note}).',
      _ => null,
    };
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(connected ? Icons.link : Icons.link_off),
      title: Text(connected ? '${site.label}: connected' : 'Connect ${site.label}'),
      subtitle: Text(
        [
          connected
              ? 'Since $since. Search reads ${site.label} as you, from this device only.'
              : since != null
              ? 'Signed out since you connected. Connect again to search as you.'
              : 'Sign in on ${site.label}\'s own page here; the app never sees your password.',
          ?status,
          if (!connected) ?siteRisk(site),
        ].join(' '),
      ),
      trailing: connected
          ? TextButton(
              onPressed: () async {
                if (await guarded(context, () => disconnectSite(ref, site)) && context.mounted) {
                  showMessage(context, '${site.label} disconnected.');
                }
              },
              child: const Text('Disconnect'),
            )
          : const Icon(Icons.chevron_right),
      onTap: connected ? null : () => connectSite(context, ref, site),
    );
  }
}

/// Sites Search links to but does not read (their owners do not allow it):
/// each opens in the user's own browser, at the search's town where it can.
class MoreSitesTile extends StatelessWidget {
  const MoreSitesTile(this.q, {super.key});
  final SearchRequest? q;

  @override
  Widget build(BuildContext context) {
    final q = this.q;
    if (q == null || q.area.isEmpty) return const SizedBox.shrink();
    final links = moreSiteLinks(q);
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      leading: const Icon(Icons.open_in_new),
      title: Text('More sites (${links.length})'),
      subtitle: const Text('Open in your browser; Search does not read these'),
      children: [
        for (final l in links)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.label),
            subtitle: Text(l.note),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => openUri(context, l.url),
          ),
      ],
    );
  }
}
