import 'dart:convert';

import 'package:brahma_core/brahma_core.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../db/database.dart';
import '../domain/listing.dart';
import '../domain/local_rules.dart';
import '../domain/research.dart';
import '../domain/tax.dart';
import 'browser_page.dart';
import 'common.dart';
import 'look.dart';
import 'invest_page.dart';

/// What to check before buying land or a building to develop, by topic.
const _devChecklist = <({String title, String body})>[
  (
    title: 'Title and boundaries',
    body:
        'HM Land Registry (England, Wales), Registers of Scotland, or Land & Property Services in Northern '
        'Ireland. Look for covenants, easements, ransom strips and rights of way.',
  ),
  (
    title: 'Planning',
    body:
        'The council\'s local development plan, planning history on the site and next door, conservation '
        'areas and listed buildings. Ask for pre-application advice before buying.',
  ),
  (
    title: 'Access and highways',
    body: 'Visibility splays, adopted roads, and whether the roads authority (DfI Roads in NI) will accept the access.',
  ),
  (
    title: 'Services',
    body: 'Water and sewer capacity (NI Water, Scottish Water, Welsh Water or the English company), electricity and gas connection costs.',
  ),
  (
    title: 'Ground, flooding and ecology',
    body: 'Site investigation, mining and radon, flood maps, trees, bats and protected habitats. Each can stop or delay a scheme.',
  ),
  (
    title: 'Contributions and tax',
    body:
        'Section 106 / CIL in England and Wales, developer contributions elsewhere; land transaction tax, VAT on '
        'commercial land, and whether you trade as a company.',
  ),
  (
    title: 'Build and sale',
    body: 'Building control, a structural warranty (NHBC, LABC, Premier) that buyers\' lenders accept, and local new-build prices.',
  ),
];

class ResearchPage extends ConsumerStatefulWidget {
  const ResearchPage({super.key, this.postcode});
  final String? postcode;

  @override
  ConsumerState<ResearchPage> createState() => _ResearchPageState();
}

class _ResearchPageState extends ConsumerState<ResearchPage> {
  late final postcode = TextEditingController(text: widget.postcode);
  AreaReport? report;
  String? error;
  bool busy = false;

  final taxPrice = TextEditingController(text: '200000');
  var taxNation = Nation.northernIreland;
  var taxBuyer = BuyerType.mover;
  var nonResident = false;

  @override
  void initState() {
    super.initState();
    if (widget.postcode != null) _lookUp();
  }

  @override
  void dispose() {
    postcode.dispose();
    taxPrice.dispose();
    super.dispose();
  }

