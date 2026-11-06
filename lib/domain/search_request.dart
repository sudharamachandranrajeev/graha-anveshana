import 'catalog.dart';
import 'listing.dart';

/// What the user typed in the search bar, read into filters on the device.
/// Every part is optional except the words themselves.
class SearchRequest {
  const SearchRequest({
    this.text = '',
    this.area = '',
    this.rent = true,
    this.minBeds,
    this.maxBeds,
    this.minPrice,
    this.maxPrice,
    this.radiusMiles,
    this.near = '',
    this.must = const [],
    this.mustNot = const [],
    this.includeGone = false,
  });

  /// The request as typed.
  final String text;

  /// The town, district or postcode the portals are searched in.
  final String area;
  final bool rent;
  final int? minBeds, maxBeds, minPrice, maxPrice;
  final double? radiusMiles;

  /// A place distances are measured from ("near the hospital", a postcode).
  /// Empty: the [area] itself.
  final String near;

  /// Words an advert must mention, and must not.
  final List<String> must, mustNot;

  /// Also show adverts already let or sold.
  final bool includeGone;

  bool get isEmpty => area.isEmpty;

  SearchRequest copyWith({
    String? area,
    bool? rent,
    int? Function()? minBeds,
    int? Function()? maxBeds,
    int? Function()? minPrice,
    int? Function()? maxPrice,
    double? Function()? radiusMiles,
    String? near,
    List<String>? must,
    List<String>? mustNot,
    bool? includeGone,
  }) => SearchRequest(
    text: text,
    area: area ?? this.area,
    rent: rent ?? this.rent,
    minBeds: minBeds == null ? this.minBeds : minBeds(),
    maxBeds: maxBeds == null ? this.maxBeds : maxBeds(),
    minPrice: minPrice == null ? this.minPrice : minPrice(),
    maxPrice: maxPrice == null ? this.maxPrice : maxPrice(),
    radiusMiles: radiusMiles == null ? this.radiusMiles : radiusMiles(),
    near: near ?? this.near,
    must: must ?? this.must,
    mustNot: mustNot ?? this.mustNot,
    includeGone: includeGone ?? this.includeGone,
  );

  /// The same filters as a research's, so results and catalogs score alike.
  ResearchCriteria criteria({double? lat, double? lon}) => ResearchCriteria(
    place: near.isEmpty ? area : near,
    lat: lat,
    lon: lon,
    radiusKm: radiusMiles == null ? null : radiusMiles! * 1.609344,
    maxPrice: maxPrice,
    minBeds: minBeds,
    words: [...must, for (final w in mustNot) '-$w'].join(' '),
  );

  /// A short label for a saved search: "2+ bed to rent in Leeds, up to £900".
  String get label {
    final beds = switch ((minBeds, maxBeds)) {
      (0, 0) => 'Studio',
      (final a?, final b?) when a == b => '$a bed',
      (final a?, final b?) => '$a–$b bed',
      (final a?, null) => '$a+ bed',
      (null, final b?) => 'Up to $b bed',
      _ => 'Homes',
    };
    final price = switch ((minPrice, maxPrice)) {
      (final a?, final b?) => ', £$a–£$b',
      (null, final b?) => ', up to £$b',
      (final a?, null) => ', from £$a',
      _ => '',
    };
    final within = radiusMiles == null ? '' : ', within ${_miles(radiusMiles!)} mi';
    return '$beds ${rent ? 'to rent' : 'for sale'} in ${area.isEmpty ? '…' : area}$price$within';
  }
}

String _miles(double m) => m == m.roundToDouble() ? '${m.round()}' : '$m';

