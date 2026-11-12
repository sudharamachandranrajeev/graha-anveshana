import 'package:brahma_core/brahma_core.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../db/database.dart';
import '../domain/book.dart' show HomePoint;
import '../domain/catalog_book.dart';
import '../domain/hunt_filter.dart';
import '../domain/listing.dart';
import '../domain/pipeline.dart';
import '../domain/price_log.dart';
import '../domain/portals.dart';
import '../domain/running_costs.dart';
import '../domain/viewing_plan.dart';
import 'common.dart';
import 'compare_page.dart';
import 'homes_map.dart';
import 'look.dart';
import 'property_page.dart';
import 'viewing_plan_page.dart';

class HuntPage extends ConsumerStatefulWidget {
  const HuntPage({super.key});

  @override
  ConsumerState<HuntPage> createState() => _HuntPageState();
}

class _HuntPageState extends ConsumerState<HuntPage> {
  var kind = PropertyKind.rent;
  var showDropped = false;
  var filter = const HuntFilter();
  var sort = HuntSort.nearest;
  final words = TextEditingController();
  final maxPrice = TextEditingController();

  @override
  void dispose() {
    words.dispose();
    maxPrice.dispose();
    super.dispose();
  }

  void _setFilter({int? minBeds, bool clearBeds = false}) => setState(
    () => filter = HuntFilter(
      words: words.text,
      minBeds: clearBeds ? null : (minBeds ?? filter.minBeds),
      maxPrice: int.tryParse(maxPrice.text.replaceAll(RegExp(r'[^0-9]'), '')),
    ),
  );

  /// Homes picked for a bulk action; the Shortlist is in picking mode
  /// while [_picking] is on.
  final _picked = <String>{};
  var _picking = false;

  void _pick(String id) => setState(() {
    _picking = true;
    _picked.contains(id) ? _picked.remove(id) : _picked.add(id);
  });

  void _endPicking() => setState(() {
    _picking = false;
    _picked.clear();
  });

