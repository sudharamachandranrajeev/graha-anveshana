import 'package:brahma_core/brahma_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import '../domain/advert_check.dart';
import '../domain/pipeline.dart';
import '../domain/price_check.dart';
import '../domain/research.dart';
import 'common.dart';
import 'look.dart';

/// Is the rent or price fair? Compares an advert with open data for its
/// postcode, and for lets lists the most a tenant can be asked to pay up front.
class PriceCheckCard extends ConsumerStatefulWidget {
  const PriceCheckCard(this.p, {super.key});
  final Property p;

  @override
  ConsumerState<PriceCheckCard> createState() => _PriceCheckCardState();
}

class _PriceCheckCardState extends ConsumerState<PriceCheckCard> {
  List<CheckLine>? lines;
  String? error;
  var busy = false;

  Future<void> _run() async {
    final p = widget.p;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final research = Research();
      final place = await research.place(p.postcode);
      final result = <CheckLine>[];
      if (PropertyKind.of(p.kind) == PropertyKind.rent) {
        result.addAll(rentCheck(rent: p.price!, beds: p.beds, place: place));
      } else {
        // Each source can fail on its own; the other still answers.
        List<Sale> sales = const [];
        PriceIndex? index;
        final problems = <String>[];
        try {
          sales = await research.sales(place.postcode);
          // A postcode holds few homes: widen to the street when too few are comparable.
          final first = sales.firstOrNull;
          final today = ref.read(todayProvider);
          if (first != null &&
              first.street.isNotEmpty &&
              comparableSales(sales, today, p.style).sales.length < minComparableSales) {
            final street = await research.salesOnStreet(first.street, first.town);
            final seen = {for (final s in sales) '${s.date}|${s.price}|${s.address}'};
            sales = [
              ...sales,
              for (final s in street)
                if (!seen.contains('${s.date}|${s.price}|${s.address}')) s,
            ];
          }
        } catch (e) {
          problems.add('Sold prices: ${describeError(e)}');
        }
        try {
          index = await research.priceIndex(place.district);
        } catch (e) {
          problems.add('House price index: ${describeError(e)}');
        }
        result.addAll(
          priceCheck(
            price: p.price!,
            style: p.style,
            today: ref.read(todayProvider),
            sales: sales,
            index: index,
          ),
        );
        if (problems.isNotEmpty) error = problems.join('\n');
      }
      if (mounted) setState(() => lines = result);
    } catch (e) {
      if (mounted) setState(() => error = describeError(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final rent = PropertyKind.of(p.kind) == PropertyKind.rent;
    if (p.price == null || p.postcode.isEmpty || PropertyKind.of(p.kind) == PropertyKind.owned) {
      return const SizedBox.shrink();
    }
    final costs = rent ? moveInCosts(p.price!) : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SectionCard(
        title: 'Is it fair?',
        trailing: TextButton.icon(
          onPressed: busy ? null : _run,
          icon: const Icon(Icons.fact_check_outlined),
          label: const Text('Check'),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (busy) const LinearProgressIndicator(),
            if (lines == null && !busy)
              Text(
                rent
                    ? 'Compare this rent with the area and with housing benefit rates.'
                    : 'Compare this price with recent sales in the postcode and the area average.',
              ),
            if (lines != null && lines!.isEmpty) const Text('Nothing to compare with for this area yet.'),
            for (final l in lines ?? const <CheckLine>[]) ...[
              FigureRow(l.label, l.value, status: _status(l.verdict)),
              if (l.note.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(l.note, style: Theme.of(context).textTheme.bodySmall),
                ),
            ],
            if (error != null)
              Padding(padding: const EdgeInsets.only(top: 8), child: StatusLabel(Status.info, error!)),
            if (costs != null) ...[
              const Divider(height: 24),
              const Eyebrow('Most you can be asked to pay before moving in (England)'),
              FigureRow('Holding deposit (one week)', gbp(costs.holding)),
              FigureRow(
                'Tenancy deposit (${costs.depositWeeks == 6 ? 'six' : 'five'} weeks)',
                gbp(costs.deposit),
              ),
              FigureRow('First month\'s rent', gbp(costs.firstMonth)),
              FigureRow('Needed on the day', gbp(costs.total), strong: true),
              Text(
                'The holding deposit comes off the first payment. Agents cannot charge fees for references or '
                'a tenancy agreement, and cannot ask for more than a month\'s rent in advance.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Divider(height: 24),
              const Eyebrow('Income referencing usually asks for'),
              FigureRow('Your yearly income (30 times the rent)', gbp(referencingIncome(p.price!).tenant)),
              FigureRow('Or a guarantor earning (36 times)', gbp(referencingIncome(p.price!).guarantor)),
              Text(
                'Sharers can usually add their incomes together. Referencing firms set their own rules, and '
                'some take savings instead. From 1 May 2026 a landlord cannot refuse you just because you '
                'claim benefits.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Status _status(Verdict v) => switch (v) {
    Verdict.inLine => Status.good,
    Verdict.above => Status.warning,
    Verdict.below => Status.info,
    Verdict.info => Status.info,
  };
}

/// Paste an advert's text to see which wording is banned in England or
/// looks like a scam.
Future<void> checkAdvertWording(BuildContext context, {int? rent}) async {
  final text = TextEditingController();
  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final flags = checkAdvertText(text.text, monthlyRent: rent);
        return AlertDialog(
          title: const Text('Check the advert wording'),
          scrollable: true,
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("Paste the advert's description, including any fees and deposit it names."),
                const SizedBox(height: 12),
                TextField(
                  controller: text,
                  minLines: 5,
                  maxLines: 10,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(labelText: 'Advert text'),
                ),
                const SizedBox(height: 12),
                if (text.text.trim().isEmpty)
                  const SizedBox.shrink()
                else if (flags.isEmpty)
                  const StatusLabel(Status.good, 'Nothing flagged. That is not proof an advert is genuine.')
                else
                  for (final f in flags)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StatusLabel(f.kind == FlagKind.outdated ? Status.info : Status.warning, f.title),
                          Text(f.why, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                const SizedBox(height: 8),
                Text(
                  'Guidance for England, not legal advice. Check gov.uk or Shelter before you act.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
        );
      },
    ),
  );
}
