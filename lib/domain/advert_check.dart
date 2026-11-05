/// Reads the wording of a letting advert for things that are banned in
/// England since the Renters' Rights Act (1 May 2026) and the Tenant Fees
/// Act 2019, and for signs of a rental scam. Guidance only, not legal advice.
enum FlagKind { scam, banned, outdated }

class AdvertFlag {
  const AdvertFlag(this.kind, this.title, this.why);
  final FlagKind kind;
  final String title, why;
}

class _Rule {
  const _Rule(this.kind, this.pattern, this.title, this.why);
  final FlagKind kind;
  final String pattern;
  final String title, why;
}

const _rules = <_Rule>[
  _Rule(
    FlagKind.scam,
    r'(western union|moneygram|gift card|crypto|bitcoin|bank transfer (before|prior)|pay(ment)? (before|prior to) (the )?view|deposit (before|prior to) (the )?view|cash only)',
    'Asks for money before you can see the home',
    'Never pay before you have viewed in person and seen the landlord or agent. Fake adverts take deposits for homes that are not theirs.',
  ),
  _Rule(
    FlagKind.scam,
    r"(keys? (will be|can be|are) (posted|sent|couriered|mailed)|(landlord|owner) (is|lives|currently) (abroad|overseas|out of (the )?country)|cannot (show|view)|can'?t (show|view)|no viewings?)",
    'The home cannot be viewed',
    'A landlord who is abroad and posts the keys is a common scam. Ask for a viewing, or video call from inside the home, and check the owner on the Land Registry.',
  ),
  _Rule(
    FlagKind.banned,
    r'(best (and final )?offers?|highest (offer|bid)|bids? (over|above|from|invited|welcome)|offers? (invited|welcome)|closing date for (offers|bids)|blind (bid|offer)|rent (bidding|auction)|competitive (bids|offers))',
    'Rent bidding',
    'Banned in England from 1 May 2026. An advert must state one rent, and the landlord cannot accept more.',
  ),
  _Rule(
    FlagKind.banned,
    r"(\b(2|3|4|5|6|9|12|two|three|four|five|six|nine|twelve)\s+months?'?\s*(rent\s*)?(in advance|upfront|up front|advance|paid up ?front))|(rent in advance of \b(2|3|4|5|6|two|three|four|six)\b)",
    'More than a month of rent in advance',
    'Landlords and agents can ask for no more than one month of rent in advance in England.',
  ),
  _Rule(
    FlagKind.banned,
    r'(admin(istration)?|referenc(e|ing)|tenancy (agreement|set ?up)|check[- ]?in|check[- ]?out|inventory|credit check|application|renewal|setup|set up)\s+(fee|charge|cost)s?',
    'A fee that tenants cannot be charged',
    'The Tenant Fees Act bans fees for references, tenancy agreements, inventories, check-in, renewals and the like. Only rent, a deposit, a holding deposit and a few default charges are allowed.',
  ),
  _Rule(
    FlagKind.banned,
    r"(no\s+(dss|d\.s\.s|housing benefit|benefits?|universal credit|uc|lha)|(dss|benefits?)\s+(not|unfortunately not)\s+(accepted|considered|welcome)|(not|unable to)\s+(accept|consider)\s+(dss|benefits?|housing benefit|universal credit)|employed (tenants )?only|working (tenants )?only)",
    'Refuses tenants on benefits',
    'Banned in England from 1 May 2026. Landlords and agents cannot refuse or discourage people because they claim benefits.',
  ),
  _Rule(
    FlagKind.banned,
    r"(no\s+(children|kids|families|family)|(adults|couples|professionals) only|not suitable for (children|families))",
    'Refuses families with children',
    'Banned in England from 1 May 2026. Blanket refusal of families with children is unlawful. A home that is genuinely unsuitable should say why.',
  ),
  _Rule(
    FlagKind.outdated,
    r"(assured shorthold|\bAST\b|fixed[- ]term|(6|12|six|twelve)[- ]months? (fixed|tenancy|contract|initial|minimum)|minimum (term|tenancy) of|section ?21|\bs\.?21\b|no[- ]fault eviction)",
    'Old-style tenancy wording',
    'Since 1 May 2026 new tenancies in England are rolling (periodic). Section 21 and fixed terms are gone, and a tenant can leave with two months\' notice. An advert that promises them is out of date, or the agent is.',
  ),
];

final _compiled = [for (final r in _rules) (r, RegExp(r.pattern, caseSensitive: false))];

/// Flags found in [text]. [monthlyRent] lets it test the deposit and holding
/// deposit against the legal limits when the text names them.
List<AdvertFlag> checkAdvertText(String text, {int? monthlyRent}) {
  final flags = <AdvertFlag>[
    for (final (r, re) in _compiled)
      if (re.hasMatch(text)) AdvertFlag(r.kind, r.title, r.why),
  ];
  if (monthlyRent != null && monthlyRent > 0) {
    final week = monthlyRent * 12 / 52;
    final deposit = _amount(text, r'(?:tenancy |security )?deposit');
    if (deposit != null && deposit > week * (monthlyRent * 12 >= 50000 ? 6 : 5) + 1) {
      flags.add(
        AdvertFlag(
          FlagKind.banned,
          'Deposit above the legal limit',
          'A deposit of £$deposit is more than five weeks\' rent (£${(week * 5).floor()}). The limit is 5 weeks '
              'for rents under £50,000 a year, 6 weeks above.',
        ),
      );
    }
    final holding = _amount(text, r'holding (?:deposit|fee)');
    if (holding != null && holding > week + 1) {
      flags.add(
        AdvertFlag(
          FlagKind.banned,
          'Holding deposit above one week\'s rent',
          'A holding deposit of £$holding is more than one week\'s rent (£${week.floor()}), which is the limit.',
        ),
      );
    }
  }
  return flags;
}

/// The pound amount that follows [label] ("holding deposit of £150").
int? _amount(String text, String label) {
  final m = RegExp(
    '$label[^£0-9]{0,25}£\\s?([0-9][0-9,]*)(?:\\.[0-9]{2})?',
    caseSensitive: false,
  ).firstMatch(text);
  return m == null ? null : int.tryParse(m.group(1)!.replaceAll(',', ''));
}