  @override
  Widget build(BuildContext context) {
    final home = ref.watch(homeProvider).value;
    final log = ref.watch(interactionsProvider).value ?? const <Interaction>[];
    final views = ref.watch(viewingsProvider).value ?? const <Viewing>[];
    final props = ref.watch(propertiesProvider);
    final all = props.value ?? const <Property>[];
    // A home picked and then removed elsewhere is no longer picked.
    _picked.retainWhere((id) => all.any((p) => p.id == id && p.kind == kind.name));
    return PageScaffold(
      title: 'Shortlist',
      actions: [
        HintIconButton(
          'hunt.compare',
          icon: Icons.compare_arrows,
          label: 'Compare shortlist',
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ComparePage(kind))),
        ),
        IconButton(
          tooltip: 'Pick homes to move, compare or add to a collection',
          isSelected: _picking,
          icon: const Icon(Icons.checklist),
          onPressed: () => _picking ? _endPicking() : setState(() => _picking = true),
        ),
        PopupMenuButton<String>(
          tooltip: 'More',
          onSelected: (v) => switch (v) {
            'viewings' => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const ViewingPlanPage())),
            'share' => _share(context, all, views),
            'map' => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => HuntMapPage(kind))),
            _ => _checkWatch(context, ref),
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'viewings',
              child: ListTile(leading: Icon(Icons.event_note_outlined), title: Text('Viewings, day by day')),
            ),
            PopupMenuItem(
              value: 'share',
              child: ListTile(leading: Icon(Icons.ios_share), title: Text('Share the shortlist')),
            ),
            PopupMenuItem(
              value: 'map',
              child: ListTile(leading: Icon(Icons.map_outlined), title: Text('Map')),
            ),
            PopupMenuItem(
              value: 'watch',
              child: ListTile(
                leading: Icon(Icons.notifications_active_outlined),
                title: Text('Check Brahma Watch'),
              ),
            ),
          ],
        ),
      ],
      fab: _picking
          ? null
          : Hint(
              'hunt.add',
              child: FloatingActionButton.extended(
                heroTag: null,
                onPressed: () => _add(context, ref, kind),
                icon: const Icon(Icons.add_home_outlined),
                label: const Text('Add'),
              ),
            ),
      // Built as it scrolls, so a long shortlist stays quick.
      body: AsyncView(
        props,
        builder: (all) {
          final rows = [
            const HintBanner('page.hunt'),
            _picking ? _pickBar(context, all) : _filters(),
            const SizedBox(height: 12),
            ..._homes(context, all, home, log),
          ];
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 96 + MediaQuery.paddingOf(context).bottom),
            itemCount: rows.length,
            itemBuilder: (_, i) => Readable(child: rows[i]),
          );
        },
      ),
    );
  }

  Widget _filters() => Wrap(
    spacing: 12,
    runSpacing: 8,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      SegmentedButton<PropertyKind>(
        segments: const [
          ButtonSegment(value: PropertyKind.rent, label: Text('To rent'), icon: Icon(Icons.key_outlined)),
          ButtonSegment(value: PropertyKind.buy, label: Text('To buy'), icon: Icon(Icons.sell_outlined)),
        ],
        selected: {kind},
        onSelectionChanged: (s) => setState(() => kind = s.first),
      ),
      FilterChip(
        label: const Text('Not for us'),
        selected: showDropped,
        onSelected: (v) => setState(() => showDropped = v),
      ),
      SizedBox(
        width: 240,
        child: TextField(
          controller: words,
          onChanged: (_) => _setFilter(),
          decoration: const InputDecoration(
            isDense: true,
            prefixIcon: Icon(Icons.search),
            labelText: 'Find',
            helperText: 'Address, postcode or notes. -word hides',
          ),
        ),
      ),
      DropdownButton<int?>(
        value: filter.minBeds,
        hint: const Text('Any beds'),
        items: [
          const DropdownMenuItem(value: null, child: Text('Any beds')),
          for (final b in [1, 2, 3, 4]) DropdownMenuItem(value: b, child: Text('$b+ beds')),
        ],
        onChanged: (b) => b == null ? _setFilter(clearBeds: true) : _setFilter(minBeds: b),
      ),
      DropdownButton<HuntSort>(
        value: sort,
        items: [for (final s in HuntSort.values) DropdownMenuItem(value: s, child: Text(s.label))],
        onChanged: (s) => setState(() => sort = s ?? sort),
      ),
      SizedBox(
        width: 140,
        child: TextField(
          controller: maxPrice,
          keyboardType: TextInputType.number,
          onChanged: (_) => _setFilter(),
          decoration: InputDecoration(
            isDense: true,
            prefixText: '£',
            labelText: kind == PropertyKind.rent ? 'Most a month' : 'Most',
          ),
        ),
      ),
    ],
  );

  /// The cards, under their stage headings, after the summary.
  List<Widget> _homes(BuildContext context, List<Property> all, HomePoint? home, List<Interaction> log) {
    final mine = all.where((p) => p.kind == kind.name).toList();
    if (mine.isEmpty) {
      return [
        EmptyState(
          icon: Icons.travel_explore,
          title: kind == PropertyKind.rent ? 'No homes to rent yet' : 'No homes to buy yet',
          message:
              'Paste a PropertyPal link, type one in, or set up a search and let Brahma Watch bring new '
              'listings here.',
          actions: [
            FilledButton(onPressed: () => _add(context, ref, kind), child: const Text('Add a property')),
          ],
        ),
      ];
    }
    final hidden = mine.where((p) => !filter.matches(p)).length;
    mine.removeWhere((p) => !filter.matches(p));
    double? dist(Property p) => distanceFromHome(home, p.lat, p.lon);
    // Grouped once, not searched again for each card.
    final logOf = <String, List<Interaction>>{};
    for (final i in log) {
      if (i.propertyId case final id?) (logOf[id] ??= []).add(i);
    }
    final inPlay = mine.where((p) => Stage.of(p.stage).active).toList();
    final top = ([
      ...inPlay.where((p) => p.rating > 0),
    ]..sort((a, b) => b.rating.compareTo(a.rating))).firstOrNull;
    final dearest = mine.map((p) => p.price ?? 0).fold(0, (a, b) => a > b ? a : b);
    final closest = inPlay.map(dist).nonNulls.fold<double?>(null, (a, b) => a == null || b < a ? b : a);
    final day = today();
    return [
      FigureCard(
        eyebrow: kind == PropertyKind.rent ? 'To rent · in play' : 'To buy · in play',
        value: '${inPlay.length}',
        caption: top == null ? 'Rate the ones you like' : 'Top rated: ${top.address.split(',').first}',
        detail: closest == null ? null : 'Closest is ${km(closest)} from home',
      ),
      if (hidden > 0)
        Padding(padding: const EdgeInsets.only(top: 8), child: Text('$hidden hidden by the filters.')),
      for (final stage in Stage.values)
        if (stage.active || showDropped)
          ...() {
            final rows = mine.where((p) => Stage.of(p.stage) == stage).toList()
              ..sort((a, b) => sort.compare(a, b, dist));
            if (rows.isEmpty) return const <Widget>[];
            return [
              _StageHeading('${stage.label(kind)} (${rows.length})'),
              for (final p in rows)
                PropertyCard(
                  p,
                  distance: dist(p),
                  best: top != null && p.id == top.id,
                  share: dearest > 0 && p.price != null ? p.price! / dearest : null,
                  quietDays: stage == Stage.enquired || stage == Stage.viewing
                      ? daysWithoutReply([
                          for (final i in logOf[p.id] ?? const <Interaction>[])
                            (channel: i.channel, direction: i.direction, at: i.at),
                        ], day)
                      : null,
                  picked: _picking ? _picked.contains(p.id) : null,
                  onPick: () => _pick(p.id),
                ),
            ];
          }(),
    ];
  }

  /// What can be done to the picked homes at once.
  Widget _pickBar(BuildContext context, List<Property> all) {
    final picked = [
      for (final p in all)
        if (_picked.contains(p.id)) p,
    ];
    final none = picked.isEmpty;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              none ? 'Tap homes to pick them' : '${picked.length} picked',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            PopupMenuButton<Stage>(
              enabled: !none,
              tooltip: 'Move the picked homes',
              onSelected: (s) => _moveTo(context, picked, s),
              itemBuilder: (_) => [
                for (final s in Stage.values)
                  PopupMenuItem(value: s, child: Text('Move to ${s.label(kind)}')),
              ],
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Text('Move to…'),
              ),
            ),
            TextButton(
              onPressed: none ? null : () => _toCollection(context, picked),
              child: const Text('Add to a collection'),
            ),
            TextButton(
              onPressed: picked.length < 2
                  ? null
                  : () =>
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => ComparePage(kind, ids: {..._picked}))),
              child: const Text('Compare'),
            ),
            TextButton(
              onPressed: none ? null : () => _moveTo(context, picked, Stage.dropped),
              child: Text(Stage.dropped.label(kind)),
            ),
            TextButton(onPressed: _endPicking, child: const Text('Done')),
          ],
        ),
      ),
    );
  }

  /// Moves [homes] to [stage], with Undo.
  Future<void> _moveTo(BuildContext context, List<Property> homes, Stage stage) async {
    final before = {for (final p in homes) p.id: Stage.of(p.stage)};
    final messenger = ScaffoldMessenger.of(context);
    if (!await guarded(context, () => ref.mutate((s) => s.book.setStages(before.keys, stage))) || !mounted) {
      return;
    }
    _endPicking();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Moved ${homes.length == 1 ? '1 home' : '${homes.length} homes'} to ${stage.label(kind)}.',
        ),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => ref.mutate((s) async {
            for (final MapEntry(key: id, value: old) in before.entries) {
              await s.book.setStage(id, old);
            }
          }),
        ),
      ),
    );
  }

  /// Adds [homes] to a collection the user picks, or a new one.
  Future<void> _toCollection(BuildContext context, List<Property> homes) async {
    final collections = (await ref.read(researchesProvider.future)).where((r) => !r.archived).toList();
    if (!context.mounted) return;
    final pick = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('Add to which collection?')),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('A new collection'),
              onTap: () => Navigator.pop(sheet, ''),
            ),
            for (final r in collections)
              ListTile(
                leading: const Icon(Icons.collections_bookmark_outlined),
                title: Text(r.name),
                onTap: () => Navigator.pop(sheet, r.id),
              ),
          ],
        ),
      ),
    );
    if (pick == null || !context.mounted) return;
    var id = pick;
    if (id.isEmpty) {
      final name = TextEditingController();
      final made = await showFormDialog(
        context,
        title: 'New collection',
        action: 'Make it',
        fields: (_) => [Field(name, 'Name', autofocus: true)],
        onSave: () async {
          if (name.text.trim().isEmpty) return 'Give it a name.';
          id = await ref.mutate((s) => s.book.createResearch(name.text.trim(), kind: kind.name));
          return null;
        },
      );
      if (!made || !context.mounted) return;
    }
    var added = 0;
    if (await guarded(context, () async => added = await ref.mutate((s) => s.book.addHomes(id, homes))) &&
        context.mounted) {
      _endPicking();
      final skipped = homes.length - added;
      showMessage(
        context,
        'Added ${added == 1 ? '1 home' : '$added homes'} to the collection.'
        '${skipped > 0 ? ' $skipped already in it.' : ''}',
      );
    }
  }

  /// The homes in play, or the picked ones, as text to copy or email.
  Future<void> _share(BuildContext context, List<Property> all, List<Viewing> views) {
    final latest = <String, Viewing>{};
    for (final v in views) {
      if (v.status != 'done' || Impression.of(v.rating) == null) continue;
      if (latest[v.propertyId] case final had? when had.at.compareTo(v.at) >= 0) continue;
      latest[v.propertyId] = v;
    }
    final text = shortlistText(
      _picked.isEmpty
          ? all
          : [
              for (final p in all)
                if (_picked.contains(p.id)) p,
            ],
      kind,
      impressions: {for (final MapEntry(:key, :value) in latest.entries) key: Impression.of(value.rating)!},
      today: today(),
    );
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Share the shortlist', style: Theme.of(sheet).textTheme.titleMedium),
              const SizedBox(height: 4),
              const Text('Prices, sizes, your ratings and advert links. No agents, phone numbers or notes.'),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(sheet).height * 0.45),
                child: SingleChildScrollView(child: SelectableText(text, style: tabular)),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => openUri(
                      sheet,
                      Uri(
                        scheme: 'mailto',
                        query:
                            'subject=${Uri.encodeComponent('Homes on my shortlist')}'
                            '&body=${Uri.encodeComponent(text)}',
                      ),
                    ),
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('Email'),
                  ),
                  FilledButton.icon(
                    onPressed: () => copyText(sheet, text, what: 'Shortlist copied.'),
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkWatch(BuildContext context, WidgetRef ref) async {
    final watch = await ref.read(watchProvider.future);
    if (!context.mounted) return;
    if (watch == null) {
      showMessage(context, 'Set up Brahma Watch in Settings first.');
      return;
    }
    var added = 0;
    if (await guarded(context, () async => added = await ref.mutate((s) => pullWatchEvents(s, watch))) &&
        context.mounted) {
      showMessage(context, added == 0 ? 'Nothing new from Brahma Watch.' : 'Added $added new properties.');
    }
  }

  Future<void> _add(BuildContext context, WidgetRef ref, PropertyKind kind) async {
    final how = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('From a link'),
              subtitle: const Text(
                'PropertyPal adverts and searches, or an advert on Rightmove, Zoopla, OnTheMarket, OpenRent',
              ),
              onTap: () => Navigator.pop(context, 'link'),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Type it in'),
              subtitle: const Text('From a sign, a paper or another site'),
              onTap: () => Navigator.pop(context, 'manual'),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    switch (how) {
      case 'link':
        await importFromLink(context, ref, kind);
      case 'manual':
        await editProperty(context, ref, kind: kind);
    }
  }
}

