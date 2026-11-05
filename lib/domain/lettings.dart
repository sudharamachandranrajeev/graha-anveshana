import 'package:brahma_core/brahma_core.dart';

import 'tax.dart';

/// A recurring landlord duty. [months] is how often it comes round (null:
/// once per tenancy). [nations] limits it (empty: everywhere).
typedef ComplianceKind = ({String id, String label, int? months, Set<Nation> nations, String note});

const complianceKinds = <ComplianceKind>[
  (
    id: 'gas',
    label: 'Gas safety certificate',
    months: 12,
    nations: {},
    note: 'Every year, by a Gas Safe engineer.',
  ),
  (
    id: 'eicr',
    label: 'Electrical safety report (EICR)',
    months: 60,
    nations: {},
    note: 'Every five years. Northern Ireland: for tenancies from 1 April 2025.',
  ),
  (id: 'epc', label: 'Energy certificate (EPC)', months: 120, nations: {}, note: 'Valid ten years.'),
  (
    id: 'alarms',
    label: 'Smoke and carbon monoxide alarms',
    months: 12,
    nations: {},
    note: 'Test at the start of each tenancy; check yearly.',
  ),
  (
    id: 'deposit',
    label: 'Deposit protected and details given',
    months: null,
    nations: {},
    note: 'NI: 28 days. England and Wales: 30 days. Scotland: 30 working days.',
  ),
  (
    id: 'register',
    label: 'Landlord registration',
    months: 36,
    nations: {Nation.northernIreland, Nation.scotland, Nation.wales},
    note: 'NI and Scotland: renew every 3 years. Wales (Rent Smart Wales): every 5.',
  ),
  (
    id: 'notice',
    label: 'Notice of information / written statement to tenant',
    months: null,
    nations: {},
    note: 'NI: within 28 days of the tenancy starting.',
  ),
  (
    id: 'rra_sheet',
    label: "Renters' Rights Act information sheet given",
    months: null,
    nations: {Nation.england},
    note: 'England: give it to every tenant. Existing tenants were due it by 31 May 2026.',
  ),
  (
    id: 'prs_register',
    label: 'Private rented sector database registration',
    months: null,
    nations: {Nation.england},
    note:
        'England: you and each property must register. Opens by region from 15 Dec 2026, starting in the '
        'West Midlands; the Yorkshire date and fee are not yet confirmed. Check gov.uk.',
  ),
  (
    id: 'right_to_rent',
    label: 'Right to rent check',
    months: null,
    nations: {Nation.england},
    note: 'England: before the tenancy starts, for every adult who will live there.',
  ),
  (id: 'insurance', label: 'Landlord insurance renewal', months: 12, nations: {}, note: ''),
  (id: 'legionella', label: 'Legionella risk assessment', months: 24, nations: {}, note: ''),
];

ComplianceKind? complianceKind(String id) => complianceKinds.where((k) => k.id == id).firstOrNull;

/// Rent due dates from [start] up to and including [asOf] (or [end]).
List<String> rentDueDates({required String start, String? end, required int day, required String asOf}) {
  final stop = end != null && end.compareTo(asOf) < 0 ? end : asOf;
  var y = int.parse(start.substring(0, 4)), m = int.parse(start.substring(5, 7));
  // The first payment is due on the start date itself.
  final out = <String>[start];
  while (true) {
    m++;
    if (m > 12) {
      m = 1;
      y++;
    }
    final last = DateTime.utc(y, m + 1, 0).day;
    final due = isoDate(DateTime.utc(y, m, day > last ? last : day));
    if (due.compareTo(stop) > 0) break;
    out.add(due);
  }
  return out.where((d) => d.compareTo(stop) <= 0).toList();
}

/// Rent owed so far minus rent paid: positive means arrears.
int rentBalance({
  required String start,
  String? end,
  required int day,
  required int rent,
  required Iterable<int> paid,
  required String asOf,
}) =>
    rentDueDates(start: start, end: end, day: day, asOf: asOf).length * rent - paid.fold(0, (a, b) => a + b);

