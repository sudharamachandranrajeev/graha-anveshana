/// More UK sites the Search tab links to but never reads: their terms or
/// owners do not allow automated reading (docs/2026-11-09-uk-property-sites.md),
/// so the user opens them in their own browser.
library;

import 'search_request.dart';

typedef SiteLink = ({String label, String note, Uri url});

/// The sites worth opening for [q]: flat-shares and council housing to rent;
/// shared ownership and auctions to buy. Each link goes to the search's town
/// where the site has a page for it, else to the site's front page.
List<SiteLink> moreSiteLinks(SearchRequest q) {
  final town = _slug(q.area);
  final where = q.area.toLowerCase();
  final postcode = where.replaceAll(' ', '');
  bool near(String name, String area) => where.contains(name) || RegExp('^$area\\d').hasMatch(postcode);
  return [
    if (q.rent) ...[
      (
        label: 'SpareRoom',
        note: 'Rooms and flat-shares',
        url: town.isEmpty
            ? Uri.https('www.spareroom.co.uk')
            : Uri.https('www.spareroom.co.uk', '/flatshare/$town'),
      ),
      if (near('leeds', 'ls'))
        (
          label: 'Leeds Homes',
          note: 'Council and housing association homes in Leeds (register to bid)',
          url: Uri.https('www.leedshomes.org.uk', '/PropertySearch'),
        ),
      if (near('doncaster', 'dn'))
        (
          label: 'Doncaster HomeChoice',
          note: 'Council homes in Doncaster (register to bid)',
          url: Uri.https('www.stlegerhomes.co.uk', '/homechoice/'),
        ),
    ] else ...[
      (
        label: 'Share to Buy',
        note: 'Shared ownership and Help to Buy homes',
        url: town.isEmpty
            ? Uri.https('www.sharetobuy.com')
            : Uri.https('www.sharetobuy.com', '/locations/$town'),
      ),
      (label: 'Allsop', note: 'Property auctions', url: Uri.https('www.allsop.co.uk', '/auctions/')),
      (
        label: 'BTG Eddisons',
        note: 'Property auctions, including Yorkshire',
        url: Uri.https('www.btgeddisonspropertyauctions.com'),
      ),
      (
        label: 'EIG',
        note: 'Auction lots across many auctioneers, Yorkshire',
        url: Uri.https('www.eigpropertyauctions.co.uk', '/search/property/yorkshire'),
      ),
      (
        label: 'Auction House',
        note: 'Property auctions',
        url: Uri.https('online.auctionhouse.co.uk', '/search', {'view': 'list'}),
      ),
    ],
    (
      label: 'Home.co.uk',
      note: 'Listings from many agents, and rent and price reports',
      url: Uri.https('www.home.co.uk'),
    ),
  ];
}

/// "Leeds", "Pontefract, West Yorkshire" -> "leeds", "pontefract". A
/// postcode gives no town: empty.
String _slug(String area) {
  final first = area.split(',').first.trim().toLowerCase();
  if (RegExp(r'\d').hasMatch(first)) return '';
  return first.replaceAll(RegExp(r'[^a-z]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');
}
