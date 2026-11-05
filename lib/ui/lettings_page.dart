import 'package:brahma_core/brahma_core.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../db/database.dart';
import '../domain/bank_import.dart';
import '../domain/lettings.dart';
import '../domain/pipeline.dart';
import 'common.dart';
import 'look.dart';
import 'hunt_page.dart';
import 'property_page.dart';

class LettingsPage extends ConsumerWidget {
  const LettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final properties = ref.watch(propertiesProvider).value ?? const <Property>[];
    final byId = {for (final p in properties) p.id: p};
    final owned = properties.where((p) => p.kind == PropertyKind.owned.name).toList();
    final payments = ref.watch(rentPaymentsProvider).value ?? const <RentPayment>[];
    final checks = ref.watch(complianceProvider).value ?? const <ComplianceItem>[];
    final day = ref.watch(todayProvider);
    final tenancies = ref.watch(tenanciesProvider).value ?? const <Tenancy>[];
    // What tenants owe you, across every let you are the landlord of.
    final arrears = tenancies.where((t) => t.role == 'landlord').fold<int>(0, (sum, t) {
      final b = rentBalance(
        start: t.start,
        end: t.end,
        day: t.rentDay,
        rent: t.rent,
        paid: payments.where((p) => p.tenancyId == t.id).map((p) => p.amount),
        asOf: day,
      );
      return sum + (b > 0 ? b : 0);
    });
    // Rent received as landlord, for the tax-quarter totals.
    final landlordOf = {
      for (final t in tenancies)
        if (t.role == 'landlord') t.id: byId[t.propertyId]?.address ?? 'Property removed',
    };
    final received = [
      for (final p in payments)
        if (landlordOf[p.tenancyId] case final address?) (date: p.date, property: address, amount: p.amount),
    ];
    final thisYear = taxQuarter(day).taxYear;
    final open = checks.where((c) => c.done == null).toList();
    final overdue = open.where((c) => c.due.compareTo(day) < 0).length;
    final soon = open.where((c) => c.due.compareTo(addDays(day, 30)) <= 0).length;
    return PageScaffold(
      title: 'Lettings',
      banner: 'page.lettings',
      fab: FloatingActionButton.extended(
        heroTag: null,
        onPressed: properties.isEmpty ? null : () => editTenancy(context, ref, properties),
        icon: const Icon(Icons.assignment_outlined),
        label: const Text('Add tenancy'),
      ),
      children: [
        FigureCard(
          eyebrow: 'Rent outstanding',
          value: gbp(arrears),
          caption: arrears == 0 ? 'Every tenant is up to date' : 'Chase it up',
          detail: '${tenancies.length} ${tenancies.length == 1 ? 'tenancy' : 'tenancies'}',
          accent: arrears == 0,
        ),
        StatStrip([
          StatTile('Homes owned', '${owned.length}'),
          StatTile('Checks due in 30 days', '$soon', alert: soon > 0),
          StatTile('Checks overdue', '$overdue', alert: overdue > 0),
        ]),
        SectionCard(
          title: 'Homes you own',
          trailing: TextButton.icon(
            onPressed: () => editProperty(context, ref, kind: PropertyKind.owned),
            icon: const Icon(Icons.add_home_outlined),
            label: const Text('Add'),
          ),
          child: owned.isEmpty
              ? const Text('None yet. Add one, or mark a property you bought as owned.')
              : Column(
                  children: [
                    for (final p in owned)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.home_work_outlined),
                        title: Text(p.address),
                        subtitle: Text(
                          [
                            if (p.price != null) 'Bought for ${gbp(p.price!)}',
                            propertyFacts(p),
                          ].where((s) => s.isNotEmpty).join(' · '),
                        ),
                        onTap: () =>
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => PropertyPage(p.id))),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 12),
        AsyncView(
          ref.watch(tenanciesProvider),
          builder: (tenancies) => tenancies.isEmpty
              ? const EmptyState(
                  icon: Icons.assignment_outlined,
                  title: 'No tenancies',
                  message: 'Add a tenancy for a home you let out, or for the home you rent.',
                )
              : Column(
                  children: [
                    for (final t in tenancies)
                      _TenancyCard(
                        t,
                        byId[t.propertyId],
                        payments.where((p) => p.tenancyId == t.id).toList(),
                        day,
                        properties,
                      ),
                  ],
                ),
        ),
        if (received.isNotEmpty) ...[
          const SizedBox(height: 12),
          SectionCard(
            title: 'Rent for tax returns',
            trailing: TextButton.icon(
              onPressed: () => copyText(
                context,
                rentByQuarterCsv(received),
                what: 'Rent by tax quarter copied. Paste it into a spreadsheet or your tax software.',
              ),
              icon: const Icon(Icons.copy_all_outlined),
              label: const Text('Copy by quarter'),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var q = 1; q <= 4; q++)
                  FigureRow(
                    '${taxYearLabel(thisYear)} Q$q (to ${niceDate(taxQuarterDates(thisYear, q).to)})',
                    gbp(
                      received
                          .where((r) => taxQuarter(r.date) == (taxYear: thisYear, quarter: q))
                          .fold(0, (a, r) => a + r.amount),
                    ),
                  ),
                Text(
                  'Rent recorded as received, by Making Tax Digital quarter. Expenses are not kept here. '
                  'The app does not send anything to HMRC.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        SectionCard(
          title: 'Landlord checks',
          hint: 'lettings.checks',
          trailing: TextButton.icon(
            onPressed: properties.isEmpty
                ? null
                : () => addCheck(context, ref, owned.isEmpty ? properties : owned),
            icon: const Icon(Icons.add_task),
            label: const Text('Add'),
          ),
          child: checks.where((c) => c.done == null).isEmpty
              ? const Text('Nothing due. Add gas, electrical, EPC and other checks to be reminded.')
              : Column(
                  children: [
                    for (final c in checks.where((c) => c.done == null))
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(complianceKind(c.kind)?.label ?? c.kind),
                        subtitle: Text(
                          '${byId[c.propertyId]?.address ?? ''}\n${complianceKind(c.kind)?.note ?? ''}'
                              .trim(),
                        ),
                        isThreeLine: complianceKind(c.kind)?.note.isNotEmpty ?? false,
                        leading: Icon(_checkStatus(c.due, day).icon, color: _checkStatus(c.due, day).color),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(niceDate(c.due)),
                            InkWell(
                              onTap: () => _done(context, ref, c),
                              child: const Text(
                                'Mark done',
                                style: TextStyle(decoration: TextDecoration.underline),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  static Status _checkStatus(String due, String day) => due.compareTo(day) < 0
      ? Status.critical
      : due.compareTo(addDays(day, 30)) <= 0
      ? Status.warning
      : Status.good;

  /// Marks a check done and, if it recurs, adds the next one.
  Future<void> _done(BuildContext context, WidgetRef ref, ComplianceItem c) async {
    final day = today();
    final months = complianceKind(c.kind)?.months;
    await guarded(
      context,
      () => ref.mutate((s) async {
        await s.book.save(s.db.complianceItems, c.copyWith(done: Value(day)), c.id);
        if (months != null) {
          final id = newId();
          await s.book.save(
            s.db.complianceItems,
            ComplianceItemsCompanion.insert(
              id: id,
              propertyId: c.propertyId,
              kind: c.kind,
              due: addMonths(day, months),
            ),
            id,
          );
        }
      }),
    );
  }
}

class _TenancyCard extends ConsumerWidget {
  const _TenancyCard(this.t, this.p, this.payments, this.day, this.properties);
  final Tenancy t;
  final Property? p;
  final List<RentPayment> payments;
  final String day;
  final List<Property> properties;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = rentBalance(
      start: t.start,
      end: t.end,
      day: t.rentDay,
      rent: t.rent,
      paid: payments.map((p) => p.amount),
      asOf: day,
    );
    final landlord = t.role == 'landlord';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        shape: const Border(),
        title: Text(p?.address ?? 'Property removed'),
        subtitle: Text(
          [
            landlord
                ? 'Let to ${t.otherParty.isEmpty ? 'tenant' : t.otherParty}'
                : 'Rented from ${t.otherParty.isEmpty ? 'landlord' : t.otherParty}',
            '${gbp(t.rent)} pcm, due on day ${t.rentDay}',
            'From ${niceDate(t.start)}${t.end == null ? '' : ' to ${niceDate(t.end!)}'}',
          ].join('\n'),
        ),
        trailing: Hint(
          'lettings.balance',
          child: StatusLabel(
            balance > 0 ? Status.warning : Status.good,
            balance > 0 ? '${gbp(balance)} owed' : (balance < 0 ? '${gbp(-balance)} ahead' : 'Up to date'),
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          if (t.deposit > 0)
            FigureRow(
              'Deposit',
              [
                gbp(t.deposit),
                if (t.depositScheme.isNotEmpty) t.depositScheme,
                if (t.depositRef.isNotEmpty) t.depositRef,
              ].join(' · '),
            ),
          for (final pay in payments)
            FigureRow('${niceDate(pay.date)}${pay.note.isEmpty ? '' : ' · ${pay.note}'}', gbp(pay.amount)),
          Wrap(
            spacing: 8,
            children: [
              TextButton.icon(
                onPressed: () => _recordRent(context, ref),
                icon: const Icon(Icons.payments_outlined),
                label: Text(landlord ? 'Record rent received' : 'Record rent paid'),
              ),
              TextButton.icon(
                onPressed: () => _importFromBank(context, ref),
                icon: const Icon(Icons.account_balance_outlined),
                label: const Text('Import from bank'),
              ),
              if (payments.isNotEmpty)
                TextButton.icon(
                  onPressed: () => copyText(
                    context,
                    rentRecordCsv(
                      address: p?.address ?? '',
                      tenant: t.otherParty,
                      payments: [for (final x in payments) (date: x.date, amount: x.amount, note: x.note)],
                    ),
                    what: 'Rent record copied. Paste it into a spreadsheet.',
                  ),
                  icon: const Icon(Icons.copy_all_outlined),
                  label: const Text('Copy rent record'),
                ),
              if (landlord)
                TextButton.icon(
                  onPressed: () => _rentIncrease(context),
                  icon: const Icon(Icons.trending_up),
                  label: const Text('Rent rise dates'),
                ),
              TextButton.icon(
                onPressed: () => editTenancy(context, ref, properties, t: t),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// England: when a rent rise can start and what it is as a percentage.
  Future<void> _rentIncrease(BuildContext context) async {
    final newRent = TextEditingController();
    var notice = today(), last = t.start;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final from = earliestRentIncrease(noticeServed: notice, lastIncreaseOrStart: last);
          final rent = intIn(newRent);
          final rise = rent == null || t.rent == 0 ? null : (rent - t.rent) / t.rent * 100;
          return AlertDialog(
            title: const Text('Rent rise dates'),
            scrollable: true,
            content: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Notice served on'),
                  DateField(value: notice, onChanged: (d) => setState(() => notice = d)),
                  const SizedBox(height: 12),
                  const Text('Last rent rise, or the tenancy start'),
                  DateField(value: last, onChanged: (d) => setState(() => last = d)),
                  const SizedBox(height: 12),
                  Field(newRent, 'New rent a month', number: true, prefix: '£'),
                  FigureRow('Earliest the new rent can start', niceDate(from), strong: true),
                  if (rise != null) FigureRow('Rise on ${gbp(t.rent)}', '${rise.toStringAsFixed(1)}%'),
                  const SizedBox(height: 8),
                  const Text(
                    'England, from 1 May 2026: one rise a year, by a formal notice (section 13, Form 4A) '
                    'giving at least two months. The tenant can ask a tribunal to set the market rent. '
                    'Guidance only, not legal advice: check gov.uk before you serve it.',
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

  /// Paste a bank statement CSV; the rent lines it finds are offered ticked.
  Future<void> _importFromBank(BuildContext context, WidgetRef ref) async {
    final text = TextEditingController();
    final landlord = t.role == 'landlord';
    final skip = <BankLine>{};
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final parsed = text.text.trim().isEmpty ? null : parseStatement(text.text);
          final found = parsed == null
              ? const <BankLine>[]
              : rentLines(
                  parsed.lines,
                  received: landlord,
                  rent: t.rent,
                  start: t.start,
                  end: t.end,
                  otherParty: t.otherParty,
                  recorded: [for (final x in payments) (date: x.date, amount: x.amount)],
                );
          final chosen = [
            for (final l in found)
              if (!skip.contains(l)) l,
          ];
          return AlertDialog(
            title: const Text('Import rent from a bank statement'),
            scrollable: true,
            content: SizedBox(
              width: 560,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Download your statement from online banking as CSV, open it, copy everything and paste '
                    'it here. It stays on this device. Lines for ${gbp(t.rent)}'
                    '${t.otherParty.isEmpty ? '' : ' or naming ${t.otherParty}'} '
                    '${landlord ? 'paid in' : 'paid out'} since ${niceDate(t.start)} are picked out.',
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: text,
                    minLines: 4,
                    maxLines: 8,
                    autofocus: true,
                    onChanged: (_) => setState(skip.clear),
                    decoration: const InputDecoration(labelText: 'Statement CSV'),
                  ),
                  const SizedBox(height: 12),
                  if (parsed?.error != null)
                    StatusLabel(Status.warning, parsed!.error!)
                  else if (parsed != null && found.isEmpty)
                    Text(
                      '${parsed.lines.length} lines read. None look like this rent, or all are already recorded.',
                    )
                  else
                    for (final l in found)
                      CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        value: !skip.contains(l),
                        onChanged: (v) => setState(() => v == true ? skip.remove(l) : skip.add(l)),
                        title: Text('${niceDate(l.date)} · £${(l.amount.abs() / 100).toStringAsFixed(2)}'),
                        subtitle: l.text.isEmpty
                            ? null
                            : Text(l.text, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              FilledButton(
                onPressed: chosen.isEmpty
                    ? null
                    : () async {
                        await ref.mutate((s) async {
                          for (final l in chosen) {
                            final id = newId();
                            await s.book.save(
                              s.db.rentPayments,
                              RentPaymentsCompanion.insert(
                                id: id,
                                tenancyId: t.id,
                                date: l.date,
                                amount: (l.amount.abs() / 100).round(),
                                note: const Value('From bank statement'),
                              ),
                              id,
                            );
                          }
                        });
                        if (context.mounted) Navigator.pop(context);
                      },
                child: Text('Record ${chosen.length}'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _recordRent(BuildContext context, WidgetRef ref) {
    final amount = TextEditingController(text: '${t.rent}');
    final note = TextEditingController();
    var date = today();
    return showFormDialog(
      context,
      title: 'Rent',
      fields: (setState) => [
        DateField(value: date, onChanged: (d) => setState(() => date = d)),
        const SizedBox(height: 12),
        Field(amount, 'Amount', number: true, prefix: '£'),
        Field(note, 'Note'),
      ],
      onSave: () async {
        final a = intIn(amount);
        if (a == null || a <= 0) return 'Enter the amount.';
        final id = newId();
        await ref.mutate(
          (s) => s.book.save(
            s.db.rentPayments,
            RentPaymentsCompanion.insert(
              id: id,
              tenancyId: t.id,
              date: date,
              amount: a,
              note: Value(note.text.trim()),
            ),
            id,
          ),
        );
        return null;
      },
    );
  }
}

/// Adds or edits a tenancy.
Future<void> editTenancy(BuildContext context, WidgetRef ref, List<Property> properties, {Tenancy? t}) {
  final other = TextEditingController(text: t?.otherParty);
  final rent = TextEditingController(text: t?.rent.toString());
  final rentDay = TextEditingController(text: '${t?.rentDay ?? 1}');
  final deposit = TextEditingController(text: t == null || t.deposit == 0 ? '' : '${t.deposit}');
  final scheme = TextEditingController(text: t?.depositScheme);
  final ref_ = TextEditingController(text: t?.depositRef);
  var propertyId = t?.propertyId ?? properties.first.id;
  var role = t?.role ?? (properties.any((p) => p.kind == PropertyKind.owned.name) ? 'landlord' : 'tenant');
  var start = t?.start ?? today();
  String? end = t?.end;
  return showFormDialog(
    context,
    title: t == null ? 'New tenancy' : 'Edit tenancy',
    fields: (setState) => [
      Choice(
        label: 'Property',
        value: propertyId,
        options: {for (final p in properties) p.id: p.address},
        onChanged: (v) => setState(() => propertyId = v),
      ),
      Choice(
        label: 'You are the',
        value: role,
        options: const {'landlord': 'Landlord', 'tenant': 'Tenant'},
        onChanged: (v) => setState(() => role = v),
      ),
      Field(other, role == 'landlord' ? 'Tenant' : 'Landlord or agent'),
      DateField(value: start, label: 'Start', onChanged: (d) => setState(() => start = d)),
      const SizedBox(height: 12),
      CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Has an end date'),
        value: end != null,
        onChanged: (v) => setState(() => end = v! ? addMonths(start, 12) : null),
      ),
      if (end != null) ...[
        DateField(value: end!, label: 'End', onChanged: (d) => setState(() => end = d)),
        const SizedBox(height: 12),
      ],
      Field(rent, 'Rent a month', number: true, prefix: '£'),
      Field(rentDay, 'Due on day of the month', number: true),
      Field(deposit, 'Deposit', number: true, prefix: '£'),
      Field(scheme, 'Deposit scheme', hint: 'TDS NI, mydeposits, DPS…'),
      Field(ref_, 'Deposit reference'),
    ],
    onSave: () async {
      final r = intIn(rent), d = intIn(rentDay);
      if (r == null || r <= 0) return 'Enter the rent.';
      if (d == null || d < 1 || d > 31) return 'The due day is 1 to 31.';
      if (end != null && end!.compareTo(start) <= 0) return 'The end comes after the start.';
      final id = t?.id ?? newId();
      await ref.mutate(
        (s) => s.book.save(
          s.db.tenancies,
          TenanciesCompanion(
            id: Value(id),
            propertyId: Value(propertyId),
            role: Value(role),
            otherParty: Value(other.text.trim()),
            start: Value(start),
            end: Value(end),
            rent: Value(r),
            rentDay: Value(d),
            deposit: Value(intIn(deposit) ?? 0),
            depositScheme: Value(scheme.text.trim()),
            depositRef: Value(ref_.text.trim()),
          ),
          id,
        ),
      );
      return null;
    },
  );
}

/// Adds a landlord check with its next due date.
Future<void> addCheck(BuildContext context, WidgetRef ref, List<Property> properties) {
  var propertyId = properties.first.id;
  var kind = complianceKinds.first.id;
  var due = today();
  return showFormDialog(
    context,
    title: 'New check',
    fields: (setState) => [
      Choice(
        label: 'Property',
        value: propertyId,
        options: {for (final p in properties) p.id: p.address},
        onChanged: (v) => setState(() => propertyId = v),
      ),
      Choice(
        label: 'Check',
        value: kind,
        options: {for (final k in complianceKinds) k.id: k.label},
        onChanged: (v) => setState(() => kind = v),
      ),
      if (complianceKind(kind)!.note.isNotEmpty)
        Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(complianceKind(kind)!.note)),
      DateField(value: due, label: 'Due', onChanged: (d) => setState(() => due = d)),
    ],
    onSave: () async {
      final id = newId();
      await ref.mutate(
        (s) => s.book.save(
          s.db.complianceItems,
          ComplianceItemsCompanion.insert(id: id, propertyId: propertyId, kind: kind, due: due),
          id,
        ),
      );
      return null;
    },
  );
}
