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