  Future<void> _lookUp() async {
    final pc = postcodeIn(postcode.text) ?? postcode.text.trim();
    if (pc.isEmpty) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final r = await Research().report(pc);
      if (mounted) setState(() => report = r);
    } catch (e) {
      if (mounted) setState(() => error = describeError(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = report;
    return PageScaffold(
      title: 'Areas',
      banner: 'page.research',
      children: [
        SectionCard(
          title: 'Area report',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: postcode,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(labelText: 'Any UK postcode'),
                      onSubmitted: (_) => _lookUp(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(onPressed: busy ? null : _lookUp, child: const Text('Look up')),
                ],
              ),
              if (busy) const Padding(padding: EdgeInsets.only(top: 12), child: LinearProgressIndicator()),
              if (error != null)
                Padding(padding: const EdgeInsets.only(top: 12), child: StatusLabel(Status.critical, error!)),
            ],
          ),
        ),
        if (r != null) ...[const SizedBox(height: 12), _ReportView(r, onSave: () => _save(r))],
        const SizedBox(height: 12),
        _savedAreas(),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Purchase tax',
          hint: 'research.tax',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Field(taxPrice, 'Price', number: true, prefix: '£'),
              Choice(
                label: 'Where',
                value: taxNation,
                options: {for (final n in Nation.values) n: n.label},
                onChanged: (v) => setState(() => taxNation = v),
              ),
              Choice(
                label: 'Buyer',
                value: taxBuyer,
                options: {for (final b in BuyerType.values) b: b.label},
                onChanged: (v) => setState(() => taxBuyer = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Buyer lives outside the UK'),
                value: nonResident,
                onChanged: (v) => setState(() => nonResident = v),
              ),
              ListenableBuilder(
                listenable: taxPrice,
                builder: (context, _) => PurchaseTaxView(
                  residentialTax(
                    (numberIn(taxPrice) ?? 0).toDouble(),
                    taxNation,
                    taxBuyer,
                    nonResident: nonResident,
                  ),
                ),
              ),
              Text('Rates as of $ratesAsOf.', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Before you develop',
          child: Column(
            children: [
              for (final c in _devChecklist)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.checklist),
                  title: Text(c.title),
                  subtitle: Text(c.body),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// The ONS average rent where the app has it for the area's council.
  int? _rentOf(AreaReport rep) => rentFor(rep.place.district, null).average;

  Widget _savedAreas() => AsyncView(
    ref.watch(areasProvider),
    builder: (areas) {
      if (areas.isEmpty) return const SizedBox();
      final reports = [for (final a in areas) (a, AreaReport.fromJson((jsonDecode(a.report) as Map).cast()))];
      return SectionCard(
        title: 'Saved areas',
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            columns: const [
              DataColumn(label: Text('Postcode')),
              DataColumn(label: Text('Area')),
              DataColumn(label: Text('Average price'), numeric: true),
              DataColumn(label: Text('A year'), numeric: true),
              DataColumn(label: Text('Average rent'), numeric: true),
              DataColumn(label: Text('Rent against price'), numeric: true),
              DataColumn(label: Text('Crimes a month'), numeric: true),
              DataColumn(label: Text('')),
            ],
            rows: [
              for (final (a, rep) in reports)
                DataRow(
                  onSelectChanged: (_) => setState(() {
                    report = rep;
                    postcode.text = a.postcode;
                  }),
                  cells: [
                    DataCell(Text(a.postcode)),
                    DataCell(Text(a.label.isNotEmpty ? a.label : rep.place.district)),
                    DataCell(Text(rep.prices == null ? '–' : gbp(rep.prices!.average), style: tabular)),
                    DataCell(
                      Text(
                        rep.prices?.annualChange == null
                            ? '–'
                            : '${rep.prices!.annualChange!.toStringAsFixed(1)}%',
                        style: tabular,
                      ),
                    ),
                    DataCell(Text(_rentOf(rep) == null ? '–' : gbp(_rentOf(rep)!), style: tabular)),
                    DataCell(
                      Text(
                        _rentOf(rep) == null || rep.prices == null
                            ? '–'
                            : '${grossYield(_rentOf(rep)!, rep.prices!.average).toStringAsFixed(1)}%',
                        style: tabular,
                      ),
                    ),
                    DataCell(Text(rep.crimeMonth == null ? '–' : '${rep.crimeTotal}', style: tabular)),
                    DataCell(
                      IconButton(
                        tooltip: 'Remove',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => ref.mutate((s) => s.book.remove(s.db.areas, a.id)),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    },
  );

  Future<void> _save(AreaReport r) async {
    final areas = await ref.read(areasProvider.future);
    final existing = areas.where((a) => a.postcode == r.place.postcode).firstOrNull;
    if (!mounted) return;
    final label = TextEditingController(text: existing?.label ?? r.place.ward);
    await showFormDialog(
      context,
      title: 'Save ${r.place.postcode}',
      fields: (_) => [Field(label, 'Name', autofocus: true)],
      onSave: () async {
        final id = existing?.id ?? newId();
        await ref.mutate(
          (s) => s.book.save(
            s.db.areas,
            AreasCompanion(
              id: Value(id),
              postcode: Value(r.place.postcode),
              label: Value(label.text.trim()),
              report: Value(jsonEncode(r.toJson())),
              fetched: Value(today()),
            ),
            id,
          ),
        );
        return null;
      },
    );
  }
}

class _ReportView extends StatelessWidget {
  const _ReportView(this.r, {required this.onSave});
  final AreaReport r;
  final VoidCallback onSave;

  /// Rents, benefit rates and letting rules for the council area, where the
  /// app has them (see domain/local_rules.dart).
  List<Widget> _renting(BuildContext context) {
    final district = r.place.district;
    final rent = rentFor(district, null).average;
    final byBeds = [for (var b = 1; b <= 4; b++) rentFor(district, b).forBeds];
    final lha = lhaFor(district);
    final notes = localNotes(r.place);
    if (rent == null && lha == null && notes.isEmpty) return const [];
    final price = r.prices?.average;
    return [
      const Divider(height: 24),
      const Eyebrow('Renting here'),
      if (rent != null) FigureRow('Average private rent a month (ONS, Sep 2026)', gbp(rent)),
      for (var b = 0; b < 4; b++)
        if (byBeds[b] != null) FigureRow('   ${b + 1} bed${b == 3 ? 's or more' : ''}', gbp(byBeds[b]!)),
      if (rent != null && price != null)
        FigureRow(
          'Average rent against average price',
          '${grossYield(rent, price).toStringAsFixed(1)}% a year',
        ),
      if (lha != null) ...[
        FigureRow('Housing benefit rate, ${lha.area} (2026-27)', ''),
        FigureRow('   1 bed', gbp(lha.b1)),
        FigureRow('   2 beds', gbp(lha.b2)),
        FigureRow('   3 beds', gbp(lha.b3)),
        FigureRow('   4 beds', gbp(lha.b4)),
      ],
      for (final n in notes)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: StatusLabel(n.concern == Concern.caution ? Status.warning : Status.info, n.text),
              ),
              IconButton(
                tooltip: 'Open the council page',
                icon: const Icon(Icons.open_in_new, size: 18),
                onPressed: () => openInApp(context, n.url),
              ),
            ],
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final p = r.place;
    final small = Theme.of(context).textTheme.bodySmall;
    final crimes = r.crimes.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return SectionCard(
      title: p.postcode,
      trailing: HintIconButton(
        'research.save',
        icon: Icons.bookmark_add_outlined,
        label: 'Save',
        onPressed: onSave,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text([p.ward, p.district, p.region, p.country].where((s) => s.isNotEmpty).toSet().join(', ')),
          if (p.constituency.isNotEmpty) Text('Constituency: ${p.constituency}', style: small),
          const SizedBox(height: 12),
          if (r.prices case final idx?)
            FigureCard(
              eyebrow: 'Average price · ${monthLabel(idx.month, year: true)}',
              value: gbp(idx.average),
              caption: idx.region,
              detail: idx.annualChange == null
                  ? null
                  : '${idx.annualChange! >= 0 ? '+' : ''}${idx.annualChange!.toStringAsFixed(1)}% in a year',
              accent: (idx.annualChange ?? 0) >= 0,
            ),
          const Eyebrow('House prices'),
          for (final idx in [r.prices, r.regionPrices].nonNulls) ...[
            FigureRow(
              '${idx.region}, ${monthLabel(idx.month, year: true)}',
              '${gbp(idx.average)}${idx.annualChange == null ? '' : ' (${idx.annualChange! >= 0 ? '+' : ''}${idx.annualChange!.toStringAsFixed(1)}% a year)'}',
            ),
            for (final e in idx.byType.entries) FigureRow('   ${e.key}', gbp(e.value)),
          ],
          if (r.sales.isNotEmpty) ...[
            const Divider(height: 24),
            const Eyebrow('Sold in this postcode'),
            for (final s in r.sales.take(10))
              FigureRow('${niceDate(s.date)} · ${s.address}${s.newBuild ? ' (new)' : ''}', gbp(s.price)),
          ],
          if (r.crimeMonth != null) ...[
            const Divider(height: 24),
            Text(
              'Recorded crime within about a mile, ${monthLabel(r.crimeMonth!, year: true)}: ${r.crimeTotal}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            for (final e in crimes.take(8))
              FigureRow('   ${e.key[0].toUpperCase()}${e.key.substring(1)}', '${e.value}'),
          ],
          if (r.floods case final floods?) ...[
            const Divider(height: 24),
            const Eyebrow('Flood warnings today, within 5 km'),
            if (floods.isEmpty)
              const Text(
                'None in force. These are warnings in force today, not the long-term risk: see the link below.',
              )
            else
              for (final f in floods)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: StatusLabel(
                    f.level == 3 ? Status.warning : Status.critical,
                    '${f.severity}: ${f.area}',
                  ),
                ),
          ],
          ..._renting(context),
          for (final n in r.notes)
            Padding(padding: const EdgeInsets.only(top: 8), child: StatusLabel(Status.info, n)),
          const Divider(height: 24),
          const Eyebrow('Look further'),
          Wrap(
            spacing: 8,
            children: [
              for (final l in researchLinks(p))
                TextButton.icon(
                  onPressed: () => openInApp(context, l.url),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: Text(l.label),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
