/// The true cost of a leasehold home for sale: service charge, ground rent
/// and years left on the lease, read from the advert, with what it leaves
/// out. Information, not legal advice.
library;

import 'advert.dart';

class LeaseholdCosts {
  const LeaseholdCosts({
    this.tenure = '',
    this.serviceChargeYear,
    this.groundRentYear,
    this.yearsLeft,
    this.shareOfFreehold = false,
  });

  /// The advert's own word ("Leasehold", "Freehold", "Share of freehold").
  final String tenure;
  final int? serviceChargeYear, groundRentYear, yearsLeft;
  final bool shareOfFreehold;

  bool get leasehold => RegExp(r'leasehold', caseSensitive: false).hasMatch(tenure) || shareOfFreehold;

  /// Service charge and ground rent a month, from what the advert gives.
  int? get monthly {
    if (serviceChargeYear == null && groundRentYear == null) return null;
    return (((serviceChargeYear ?? 0) + (groundRentYear ?? 0)) / 12).round();
  }

  /// What a leasehold advert should say but does not.
  List<String> get missing => [
    if (leasehold && serviceChargeYear == null) 'service charge',
    if (leasehold && groundRentYear == null && !shareOfFreehold) 'ground rent',
    if (leasehold && yearsLeft == null) 'years left on the lease',
  ];

  /// Points to take to a solicitor.
  List<String> get warnings => [
    if (yearsLeft != null && yearsLeft! < 80)
      'Under 80 years left: extending the lease costs more, and some lenders will not lend. '
          'Ask a solicitor before you offer.'
    else if (yearsLeft != null && yearsLeft! < 100)
      'Under 100 years left: ask a solicitor what extending it would cost.',
  ];
}

final _money = r'£\s*([\d,]+(?:\.\d+)?)';
final _perYear = r'(?:per\s*(?:annum|year)|p\.?\s*a\.?|a\s*year|annually|yearly|/\s*(?:yr|year|annum))';
final _perMonth = r'(?:per\s*(?:calendar\s*)?month|pcm|a\s*month|monthly|/\s*(?:month|mth))';

int? _amount(String s) => double.tryParse(s.replaceAll(',', ''))?.round();

/// A yearly charge named [name] in [text]: "Service charge: £1,200 per annum",
/// "service charge of £95 per month" (made yearly). Null when not given.
int? _yearly(String text, String name) {
  final m = RegExp(
    '$name[^£\\n]{0,40}$_money(?:\\s*($_perYear|$_perMonth))?',
    caseSensitive: false,
  ).firstMatch(text);
  if (m == null) return null;
  final v = _amount(m.group(1)!);
  if (v == null) return null;
  final per = m.group(2) ?? '';
  return RegExp(_perMonth, caseSensitive: false).hasMatch(per) ? v * 12 : v;
}

/// Years left: "95 years remaining", "lease: 125 years from 2005".
int? _yearsLeft(String text, int thisYear) {
  final left = RegExp(
    r'(\d{2,3})\s*years?\s*(?:remaining|left|unexpired|to run)',
    caseSensitive: false,
  ).firstMatch(text);
  if (left != null) return int.parse(left.group(1)!);
  final from = RegExp(
    r'(\d{2,4})\s*years?\s*(?:lease\s*)?(?:from|commencing|starting)\s*(?:\d{1,2}(?:st|nd|rd|th)?\s+\w+\s+)?((?:19|20)\d{2})',
    caseSensitive: false,
  ).firstMatch(text);
  if (from != null) {
    final term = int.parse(from.group(1)!), start = int.parse(from.group(2)!);
    final rest = term - (thisYear - start);
    if (rest > 0 && rest <= term) return rest;
  }
  return null;
}

/// Reads the leasehold costs from an advert's facts and words. [thisYear]
/// dates leases given as "125 years from 2005".
LeaseholdCosts readLeasehold(AdvertDetails d, {required int thisYear}) {
  final facts = d.facts.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  final text = '$facts\n${d.features.join('\n')}\n${d.description}';
  final tenure =
      d.facts.entries.where((e) => e.key.toLowerCase() == 'tenure').map((e) => e.value).firstOrNull ??
      RegExp(
        r'\b(share of freehold|leasehold|freehold)\b',
        caseSensitive: false,
      ).firstMatch(text)?.group(1) ??
      '';
  return LeaseholdCosts(
    tenure: tenure,
    serviceChargeYear: _yearly(text, r'service\s*charges?'),
    groundRentYear:
        RegExp(r'ground\s*rent[^.\n]{0,20}\b(?:peppercorn|nil|none)\b', caseSensitive: false).hasMatch(text)
        ? 0
        : _yearly(text, r'ground\s*rent'),
    yearsLeft: _yearsLeft(text, thisYear),
    shareOfFreehold: RegExp(r'share of (?:the )?freehold', caseSensitive: false).hasMatch(text),
  );
}
