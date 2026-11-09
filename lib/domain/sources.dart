import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'listing.dart';
import 'search_request.dart';

/// The property sites the Search tab reads, inside the app. Each is read only
/// when the user searches, one results page at a time as they scroll, from
/// their own device. Each one can be switched off in Settings.
enum SourceId {
  propertyPal('PropertyPal', 'propertypal.com'),
  rightmove('Rightmove', 'rightmove.co.uk'),
  onTheMarket('OnTheMarket', 'onthemarket.com'),
  openRent('OpenRent', 'openrent.co.uk'),
  zoopla('Zoopla', 'zoopla.co.uk'),
  facebook('Facebook Marketplace', 'facebook.com');

  const SourceId(this.label, this.host);
  final String label, host;

  /// The id adverts from this site carry in [Listing.source].
  String get key => name.toLowerCase();

  /// Sites that turn plain HTTP apps away and draw their results with
  /// script: the app reads them in a hidden web view instead (see
  /// [browserSearchUrl]), and opens that page for the user when the site
  /// wants a robot check or a sign-in.
  bool get readInBrowser => this == zoopla || this == facebook;

  static SourceId? ofKey(String key) => values.where((s) => s.key == key).firstOrNull;
}

/// A results page read from one site.
typedef SourcePage = ({List<Listing> items, bool more});

/// A site answered with its bot check, or blocks apps, instead of results.
/// The in-app browser can open [url] for the user to pass the check.
class SourceBlocked implements Exception {
  const SourceBlocked(this.source, this.url);
  final SourceId source;
  final Uri url;
  @override
  String toString() => '${source.label} asked to check you are not a robot.';
}

/// A site that cannot be read for this request (no sales on OpenRent, an
/// area the site does not know). Not an error: the source sits this one out.
class SourceSkipped implements Exception {
  const SourceSkipped(this.reason);
  final String reason;
  @override
  String toString() => reason;
}

const userAgent = 'Mozilla/5.0 (compatible; Anveshana/0.9; personal property search)';

Map<String, Object?>? nextData(String html) {
  final m = RegExp(r'<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)</script>').firstMatch(html);
  if (m == null) return null;
  try {
    return (jsonDecode(m.group(1)!) as Map).cast<String, Object?>();
  } on FormatException {
    return null;
  }
}

Object? _at(Object? o, List<Object> path) {
  for (final k in path) {
    o = switch ((o, k)) {
      (Map m, String s) => m[s],
      (List l, int i) => i < l.length ? l[i] : null,
      _ => null,
    };
  }
  return o;
}

int _monthly(num amount, String frequency) => switch (frequency) {
  'weekly' || 'pw' => (amount * 52 / 12).round(),
  'yearly' => (amount / 12).round(),
  _ => amount.round(),
};

String _statusOf(String text, {required bool rent}) {
  final t = text.toLowerCase();
  if (t.contains('let agreed')) return 'letAgreed';
  if (t.contains('sold stc') || t.contains('under offer') || t.contains('sale agreed')) return 'saleAgreed';
  if (t.contains('sold')) return 'sold';
  return rent ? 'toLet' : 'forSale';
}

int? _int(Object? o) => switch (o) {
  num n => n.toInt(),
  String s => int.tryParse(s.replaceAll(RegExp(r'[^\d]'), '')),
  _ => null,
};

/// A Rightmove search page (`find.html`) as adverts.
SourcePage parseRightmoveSearch(String html, {required bool rent}) {
  final results = _at(nextData(html), ['props', 'pageProps', 'searchResults']);
  if (results is! Map) throw const FormatException('No Rightmove results on that page');
  final out = <Listing>[];
  for (final p in (results['properties'] as List?) ?? const []) {
    if (p is! Map) continue;
    final price = p['price'] as Map? ?? const {};
    final amount = price['amount'] as num?;
    final features = [
      for (final f in (p['keyFeatures'] as List?) ?? const [])
        if (f is Map) '${f['description'] ?? ''}',
    ];
    final address = '${p['displayAddress'] ?? ''}';
    out.add(
      Listing(
        source: SourceId.rightmove.key,
        sourceId: '${p['id']}',
        url: 'https://www.rightmove.co.uk/properties/${p['id']}',
        address: address,
        postcode: postcodeIn(address) ?? '',
        price: amount == null ? null : (rent ? _monthly(amount, '${price['frequency']}') : amount.round()),
        priceSuffix: rent ? 'pcm' : '',
        beds: _int(p['bedrooms']),
        baths: _int(p['bathrooms']),
        style: '${p['propertySubType'] ?? ''}',
        availableFrom: (p['letAvailableDate'] as String?)?.split('T').first,
        lat: (_at(p, ['location', 'latitude']) as num?)?.toDouble(),
        lon: (_at(p, ['location', 'longitude']) as num?)?.toDouble(),
        agent: '${_at(p, ['customer', 'branchDisplayName']) ?? ''}',
        agentPhone: '${_at(p, ['customer', 'contactTelephone']) ?? ''}',
        image: _at(p, ['images', 0, 'srcUrl']) as String?,
        status: _statusOf('${p['displayStatus'] ?? ''}', rent: rent),
        description: [p['summary'] ?? '', ...features].join('\n').trim(),
      ),
    );
  }
  return (items: out, more: _at(results, ['pagination', 'next']) != null);
}

