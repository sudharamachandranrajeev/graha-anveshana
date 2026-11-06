import 'dart:convert';

import 'package:brahma_core/brahma_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../app/search_controller.dart';
import '../domain/catalog.dart';
import '../domain/catalog_book.dart';
import '../domain/page_reader.dart';
import '../domain/pipeline.dart';
import '../domain/property_search.dart';
import '../domain/search_request.dart';
import '../domain/sources.dart';
import 'advert_page.dart';
import 'browser_page.dart';
import 'common.dart';
import 'searches_page.dart';

const _recentKey = 'anveshana.search.recent';

/// The last searches on this device, newest first.
final recentSearchesProvider = FutureProvider<List<String>>((ref) async {
  ref.watch(revisionProvider);
  final raw = await ref.watch(sessionProvider).db.localSetting(_recentKey);
  if (raw == null) return const [];
  try {
    return [for (final s in jsonDecode(raw) as List) '$s'];
  } on FormatException {
    return const [];
  }
});

Future<void> _remember(WidgetRef ref, String text) async {
  final now = [text, ...(await ref.read(recentSearchesProvider.future)).where((s) => s != text)].take(8);
  await ref.read(sessionProvider).db.setLocalSetting(_recentKey, jsonEncode(now.toList()));
  ref.changed();
}

const _examples = [
  '2 bed flat to rent in Leeds under £900 with parking',
  'house for sale in York under £250k with a garden',
  'studio to rent near Manchester Piccadilly within 2 miles',
  '3 bed to rent in Enniskillen, pets allowed, no students',
];

/// "1.2 mi".
String miles(double km) {
  final mi = km / 1.609344;
  return mi < 10 ? '${mi.toStringAsFixed(1)} mi' : '${mi.round()} mi';
}

String _labels(Set<String> keys) => [for (final k in keys) SourceId.ofKey(k)?.label ?? k].join(' · ');

/// Saves [h] to the Hunt. Returns the property id.
Future<String?> saveToHunt(BuildContext context, WidgetRef ref, FoundHome h, {required bool rent}) async {
  String? id;
  final ok = await guarded(context, () async {
    final r = await ref.mutate(
      (s) => s.book.importListing(h.main, kind: rent ? PropertyKind.rent : PropertyKind.buy),
    );
    id = r.id;
    if (context.mounted) {
      showMessage(context, r.added ? 'Added to Hunt.' : 'Already in Hunt; its details are updated.');
    }
  });
  return ok ? id : null;
}

/// Adds [h] to a research's catalog the user picks, or to a new one made
/// from [q].
Future<void> saveToResearch(BuildContext context, WidgetRef ref, FoundHome h, SearchRequest q) async {
  final all = (await ref.read(researchesProvider.future)).where((r) => !r.archived).toList();
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
            title: const Text('A new research for this search'),
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
          : await s.book.createResearch(q.label, kind: q.rent ? 'rent' : 'buy', criteria: q.criteria());
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
    if (context.mounted) showMessage(context, 'Added to the research.');
  });
}

/// Opens [s]'s results in the in-app browser; the user can pass the site's
/// check or browse, then read the page into the results.
Future<void> openSourcePage(BuildContext context, WidgetRef ref, SourceId s, Uri url) {
  final rent = ref.read(searchProvider).request?.rent ?? true;
  return openInApp(
    context,
    url,
    title: s.label,
    cardsScript: cardsScript,
    read: (html, cards) async {
      final page = readOpenPage(s, html, cards, rent: rent);
      if (page.items.isEmpty) return 'No adverts found on this page. Open a results page first.';
      final added = ref.read(searchProvider.notifier).addFromPage(s, page);
      return 'Read ${page.items.length} adverts from ${s.label}; $added new to your results.';
    },
  );
}

