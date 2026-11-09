import 'listing.dart';
import 'property_search.dart';

/// A home the user threw out of Search. It is never shown again, on any
/// site, until it is restored from the Trash.
class TrashedHome {
  const TrashedHome({
    required this.keys,
    required this.address,
    required this.at,
    this.source = '',
    this.url = '',
    this.postcode = '',
    this.price,
    this.beds,
    this.lat,
    this.lon,
    this.image,
  });

  /// "source:sourceId" of every site's advert for it when it was thrown out.
  final List<String> keys;
  final String address, source, url, postcode;
  final int? price, beds;
  final double? lat, lon;
  final String? image;

  /// When it was thrown out, yyyy-MM-dd.
  final String at;

  String get id => keys.first;

  factory TrashedHome.of(FoundHome h, String today) => TrashedHome(
    keys: [for (final c in h.copies) '${c.source}:${c.sourceId}'],
    address: h.main.address,
    source: h.main.source,
    url: h.main.url,
    postcode: h.postcode,
    price: h.price,
    beds: h.beds,
    lat: h.lat,
    lon: h.lon,
    image: h.image,
    at: today,
  );

  /// The advert it was, to match the same home listed again or elsewhere.
  Listing get listing => Listing(
    source: source,
    sourceId: id.substring(id.indexOf(':') + 1),
    url: url,
    address: address,
    postcode: postcode,
    price: price,
    beds: beds,
    lat: lat,
    lon: lon,
  );

  Map<String, Object?> toJson() => {
    'keys': keys,
    'address': address,
    'at': at,
    if (source.isNotEmpty) 'source': source,
    if (url.isNotEmpty) 'url': url,
    if (postcode.isNotEmpty) 'postcode': postcode,
    'price': ?price,
    'beds': ?beds,
    'lat': ?lat,
    'lon': ?lon,
    'image': ?image,
  };

  static TrashedHome? fromJson(Object? j) => switch (j) {
    {'keys': final List keys, 'address': final String address, 'at': final String at} when keys.isNotEmpty =>
      TrashedHome(
        keys: [for (final k in keys) '$k'],
        address: address,
        at: at,
        source: '${j['source'] ?? ''}',
        url: '${j['url'] ?? ''}',
        postcode: '${j['postcode'] ?? ''}',
        price: (j['price'] as num?)?.toInt(),
        beds: (j['beds'] as num?)?.toInt(),
        lat: (j['lat'] as num?)?.toDouble(),
        lon: (j['lon'] as num?)?.toDouble(),
        image: j['image'] as String?,
      ),
    _ => null,
  };
}

/// Whether [h] was thrown out: one of its adverts is, or it is the same home
/// as one thrown out (the shared same-home rules), on any site.
bool isTrashed(FoundHome h, List<TrashedHome> trash) {
  if (trash.isEmpty) return false;
  for (final t in trash) {
    final was = t.listing;
    for (final c in h.copies) {
      if (t.keys.contains('${c.source}:${c.sourceId}') || sameListedHome(c, was)) return true;
    }
  }
  return false;
}