/// An OnTheMarket search page as adverts.
SourcePage parseOnTheMarketSearch(String html, {required bool rent}) {
  final results = _at(nextData(html), ['props', 'pageProps', 'initialReduxState', 'results']);
  if (results is! Map) throw const FormatException('No OnTheMarket results on that page');
  final out = <Listing>[];
  for (final p in (results['list'] as List?) ?? const []) {
    if (p is! Map) continue;
    final priceText = '${p['price'] ?? ''}';
    final short = _int(p['short-price']);
    final weekly = !priceText.contains('pcm') && priceText.contains('pw');
    final address = '${p['address'] ?? ''}';
    final title = '${p['property-title'] ?? ''}';
    final label = '${p['main-label'] ?? ''}';
    out.add(
      Listing(
        source: SourceId.onTheMarket.key,
        sourceId: '${p['id']}',
        url: 'https://www.onthemarket.com${p['details-url'] ?? '/details/${p['id']}/'}',
        address: address,
        postcode: postcodeIn(address) ?? '',
        price: short == null ? null : (rent && weekly ? _monthly(short, 'pw') : short),
        priceSuffix: rent ? 'pcm' : '',
        beds: _int(p['bedrooms']),
        baths: _int(p['bathrooms']),
        style: '${p['humanised-property-type'] ?? ''}',
        lat: (_at(p, ['location', 'lat']) as num?)?.toDouble(),
        lon: (_at(p, ['location', 'lon']) as num?)?.toDouble(),
        agent: '${_at(p, ['agent', 'name']) ?? ''}',
        agentPhone: '${_at(p, ['agent', 'telephone']) ?? ''}',
        image: _at(p, ['cover-image', 'default']) as String?,
        status: _statusOf('$label $title $priceText', rent: rent),
        description: [title, for (final f in (p['features'] as List?) ?? const []) '$f'].join('\n').trim(),
      ),
    );
  }
  return (items: out, more: _at(results, ['paginationControls', 'next']) != null);
}

List<String> _jsArray(String html, String name) {
  final m = RegExp('var $name = \\[([\\s\\S]*?)\\];').firstMatch(html);
  if (m == null) return const [];
  return [for (final v in m.group(1)!.split(',')) v.trim().replaceAll('"', '').replaceAll("'", '')];
}

const _openRentTypes = {'1': 'House', '2': 'Flat', '3': 'Room'};

/// An OpenRent area page. Every match is in the page's script data; the
/// first twenty also have a card with a title and photo.
SourcePage parseOpenRentSearch(String html) {
  final ids = _jsArray(html, 'PROPERTYIDS');
  if (ids.isEmpty || ids.first.isEmpty) {
    if (html.contains('PROPERTYIDS')) return (items: const [], more: false);
    throw const FormatException('No OpenRent results on that page');
  }
  List<String> col(String name) {
    final a = _jsArray(html, name);
    return a.length == ids.length ? a : List.filled(ids.length, '');
  }

  final prices = col('prices'), beds = col('bedrooms'), baths = col('bathrooms');
  final lats = col('PROPERTYLISTLATITUDES'), lons = col('PROPERTYLISTLONGITUDES');
  final types = col('propertyTypes'), studio = col('isstudio'), live = col('islivelistBool');
  final furnished = col('furnished'), unfurnished = col('unfurnished');
  final flags = {
    'Parking': col('parkings'),
    'Garden': col('gardens'),
    'Pets allowed': col('pets'),
    'Bills included': col('bills'),
    'Students allowed': col('students'),
    'Fireplace': col('fireplaces'),
  };
  // Cards: link, then the photo with the title as its alt text.
  final cards = <String, ({String path, String? image, String title})>{};
  for (final m in RegExp(
    r'<a href="(/property-to-rent/[^"]*/(\d+))"[^>]*search-property-card[\s\S]*?<img[^>]*src="([^"]+)"[^>]*alt="([^"]*)"',
  ).allMatches(html)) {
    final src = m.group(3)!;
    cards[m.group(2)!] = (
      path: m.group(1)!,
      image: src.startsWith('//') ? 'https:$src' : src,
      title: _unescape(m.group(4)!),
    );
  }
  final out = <Listing>[];
  for (var i = 0; i < ids.length; i++) {
    final id = ids[i];
    final card = cards[id];
    final b = int.tryParse(beds[i]);
    final kind = studio[i] == '1' ? 'Studio' : (_openRentTypes[types[i]] ?? 'Home');
    final title = card?.title ?? (b == null || kind == 'Studio' ? kind : '$b bed ${kind.toLowerCase()}');
    out.add(
      Listing(
        source: SourceId.openRent.key,
        sourceId: id,
        url: 'https://www.openrent.co.uk${card?.path ?? '/$id'}',
        address: title,
        postcode: postcodeIn(title) ?? '',
        price: int.tryParse(prices[i]),
        priceSuffix: 'pcm',
        beds: studio[i] == '1' ? 0 : b,
        baths: int.tryParse(baths[i]),
        style: kind,
        furnished: furnished[i] == '1' ? 'Furnished' : (unfurnished[i] == '1' ? 'Unfurnished' : ''),
        lat: double.tryParse(lats[i]),
        lon: double.tryParse(lons[i]),
        agent: 'Private landlord (OpenRent)',
        image: card?.image,
        status: live[i] == '0' ? 'letAgreed' : 'toLet',
        description: [
          title,
          for (final MapEntry(:key, :value) in flags.entries)
            if (value[i] == '1') key,
        ].join('\n'),
      ),
    );
  }
  return (items: out, more: false);
}

