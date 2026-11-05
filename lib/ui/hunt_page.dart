import 'package:brahma_core/brahma_core.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../db/database.dart';
import '../domain/hunt_filter.dart';
import '../domain/listing.dart';
import '../domain/pipeline.dart';
import '../domain/portals.dart';
import 'common.dart';
import 'compare_page.dart';
import 'look.dart';
import 'property_page.dart';

class HuntPage extends ConsumerStatefulWidget {
  const HuntPage({super.key});

  @override
  ConsumerState<HuntPage> createState() => _HuntPageState();
}

class _HuntPageState extends ConsumerState<HuntPage> {
  var kind = PropertyKind.rent;
  var showDropped = false;
  var filter = const HuntFilter();
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

  @override
  Widget build(BuildContext context) {
    final home = ref.watch(homeProvider).value;
    final log = ref.watch(interactionsProvider).value ?? const <Interaction>[];
    return PageScaffold(
      title: 'Hunt',
      banner: 'page.hunt',
      actions: [
        HintIconButton(
          'hunt.compare',
          icon: Icons.compare_arrows,
          label: 'Compare shortlist',
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ComparePage(kind))),
        ),
        HintIconButton(
          'hunt.watch',
          icon: Icons.notifications_active_outlined,
          label: 'Check Brahma Watch',
          onPressed: () => _checkWatch(context, ref),
        ),
      ],
      fab: Hint(
        'hunt.add',
        child: FloatingActionButton.extended(
          heroTag: null,
          onPressed: () => _add(context, ref, kind),
          icon: const Icon(Icons.add_home_outlined),
          label: const Text('Add'),
        ),
      ),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SegmentedButton<PropertyKind>(
              segments: const [
                ButtonSegment(
                  value: PropertyKind.rent,
                  label: Text('To rent'),
                  icon: Icon(Icons.key_outlined),
                ),
                ButtonSegment(
                  value: PropertyKind.buy,
                  label: Text('To buy'),
                  icon: Icon(Icons.sell_outlined),
                ),
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
        ),
        const SizedBox(height: 12),
        AsyncView(
          ref.watch(propertiesProvider),
          builder: (all) {
            final mine = all.where((p) => p.kind == kind.name).toList();
            if (mine.isEmpty) {
              return EmptyState(
                icon: Icons.travel_explore,
                title: kind == PropertyKind.rent ? 'No homes to rent yet' : 'No homes to buy yet',
                message:
                    'Paste a PropertyPal link, type one in, or set up a search and let Brahma Watch bring new '
                    'listings here.',
                actions: [
                  FilledButton(
                    onPressed: () => _add(context, ref, kind),
                    child: const Text('Add a property'),
                  ),
                ],
              );
            }
            final hidden = mine.where((p) => !filter.matches(p)).length;
            mine.removeWhere((p) => !filter.matches(p));
            double? dist(Property p) => distanceFromHome(home, p.lat, p.lon);
            final inPlay = mine.where((p) => Stage.of(p.stage).active).toList();
            final top = ([
              ...inPlay.where((p) => p.rating > 0),
            ]..sort((a, b) => b.rating.compareTo(a.rating))).firstOrNull;
            final dearest = mine.map((p) => p.price ?? 0).fold(0, (a, b) => a > b ? a : b);
            final closest = inPlay
                .map(dist)
                .nonNulls
                .fold<double?>(null, (a, b) => a == null || b < a ? b : a);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FigureCard(
                  eyebrow: kind == PropertyKind.rent ? 'To rent · in play' : 'To buy · in play',
                  value: '${inPlay.length}',
                  caption: top == null
                      ? 'Rate the ones you like'
                      : 'Top rated: ${top.address.split(',').first}',
                  detail: closest == null ? null : 'Closest is ${km(closest)} from home',
                ),
                if (hidden > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('$hidden hidden by the filters.'),
                  ),
                for (final stage in Stage.values)
                  if (stage.active || showDropped)
                    ...() {
                      final rows = mine.where((p) => Stage.of(p.stage) == stage).toList()
                        ..sort((a, b) => (dist(a) ?? 1e9).compareTo(dist(b) ?? 1e9));
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
                                    for (final i in log.where((i) => i.propertyId == p.id))
                                      (channel: i.channel, direction: i.direction, at: i.at),
                                  ], today())
                                : null,
                          ),
                      ];
                    }(),
              ],
            );
          },
        ),
      ],
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
        'kept and you type the details, because those sites do not allow apps to read them. If PropertyPal '
        'asks for a browser check, Brahma Watch can bring the listing in instead.',
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
    ],
    onSave: () async {
      if (address.text.trim().isEmpty) return 'Enter the address.';
      final pc = postcode.text.trim().isEmpty ? postcodeIn(address.text) : postcodeIn(postcode.text);
      if (p == null && advert != null) {
        final all = await ref.read(propertiesProvider.future);
        final dup = all.where((x) => x.source == advert.portal.name && x.sourceId == advert.id).firstOrNull;
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
            source: p == null && advert != null ? Value(advert.portal.name) : const Value.absent(),
            sourceId: p == null && advert != null ? Value(advert.id) : const Value.absent(),
            added: Value(p?.added ?? today()),
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
  const PropertyCard(this.p, {super.key, this.distance, this.best = false, this.share, this.quietDays});
  final Property p;

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
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PropertyPage(p.id))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