/// Asks for an advert link. PropertyPal adverts are read; an advert on
/// another portal is only recognised from its link (those sites forbid
/// fetching), so its details are typed in beside the saved link.
Future<void> importFromLink(BuildContext context, WidgetRef ref, PropertyKind kind) async {
  final link = TextEditingController();
  var added = 0, updated = 0;
  PortalAdvert? portal;
  final ok = await showFormDialog(
    context,
    title: 'Add from a link',
    action: 'Add',
    fields: (_) => [
      Field(link, 'Link', hint: 'https://www.propertypal.com/…', autofocus: true),
      const Text(
        'PropertyPal adverts are read for you. For Rightmove, Zoopla, OnTheMarket or OpenRent the link is '
        'kept and you type the details. Quicker: find the home with Search, which reads those sites in '
        'the app, and tap Add to Shortlist.',
      ),
    ],
    onSave: () async {
      portal = parsePortalLink(link.text);
      if (portal != null) return null;
      final List<Listing> listings;
      try {
        listings = await fetchPropertyPal(link.text);
      } on FormatException catch (e) {
        return e.message;
      }
      await ref.mutate((s) async {
        for (final l in listings) {
          (await s.book.importListing(l, kind: kind)).added ? added++ : updated++;
        }
      });
      return null;
    },
  );
  if (!ok || !context.mounted) return;
  if (portal != null) {
    await editProperty(context, ref, kind: kind, advert: portal);
  } else {
    showMessage(context, ['Added $added', if (updated > 0) 'updated $updated'].join(', '));
  }
}

