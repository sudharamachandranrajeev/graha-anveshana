/// Named features a home must have, or must never be, read from the advert's
/// own words. Adverts often do not say: a feature is then unknown, not
/// missing, and the user chooses whether unknown homes stay.
library;

/// What an advert says about a feature.
enum Says { yes, no, unknown }

/// A feature the user can ask for ("must have") or rule out ("never show").
enum HomeFeature {
  // Must-haves.
  garage('Garage', must: true, yes: [r'\bgarages?\b', r'\bcar ?port\b'], no: [r'\bno garage\b']),
  driveway(
    'Driveway or off-road parking',
    must: true,
    yes: [
      r'\bdriveway\b',
      r'\boff[ -]?(?:road|street) parking\b',
      r'\ballocated parking\b',
      r'\bparking space\b',
    ],
    no: [r'\bon[ -]street parking only\b', r'\bno (?:off[ -]road |allocated )?parking\b', r'\bno driveway\b'],
  ),
  parking(
    'Any parking',
    must: true,
    yes: [r'\bparking\b', r'\bgarages?\b', r'\bdriveway\b', r'\bcar ?port\b'],
    no: [r'\bno parking\b', r'\bparking is not available\b'],
  ),
  garden(
    'Garden',
    must: true,
    yes: [r'\bgardens?\b', r'\byard\b', r'\bpatio\b'],
    no: [r'\bno garden\b', r'\bno outside space\b', r'\bno outdoor space\b'],
  ),
  enSuite('En suite', must: true, yes: [r'\ben[ -]?suite\b'], no: []),
  twoBathrooms(
    'Two or more bathrooms',
    must: true,
    yes: [r'\b(?:two|2|three|3) bathrooms\b', r'\bbathroom and (?:a )?(?:shower room|en[ -]?suite)\b'],
    no: [],
  ),
  groundFloor(
    'Ground floor or lift',
    must: true,
    yes: [r'\bground floor\b', r'\blift\b', r'\belevator\b'],
    no: [],
  ),
  petsAllowed(
    'Pets allowed',
    must: true,
    yes: [r'\bpets? (?:allowed|considered|welcome|friendly)\b', r'\bpet[ -]friendly\b'],
    no: [r'\bno pets\b', r'\bpets not (?:allowed|permitted)\b'],
  ),

  // Never-shows.
  retirement(
    'Retirement homes',
    must: false,
    yes: [
      r'\bretirement\b',
      r'\bover[ -]?(?:55|60|65)s?\b',
      r'\bsheltered (?:housing|accommodation|flat|apartment|scheme)\b',
      r'\bage restrict',
    ],
    no: [],
  ),
  sharedOwnership(
    'Shared ownership',
    must: false,
    yes: [r'\bshared ownership\b', r'\b\d{1,2}% share\b', r'\bpart[ -]buy\b'],
    no: [],
  ),
  parkHome(
    'Park and holiday homes',
    must: false,
    yes: [
      r'\bpark home\b',
      r'\bmobile home\b',
      r'\bholiday (?:home|let|lodge|park)\b',
      r'\bstatic caravan\b',
      r'\bholiday lodge\b',
    ],
    no: [],
  ),
  auction('Auctions', must: false, yes: [r'\bauction\b', r'\bmodern method of auction\b'], no: []),
  cashOnly(
    'Cash buyers only',
    must: false,
    yes: [r'\bcash buyers? only\b', r'\bnon[ -]?mortgageable\b', r'\bunmortgageable\b'],
    no: [],
  ),
  houseShare(
    'Rooms in shared houses',
    must: false,
    yes: [
      r'\broom in a shared\b',
      r'\bhouse ?share\b',
      r'\bflat ?share\b',
      r'\bhmo\b',
      r'\broom to (?:rent|let) in\b',
    ],
    no: [],
  ),
  students(
    'Student lets',
    must: false,
    yes: [r'\bstudents? only\b', r'\bstudent (?:let|accommodation|house)\b'],
    no: [],
  );

  const HomeFeature(this.label, {required this.must, required this.yes, required this.no});
  final String label;

  /// A must-have (true) or a never-show (false).
  final bool must;
  final List<String> yes, no;

  static HomeFeature? ofName(String name) => values.where((f) => f.name == name).firstOrNull;

  static Iterable<HomeFeature> get mustHaves => values.where((f) => f.must);
  static Iterable<HomeFeature> get neverShows => values.where((f) => !f.must);

  /// What [text] (an advert's words) says about this feature. A "no" phrase
  /// wins over a "yes" one ("no garage" also contains "garage").
  Says said(String text) {
    final t = text.toLowerCase();
    if (no.any((p) => RegExp(p).hasMatch(t))) return Says.no;
    if (yes.any((p) => RegExp(p).hasMatch(t))) return Says.yes;
    return Says.unknown;
  }
}

/// Whether a home with advert [text] passes the user's [has] and [never]
/// features. A must-have the advert denies fails; one it does not mention
/// fails only when [strict]. A never-show it mentions fails.
bool passesFeatures(
  String text,
  Iterable<HomeFeature> has,
  Iterable<HomeFeature> never, {
  bool strict = false,
}) {
  for (final f in has) {
    final s = f.said(text);
    if (s == Says.no || (strict && s == Says.unknown)) return false;
  }
  return !never.any((f) => f.said(text) == Says.yes);
}
