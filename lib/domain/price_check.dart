import 'local_rules.dart';
import 'research.dart';

/// How an asking figure compares with what the area suggests.
enum Verdict { inLine, above, below, info }

class CheckLine {
  const CheckLine(this.label, this.value, {this.verdict = Verdict.info, this.note = ''});
  final String label, value, note;
  final Verdict verdict;
}

const _band = 5.0;

/// Fewest sales that make a fair comparison.
const minComparableSales = 3;

Verdict _compare(num asking, num benchmark) {
  if (benchmark <= 0) return Verdict.info;
  final pct = (asking - benchmark) / benchmark * 100;
  return pct > _band ? Verdict.above : (pct < -_band ? Verdict.below : Verdict.inLine);
}

String _pct(num asking, num benchmark) {
  final pct = (asking - benchmark) / benchmark * 100;
  return '${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(0)}%';
}

/// The sale-type word Land Registry uses for an advert's style text.
String? saleTypeFor(String style) {
  final s = style.toLowerCase();
  if (s.contains('semi')) return 'semi-detached';
  if (s.contains('detached')) return 'detached';
  if (s.contains('terrac') || s.contains('town house') || s.contains('townhouse')) return 'terraced';
  if (s.contains('flat') || s.contains('apartment') || s.contains('maisonette')) return 'flat-maisonette';
  return null;
}

/// The middle value of [xs]; 0 when empty.
int median(List<int> xs) {
  if (xs.isEmpty) return 0;
  final s = [...xs]..sort();
  final m = s.length ~/ 2;
  return s.length.isOdd ? s[m] : ((s[m - 1] + s[m]) / 2).round();
}

/// Sales within three years of [today] (yyyy-MM-dd) of the advert's type
/// where there are at least three, otherwise of every type.
({List<Sale> sales, bool sameType}) comparableSales(List<Sale> sales, String today, String style) {
  final since = '${int.parse(today.substring(0, 4)) - 3}${today.substring(4)}';
  final recent = [
    for (final s in sales)
      if (s.date.compareTo(since) >= 0) s,
  ];
  final type = saleTypeFor(style);
  final same = type == null
      ? <Sale>[]
      : [
          for (final s in recent)
            if (s.type.toLowerCase().contains(type)) s,
        ];
  return same.length >= 3 ? (sales: same, sameType: true) : (sales: recent, sameType: false);
}

/// What the app can say about a rent: against the ONS average and what
/// housing benefit would cover.
List<CheckLine> rentCheck({required int rent, int? beds, required Place place}) {
  final lines = <CheckLine>[];
  final r = rentFor(place.district, beds);
  final bench = r.forBeds ?? r.average;
  if (bench != null) {
    final what = r.forBeds != null ? '$beds-bed average' : 'all-homes average';
    lines.add(
      CheckLine(
        'Against the ${place.district} $what (ONS)',
        '${_pct(rent, bench)} on $bench',
        verdict: _compare(rent, bench),
        note: r.forBeds == null && beds != null ? 'No average for $beds beds, so this is every size.' : '',
      ),
    );
  }
  final lha = lhaFor(place.district);
  if (lha != null) {
    final rate = lhaRate(lha, beds)!;
    final gap = rent - rate;
    lines.add(
      CheckLine(
        'Housing benefit rate for ${beds ?? 0} ${beds == 1 ? 'bed' : 'beds'} in ${lha.area}',
        gap <= 0 ? 'covers the rent' : '£${gap.round()} a month short',
        verdict: gap <= 0 ? Verdict.inLine : Verdict.above,
        note: 'Rate £${rate.toStringAsFixed(0)} a month.',
      ),
    );
  }
  return lines;
}

/// What the app can say about an asking price: against recent sales nearby
/// and the council area's average for the type.
List<CheckLine> priceCheck({
  required int price,
  required String style,
  required String today,
  required List<Sale> sales,
  PriceIndex? index,
}) {
  final lines = <CheckLine>[];
  final c = comparableSales(sales, today, style);
  if (c.sales.length < minComparableSales) {
    lines.add(
      CheckLine(
        'Sales on this street or postcode in 3 years',
        '${c.sales.length}',
        note: 'Too few to compare with. Look at sold prices on nearby streets.',
      ),
    );
  } else {
    final m = median([for (final s in c.sales) s.price]);
    lines.add(
      CheckLine(
        'Against ${c.sales.length} ${c.sameType ? 'similar ' : ''}sales nearby in 3 years (median $m)',
        _pct(price, m),
        verdict: _compare(price, m),
        note: c.sameType ? '' : 'Mixed types, so a flat and a detached house count together.',
      ),
    );
  }
  if (index != null) {
    final name = switch (saleTypeFor(style)) {
      'semi-detached' => 'Semi-detached',
      'detached' => 'Detached',
      'terraced' => 'Terraced',
      'flat-maisonette' => 'Flat or maisonette',
      _ => null,
    };
    final bench = name == null ? null : index.byType[name];
    final b = bench ?? index.average;
    lines.add(
      CheckLine(
        'Against the ${index.region} ${bench == null ? 'average' : '${name!.toLowerCase()} average'}',
        _pct(price, b),
        verdict: _compare(price, b),
        note: 'Average of $b.',
      ),
    );
  }
  return lines;
}

/// What a tenant can be asked to pay before moving in, England (Tenant Fees
/// Act 2019 and the Renters' Rights Act): a holding deposit of up to one
/// week's rent, a deposit of up to five weeks' (six if the rent is
/// £50,000 a year or more), and the first month's rent.
({int holding, int deposit, int depositWeeks, int firstMonth, int total}) moveInCosts(int monthlyRent) {
  final week = monthlyRent * 12 / 52;
  final weeks = monthlyRent * 12 >= 50000 ? 6 : 5;
  final deposit = (week * weeks).floor();
  return (
    holding: week.floor(),
    deposit: deposit,
    depositWeeks: weeks,
    firstMonth: monthlyRent,
    // The holding deposit counts towards the first payment, so it is not added.
    total: deposit + monthlyRent,
  );
}

/// The yearly income tenant referencing usually asks for: 30 times the
/// monthly rent for the tenant (all tenants together on a joint let) and 36
/// times for a guarantor. Referencing firms set their own multiples, so
/// this is a guide.
({int tenant, int guarantor}) referencingIncome(int monthlyRent) =>
    (tenant: monthlyRent * 30, guarantor: monthlyRent * 36);
