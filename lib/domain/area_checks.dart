/// Checks on the area around one home, each run only when the user asks:
/// schools nearby and the building's outline (from OpenStreetMap through
/// Overpass; only the map point is sent), where the sun rises and sets
/// (worked out on the device), road and rail noise maps (Defra, Open
/// Government Licence) and links to the coal mining and radon maps.
library;

import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import 'search_request.dart';
import 'travel.dart' show routerUserAgent;

const overpassUrl = 'https://overpass-api.de/api/interpreter';

/// A school near a home.
typedef NearSchool = ({String name, String kind, double km, double lat, double lon});

class AreaUnavailable implements Exception {
  const AreaUnavailable(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Straight-line distance in km.
double kmBetween(LatLon a, LatLon b) {
  const r = 6371.0;
  double rad(double d) => d * pi / 180;
  final dLat = rad(b.lat - a.lat), dLon = rad(b.lon - a.lon);
  final h = pow(sin(dLat / 2), 2) + cos(rad(a.lat)) * cos(rad(b.lat)) * pow(sin(dLon / 2), 2);
  return 2 * r * asin(sqrt(h));
}

/// Reads OpenStreetMap through Overpass. Results are kept for the session.
class AreaChecks {
  AreaChecks(this._http);
  final http.Client _http;
  final _cache = <String, Object?>{};

  Future<Map<String, Object?>> _ask(String query) async {
    final http.Response r;
    try {
      r = await _http
          .post(Uri.parse(overpassUrl), headers: {'user-agent': routerUserAgent}, body: {'data': query})
          .timeout(const Duration(seconds: 40));
    } on Exception {
      throw const AreaUnavailable('OpenStreetMap (Overpass) did not answer. Try again later.');
    }
    if (r.statusCode != 200) {
      throw AreaUnavailable(
        r.statusCode == 429 || r.statusCode >= 500
            ? 'OpenStreetMap\'s free server (Overpass) is busy. Try again in a minute.'
            : 'OpenStreetMap\'s free server (Overpass) turned the request away (${r.statusCode}). '
                  'Try again later.',
      );
    }
    final j = jsonDecode(r.body);
    if (j is! Map<String, Object?>) throw const AreaUnavailable('OpenStreetMap gave no answer.');
    return j;
  }

  static String _p(LatLon p) => '${p.lat.toStringAsFixed(5)},${p.lon.toStringAsFixed(5)}';

  /// Schools within [metres] (a mile) of [at], nearest first.
  Future<List<NearSchool>> schools(LatLon at, {int metres = 1609}) async {
    final key = 'schools|${_p(at)}|$metres';
    if (_cache[key] case final List<NearSchool> got) return got;
    final j = await _ask(
      '[out:json][timeout:25];nwr["amenity"="school"](around:$metres,${_p(at)});out center tags;',
    );
    final found = <NearSchool>[];
    for (final e in (j['elements'] as List? ?? const [])) {
      if (e is! Map) continue;
      final c = e['center'] is Map ? e['center'] as Map : e;
      final lat = (c['lat'] as num?)?.toDouble(), lon = (c['lon'] as num?)?.toDouble();
      final tags = e['tags'] is Map ? e['tags'] as Map : const {};
      final name = '${tags['name'] ?? ''}'.trim();
      if (lat == null || lon == null || name.isEmpty) continue;
      found.add((
        name: name,
        kind: schoolKind(tags.map((k, v) => MapEntry('$k', '$v'))),
        km: kmBetween(at, (lat: lat, lon: lon)),
        lat: lat,
        lon: lon,
      ));
    }
    found.sort((a, b) => a.km.compareTo(b.km));
    // The same school can be mapped as both a site and a building.
    final seen = <String>{};
    final out = [
      for (final s in found)
        if (seen.add(s.name.toLowerCase())) s,
    ];
    _cache[key] = out;
    return out;
  }

  /// The outline of the building at [at] (the one it falls in, else the
  /// nearest within 30 m); null when OpenStreetMap has none.
  Future<List<LatLon>?> building(LatLon at) async {
    final key = 'building|${_p(at)}';
    if (_cache.containsKey(key)) return _cache[key] as List<LatLon>?;
    final j = await _ask('[out:json][timeout:25];way["building"](around:30,${_p(at)});out geom;');
    final outlines = <List<LatLon>>[
      for (final e in (j['elements'] as List? ?? const []))
        if (e is Map && e['geometry'] is List)
          [
            for (final g in e['geometry'] as List)
              if (g is Map && g['lat'] is num && g['lon'] is num)
                (lat: (g['lat'] as num).toDouble(), lon: (g['lon'] as num).toDouble()),
          ],
    ].where((o) => o.length >= 4).toList();
    List<LatLon>? best = outlines.where((o) => insideShape(at, o)).firstOrNull;
    if (best == null && outlines.isNotEmpty) {
      double gap(List<LatLon> o) => o.map((p) => kmBetween(at, p)).reduce(min);
      best = (outlines..sort((a, b) => gap(a).compareTo(gap(b)))).first;
    }
    _cache[key] = best;
    return best;
  }
}

/// "Primary", "Secondary", "Nursery" … from a school's OpenStreetMap tags.
String schoolKind(Map<String, String> tags) {
  final s = '${tags['school'] ?? ''} ${tags['isced:level'] ?? ''} ${tags['name'] ?? ''}'.toLowerCase();
  if (RegExp(r'\b(primary|infant|junior|1)\b').hasMatch(s) && !s.contains('secondary')) return 'Primary';
  if (RegExp(r'\b(secondary|academy|high|grammar|college|2|3)\b').hasMatch(s)) return 'Secondary';
  if (RegExp(r'\b(nursery|0)\b').hasMatch(s)) return 'Nursery';
  return '';
}

/// A search for the school's inspection report on Ofsted (England).
Uri ofstedSearch(String name) => Uri.https('reports.ofsted.gov.uk', '/search', {'q': name});

// --- The sun --------------------------------------------------------------

/// "north", "south-west" … for a compass bearing in degrees.
String compass(double deg) {
  const names = ['north', 'north-east', 'east', 'south-east', 'south', 'south-west', 'west', 'north-west'];
  return names[((deg % 360) / 45).round() % 8];
}

/// Where the sun rises and sets, and how high it gets at noon, on the
/// longest and shortest days at latitude [lat]; ignores hills and
/// buildings around.
typedef SunDay = ({String day, double rise, double set, double noonHeight});

List<SunDay> sunDays(double lat) {
  double rad(double d) => d * pi / 180;
  double deg(double r) => r * 180 / pi;
  SunDay of(String day, double tilt) {
    // Bearing of sunrise from north: cos(A) = sin(tilt) / cos(lat).
    final c = (sin(rad(tilt)) / cos(rad(lat))).clamp(-1.0, 1.0);
    final rise = deg(acos(c));
    return (day: day, rise: rise, set: 360 - rise, noonHeight: 90 - lat + tilt);
  }

  return [of('Midsummer', 23.44), of('Spring and autumn', 0), of('Midwinter', -23.44)];
}

/// The two ways the long sides of a building [outline] face, as compass
/// bearings; null when it is too small or square to say.
(double, double)? facing(List<LatLon> outline) {
  if (outline.length < 4) return null;
  final lat0 = outline.first.lat * pi / 180;
  // Metres east and north of the first corner.
  ({double x, double y}) m(LatLon p) =>
      (x: (p.lon - outline.first.lon) * 111320 * cos(lat0), y: (p.lat - outline.first.lat) * 110540);
  final lengths = <double, double>{};
  for (var i = 0; i + 1 < outline.length; i++) {
    final a = m(outline[i]), b = m(outline[i + 1]);
    final len = sqrt(pow(b.x - a.x, 2) + pow(b.y - a.y, 2));
    if (len < 1) continue;
    // The side's direction, folded to 0–180 so both ends count the same.
    final along = (atan2(b.x - a.x, b.y - a.y) * 180 / pi) % 180;
    final k = (along / 10).round() * 10 % 180;
    lengths[k.toDouble()] = (lengths[k.toDouble()] ?? 0) + len;
  }
  if (lengths.isEmpty) return null;
  final sorted = lengths.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  final along = sorted.first.key;
  // Square-ish: the cross direction is about as long.
  final cross = lengths[((along + 90) % 180)] ?? 0;
  if (cross > sorted.first.value * 0.85) return null;
  return ((along + 90) % 360, (along + 270) % 360);
}

/// What sun a garden or window facing [deg] gets in the UK.
String sunFor(double deg) {
  final d = deg % 360;
  if (d >= 135 && d <= 225) return 'sun for most of the day';
  if (d > 225 && d < 315) return 'afternoon and evening sun';
  if (d > 45 && d < 135) return 'morning sun';
  return 'little direct sun, more in summer';
}

// --- Noise, coal mining, radon ---------------------------------------------

/// A Defra strategic noise map, drawn over the home's map (England).
typedef NoiseMap = ({String label, String url, String layer, String year});

const noiseMaps = <NoiseMap>[
  (
    label: 'Road noise',
    url: 'https://environment.data.gov.uk/spatialdata/road-noise-all-metrics-england-round-4/wms?',
    layer: 'Road_Noise_Lden_England_Round_4_All',
    year: '2021',
  ),
  (
    label: 'Rail noise',
    url: 'https://environment.data.gov.uk/spatialdata/rail-noise-lden-england-round-3/wms?',
    layer: 'Rail_Noise_Lden_England_Round_3',
    year: '2017',
  ),
];

/// The Mining Remediation Authority's (formerly Coal Authority) map viewer.
final coalMapUrl = Uri.parse('https://datamine-cauk.hub.arcgis.com/');

/// UKHSA's radon maps for the UK.
final radonMapUrl = Uri.parse('https://www.ukradon.org/information/ukmaps');
