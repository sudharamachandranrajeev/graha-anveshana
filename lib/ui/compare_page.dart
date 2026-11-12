import 'package:brahma_core/brahma_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../db/database.dart';
import '../domain/pipeline.dart';
import '../domain/price_log.dart';
import '../domain/price_check.dart';
import '../domain/running_costs.dart';
import 'common.dart';
import 'look.dart';
import 'property_page.dart';

/// Homes side by side: those picked on the Shortlist, else every home in
/// play from Liked on, with New ones too when asked. Homes are columns so
/// each fact reads across.
class ComparePage extends ConsumerStatefulWidget {
  const ComparePage(this.kind, {super.key, this.ids});
  final PropertyKind kind;

  /// The homes picked to compare; null: the whole shortlist.
  final Set<String>? ids;

  @override
  ConsumerState<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends ConsumerState<ComparePage> {
  var _withNew = false;

  @override
  Widget build(BuildContext context) {
    final kind = widget.kind, ids = widget.ids;
    final home = ref.watch(homeProvider).value;
    final contacts = {for (final c in ref.watch(contactsProvider).value ?? const <Contact>[]) c.id: c};
    final all = ref.watch(propertiesProvider).value ?? const <Property>[];
    bool inPlay(Property p) => p.kind == kind.name && Stage.of(p.stage).active;
    final fresh = all.where((p) => inPlay(p) && Stage.of(p.stage) == Stage.fresh).length;
    final rows = [
      for (final p in all)
        if (ids != null ? ids.contains(p.id) : inPlay(p) && (_withNew || Stage.of(p.stage) != Stage.fresh)) p,
    ]..sort((a, b) => (a.price ?? 1 << 40).compareTo(b.price ?? 1 << 40));
    final rent = kind == PropertyKind.rent;

    String dist(Property p) {
      final d = distanceFromHome(home, p.lat, p.lon);
      return d == null ? '–' : km(d);
    }

    final facts = <(String, String Function(Property))>[
      (rent ? 'Rent a month' : 'Price', (p) => p.price == null ? '–' : gbp(p.price!)),
      ('Council tax a month', (p) => _money(runningCosts(p).councilTax)),
      ('Bills a month', (p) => _money(runningCosts(p).bills)),
      if (rent) ('All in a month', (p) => _money(allInMonthly(p))),
      if (rent) ('Needed on the day', (p) => p.price == null ? '–' : gbp(moveInCosts(p.price!).total)),
      ('Stage', (p) => Stage.of(p.stage).label(kind)),
      ('Bedrooms', (p) => p.beds == null ? '–' : (p.beds == 0 ? 'Studio' : '${p.beds}')),
      ('Bathrooms', (p) => p.baths == null ? '–' : '${p.baths}'),
      ('Type', (p) => p.style.isEmpty ? '–' : p.style),
      (
        'Floor area',
        (p) => switch (MarketFacts.of(p.meta).sqft) {
          final a? => '$a sq ft',
          null => '–',
        },
      ),
      ('Distance from home', dist),
      ('Rating', (p) => p.rating == 0 ? '–' : '${p.rating} of 5'),
      ('Advert', (p) => p.listingStatus.isEmpty ? '–' : listingStatusLabel(p.listingStatus)),
      ('Available', (p) => p.availableFrom == null ? '–' : availableLabel(p.availableFrom!)),
      ('Agent', (p) => contacts[p.agentId]?.name ?? '–'),
      ('Postcode', (p) => p.postcode.isEmpty ? '–' : p.postcode),
    ];
    final t = Theme.of(context).textTheme;
    return PageScaffold(
      title: 'Compare',
      children: [
        if (ids == null && fresh > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilterChip(
                label: Text('Include New ($fresh)'),
                selected: _withNew,
                onSelected: (v) => setState(() => _withNew = v),
              ),
            ),
          ),
        if (rows.length < 2)
          EmptyState(
            icon: Icons.compare_arrows,
            title: 'Shortlist two or more',
            message: ids != null
                ? 'Pick two or more homes on the Shortlist to compare them.'
                : 'Homes you liked, enquired about, viewed, applied for or agreed show here side by side. '
                      '${fresh > 0 ? 'Tap Include New to add the ones you have not sorted yet.' : ''}',
          )
        else
          SectionCard(
            title: '${rows.length} homes, ${rent ? 'cheapest' : 'lowest price'} first',
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                defaultColumnWidth: const IntrinsicColumnWidth(),
                children: [
                  TableRow(
                    children: [
                      const SizedBox.shrink(),
                      for (final p in rows)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 4, 24, 8),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 190),
                            child: InkWell(
                              onTap: () =>
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(builder: (_) => PropertyPage(p.id))),
                              child: Text(p.address.split(',').first, style: t.titleSmall),
                            ),
                          ),
                        ),
                    ],
                  ),
                  for (final (label, value) in facts)
                    TableRow(
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Tones.of(context).hairline)),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 24, 8),
                          child: Text(label, style: t.bodySmall),
                        ),
                        for (final p in rows)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 24, 8),
                            child: Text(value(p), style: tabular),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

String _money(int? v) => v == null ? '–' : gbp(v);