String _unescape(String s) => s
    .replaceAll('&amp;', '&')
    .replaceAll('&#39;', "'")
    .replaceAll('&quot;', '"')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>');

String _slug(String area) =>
    area.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');

/// Rightmove radii, in miles. It rejects any other value.
const _rightmoveRadii = [0.0, 0.25, 0.5, 1.0, 3.0, 5.0, 10.0, 15.0, 20.0, 30.0, 40.0];

double _radiusAtLeast(double miles) => _rightmoveRadii.firstWhere((r) => r >= miles, orElse: () => 40);

/// Facebook Marketplace names towns by a short name ("leeds",
/// "newcastleupontyne"). It does not know postcodes.
String _marketplacePlace(SearchRequest q) => _slug(q.area).replaceAll('-', '');

/// The results page [page] (0 first) of a [SourceId.readInBrowser] site for
/// [q], with the request's filters, as a person would open it.
Uri browserSearchUrl(SourceId source, SearchRequest q, {int page = 0}) => switch (source) {
  SourceId.facebook => Uri.https(
    'www.facebook.com',
    '/marketplace/${_marketplacePlace(q)}/${q.rent ? 'propertyrentals' : 'propertyforsale'}',
    {
      if (q.minPrice != null) 'minPrice': '${q.minPrice}',
      if (q.maxPrice != null) 'maxPrice': '${q.maxPrice}',
      if (q.minBeds != null) 'minBedrooms': '${q.minBeds}',
      if (q.maxBeds != null) 'maxBedrooms': '${q.maxBeds}',
      if (q.radiusMiles != null) 'radius': '${(q.radiusMiles! * 1.609344).ceil()}',
      'exact': 'false',
    },
  ),
  SourceId.zoopla => Uri.https(
    'www.zoopla.co.uk',
    '/${q.rent ? 'to-rent' : 'for-sale'}/property/${_slug(q.area)}/',
    {
      'q': q.area,
      'search_source': q.rent ? 'to-rent' : 'for-sale',
      if (q.rent) 'price_frequency': 'per_month',
      if (q.minBeds != null) 'beds_min': '${q.minBeds}',
      if (q.maxBeds != null) 'beds_max': '${q.maxBeds}',
      if (q.minPrice != null) 'price_min': '${q.minPrice}',
      if (q.maxPrice != null) 'price_max': '${q.maxPrice}',
      if (q.radiusMiles != null) 'radius': '${_radiusAtLeast(q.radiusMiles!)}',
      if (page > 0) 'pn': '${page + 1}',
    },
  ),
  _ => throw ArgumentError('${source.label} is read over HTTP'),
};

/// Whether [html], page [page] of a [SourceId.readInBrowser] site, links to
/// a next page. Marketplace loads more as it scrolls: one page only.
bool browserHasMore(SourceId source, String html, int page) =>
    source == SourceId.zoopla && html.contains('pn=${page + 2}');

/// Reads the sites over HTTP. Zoopla and Facebook turn apps away; the Search
/// tab reads them in a hidden web view instead ([browserSearchUrl]).
class SourceReader {
  SourceReader(this._http);
  final http.Client _http;
  final _rightmoveAreas = <String, String>{};