/// The earliest date a rent rise can start in England under the Renters'
/// Rights Act: at least two months after the notice, and at least a year
/// after the last rise (or after the tenancy began, for the first rise).
/// Dates are yyyy-MM-dd.
String earliestRentIncrease({required String noticeServed, required String lastIncreaseOrStart}) {
  final byNotice = addMonths(noticeServed, 2), byYear = addMonths(lastIncreaseOrStart, 12);
  return byNotice.compareTo(byYear) >= 0 ? byNotice : byYear;
}

/// A CSV cell. Cells that start with = + - @ are prefixed so a spreadsheet
/// cannot run them as formulas.
String _cell(String v) {
  final safe = RegExp(r'^[=+\-@\t\r]').hasMatch(v) ? "'$v" : v;
  return RegExp(r'[",\n\r]').hasMatch(safe) ? '"${safe.replaceAll('"', '""')}"' : safe;
}

/// Rent received as CSV (date, property, tenant, amount, note), oldest first,
/// for a tax return or an accountant.
String rentRecordCsv({
  required String address,
  required String tenant,
  required Iterable<({String date, int amount, String note})> payments,
}) {
  final rows = [...payments]..sort((a, b) => a.date.compareTo(b.date));
  return [
    'Date,Property,Tenant,Amount (GBP),Note',
    for (final r in rows) [r.date, _cell(address), _cell(tenant), r.amount, _cell(r.note)].join(','),
  ].join('\n');
}

/// The UK tax quarter a date (yyyy-MM-dd) falls in. The tax year runs from
/// 6 April; Making Tax Digital's standard quarters end on 5 July, 5 October,
/// 5 January and 5 April. [taxYear] is the year it starts, so 2026 means
/// 2026-27.
({int taxYear, int quarter}) taxQuarter(String date) {
  final y = int.parse(date.substring(0, 4)), md = date.substring(5, 10);
  if (md.compareTo('04-06') >= 0 && md.compareTo('07-05') <= 0) return (taxYear: y, quarter: 1);
  if (md.compareTo('07-06') >= 0 && md.compareTo('10-05') <= 0) return (taxYear: y, quarter: 2);
  if (md.compareTo('10-06') >= 0) return (taxYear: y, quarter: 3);
  if (md.compareTo('01-05') <= 0) return (taxYear: y - 1, quarter: 3);
  return (taxYear: y - 1, quarter: 4);
}

/// First and last day (yyyy-MM-dd) of a tax quarter.
({String from, String to}) taxQuarterDates(int taxYear, int quarter) => switch (quarter) {
  1 => (from: '$taxYear-04-06', to: '$taxYear-07-05'),
  2 => (from: '$taxYear-07-06', to: '$taxYear-10-05'),
  3 => (from: '$taxYear-10-06', to: '${taxYear + 1}-01-05'),
  _ => (from: '${taxYear + 1}-01-06', to: '${taxYear + 1}-04-05'),
};

/// "2026-27".
String taxYearLabel(int taxYear) => '$taxYear-${((taxYear + 1) % 100).toString().padLeft(2, '0')}';

/// Rent received per tax quarter and property, oldest first, as CSV for
/// whatever Making Tax Digital software or accountant files the return.
/// The app keeps no expenses, so this is the income side only.
String rentByQuarterCsv(Iterable<({String date, String property, int amount})> payments) {
  final totals = <({int taxYear, int quarter, String property}), int>{};
  for (final p in payments) {
    final q = taxQuarter(p.date);
    final key = (taxYear: q.taxYear, quarter: q.quarter, property: p.property);
    totals[key] = (totals[key] ?? 0) + p.amount;
  }
  final keys = totals.keys.toList()
    ..sort(
      (a, b) => a.taxYear != b.taxYear
          ? a.taxYear.compareTo(b.taxYear)
          : (a.quarter != b.quarter ? a.quarter.compareTo(b.quarter) : a.property.compareTo(b.property)),
    );
  return [
    'Tax year,Quarter,From,To,Property,Rent received (GBP)',
    for (final k in keys)
      [
        taxYearLabel(k.taxYear),
        'Q${k.quarter}',
        taxQuarterDates(k.taxYear, k.quarter).from,
        taxQuarterDates(k.taxYear, k.quarter).to,
        _cell(k.property),
        totals[k],
      ].join(','),
  ].join('\n');
}