/// The Search tab: type what you want, see every site's homes that answer
/// it in one list, open any of them in the app.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _text = TextEditingController();
  final _focus = FocusNode();
  var _rent = true;

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
    _focus.unfocus();
    final q = readRequest(words, rent: _rent);
    setState(() => _rent = q.rent);
    await _remember(ref, words);
    await ref.read(searchProvider.notifier).refine(q);
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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Readable(
                    child: SizedBox(width: double.infinity, child: _summary(context, s)),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                sliver: SliverList.builder(
                  itemCount: s.homes.length,
                  itemBuilder: (context, i) {
                    final card = Readable(child: _HomeCard(s.homes[i], q, first: i == 0));
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
                ref.read(searchProvider.notifier).refine(q.copyWith(rent: _rent));
              }
            },
          ),
        ),
      ),
    ],
  );

  Widget _start(BuildContext context) {
    final recent = ref.watch(recentSearchesProvider).value ?? const [];
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Say what you want in your own words: where, rent or buy, bedrooms, price, how far, and what it '
          'must or must not have. Graha Anveshana reads Rightmove, OnTheMarket, OpenRent and PropertyPal '
          'for you and shows every home that answers, in one list, inside the app.',
        ),
        if (recent.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Recent', style: t.titleSmall),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final r in recent) ActionChip(label: Text(r), onPressed: () => _go(r))],
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
            label: Text(q.near.isEmpty ? q.area : '${q.area}, near ${q.near}'),
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
    final must = TextEditingController(text: q.must.join(', '));
    final mustNot = TextEditingController(text: q.mustNot.join(', '));
    List<String> words(TextEditingController c) => [
      for (final w in c.text.split(','))
        if (w.trim().isNotEmpty) w.trim().toLowerCase(),
    ];
    SearchRequest? next;
    await showFormDialog(
      context,
      title: 'Change the search',
      action: 'Search',
      fields: (_) => [
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
        Field(must, 'Must mention', hint: 'parking, garden'),
        Field(mustNot, 'Must not mention', hint: 'students, shared'),
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
          must: words(must),
          mustNot: words(mustNot),
        );
        return null;
      },
    );
    for (final c in [area, near, minBeds, maxBeds, minPrice, maxPrice, radius, must, mustNot]) {
      c.dispose();
    }
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
                tooltip: id == SourceId.zoopla
                    ? 'Zoopla turns apps away. Open it here in the app, then add its homes to your results.'
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

  Widget _summary(BuildContext context, SearchState s) {
    final t = Theme.of(context).textTheme;
    final c = s.centre;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (s.centreNote.isNotEmpty) Text(s.centreNote, style: t.bodySmall),
        Text(
          s.busy && s.homes.isEmpty
              ? 'Searching…'
              : [
                  '${s.homes.length} ${s.homes.length == 1 ? 'home answers' : 'homes answer'}',
                  if (s.read > s.homes.length) 'of ${s.read} read',
                  if (c != null) 'distances from ${c.label}',
                ].join(', '),
          style: t.titleSmall,
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
  const _HomeCard(this.h, this.q, {this.first = false});
  final FoundHome h;
  final SearchRequest q;
  final bool first;

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
      if (h.km != null) miles(h.km!),
    ].join(' · ');
    final save = PopupMenuButton<String>(
      tooltip: 'Save',
      icon: const Icon(Icons.bookmark_add_outlined),
      onSelected: (v) =>
          v == 'hunt' ? saveToHunt(context, ref, h, rent: q.rent) : saveToResearch(context, ref, h, q),
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'hunt', child: Text('Add to Hunt')),
        PopupMenuItem(value: 'research', child: Text('Add to a research')),
      ],
    );
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
              if (h.gone) StatusLabel(Status.warning, q.rent ? 'Let agreed' : 'Sold'),
              first ? TourTarget('search.save', child: save) : save,
            ],
          ),
          Text(l.address, maxLines: 2, overflow: TextOverflow.ellipsis),
          if (facts.isNotEmpty) Text(facts, style: t.bodySmall),
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
                SourceId.zoopla => 'Opened here in the app when you tap it; Zoopla turns apps away',
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
                if (await guarded(context, signOutOfSites) && context.mounted) {
                  showMessage(context, 'Signed out of every site.');
                }
              },
            ),
        ],
      ),
    );
  }
}
