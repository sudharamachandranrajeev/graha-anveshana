/// Advert links from England's big property portals, recognised from the
/// link alone when the user pastes one into Shortlist. (Searching them is the
/// Search tab's job: see sources.dart.)
library;

enum Portal {
  rightmove('Rightmove', 'rightmove.co.uk'),
  zoopla('Zoopla', 'zoopla.co.uk'),
  onTheMarket('OnTheMarket', 'onthemarket.com'),
  openRent('OpenRent', 'openrent.co.uk');

  const Portal(this.label, this.host);
  final String label, host;

  /// OpenRent lists lettings only.
  bool get lettingsOnly => this == openRent;
}

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
    }
    if (id == null) return null;
    final clean = Uri(scheme: 'https', host: u.host, pathSegments: seg);
    return PortalAdvert(p, id, clean, _title(words));
  }
  return null;
}

String _title(String slug) =>
    slug.split('-').where((w) => w.isNotEmpty).map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