  Future<String> _get(SourceId source, Uri url) async {
    final http.Response r;
    try {
      r = await _http
          .get(url, headers: {'user-agent': userAgent, 'accept': 'text/html,application/json'})
          .timeout(const Duration(seconds: 30));
    } on TimeoutException {
      throw SourceSkipped('${source.label} did not answer in time.');
    } on SocketException {
      throw SourceSkipped('No connection to ${source.label}.');
    } on http.ClientException {
      throw SourceSkipped('No connection to ${source.label}.');
    }
    if (r.statusCode == 403 || r.statusCode == 429 || r.statusCode == 503) throw SourceBlocked(source, url);
    if (r.statusCode == 404 || r.statusCode == 410) {
      throw SourceSkipped('${source.label} does not know that area.');
    }
    if (r.statusCode != 200) throw SourceSkipped('${source.label} answered with error ${r.statusCode}.');
    return r.body;
  }

  /// The results page [page] (0 first) of [source] for [q].
  Future<SourcePage> search(SourceId source, SearchRequest q, {int page = 0}) async {
    if (q.area.isEmpty) throw const SourceSkipped('Say where to search.');
    switch (source) {
      case SourceId.propertyPal:
        final url = Uri.https(
          'www.propertypal.com',
          '/${q.rent ? 'property-to-rent' : 'property-for-sale'}/${_slug(q.area)}${page == 0 ? '' : '/page-${page + 1}'}',
        );
        final html = await _get(source, url);
        final data = _at(nextData(html), ['props', 'pageProps', 'initialState', 'properties', 'data']);
        if (data is! Map) throw SourceBlocked(source, url);
        final items = parsePropertyPalPage(html);
        final pages = _int(data['totalPages']) ?? 1;
        return (items: items, more: page + 1 < pages);
      case SourceId.rightmove:
        final location = await _rightmoveArea(q.area);
        final url = Uri.https(
          'www.rightmove.co.uk',
          q.rent ? '/property-to-rent/find.html' : '/property-for-sale/find.html',
          {
            'locationIdentifier': location,
            if (q.radiusMiles != null) 'radius': _radiusAtLeast(q.radiusMiles!).toStringAsFixed(1),
            if (q.minBeds != null) 'minBedrooms': '${q.minBeds}',
            if (q.maxBeds != null) 'maxBedrooms': '${q.maxBeds}',
            if (q.maxPrice != null) 'maxPrice': '${q.maxPrice}',
            if (q.minPrice != null) 'minPrice': '${q.minPrice}',
            if (!q.includeGone) (q.rent ? 'includeLetAgreed' : 'includeSSTC'): 'false',
            'index': '${page * 24}',
          },
        );
        final html = await _get(source, url);
        if (nextData(html) == null) throw SourceBlocked(source, url);
        return parseRightmoveSearch(html, rent: q.rent);
      case SourceId.onTheMarket:
        final url = Uri.https(
          'www.onthemarket.com',
          '/${q.rent ? 'to-rent' : 'for-sale'}/property/${_slug(q.area)}/',
          {
            if (q.minBeds != null) 'min-bedrooms': '${q.minBeds}',
            if (q.maxBeds != null) 'max-bedrooms': '${q.maxBeds}',
            if (q.maxPrice != null) 'max-price': '${q.maxPrice}',
            if (q.minPrice != null) 'min-price': '${q.minPrice}',
            if (q.radiusMiles != null) 'radius': '${_radiusAtLeast(q.radiusMiles!)}',
            if (page > 0) 'page': '${page + 1}',
          },
        );
        final html = await _get(source, url);
        if (nextData(html) == null) throw SourceBlocked(source, url);
        return parseOnTheMarketSearch(html, rent: q.rent);
      case SourceId.openRent:
        if (!q.rent) throw const SourceSkipped('OpenRent lists homes to rent only.');
        if (page > 0) return (items: const <Listing>[], more: false);
        final url = Uri.https('www.openrent.co.uk', '/properties-to-rent/${_slug(q.area)}', {'term': q.area});
        return parseOpenRentSearch(await _get(source, url));
      case SourceId.zoopla || SourceId.facebook:
        // These answer plain HTTP with a robot check: the search page opens
        // in the browser instead.
        throw SourceBlocked(source, browserSearchUrl(source, q, page: page));
    }
  }

  /// Rightmove names areas by its own id ("REGION^787"), from its place search.
  Future<String> _rightmoveArea(String area) async {
    final key = area.trim().toLowerCase();
    if (_rightmoveAreas[key] case final id?) return id;
    final postcode = postcodeIn(area);
    final url = Uri.https('los.rightmove.co.uk', '/typeahead', {
      'query': postcode ?? area.trim(),
      'limit': '5',
      'exclude': 'STREET',
    });
    final Object? body;
    try {
      body = jsonDecode(await _get(SourceId.rightmove, url));
    } on FormatException {
      throw const SourceSkipped('Rightmove could not look up that area.');
    }
    final match = _at(body, ['matches', 0]);
    if (match is! Map) throw const SourceSkipped('Rightmove does not know that area.');
    return _rightmoveAreas[key] = '${match['type']}^${match['id']}';
  }
}