/// Adds a property by hand, or edits one.
Future<void> editProperty(
  BuildContext context,
  WidgetRef ref, {
  Property? p,
  PropertyKind kind = PropertyKind.rent,
  PortalAdvert? advert,
}) {
  final address = TextEditingController(text: p?.address ?? advert?.address);
  final postcode = TextEditingController(text: p?.postcode);
  final price = TextEditingController(text: p?.price?.toString());
  final beds = TextEditingController(text: p?.beds?.toString());
  final style = TextEditingController(text: p?.style);
  final url = TextEditingController(text: p?.url ?? advert?.url.toString());
  final costs = p == null ? null : runningCosts(p);
  final councilTax = TextEditingController(text: costs?.councilTax?.toString());
  final bills = TextEditingController(text: costs?.bills?.toString());
  var k = p == null ? kind : PropertyKind.of(p.kind);
  return showFormDialog(
    context,
    title: p == null ? 'New property' : 'Edit property',
    fields: (setState) => [
      Field(address, 'Address', autofocus: p == null),
      Field(postcode, 'Postcode'),
      Choice(
        label: 'What for',
        value: k,
        options: {for (final x in PropertyKind.values) x: x.label},
        onChanged: (v) => setState(() => k = v),
      ),
      Field(price, k == PropertyKind.rent ? 'Rent a month' : 'Price', number: true, prefix: '£'),
      Field(beds, 'Bedrooms', number: true, helper: '0 for a studio'),
      Field(style, 'Type', hint: 'Apartment, terrace, semi-detached…'),
      Field(url, 'Advert link'),
      if (k != PropertyKind.owned) ...[
        Field(
          councilTax,
          'Council tax a month',
          number: true,
          prefix: '£',
          helper: "The band's yearly charge on the council's site, divided by 12",
        ),
        Field(
          bills,
          'Bills a month',
          number: true,
          prefix: '£',
          helper: 'Energy, water, broadband: your guess',
        ),
      ],
    ],
    onSave: () async {
      if (address.text.trim().isEmpty) return 'Enter the address.';
      final pc = postcode.text.trim().isEmpty ? postcodeIn(address.text) : postcodeIn(postcode.text);
      if (p == null && advert != null) {
        final all = await ref.read(propertiesProvider.future);
        final dup = all
            .where((x) => x.source.toLowerCase() == advert.portal.source && x.sourceId == advert.id)
            .firstOrNull;
        if (dup != null) return 'This advert is already in your list: ${dup.address}.';
      }
      await ref.mutate((s) async {
        final id = p?.id ?? newId();
        await s.book.save(
          s.db.properties,
          PropertiesCompanion(
            id: Value(id),
            address: Value(address.text.trim()),
            postcode: Value(pc ?? postcode.text.trim().toUpperCase()),
            kind: Value(k.name),
            price: Value(intIn(price)),
            beds: Value(intIn(beds)),
            style: Value(style.text.trim()),
            url: Value(url.text.trim()),
            source: p == null && advert != null ? Value(advert.portal.source) : const Value.absent(),
            sourceId: p == null && advert != null ? Value(advert.id) : const Value.absent(),
            added: Value(p?.added ?? today()),
            meta: Value(
              withRunningCosts(p?.meta ?? '{}', councilTax: intIn(councilTax), bills: intIn(bills)),
            ),
          ),
          id,
        );
      });
      return null;
    },
  );
}

