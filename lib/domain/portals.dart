/// The big property portals publish no free feed, so the app builds each
/// portal's own search page and recognises advert links. It never fetches
/// those sites itself: on Android the user browses them in the app and taps
/// Save on an advert (domain/advert_page.dart reads that one page).
library;

enum Portal {
  rightmove('Rightmove', 'rightmove.co.uk'),
  zoopla('Zoopla', 'zoopla.co.uk'),
  onTheMarket('OnTheMarket', 'onthemarket.com'),
  openRent('OpenRent', 'openrent.co.uk'),
  facebook('Facebook Marketplace', 'facebook.com');

  const Portal(this.label, this.host);
  final String label, host;

  /// OpenRent lists lettings only.
  bool get lettingsOnly => this == openRent;
}

/// What the user is looking for, in terms every portal understands.
class PortalQuery {
  const PortalQuery({
    required this.area,
    required this.rent,
    this.maxPrice,
    this.minBeds,
    this.maxBeds,
    this.radiusMiles,
  });

  /// A town, district or postcode: "Pontefract", "WF8", "LS1 4AP".
  final String area;
  final bool rent;
  final int? maxPrice, minBeds, maxBeds;
  final double? radiusMiles;
}

/// Radii the portals accept, in miles. Rightmove rejects any other value.
const portalRadii = [0.0, 0.25, 0.5, 1.0, 3.0, 5.0, 10.0, 15.0, 20.0, 30.0, 40.0];

double _nearestRadius(double miles) =>
    portalRadii.reduce((a, b) => (a - miles).abs() <= (b - miles).abs() ? a : b);

String _slug(String area) =>
    area.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');

/// The portal's search page for [q], or null when it cannot do it (OpenRent
/// has no sales).
Uri? portalSearchUri(Portal portal, PortalQuery q) {
  final area = q.area.trim();
  if (area.isEmpty || (portal.lettingsOnly && !q.rent)) return null;
  final r = q.radiusMiles == null ? null : _nearestRadius(q.radiusMiles!);
  String? n(int? v) => v?.toString();
  Map<String, String> params(Map<String, String?> m) => {
    for (final e in m.entries)
      if (e.value != null) e.key: e.value!,
  };
  switch (portal) {
    case Portal.rightmove:
      return Uri.https(
        'www.rightmove.co.uk',
        q.rent ? '/property-to-rent/find.html' : '/property-for-sale/find.html',
        params({
          'searchLocation': area,
          'useLocationIdentifier': 'false',
          'radius': (r ?? 0).toStringAsFixed(1),
          'minBedrooms': n(q.minBeds),
          'maxBedrooms': n(q.maxBeds),
          'maxPrice': n(q.maxPrice),
          'includeLetAgreed': 'false',
          'includeSSTC': 'false',
        }),
      );
    case Portal.zoopla:
      return Uri.https(
        'www.zoopla.co.uk',
        '/${q.rent ? 'to-rent' : 'for-sale'}/property/${_slug(area)}/',
        params({
          'q': area,
          'beds_min': n(q.minBeds),
          'beds_max': n(q.maxBeds),
          'price_max': n(q.maxPrice),
          'price_frequency': q.rent && q.maxPrice != null ? 'per_month' : null,
          'radius': r == null || r == 0 ? null : '$r',
        }),
      );
    case Portal.onTheMarket:
      return Uri.https(
        'www.onthemarket.com',
        '/${q.rent ? 'to-rent' : 'for-sale'}/property/${_slug(area)}/',
        params({
          'min-bedrooms': n(q.minBeds),
          'max-bedrooms': n(q.maxBeds),
          'max-price': n(q.maxPrice),
          'radius': r == null || r == 0 ? null : '$r',
        }),
      );
    case Portal.openRent:
      return Uri.https(
        'www.openrent.co.uk',
        '/properties-to-rent/${_slug(area)}',
        params({
          'term': area,
          'prices_max': n(q.maxPrice),
          'bedrooms_min': n(q.minBeds),
          'bedrooms_max': n(q.maxBeds),
          'within': r == null || r == 0 ? null : '${r.round()}',
        }),
      );
    case Portal.facebook:
      // Marketplace takes a town in the path; bedrooms and distance are set
      // on its own page.
      return Uri.https(
        'www.facebook.com',
        '/marketplace/${_slug(area)}/${q.rent ? 'propertyrentals' : 'propertyforsale'}',
        params({'maxPrice': n(q.maxPrice), 'exact': 'false'}),
      );
  }
}

/// Every portal's search page that can serve [q].
List<({Portal portal, Uri url})> portalSearches(PortalQuery q) => [
  for (final p in Portal.values)
    if (portalSearchUri(p, q) case final u?) (portal: p, url: u),
];

/// An advert on one of the portals, read from its link alone.
class PortalAdvert {
  const PortalAdvert(this.portal, this.id, this.url, this.address);
  final Portal portal;
  final String id;
  final Uri url;

  /// A guess from the link's own words; empty when the link carries none.
  final String address;
}

final _digits = RegExp(r'^\d{5,}$');

/// Recognises an advert link ("https://www.rightmove.co.uk/properties/1234")
/// without fetching it. Null for anything else. Tracking parameters and
/// fragments are dropped so the same advert always has one link.
PortalAdvert? parsePortalLink(String link) {
  final u = Uri.tryParse(link.trim());
  if (u == null || u.scheme != 'https') return null;
  for (final p in Portal.values) {
    if (u.host != p.host && !u.host.endsWith('.${p.host}')) continue;
    final seg = [
      for (final s in u.pathSegments)
        if (s.isNotEmpty) s,
    ];
    String? id;
    var words = '';
    switch (p) {
      case Portal.rightmove:
        // /properties/123456789 and /property-to-rent/property-123456789.html
        if (seg.length >= 2 && seg[0] == 'properties' && _digits.hasMatch(seg[1])) id = seg[1];
        final m = RegExp(r'property-(\d{5,})\.html$').firstMatch(seg.isEmpty ? '' : seg.last);
        id ??= m?.group(1);
      case Portal.zoopla:
        // /to-rent/details/12345678/ and /for-sale/details/12345678/
        final i = seg.indexOf('details');
        if (i >= 0 && i + 1 < seg.length && _digits.hasMatch(seg[i + 1])) id = seg[i + 1];
      case Portal.onTheMarket:
        // /details/12345678/
        final i = seg.indexOf('details');
        if (i >= 0 && i + 1 < seg.length && _digits.hasMatch(seg[i + 1])) id = seg[i + 1];
      case Portal.openRent:
        // /property-to-rent/leeds/2-bed-flat-high-street/2345678
        if (seg.length >= 2 && seg[0] == 'property-to-rent' && _digits.hasMatch(seg.last)) {
          id = seg.last;
          words = seg.length >= 3 ? seg[seg.length - 2] : '';
        }
      case Portal.facebook:
        // /marketplace/item/1234567890123456/
        if (seg.length >= 3 && seg[0] == 'marketplace' && seg[1] == 'item' && _digits.hasMatch(seg[2])) {
          id = seg[2];
        }
    }
    if (id == null) return null;
    final clean = Uri(scheme: 'https', host: u.host, pathSegments: seg);
    return PortalAdvert(p, id, clean, _title(words));
  }
  return null;
}

String _title(String slug) =>
    slug.split('-').where((w) => w.isNotEmpty).map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
