import 'research.dart';

/// Facts about local authorities that no open API serves, bundled with the
/// app and dated. Councils change schemes without notice, so every note
/// says to check the council, and links to it.
const localFactsChecked = '2026-11-05';

/// Monthly Local Housing Allowance (what Universal Credit pays towards rent)
/// for 2026-27 in a broad rental market area, from the gov.uk rates sheet.
typedef Lha = ({String area, double shared, double b1, double b2, double b3, double b4});

/// Average private rent a month (ONS, September 2026) for a council area,
/// with the average by bedrooms where ONS gave it.
typedef LocalRent = ({int average, List<int> byBeds});

const _lha = <String, Lha>{
  'leeds': (area: 'Leeds', shared: 347.62, b1: 675, b2: 775, b3: 850, b4: 1200),
  'wakefield': (area: 'Wakefield', shared: 326.98, b1: 500, b2: 595, b3: 725, b4: 885),
  'doncaster': (area: 'Doncaster', shared: 304.17, b1: 425, b2: 500, b3: 550, b4: 725),
  'barnsley': (area: 'Barnsley', shared: 316.33, b1: 415, b2: 450, b3: 550, b4: 775),
  'rotherham': (area: 'Rotherham', shared: 351.33, b1: 430, b2: 500, b3: 550, b4: 817.5),
  'bradford': (area: 'Bradford and South Dales', shared: 326.33, b1: 450, b2: 525, b3: 635, b4: 750),
};

const _rents = <String, LocalRent>{
  'leeds': (average: 1148, byBeds: []),
  'wakefield': (average: 810, byBeds: [579, 730, 874, 1224]),
  'doncaster': (average: 699, byBeds: [496, 641, 763, 1083]),
  'rotherham': (average: 689, byBeds: []),
  'bradford': (average: 739, byBeds: []),
};

String _key(String council) =>
    council.toLowerCase().replaceAll(RegExp(r'\b(city|metropolitan|borough|council|of)\b'), '').trim();

/// The Local Housing Allowance area covering [district], if bundled.
Lha? lhaFor(String district) => _lha[_key(district)];

/// The LHA for a home of [beds] bedrooms (0 or null: shared room rate).
double? lhaRate(Lha l, int? beds) => switch (beds) {
  null || 0 => l.shared,
  1 => l.b1,
  2 => l.b2,
  3 => l.b3,
  _ => l.b4,
};

/// The ONS average rent for [district] and, if known, for [beds] bedrooms.
({int? forBeds, int? average}) rentFor(String district, int? beds) {
  final r = _rents[_key(district)];
  if (r == null) return (forBeds: null, average: null);
  final i = beds == null ? null : (beds.clamp(1, 4) - 1);
  return (forBeds: i != null && i < r.byBeds.length ? r.byBeds[i] : null, average: r.average);
}

/// Gross yield in per cent from a monthly rent and a price.
double grossYield(num monthlyRent, num price) => price <= 0 ? 0 : monthlyRent * 12 / price * 100;

enum Concern { info, caution }

class LocalNote {
  const LocalNote(this.concern, this.text, this.url);
  final Concern concern;
  final String text;
  final Uri url;
}

String _ward(String s) => s
    .toLowerCase()
    .replaceAll('&', 'and')
    .replaceAll(RegExp(r'[^a-z ]'), ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

const _leedsWards = [
  'armley',
  'beeston and holbeck',
  'burmantofts and richmond hill',
  'hunslet and riverside',
  'gipton and harehills',
  'farnley and wortley',
];

/// Letting rules and housing routes that apply at [p], for landlords and
/// renters. England only; empty elsewhere or when nothing is bundled.
List<LocalNote> localNotes(Place p) {
  final d = _key(p.district), ward = _ward(p.ward);
  Uri u(String s) => Uri.parse(s);
  final out = <LocalNote>[];
  switch (d) {
    case 'leeds':
      final hit = _leedsWards.any((w) => ward.contains(w));
      out.add(
        LocalNote(
          hit ? Concern.caution : Concern.info,
          hit
              ? 'Selective licensing may apply: ${p.ward} is one of six Leeds wards with licensed areas '
                    '(from 9 Feb 2026). Only some streets are in. Landlords need a licence, about £1,100, '
                    'or face a penalty of up to £40,000. Check the street map.'
              : 'Leeds has selective licensing in parts of six wards (Armley, Beeston and Holbeck, '
                    'Burmantofts and Richmond Hill, Hunslet and Riverside, Gipton and Harehills, Farnley and '
                    'Wortley). ${p.ward.isEmpty ? 'This postcode' : p.ward} is not one of them.',
          u('https://www.leeds.gov.uk/housing/information-for-landlords/selective-licensing'),
        ),
      );
      out.add(
        LocalNote(
          Concern.info,
          'Social housing in Leeds is let through Leeds Homes (choice-based lettings).',
          u('https://leeds.gov.uk/housing/finding-a-home/lettings-policy'),
        ),
      );
    case 'wakefield':
      out.add(
        LocalNote(
          Concern.info,
          'No selective licensing found in Wakefield district. An Article 4 Direction on small shared '
          'houses (HMOs) covers parts of Castleford and Wakefield city, so check before converting a house '
          'to a shared home. Pontefract is not named.',
          u(
            'https://www.wakefield.gov.uk/planning/planning-applications-and-advice/help-with-a-planning-application/article-4-direction-for-smaller-houses-in-multiple-occupation',
          ),
        ),
      );
      out.add(
        LocalNote(
          Concern.info,
          'Social housing here is let through Vico Homesearch (choice-based lettings).',
          u('https://www.wakefield.gov.uk/housing/finding-a-new-home/what-is-choice-based-lettings'),
        ),
      );
    case 'doncaster':
      final hit = ward.contains('hexthorpe');
      out.add(
        LocalNote(
          hit ? Concern.caution : Concern.info,
          hit
              ? 'Selective licensing applies in Hexthorpe (scheme 2022 to 2027). Landlords need a licence.'
              : 'Doncaster\'s selective licensing covers Hexthorpe only. Edlington\'s ended in 2023.',
          u('https://www.doncaster.gov.uk/services/business-investment/selective-licensing'),
        ),
      );
      out.add(
        LocalNote(
          Concern.info,
          'Social housing is let through Doncaster HomeChoice (St Leger Homes). You need a local connection.',
          u('https://stlegerhomes.co.uk/find-a-home/doncaster-homechoice/allocations'),
        ),
      );
    case 'rotherham':
      out.add(
        LocalNote(
          Concern.caution,
          'Rotherham has selective licensing in six areas from February 2026 (town centre, Masbrough and '
          'Kimberworth, Thurcroft, Dinnington, Brinsworth, Parkgate). Check whether the street is in one.',
          u('https://www.rotherham.gov.uk/housing/selective-licensing-2026-2031'),
        ),
      );
  }
  if (out.isNotEmpty) {
    out.add(
      LocalNote(
        Concern.info,
        'Rules as checked on $localFactsChecked. Councils can add schemes at any time: confirm with the '
        'council before you buy or let.',
        u('https://www.gov.uk/find-local-council'),
      ),
    );
  }
  return out;
}