const _numbers = {'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5, 'six': 6, 'seven': 7};

/// Features people ask for by name; kept as must-mention words.
const _features = {
  'parking',
  'garage',
  'garden',
  'balcony',
  'pets',
  'pet',
  'furnished',
  'unfurnished',
  'ensuite',
  'en-suite',
  'dishwasher',
  'driveway',
  'bills',
  'lift',
  'conservatory',
  'fireplace',
  'detached',
  'semi-detached',
  'terraced',
  'bungalow',
  'cottage',
  'flat',
  'apartment',
  'house',
  'maisonette',
  'townhouse',
  'oil',
  'gas',
};

/// Words that end an area or place name.
final _stopAfterPlace = RegExp(
  r'\b(?:under|below|less|up|max|maximum|over|above|from|min|minimum|near|close|within|with|without|no|not|that|which|and|for|to|in|around|£|budget|having|has|must|bed|beds|bedroom|bedrooms)\b|[,.;£\d]',
  caseSensitive: false,
);

int? _amount(String n, String? k) {
  final v = double.tryParse(n.replaceAll(',', ''));
  if (v == null) return null;
  final mult = switch (k?.toLowerCase()) {
    'k' => 1000,
    'm' => 1000000,
    _ => 1,
  };
  return (v * mult).round();
}

String _tidyPlace(String s) => s
    .trim()
    .replaceAll(RegExp(r'\s+'), ' ')
    .replaceAll(RegExp(r'^(?:the)\s+', caseSensitive: false), '')
    .replaceAll(RegExp(r'[\s,.-]+$'), '');

/// Reads a plain-words request ("2 bed to rent in Leeds under £900 near LS1
/// 4AP with parking, no students") into filters. [rent] is used when the
/// words say neither rent nor buy.
SearchRequest readRequest(String input, {bool rent = true}) {
  var t = ' ${input.trim()} ';
  var rest = t;
  void used(Match m) => rest = rest.replaceFirst(m.group(0)!, ' ');

  // Rent or buy.
  final buy = RegExp(r'\b(?:for sale|to buy|buy|buying|purchase|sale)\b', caseSensitive: false).firstMatch(t);
  final let = RegExp(
    r'\b(?:to rent|to let|for rent|rent|rental|renting|let|pcm|per month|a month|pw|per week)\b',
    caseSensitive: false,
  ).firstMatch(t);
  final isRent = buy != null && let == null ? false : (let != null ? true : rent);
  for (final m in [?buy, ?let]) {
    used(m);
  }

  // Bedrooms: "studio", "2 bed", "2-3 bed", "2+ beds", "at least two bedrooms".
  int? minBeds, maxBeds;
  final n = r'(\d|one|two|three|four|five|six|seven)';
  int num(String s) => int.tryParse(s) ?? _numbers[s.toLowerCase()]!;
  final range = RegExp(
    '$n\\s*(?:-|–|to)\\s*$n\\s*-?\\s*bed(?:room)?s?\\b',
    caseSensitive: false,
  ).firstMatch(t);
  final atLeast = RegExp(
    '(?:at least|min(?:imum)?|minimum of)\\s*$n\\s*-?\\s*bed(?:room)?s?\\b',
    caseSensitive: false,
  ).firstMatch(t);
  final plus = RegExp('$n\\s*\\+\\s*-?\\s*bed(?:room)?s?\\b', caseSensitive: false).firstMatch(t);
  final one = RegExp('$n\\s*-?\\s*bed(?:room)?s?\\b', caseSensitive: false).firstMatch(t);
  final studio = RegExp(r'\bstudio\b', caseSensitive: false).firstMatch(t);
  if (range != null) {
    (minBeds, maxBeds) = (num(range[1]!), num(range[2]!));
    used(range);
  } else if (atLeast != null) {
    minBeds = num(atLeast[1]!);
    used(atLeast);
  } else if (plus != null) {
    minBeds = num(plus[1]!);
    used(plus);
  } else if (one != null) {
    // "2 bed" means at least 2: a 3 bed at the same rent is no worse.
    minBeds = num(one[1]!);
    used(one);
  } else if (studio != null) {
    (minBeds, maxBeds) = (0, 0);
    used(studio);
  }

  // Price: "under £700", "£600-£800", "from £500", "£700", "250k".
  final money = r'£?\s*(\d[\d,]*(?:\.\d+)?)\s*([km])?\b';
  int? minPrice, maxPrice;
  final between = RegExp(
    '(?:between\\s*)?$money\\s*(?:-|–|to|and)\\s*$money',
    caseSensitive: false,
  ).allMatches(t).where((m) => m[0]!.contains('£') || m[2] != null || m[4] != null).firstOrNull;
  final under = RegExp(
    '(?:under|below|less than|up to|upto|max(?:imum)?|no more than|budget(?: of)?|<|≤)\\s*$money',
    caseSensitive: false,
  ).firstMatch(t);
  final over = RegExp(
    '(?:over|above|more than|from|min(?:imum)?|>|≥)\\s*$money',
    caseSensitive: false,
  ).firstMatch(t);
  if (between != null) {
    minPrice = _amount(between[1]!, between[2]);
    maxPrice = _amount(between[3]!, between[4]);
    used(between);
  } else {
    if (under != null) {
      maxPrice = _amount(under[1]!, under[2]);
      used(under);
    }
    if (over != null && RegExp(r'£|\d{3,}|k\b', caseSensitive: false).hasMatch(over[0]!)) {
      minPrice = _amount(over[1]!, over[2]);
      used(over);
    }
    if (maxPrice == null && minPrice == null) {
      final bare = RegExp(r'£\s*(\d[\d,]*)\s*([km])?\b', caseSensitive: false).firstMatch(rest);
      if (bare != null) {
        maxPrice = _amount(bare[1]!, bare[2]);
        rest = rest.replaceFirst(bare[0]!, ' ');
      }
    }
  }
  // Rents quoted weekly become monthly, as the portals' filters are monthly.
  if (isRent && RegExp(r'\b(?:pw|per week|a week|weekly)\b', caseSensitive: false).hasMatch(t)) {
    int? monthly(int? w) => w == null ? null : (w * 52 / 12).round();
    (minPrice, maxPrice) = (monthly(minPrice), monthly(maxPrice));
    rest = rest.replaceAll(RegExp(r'\b(?:pw|per week|a week|weekly)\b', caseSensitive: false), ' ');
  }

  // Distance: "within 2 miles", "within 3km", "2 mile radius".
  double? radius;
  final within = RegExp(
    r'(?:within|in a|inside)?\s*(\d+(?:\.\d+)?)\s*(miles?|mi|km|kilomet(?:re|er)s?)\b(?:\s*radius)?(?:\s*(?:of|from))?',
    caseSensitive: false,
  ).firstMatch(rest);
  if (within != null) {
    final v = double.parse(within[1]!);
    radius = within[2]!.toLowerCase().startsWith('k') ? v / 1.609344 : v;
    rest = rest.replaceFirst(within[0]!, ' near ');
  }

  // Words it must not mention: "no students", "without stairs", "not ground floor".
  final mustNot = <String>[];
  for (final m in RegExp(
    r'\b(?:no|without|not|avoid|excluding)\s+([a-z][a-z-]+)',
    caseSensitive: false,
  ).allMatches(rest).toList()) {
    mustNot.add(m[1]!.toLowerCase());
    rest = rest.replaceFirst(m[0]!, ' ');
  }

  // Where: "near X" / "close to X" measures from X; "in X" is the area.
  String near = '';
  final nearM = RegExp(
    r'\b(?:near|close to|next to|around|by)\s+(.+)',
    caseSensitive: false,
  ).firstMatch(rest);
  if (nearM != null) {
    final after = nearM[1]!;
    final cut = postcodeIn(after) ?? after.split(_stopAfterPlace).first;
    near = _tidyPlace(cut);
    rest = rest.replaceFirst('${nearM[0]!.substring(0, nearM[0]!.length - after.length)}$cut', ' ');
  }
  String area = '';
  final inM = RegExp(r'\b(?:in|at)\s+(.+)', caseSensitive: false).firstMatch(rest);
  if (inM != null) {
    final after = inM[1]!;
    final cut = postcodeIn(after) ?? after.split(_stopAfterPlace).first;
    area = _tidyPlace(cut);
    rest = rest.replaceFirst('${inM[0]!.substring(0, inM[0]!.length - after.length)}$cut', ' ');
  }
  final postcode = postcodeIn(rest);
  if (area.isEmpty && postcode != null) {
    area = postcode;
    rest = rest.replaceFirst(RegExp(postcode.replaceAll(' ', r'\s?'), caseSensitive: false), ' ');
  }

  // Asked-for features; what is left of a place-only request is the area.
  final must = <String>[];
  final words = RegExp(r"[a-z][a-z'-]*", caseSensitive: false).allMatches(rest).map((m) => m[0]!).toList();
  for (final w in words) {
    final lower = w.toLowerCase();
    if (_features.contains(lower) && !must.contains(lower)) must.add(lower);
  }
  if (area.isEmpty) {
    final leftover = words
        .where((w) => !_features.contains(w.toLowerCase()) && !_filler.contains(w.toLowerCase()))
        .join(' ');
    area = _tidyPlace(leftover);
  }
  if (area.isEmpty && near.isNotEmpty) area = near;

  return SearchRequest(
    text: input.trim(),
    area: area,
    rent: isRent,
    minBeds: minBeds,
    maxBeds: maxBeds,
    minPrice: minPrice,
    maxPrice: maxPrice,
    radiusMiles: radius,
    near: near == area ? '' : near,
    must: must,
    mustNot: mustNot,
    includeGone: RegExp(r'\b(?:let agreed|sold stc|under offer)\b', caseSensitive: false).hasMatch(t),
  );
}

const _filler = {
  'a',
  'an',
  'the',
  'and',
  'or',
  'with',
  'home',
  'homes',
  'property',
  'properties',
  'place',
  'places',
  'somewhere',
  'something',
  'find',
  'me',
  'show',
  'looking',
  'look',
  'for',
  'want',
  'need',
  'i',
  'we',
  'our',
  'my',
  'any',
  'good',
  'nice',
  'cheap',
  'month',
  'week',
  'per',
  'pcm',
  'price',
  'of',
  'that',
  'has',
  'have',
  'having',
  'must',
  'is',
  'are',
  'near',
  'to',
  'in',
  'within',
  'radius',
  'from',
  'available',
  'family',
};
