import 'package:brahma_core/brahma_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../db/database.dart';
import '../domain/pipeline.dart';
import '../domain/price_check.dart';
import 'common.dart';
import 'look.dart';
import 'property_page.dart';

/// The homes you are seriously considering, side by side: shortlisted up to
/// agreed. Homes are columns so each fact reads across.
class ComparePage extends ConsumerWidget {
  const ComparePage(this.kind, {super.key});
  final PropertyKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeProvider).value;
    final contacts = {for (final c in ref.watch(contactsProvider).value ?? const <Contact>[]) c.id: c};
    final rows = [
      for (final p in ref.watch(propertiesProvider).value ?? const <Property>[])
        if (p.kind == kind.name && Stage.of(p.stage).active && Stage.of(p.stage) != Stage.fresh) p,
    ]..sort((a, b) => (a.price ?? 1 << 40).compareTo(b.price ?? 1 << 40));
    final rent = kind == PropertyKind.rent;

    String dist(Property p) {
      final d = distanceFromHome(home, p.lat, p.lon);
      return d == null ? '–' : km(d);
    }

    final facts = <(String, String Function(Property))>[
      (rent ? 'Rent a month' : 'Price', (p) => p.price == null ? '–' : gbp(p.price!)),
      if (rent) ('Needed on the day', (p) => p.price == null ? '–' : gbp(moveInCosts(p.price!).total)),
      ('Stage', (p) => Stage.of(p.stage).label(kind)),
      ('Bedrooms', (p) => p.beds == null ? '–' : (p.beds == 0 ? 'Studio' : '${p.beds}')),
      ('Bathrooms', (p) => p.baths == null ? '–' : '${p.baths}'),
      ('Type', (p) => p.style.isEmpty ? '–' : p.style),
      ('Distance from home', dist),
      ('Rating', (p) => p.rating == 0 ? '–' : '${p.rating} of 5'),
      ('Advert', (p) => p.listingStatus.isEmpty ? '–' : listingStatusLabel(p.listingStatus)),
      ('Available', (p) => p.availableFrom == null ? '–' : niceDate(p.availableFrom!)),
      ('Agent', (p) => contacts[p.agentId]?.name ?? '–'),
      ('Postcode', (p) => p.postcode.isEmpty ? '–' : p.postcode),
    ];
    final t = Theme.of(context).textTheme;
    return PageScaffold(
      title: 'Compare',
      children: [
        if (rows.length < 2)
          const EmptyState(
            icon: Icons.compare_arrows,
            title: 'Shortlist two or more',
            message: 'Homes you have shortlisted, enquired about, viewed, applied for or agreed show here side by side.',
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
