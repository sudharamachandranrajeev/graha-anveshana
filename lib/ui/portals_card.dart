import 'package:brahma_core/brahma_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../domain/portals.dart';
import 'common.dart';

/// Opens the big portals' own search pages for an area. England's portals
/// offer no feed and forbid apps reading them, so this only builds links.
class PortalsCard extends ConsumerStatefulWidget {
  const PortalsCard({super.key});

  @override
  ConsumerState<PortalsCard> createState() => _PortalsCardState();
}

class _PortalsCardState extends ConsumerState<PortalsCard> {
  final area = TextEditingController();
  final maxPrice = TextEditingController();
  final minBeds = TextEditingController();
  final maxBeds = TextEditingController();
  var rent = true;
  double radius = 3;

  @override
  void dispose() {
    area.dispose();
    maxPrice.dispose();
    minBeds.dispose();
    maxBeds.dispose();
    super.dispose();
  }

  PortalQuery get query => PortalQuery(
    area: area.text,
    rent: rent,
    maxPrice: intIn(maxPrice),
    minBeds: intIn(minBeds),
    maxBeds: intIn(maxBeds),
    radiusMiles: radius,
  );

  @override
  Widget build(BuildContext context) {
    final areas = {
      for (final a in ref.watch(areasProvider).value ?? const [])
        if ((a.label.isEmpty ? a.postcode : a.label).isNotEmpty) a.label.isEmpty ? a.postcode : a.label,
    };
    final links = portalSearches(query);
    return SectionCard(
      title: 'Rightmove, OnTheMarket and more',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'England\'s portals do not allow apps to read their adverts, so this opens their own search in '
            'your browser. Found one you like? Copy its link and add it under Hunt.',
          ),
          const SizedBox(height: 12),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('To rent')),
              ButtonSegment(value: false, label: Text('For sale')),
            ],
            selected: {rent},
            onSelectionChanged: (v) => setState(() => rent = v.first),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: area,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Town or postcode',
              hintText: 'Leeds, Pontefract, Doncaster, WF8…',
            ),
          ),
          if (areas.isNotEmpty)
            Wrap(
              spacing: 8,
              children: [
                for (final a in areas)
                  ActionChip(label: Text(a), onPressed: () => setState(() => area.text = a)),
              ],
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 140,
                child: TextField(
                  controller: maxPrice,
                  onChanged: (_) => setState(() {}),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: rent ? 'Rent up to' : 'Price up to',
                    prefixText: '£',
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: minBeds,
                  onChanged: (_) => setState(() {}),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Beds from'),
                ),
              ),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: maxBeds,
                  onChanged: (_) => setState(() {}),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Beds to'),
                ),
              ),
              SizedBox(
                width: 140,
                child: DropdownButtonFormField<double>(
                  initialValue: radius,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Within'),
                  items: [
                    for (final r in portalRadii)
                      DropdownMenuItem(value: r, child: Text(r == 0 ? 'This area' : '$r miles')),
                  ],
                  onChanged: (v) => setState(() => radius = v ?? radius),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final l in links)
                FilledButton.tonalIcon(
                  onPressed: () => openUri(context, l.url),
                  icon: const Icon(Icons.open_in_new),
                  label: Text(l.portal.label),
                ),
              if (links.isEmpty) const Text('Type a town or postcode to open the searches.'),
            ],
          ),
        ],
      ),
    );
  }
}
