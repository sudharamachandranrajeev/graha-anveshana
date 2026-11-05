import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

/// A property advert, from PropertyPal / PropertyNews, a Brahma Watch alert,
/// or typed in.
class Listing {
  const Listing({
    required this.source,
    required this.sourceId,
    required this.url,
    required this.address,
    this.postcode = '',
    this.price,
    this.priceSuffix = '',
    this.beds,
    this.baths,
    this.style = '',
    this.furnished = '',
    this.heating = '',
    this.availableFrom,
    this.lat,
    this.lon,
    this.agent = '',
    this.agentPhone = '',
    this.image,
    this.status = '',
    this.description = '',
  });

  final String source;
  final String sourceId;
  final String url;
  final String address;
  final String postcode;

  /// Monthly rent or asking price in pounds; null when not given.
  final int? price;
  final String priceSuffix;
  final int? beds, baths;
  final String style, furnished, heating;
  final String? availableFrom;
  final double? lat, lon;
  final String agent, agentPhone;
  final String? image;

  /// toLet, letAgreed, forSale, saleAgreed...
  final String status;
  final String description;

  /// For rent rather than for sale.
  bool get isRental =>
      status.startsWith('toLet') || status.startsWith('let') || priceSuffix.contains('month');
}

const _propertyPal = 'https://www.propertypal.com';

/// One PropertyPal property object (a search result or a listing page).
Listing listingFromPropertyPal(Map<String, Object?> r) {
  final priceObj = (r['price'] as Map?)?.cast<String, Object?>() ?? const {};
  final hidden = priceObj['priceHidden'] == true || priceObj['priceOnApplication'] == true;
  final account = (r['account'] as Map?)?.cast<String, Object?>() ?? const {};
  final phone = (account['officePhone'] as Map?)?.cast<String, Object?>() ?? const {};
  final coord = (r['coordinate'] as Map?)?.cast<String, Object?>() ?? const {};
  final images = r['images'];
  String text(Object? o) => switch (o) {
    {'text': final String t} => t,
    String s => s,
    _ => '',
  };
  return Listing(
    source: 'propertypal',
    sourceId: '${r['pathId'] ?? r['id']}',
    url: '$_propertyPal${r['path'] ?? ''}',
    address: '${r['displayAddress'] ?? ''}',
    postcode: '${r['postcode'] ?? ''}',
    price: hidden ? null : (priceObj['price'] as num?)?.round(),
    priceSuffix: '${priceObj['priceSuffix'] ?? ''}',
    beds: (r['numBedrooms'] as num?)?.toInt(),
    baths: (r['numBathrooms'] as num?)?.toInt(),
    style: text(r['style']),
    furnished: text(r['furnishedType']),
    heating: text(r['heatingType']),
    availableFrom: r['dateAvailableFrom'] as String?,
    lat: (coord['latitude'] as num?)?.toDouble(),
    lon: (coord['longitude'] as num?)?.toDouble(),
    agent: '${account['organisation'] ?? ''}',
    agentPhone: '${phone['international'] ?? ''}',
    image: images is List && images.isNotEmpty ? (images.first as Map)['url'] as String? : null,
    status: switch (r['status']) {
      {'key': final String k} => k,
      _ => '',
    },
    description: '${r['briefText'] ?? ''}',
  );
}

/// Reads a PropertyPal page: a listing page gives one, a search page many.
/// Throws when the page carries no listing data (a bot check, or the site
/// changed).
List<Listing> parsePropertyPalPage(String html) {
  final m = RegExp(r'<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)</script>').firstMatch(html);
  if (m == null) throw const FormatException('No listing data on that page (blocked, or the site changed)');
  final props = (jsonDecode(m.group(1)!) as Map)['props'] as Map?;
  final page = (props?['pageProps'] as Map?)?.cast<String, Object?>() ?? const {};
  final one = page['property'];
  if (one is Map) return [listingFromPropertyPal(one.cast())];
  final results = (((page['initialState'] as Map?)?['properties'] as Map?)?['data'] as Map?)?['results'];
  if (results is List) return [for (final r in results) listingFromPropertyPal((r as Map).cast())];
  throw const FormatException('No listing data on that page');
}

/// A listing as Brahma Watch sends it (see watch/src/propertypal.ts).
Listing listingFromWatch(Map<String, Object?> j) => Listing(
  // Alert-email adverts carry their portal (rightmove, zoopla, ...) and its
  // advert id, so they match the same advert pasted from that portal.
  source: '${j['source'] ?? 'propertypal'}',
  sourceId: '${j['sourceId'] ?? j['id']}',
  url: '${j['url'] ?? ''}',
  address: '${j['address'] ?? ''}',
  postcode: postcodeIn('${j['address'] ?? ''}') ?? '',
  price: (j['price'] as num?)?.round(),
  priceSuffix: '${j['priceSuffix'] ?? ''}',
  beds: (j['beds'] as num?)?.toInt(),
  baths: (j['baths'] as num?)?.toInt(),
  style: '${j['style'] ?? ''}',
  furnished: '${j['furnished'] ?? ''}',
  heating: '${j['heating'] ?? ''}',
  availableFrom: j['availableFrom'] as String?,
  lat: (j['lat'] as num?)?.toDouble(),
  lon: (j['lon'] as num?)?.toDouble(),
  agent: '${j['agent'] ?? ''}',
  agentPhone: '${j['agentPhone'] ?? ''}',
  image: j['image'] as String?,
  status: '${j['status'] ?? ''}',
);

final _postcode = RegExp(r'\b([A-Z]{1,2}[0-9][A-Z0-9]?) ?([0-9][A-Z]{2})\b', caseSensitive: false);

/// The first full UK postcode in [text], normalised ("bt747hh" -> "BT74 7HH").
String? postcodeIn(String text) {
  final m = _postcode.firstMatch(text);
  return m == null ? null : '${m.group(1)!.toUpperCase()} ${m.group(2)!.toUpperCase()}';
}

/// Great-circle distance in kilometres.
double distanceKm(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371.0;
  double rad(double d) => d * math.pi / 180;
  final dLat = rad(lat2 - lat1), dLon = rad(lon2 - lon1);
  final a =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(lat1)) * math.cos(rad(lat2)) * math.pow(math.sin(dLon / 2), 2);
  return 2 * r * math.asin(math.sqrt(a));
}

/// Reads the adverts on a PropertyPal page (one listing or a search). Only
/// PropertyPal links are fetched. Throws FormatException when the site
/// answers with a browser check instead of the page.
Future<List<Listing>> fetchPropertyPal(String link, {http.Client? client}) async {
  final uri = Uri.tryParse(link.trim());
  if (uri == null || uri.scheme != 'https' || !RegExp(r'(^|\.)propertypal\.com$').hasMatch(uri.host)) {
    throw const FormatException('Paste a https://www.propertypal.com link.');
  }
  final c = client ?? http.Client();
  try {
    final res = await c
        .get(uri, headers: {'user-agent': _userAgent, 'accept': 'text/html'})
        .timeout(const Duration(seconds: 30));
    if (res.statusCode != 200) throw FormatException('PropertyPal said ${res.statusCode}.');
    return parsePropertyPalPage(res.body);
  } finally {
    if (client == null) c.close();
  }
}

const _userAgent = 'Mozilla/5.0 (compatible; Anveshana/0.1; personal property search)';
