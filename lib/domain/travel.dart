/// Travel time by road, bike or on foot, from the OpenStreetMap community
/// router (routing.openstreetmap.de, run by FOSSGIS). Only coordinates are
/// sent, never place names; requests are batched, spaced a second apart and
/// cached, as its fair-use policy asks.
library;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'search_request.dart';

enum TravelMode {
  car('Car', 'routed-car', 'driving'),
  bike('Bike', 'routed-bike', 'cycling'),
  foot('Walk', 'routed-foot', 'walking');

  const TravelMode(this.label, this._server, this._profile);
  final String label, _server, _profile;

  static TravelMode of(String name) => values.where((m) => m.name == name).firstOrNull ?? car;
}

/// The router's terms ask for an identifying client; nothing personal.
const routerUserAgent = 'Anveshana/0.12 (personal property search app)';

/// Most points in one table request (the router's limit is 100).
const _batch = 80;

class TravelTimes {
  TravelTimes(this._http, {this.spacing = const Duration(seconds: 1)});
  final http.Client _http;

  /// The pause between two requests to the router.
  final Duration spacing;
  final _cache = <String, double?>{};
  DateTime _last = DateTime.fromMillisecondsSinceEpoch(0);

  static String _p(LatLon p) => '${p.lon.toStringAsFixed(5)},${p.lat.toStringAsFixed(5)}';
  static String _key(TravelMode m, LatLon from, LatLon to) => '${m.name}|${_p(from)}|${_p(to)}';

  /// The cached time from [from] to [to], if asked before.
  double? known(TravelMode m, LatLon from, LatLon to) => _cache[_key(m, from, to)];

  /// Minutes from each of [from] to [to] by [mode], in order; null where the
  /// router found no route. Throws [TravelUnavailable] when it cannot be
  /// reached.
  Future<List<double?>> minutes(TravelMode mode, List<LatLon> from, LatLon to) async {
    final missing = <LatLon>{
      for (final p in from)
        if (!_cache.containsKey(_key(mode, p, to))) p,
    }.toList();
    for (var i = 0; i < missing.length; i += _batch) {
      final part = missing.sublist(i, i + _batch > missing.length ? missing.length : i + _batch);
      final wait = spacing - DateTime.now().difference(_last);
      if (wait > Duration.zero) await Future<void>.delayed(wait);
      _last = DateTime.now();
      final coords = [to, ...part].map(_p).join(';');
      final url = Uri.parse(
        'https://routing.openstreetmap.de/${mode._server}/table/v1/${mode._profile}/$coords'
        '?destinations=0&sources=${[for (var k = 1; k <= part.length; k++) k].join(';')}&annotations=duration',
      );
      final http.Response r;
      try {
        r = await _http
            .get(url, headers: {'user-agent': routerUserAgent})
            .timeout(const Duration(seconds: 30));
      } on Exception {
        throw const TravelUnavailable('The travel time service did not answer.');
      }
      if (r.statusCode != 200) throw TravelUnavailable('The travel time service said ${r.statusCode}.');
      final j = jsonDecode(r.body);
      final rows = j is Map && j['code'] == 'Ok' ? j['durations'] : null;
      if (rows is! List || rows.length != part.length) {
        throw const TravelUnavailable('The travel time service gave no times.');
      }
      for (final (k, p) in part.indexed) {
        final s = (rows[k] as List?)?.firstOrNull;
        _cache[_key(mode, p, to)] = s is num ? s / 60 : null;
      }
    }
    return [for (final p in from) _cache[_key(mode, p, to)]];
  }

  /// Minutes from one home [from] to each of [to] (the user's places), in
  /// one request; cached like [minutes].
  Future<List<double?>> minutesToEach(TravelMode mode, LatLon from, List<LatLon> to) async {
    final missing = [
      for (final p in to)
        if (!_cache.containsKey(_key(mode, from, p))) p,
    ].take(_batch).toList();
    if (missing.isNotEmpty) {
      final wait = spacing - DateTime.now().difference(_last);
      if (wait > Duration.zero) await Future<void>.delayed(wait);
      _last = DateTime.now();
      final coords = [from, ...missing].map(_p).join(';');
      final url = Uri.parse(
        'https://routing.openstreetmap.de/${mode._server}/table/v1/${mode._profile}/$coords'
        '?sources=0&destinations=${[for (var k = 1; k <= missing.length; k++) k].join(';')}&annotations=duration',
      );
      final http.Response r;
      try {
        r = await _http
            .get(url, headers: {'user-agent': routerUserAgent})
            .timeout(const Duration(seconds: 30));
      } on Exception {
        throw const TravelUnavailable('The travel time service did not answer.');
      }
      if (r.statusCode != 200) throw TravelUnavailable('The travel time service said ${r.statusCode}.');
      final j = jsonDecode(r.body);
      final row = j is Map && j['code'] == 'Ok' ? (j['durations'] as List?)?.firstOrNull : null;
      if (row is! List || row.length != missing.length) {
        throw const TravelUnavailable('The travel time service gave no times.');
      }
      for (final (k, p) in missing.indexed) {
        final s = row[k];
        _cache[_key(mode, from, p)] = s is num ? s / 60 : null;
      }
    }
    return [for (final p in to) _cache[_key(mode, from, p)]];
  }
}

class TravelUnavailable implements Exception {
  const TravelUnavailable(this.message);
  final String message;
  @override
  String toString() => message;
}

/// "25 min", "1 h 10 min".
String minutesText(double m) {
  final r = m.round();
  return r < 60 ? '$r min' : '${r ~/ 60} h${r % 60 == 0 ? '' : ' ${r % 60} min'}';
}
