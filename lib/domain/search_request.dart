import 'catalog.dart';
import 'home_features.dart';
import 'listing.dart';

/// A point on the map.
typedef LatLon = ({double lat, double lon});

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
    this.has = const [],
    this.never = const [],
    this.strict = false,
    this.shape = const [],
    this.maxMinutes,
    this.travelMode = 'car',
    this.travelTo = '',
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

  /// Named features a home must have, and ones it must never be (see
  /// [HomeFeature]). [strict]: a must-have the advert does not mention also
  /// leaves the home out.
  final List<HomeFeature> has, never;
  final bool strict;

  /// An area drawn on the map; empty: none. Homes outside it are left out.
  final List<LatLon> shape;

  /// Homes more than [maxMinutes] away by [travelMode] ('car', 'bike' or
  /// 'foot') from the profile place named [travelTo] are left out.
  final int? maxMinutes;
  final String travelMode, travelTo;

  bool get isEmpty => area.isEmpty;

  /// The same search for the other kind, to rent or for sale. A monthly
  /// rent and a sale price are not on one scale, so the price limits go.
  SearchRequest withRent(bool rent) =>
      rent == this.rent ? this : copyWith(rent: rent, minPrice: () => null, maxPrice: () => null);

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
    List<HomeFeature>? has,
    List<HomeFeature>? never,
    bool? strict,
    List<LatLon>? shape,
    int? Function()? maxMinutes,
    String? travelMode,
    String? travelTo,
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
    has: has ?? this.has,
    never: never ?? this.never,
    strict: strict ?? this.strict,
    shape: shape ?? this.shape,
    maxMinutes: maxMinutes == null ? this.maxMinutes : maxMinutes(),
    travelMode: travelMode ?? this.travelMode,
    travelTo: travelTo ?? this.travelTo,
  );

  Map<String, Object?> toJson() => {
    'text': text,
    'area': area,
    'rent': rent,
    'minBeds': ?minBeds,
    'maxBeds': ?maxBeds,
    'minPrice': ?minPrice,
    'maxPrice': ?maxPrice,
    'radiusMiles': ?radiusMiles,
    if (near.isNotEmpty) 'near': near,
    if (must.isNotEmpty) 'must': must,
    if (mustNot.isNotEmpty) 'mustNot': mustNot,
    if (includeGone) 'includeGone': true,
    if (has.isNotEmpty) 'has': [for (final f in has) f.name],
    if (never.isNotEmpty) 'never': [for (final f in never) f.name],
    if (strict) 'strict': true,
    if (shape.isNotEmpty)
      'shape': [
        for (final p in shape) [p.lat, p.lon],
      ],
    'maxMinutes': ?maxMinutes,
    if (maxMinutes != null) 'travelMode': travelMode,
    if (maxMinutes != null && travelTo.isNotEmpty) 'travelTo': travelTo,
  };

  factory SearchRequest.fromJson(Map<String, Object?> j) {
    List<String> words(Object? o) => [
      if (o is List)
        for (final w in o) '$w',
    ];
    List<HomeFeature> features(Object? o) => [for (final w in words(o)) ?HomeFeature.ofName(w)];
    return SearchRequest(
      text: '${j['text'] ?? ''}',
      area: '${j['area'] ?? ''}',
      rent: j['rent'] != false,
      minBeds: (j['minBeds'] as num?)?.toInt(),
      maxBeds: (j['maxBeds'] as num?)?.toInt(),
      minPrice: (j['minPrice'] as num?)?.toInt(),
      maxPrice: (j['maxPrice'] as num?)?.toInt(),
      radiusMiles: (j['radiusMiles'] as num?)?.toDouble(),
      near: '${j['near'] ?? ''}',
      must: words(j['must']),
      mustNot: words(j['mustNot']),
      includeGone: j['includeGone'] == true,
      has: features(j['has']),
      never: features(j['never']),
      strict: j['strict'] == true,
      shape: [
        if (j['shape'] case final List s)
          for (final p in s)
            if (p case [final num lat, final num lon]) (lat: lat.toDouble(), lon: lon.toDouble()),
      ],
      maxMinutes: (j['maxMinutes'] as num?)?.toInt(),
      travelMode: '${j['travelMode'] ?? 'car'}',
      travelTo: '${j['travelTo'] ?? ''}',
    );
  }

  /// The same search: the same place, kind and filters, however it was typed.
  bool sameAs(SearchRequest o) {
    final a = {...toJson()}..remove('text');
    final b = {...o.toJson()}..remove('text');
    return a.toString().toLowerCase() == b.toString().toLowerCase();
  }

  /// The same filters as a collection's, so results and catalogs score alike.
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

/// Whether [p] lies inside the polygon [shape] (ray casting). Fewer than
/// three corners: no shape, so everything is inside.
bool insideShape(LatLon p, List<LatLon> shape) {
  if (shape.length < 3) return true;
  var inside = false;
  for (var i = 0, j = shape.length - 1; i < shape.length; j = i++) {
    final a = shape[i], b = shape[j];
    if ((a.lat > p.lat) != (b.lat > p.lat) &&
        p.lon < (b.lon - a.lon) * (p.lat - a.lat) / (b.lat - a.lat) + a.lon) {
      inside = !inside;
    }
  }
  return inside;
}

