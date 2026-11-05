/// Reading a bank statement exported as CSV, and picking out the rent.
///
/// Every UK bank exports a different layout, so the columns are found by
/// their headings: a date, then either one signed amount column or separate
/// money-in and money-out columns, and any text columns as the description.
/// Nothing leaves the device.
library;

/// One line of a statement. [amount] is in pence: money in is positive.
class BankLine {
  const BankLine(this.date, this.amount, this.text);
  final String date;
  final int amount;
  final String text;

  @override
  bool operator ==(Object other) =>
      other is BankLine && other.date == date && other.amount == amount && other.text == text;

  @override
  int get hashCode => Object.hash(date, amount, text);

  @override
  String toString() => '$date $amount $text';
}

/// The cells of each CSV row. Handles quoted cells with commas, doubled
/// quotes and line breaks.
List<List<String>> csvRows(String text) {
  final rows = <List<String>>[];
  var row = <String>[];
  final cell = StringBuffer();
  var quoted = false;
  for (var i = 0; i < text.length; i++) {
    final c = text[i];
    if (quoted) {
      if (c == '"') {
        if (i + 1 < text.length && text[i + 1] == '"') {
          cell.write('"');
          i++;
        } else {
          quoted = false;
        }
      } else {
        cell.write(c);
      }
    } else if (c == '"') {
      quoted = true;
    } else if (c == ',') {
      row.add(cell.toString().trim());
      cell.clear();
    } else if (c == '\n' || c == '\r') {
      if (c == '\r' && i + 1 < text.length && text[i + 1] == '\n') i++;
      row.add(cell.toString().trim());
      cell.clear();
      if (row.any((x) => x.isNotEmpty)) rows.add(row);
      row = <String>[];
    } else {
      cell.write(c);
    }
  }
  row.add(cell.toString().trim());
  if (row.any((x) => x.isNotEmpty)) rows.add(row);
  return rows;
}

const _months = {
  'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6, //
  'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
};

/// A statement date as yyyy-MM-dd. UK banks write day first: 05/11/2026,
/// 05-11-2026, 05 Nov 2026, 5-Nov-26; some write 2026-11-05.
String? bankDate(String s) {
  s = s.trim();
  var m = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})').firstMatch(s);
  if (m != null) return _iso(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
  m = RegExp(r'^(\d{1,2})[/.\-](\d{1,2})[/.\-](\d{2,4})$').firstMatch(s);
  if (m != null) return _iso(_year(m[3]!), int.parse(m[2]!), int.parse(m[1]!));
  m = RegExp(r'^(\d{1,2})[ \-]([A-Za-z]{3})[A-Za-z]*[ \-](\d{2,4})$').firstMatch(s);
  if (m != null) {
    final month = _months[m[2]!.toLowerCase()];
    if (month != null) return _iso(_year(m[3]!), month, int.parse(m[1]!));
  }
  return null;
}

int _year(String y) => y.length == 2 ? 2000 + int.parse(y) : int.parse(y);

String? _iso(int y, int m, int d) {
  if (m < 1 || m > 12 || d < 1 || d > 31) return null;
  final dt = DateTime.utc(y, m, d);
  if (dt.month != m) return null;
  return '${y.toString().padLeft(4, '0')}-${m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';
}

/// An amount in pence: "£1,050.00", "-20.5", "(20.50)", "1050.00 CR".
int? bankAmount(String s) {
  var t = s.replaceAll(RegExp(r'[£,\s]'), '');
  if (t.isEmpty) return null;
  var sign = 1;
  if (t.startsWith('(') && t.endsWith(')')) {
    sign = -1;
    t = t.substring(1, t.length - 1);
  }
  final up = t.toUpperCase();
  if (up.endsWith('DR')) {
    sign = -1;
    t = t.substring(0, t.length - 2);
  } else if (up.endsWith('CR')) {
    t = t.substring(0, t.length - 2);
  }
  final v = double.tryParse(t);
  return v == null ? null : (v * 100).round() * sign;
}

bool _has(String h, List<String> words) => words.any(h.contains);

/// The lines of a statement, or an error message saying what is missing.
({List<BankLine> lines, String? error}) parseStatement(String text) {
  final rows = csvRows(text);
  // Some banks put account details above the headings: take the first row
  // that names a date column.
  final head = rows.indexWhere((r) => r.any((c) => c.toLowerCase().contains('date')));
  if (head < 0) return (lines: const [], error: 'No column called Date was found.');
  final h = [for (final c in rows[head]) c.toLowerCase()];
  final date = h.indexWhere((c) => c.contains('date'));
  final paidIn = h.indexWhere((c) => _has(c, ['paid in', 'money in', 'credit', 'deposit', 'receipt']));
  final paidOut = h.indexWhere((c) => _has(c, ['paid out', 'money out', 'debit', 'withdrawal']));
  final amount = h.indexWhere((c) => c.contains('amount') || c == 'value');
  if (amount < 0 && paidIn < 0) return (lines: const [], error: 'No Amount or Paid in column was found.');
  final textCols = [
    for (var i = 0; i < h.length; i++)
      if (_has(h[i], [
        'description',
        'details',
        'reference',
        'memo',
        'narrative',
        'payee',
        'name',
        'counter party',
        'transaction type',
      ]))
        i,
  ];
  String at(List<String> r, int i) => i >= 0 && i < r.length ? r[i] : '';
  final lines = <BankLine>[];
  for (final r in rows.skip(head + 1)) {
    final d = bankDate(at(r, date));
    if (d == null) continue;
    int? pence;
    if (amount >= 0) {
      pence = bankAmount(at(r, amount));
    } else {
      final i = bankAmount(at(r, paidIn)), o = bankAmount(at(r, paidOut));
      pence = i != null && i != 0 ? i.abs() : (o == null ? null : -o.abs());
    }
    if (pence == null || pence == 0) continue;
    lines.add(BankLine(d, pence, [for (final i in textCols) at(r, i)].where((x) => x.isNotEmpty).join(' ')));
  }
  if (lines.isEmpty) return (lines: const [], error: 'No dated amounts were found under the headings.');
  return (lines: lines, error: null);
}

/// Lines that look like this tenancy's rent: money in (out, for a tenant)
/// on or after the start, for the full rent or naming the other party.
/// Lines already recorded (same date and whole-pound amount) are left out.
/// [rent] is pounds a month.
List<BankLine> rentLines(
  List<BankLine> lines, {
  required bool received,
  required int rent,
  required String start,
  String? end,
  String otherParty = '',
  Iterable<({String date, int amount})> recorded = const [],
}) {
  final names = [
    for (final w in otherParty.toLowerCase().split(RegExp(r'[^a-z]+')))
      if (w.length >= 3 && !const {'and', 'mrs', 'miss', 'the'}.contains(w)) w,
  ];
  final have = {for (final r in recorded) '${r.date} ${r.amount}'};
  return [
    for (final l in lines)
      if ((received ? l.amount > 0 : l.amount < 0) &&
          l.date.compareTo(start) >= 0 &&
          (end == null || l.date.compareTo(end) <= 0) &&
          (l.amount.abs() == rent * 100 || names.any(l.text.toLowerCase().contains)) &&
          !have.contains('${l.date} ${(l.amount.abs() / 100).round()}'))
        l,
  ];
}