/// A stage's heading in the spaced, quiet style of the look; it keeps its
/// case so it reads as a label ("Viewing (1)").
class _StageHeading extends StatelessWidget {
  const _StageHeading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelLarge
          ?.copyWith(color: Tones.of(context).muted, letterSpacing: 1),
    ),
  );
}

/// A property as a row of the hunt: photo, address and facts, with the rent
/// or price large on the right. [best] underlines the top-rated in lime;
/// [share] draws its price against the dearest in the list.
class PropertyCard extends StatelessWidget {
  const PropertyCard(
    this.p, {
    super.key,
    this.distance,
    this.best = false,
    this.share,
    this.quietDays,
    this.picked,
    this.onPick,
  });
  final Property p;

  /// Whether it is picked for a bulk action; null when not picking, so a
  /// tap opens the home. A long press picks it either way.
  final bool? picked;
  final VoidCallback? onPick;

  /// Days since you wrote to the agent with no reply; null when not waiting.
  final int? quietDays;
  final double? distance;
  final bool best;
  final double? share;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final gone = listingGone(p.listingStatus);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final market = MarketFacts.of(p.meta);
    final change = market.changeText;
    // Still advertised as far as the app knows, but no search has shown it.
    final stale = !gone && Stage.of(p.stage).active && market.mayBeGone(today());
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: best
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: dark ? lime.withValues(alpha: 0.35) : Tones.of(context).hairline),
              )
            : null,
        child: InkWell(
          onTap: picked != null
              ? onPick
              : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PropertyPage(p.id))),
          onLongPress: onPick,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (picked != null)
                      Checkbox(
                        value: picked,
                        onChanged: (_) => onPick?.call(),
                        semanticLabel: 'Pick ${p.address}',
                      ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 96,
                        height: 72,
                        child: p.imageUrl == null
                            ? ColoredBox(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.home_outlined),
                              )
                            : Image.network(
                                p.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Icon(Icons.home_outlined),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.address, style: t.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          if (propertyFacts(p).isNotEmpty) Text(propertyFacts(p), style: t.bodySmall),
                          if (share != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 6, right: 24),
                              child: _PriceTrack(share!, best: best),
                            ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 12,
                            children: [
                              if (distance != null)
                                Hint(
                                  'hunt.distance',
                                  child: Text(km(distance!), style: t.bodySmall?.copyWith(color: muted)),
                                ),
                              if (gone)
                                Hint(
                                  'hunt.gone',
                                  child: StatusLabel(Status.warning, listingStatusLabel(p.listingStatus)),
                                ),
                              if (quietDays != null && quietDays! >= chaseAfterDays)
                                StatusLabel(Status.info, 'No reply for $quietDays days: chase'),
                              if (change != null)
                                StatusLabel(market.change! < 0 ? Status.good : Status.warning, change),
                              if (stale)
                                Hint(
                                  'hunt.stale',
                                  child: StatusLabel(
                                    Status.warning,
                                    'May be gone: not seen since ${niceDate(market.seen!)}',
                                  ),
                                ),
                              if (p.rating > 0)
                                Text('★' * p.rating, style: t.bodySmall?.copyWith(color: lime)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      priceLabel(p),
                      textAlign: TextAlign.end,
                      style:
                          (p.price == null
                                  ? t.bodySmall
                                  : t.titleMedium?.copyWith(fontWeight: FontWeight.w800))
                              ?.merge(tabular),
                    ),
                  ],
                ),
              ),
              if (best)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(color: lime, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceTrack extends StatelessWidget {
  const _PriceTrack(this.share, {required this.best});
  final double share;
  final bool best;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(3),
    child: SizedBox(
      height: 4,
      child: Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: Tones.of(context).track)),
          FractionallySizedBox(
            widthFactor: share.clamp(0, 1).toDouble(),
            child: ColoredBox(
              color: best ? lime : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    ),
  );
}

/// The Hunt's homes of one kind on a map, with the home point. Dropped
/// homes are left off.
class HuntMapPage extends ConsumerWidget {
  const HuntMapPage(this.kind, {super.key});
  final PropertyKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeProvider).value;
    final all = ref.watch(propertiesProvider).value ?? const <Property>[];
    final mine = all.where((p) => p.kind == kind.name && Stage.of(p.stage).active);
    return Scaffold(
      appBar: AppBar(
        title: Text(kind == PropertyKind.rent ? 'Homes to rent on the map' : 'Homes to buy on the map'),
      ),
      body: HomesMap(
        centre: home == null ? null : (lat: home.lat, lon: home.lon),
        centreLabel: home?.label.isNotEmpty == true ? home!.label : 'Home',
        homes: [
          for (final p in mine)
            MapHome(
              label: p.price == null ? p.address.split(',').first : gbp(p.price!),
              lat: p.lat,
              lon: p.lon,
              postcode: p.postcode,
              address: p.address,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PropertyPage(p.id))),
            ),
        ],
      ),
    );
  }
}