String _miles(double m) => m == m.roundToDouble() ? '${m.round()}' : '$m';

const _numbers = {'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5, 'six': 6, 'seven': 7};

/// Features people ask for by name; kept as must-mention words.
const featureWords = {
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
  // Whole numbers only: "10 bed" is ten, not the 0 of 10.
  final n = r'\b(\d{1,2}|one|two|three|four|five|six|seven)';
  int num(String s) => int.tryParse(s) ?? _numbers[s.toLowerCase()]!;
  final range = RegExp(
    '$n\\s*(?:-|–|to)\\s*$n\\s*-?\\s*bed(?:room)?s?\\b',
    caseSensitive: false,
  ).firstMatch(t);
  final atLeast = RegExp(
    '(?:at least|min(?:imum)?|minimum of)\\s*$n\\s*-?\\s*bed(?:room)?s?\\b',
    caseSensitive: false,
  ).firstMatch(t);
  final atMost = RegExp(
    '(?:up to|upto|at most|max(?:imum)?|no more than)\\s*$n\\s*-?\\s*bed(?:room)?s?\\b',
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
  } else if (atMost != null) {
    maxBeds = num(atMost[1]!);
    used(atMost);
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
  // A number followed by a distance, rooms or time is not money: "up to 3
  // miles", "max 2 bedrooms", "under 30 minutes".
  final money =
      r'£?\s*(\d[\d,]*(?:\.\d+)?)\s*([km])?\b'
      r'(?!\s*(?:miles?\b|mi\b|km\b|kilomet|beds?\b|bedrooms?\b|mins?\b|minutes?\b|hours?\b|hrs?\b|years?\b))';
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
    r'(?:within|in a|inside|up to|upto|under|less than|no more than|no further than|at most|max(?:imum)?)?'
    r'\s*(\d+(?:\.\d+)?)\s*(miles?|mi|km|kilomet(?:re|er)s?)\b(?:\s*radius)?(?:\s*(?:of|from))?',
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
    // "no more than", "not less than": a comparison, not a word to avoid.
    if (const {
      'more',
      'less',
      'fewer',
      'further',
      'longer',
      'than',
      'over',
      'under',
    }.contains(m[1]!.toLowerCase())) {
      continue;
    }
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
  // A postcode district alone ("LS6", "BT9", "E14") is the area too.
  final district = RegExp(r'\b([A-Z]{1,2}\d[A-Z\d]?)\b', caseSensitive: false).firstMatch(rest);
  if (area.isEmpty && district != null) {
    area = district[1]!.toUpperCase();
    rest = rest.replaceFirst(district[0]!, ' ');
  }

  // Asked-for features; what is left of a place-only request is the area.
  final must = <String>[];
  final words = RegExp(r"[a-z][a-z'-]*", caseSensitive: false).allMatches(rest).map((m) => m[0]!).toList();
  for (final w in words) {
    final lower = w.toLowerCase();
    if (featureWords.contains(lower) && !must.contains(lower)) must.add(lower);
  }
  if (area.isEmpty) {
    final leftover = words
        .where((w) => !featureWords.contains(w.toLowerCase()) && !_filler.contains(w.toLowerCase()))
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

/// Something in [q] that was likely read wrong, with the search it
/// probably meant ([fix]; null when there is no one obvious fix).
typedef OddReading = ({String text, SearchRequest? fix});

/// The readings of [q] worth a second look: a sale price on a rent search
/// and the other way round, prices and bedrooms the wrong way round, and
/// numbers no home has.
List<OddReading> oddReadings(SearchRequest q) {
  final lo = q.minPrice, hi = q.maxPrice, top = hi ?? lo;
  return [
    if (q.rent && top != null && top >= 20000)
      (text: '${_gbp(top)} looks like a sale price.', fix: q.copyWith(rent: false)),
    if (!q.rent && top != null && top >= 1000 && top < 5000)
      (text: '${_gbp(top)} looks like a monthly rent.', fix: q.copyWith(rent: true)),
    // "under 250" on a sale search: most likely thousands.
    if (!q.rent && top != null && top > 0 && top < 1000)
      (
        text: '${_gbp(top)} is very low for a sale price.',
        fix: q.copyWith(
          minPrice: () => lo == null ? null : lo * 1000,
          maxPrice: () => hi == null ? null : hi * 1000,
        ),
      ),
    if (lo != null && hi != null && lo > hi)
      (
        text: 'The lowest price is above the highest.',
        fix: q.copyWith(minPrice: () => hi, maxPrice: () => lo),
      ),
    if (q.minBeds != null && q.maxBeds != null && q.minBeds! > q.maxBeds!)
      (
        text: 'The fewest bedrooms is above the most.',
        fix: q.copyWith(minBeds: () => q.maxBeds, maxBeds: () => q.minBeds),
      ),
    if ((q.minBeds ?? 0) > 10) (text: '${q.minBeds} bedrooms is more than almost any home has.', fix: null),
  ];
}

String _gbp(int n) => '£${n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+$)'), (_) => ',')}';
