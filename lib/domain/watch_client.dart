import 'dart:convert';

import 'package:brahma_core/brahma_core.dart';
import 'package:http/http.dart' as http;

import 'listing.dart';

class WatchException implements Exception, UserFacingError {
  WatchException(this.message);
  @override
  final String message;
  @override
  String toString() => message;
}

/// A saved search as Brahma Watch runs it (see watch/src/watch.ts).
class WatchSearch {
  const WatchSearch({
    required this.id,
    required this.name,
    this.source = 'propertypal',
    this.path = '',
    this.kind = '',
    this.keywords = const [],
    this.maxPrice,
    this.minBeds,
    this.maxBeds,
    this.centreLat,
    this.centreLon,
    this.centreLabel = '',
    this.radiusKm,
    this.includeUnpriced = true,
    this.paused = false,
  });

  final String id, name;

  /// propertypal, or email (portal alert emails forwarded to Watch).
  final String source;

  /// A PropertyPal search path, e.g. /property-to-rent/enniskillen. Empty for email.
  final String path;

  /// Email searches: rent, buy or '' (either).
  final String kind;

  /// Email searches: words the advert must mention; "-word" must not appear.
  final List<String> keywords;
  final int? maxPrice, minBeds, maxBeds;
  final double? centreLat, centreLon;
  final String centreLabel;
  final double? radiusKm;
  final bool includeUnpriced, paused;

  bool get isEmail => source == 'email';

  factory WatchSearch.fromWatchJson(Map<String, Object?> j) {
    final centre = (j['centre'] as Map?)?.cast<String, Object?>();
    return WatchSearch(
      id: '${j['id']}',
      name: '${j['name'] ?? j['id']}',
      source: j['source'] == 'email' ? 'email' : 'propertypal',
      path: '${j['path'] ?? ''}',
      kind: '${j['kind'] ?? ''}',
      keywords: [for (final k in (j['keywords'] as List?) ?? const []) '$k'],
      maxPrice: (j['maxPrice'] as num?)?.toInt(),
      minBeds: (j['minBeds'] as num?)?.toInt(),
      maxBeds: (j['maxBeds'] as num?)?.toInt(),
      centreLat: (centre?['lat'] as num?)?.toDouble(),
      centreLon: (centre?['lon'] as num?)?.toDouble(),
      centreLabel: '${centre?['label'] ?? ''}',
      radiusKm: (j['radiusKm'] as num?)?.toDouble(),
      includeUnpriced: j['includeUnpriced'] != false,
      paused: j['paused'] == true,
    );
  }

  Map<String, Object?> toWatchJson() => {
    'id': id,
    'name': name,
    'source': source,
    'path': isEmail ? '' : path,
    if (isEmail && (kind == 'rent' || kind == 'buy')) 'kind': kind,
    if (isEmail && keywords.isNotEmpty) 'keywords': keywords,
    'maxPrice': ?maxPrice,
    'minBeds': ?minBeds,
    'maxBeds': ?maxBeds,
    if (centreLat != null && centreLon != null)
      'centre': {'lat': centreLat, 'lon': centreLon, 'label': centreLabel},
    if (centreLat != null && centreLon != null) 'radiusKm': ?radiusKm,
    'includeUnpriced': includeUnpriced,
    'paused': paused,
  };
}

/// Splits "garden, -retirement, off street parking" into the words Watch
/// matches (at most 20, each up to 40 characters, as the Worker accepts).
List<String> keywordList(String text) => [
  for (final k in text.split(',').map((k) => k.trim().toLowerCase()))
    if (k.isNotEmpty && k != '-') k.length > 40 ? k.substring(0, 40) : k,
].take(20).toList();

/// Validates a search path the way the Worker does.
bool isSearchPath(String path) =>
    RegExp(r'^/property-(to-rent|for-sale)/[a-z0-9-]+(/[a-z0-9-]+)*$').hasMatch(path);

/// What the Worker found: a new listing, a price change or a status change.
class WatchEvent {
  const WatchEvent({
    required this.at,
    required this.watchId,
    required this.kind,
    required this.listing,
    this.distanceKm,
  });
  final String at, watchId, kind;
  final Listing listing;
  final double? distanceKm;

  factory WatchEvent.fromJson(Map<String, Object?> j) => WatchEvent(
    at: '${j['at']}',
    watchId: '${j['watchId']}',
    kind: '${j['kind']}',
    listing: listingFromWatch((j['listing'] as Map).cast()),
    distanceKm: (j['distanceKm'] as num?)?.toDouble(),
  );
}

/// Talks to the user's own Brahma Watch Worker.
class WatchClient {
  WatchClient(this.url, this.token, {http.Client? client}) : _http = client ?? http.Client();
  final String url, token;
  final http.Client _http;

  Uri _u(String path, [Map<String, String>? q]) =>
      Uri.parse(url.replaceAll(RegExp(r'/+$'), '') + path).replace(queryParameters: q);

  Map<String, String> get _headers => {'authorization': 'Bearer $token', 'content-type': 'application/json'};

  Future<Object?> _call(String method, String path, {Object? body, Map<String, String>? query}) async {
    final req = http.Request(method, _u(path, query))..headers.addAll(_headers);
    if (body != null) req.body = jsonEncode(body);
    final http.Response res;
    try {
      res = await http.Response.fromStream(await _http.send(req).timeout(const Duration(seconds: 30)));
    } on Exception catch (e) {
      throw WatchException('Could not reach Brahma Watch: $e');
    }
    if (res.statusCode == 401) throw WatchException('Brahma Watch refused the token. Check it in Settings.');
    if (res.statusCode >= 400) throw WatchException('Brahma Watch said ${res.statusCode}: ${res.body}');
    return res.body.isEmpty ? null : jsonDecode(res.body);
  }

  /// The searches the Worker runs now.
  Future<List<WatchSearch>> searches() async => [
    for (final w in (await _call('GET', '/watches') as List? ?? const []))
      WatchSearch.fromWatchJson((w as Map).cast()),
  ];

  /// Replaces the Worker's searches with [searches].
  Future<void> putSearches(List<WatchSearch> searches) =>
      _call('PUT', '/watches', body: [for (final s in searches) s.toWatchJson()]);

  /// Events newer than [since] (an ISO time), oldest first.
  Future<List<WatchEvent>> events({String? since}) async {
    final body = await _call('GET', '/events', query: since == null ? null : {'since': since});
    final list = switch (body) {
      List l => l,
      {'events': List l} => l,
      _ => const [],
    };
    return [for (final e in list) WatchEvent.fromJson((e as Map).cast())];
  }

  Future<void> runNow() => _call('POST', '/run');
  Future<void> testPush() => _call('POST', '/test-notify');
}
