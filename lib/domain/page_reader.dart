import 'dart:convert';

import 'listing.dart';
import 'sources.dart';

/// Reading results from a page open in a web view: Zoopla and Facebook
/// Marketplace (which turn plain HTTP apps away), read in a hidden web view
/// when the user searches, or a page the user opened in the in-app browser
/// after a site asked for a robot check or a sign-in.

/// Script run in the page: every advert card with its link, text and
/// picture. A card is the nearest box around an advert link that shows a
/// price, so it works on any site laid out as a list of cards.
const cardsScript = r'''
(() => {
  const seen = new Set(), out = [];
  const advert = /\/(?:to-rent|for-sale|property-to-rent|property-for-sale|properties|details|property|marketplace\/item)\/[^?#]*?(\d{5,})/;
  // One advert's own page: that advert, not the others it links to.
  const self = location.href.match(advert);
  const main = document.querySelector('main') || document.body;
  if (self && /details|properties|marketplace\/item/.test(location.pathname)) {
    const text = (main.innerText || '').trim().slice(0, 1500);
    if (/£\s?\d/.test(text)) {
      const img = main.querySelector('img[src^="http"]');
      const title = (document.querySelector('h1') || {}).innerText || '';
      return JSON.stringify([{id: self[1], href: location.href.split('?')[0],
        text: (title ? title + '\n' : '') + text, img: img ? img.src : ''}]);
    }
  }
  for (const a of document.querySelectorAll('a[href]')) {
    const m = a.href.match(advert);
    if (!m || seen.has(m[1])) continue;
    let box = a;
    for (let i = 0; i < 8 && box.parentElement; i++) {
      if (/£\s?\d/.test(box.innerText || '') && (box.innerText || '').length > 20) break;
      box = box.parentElement;
    }
    const text = (box.innerText || '').trim();
    if (!/£\s?\d/.test(text) || text.length > 2000) continue;
    seen.add(m[1]);
    const img = box.querySelector('img[src^="http"]');
    out.push({id: m[1], href: a.href.split('?')[0], text, img: img ? img.src : ''});
  }
  return JSON.stringify(out);
})()
''';

final _money = RegExp(
  r'£\s?([\d,]+(?:\.\d+)?)\s*(k|m)?\s*(pcm|pw|per\s+month|per\s+week|a\s+month|a\s+week|/\s*month|/\s*week)?',
  caseSensitive: false,
);

/// Listings from the cards [cardsScript] found on [source]'s page.
List<Listing> listingsFromCards(SourceId source, String json, {required bool rent}) {
  final Object? raw;
  try {
    raw = jsonDecode(json);
  } on FormatException {
    return const [];
  }
  if (raw is! List) return const [];
  return [
    for (final c in raw)
      if (c is Map && c['id'] != null && c['href'] is String) ?_card(source, c, rent: rent),
  ];
}

Listing? _card(SourceId source, Map c, {required bool rent}) {
  final text = '${c['text'] ?? ''}';
  final lines = [
    for (final l in text.split('\n'))
      if (l.trim().isNotEmpty) l.trim(),
  ];
  final m = _money.firstMatch(text);
  if (m == null) return null;
  var amount = double.tryParse(m.group(1)!.replaceAll(',', '')) ?? 0;
  amount *= switch (m.group(2)?.toLowerCase()) {
    'k' => 1000,
    'm' => 1000000,
    _ => 1,
  };
  final weekly = RegExp(r'pw|week', caseSensitive: false).hasMatch(m.group(3) ?? '');
  final price = (weekly ? amount * 52 / 12 : amount).round();
  final beds = RegExp(r'\b(\d{1,2})\s*bed', caseSensitive: false).firstMatch(text);
  final baths = RegExp(r'\b(\d{1,2})\s*bath', caseSensitive: false).firstMatch(text);
  // The kind of home, as the card names it ("2 beds 1 bath Flat").
  final style = RegExp(
    r'\b(detached house|semi-detached house|terraced house|end of terrace house|townhouse|bungalow|'
    r'maisonette|apartment|flat|house|studio|cottage|room)\b',
    caseSensitive: false,
  ).firstMatch(text);
  final studio = RegExp(r'\bstudio\b', caseSensitive: false).hasMatch(text);
  // The address: the first line naming a postcode, else the first with a
  // comma that is not the price or a feature list.
  final address =
      lines.where((l) => postcodeIn(l) != null && !l.contains('£')).firstOrNull ??
      lines.where((l) => l.contains(',') && !l.contains('£') && l.length < 120).firstOrNull ??
      lines.where((l) => !l.contains('£')).firstOrNull ??
      '';
  final gone = RegExp(r'let agreed|under offer|sold stc|sale agreed', caseSensitive: false).hasMatch(text);
  final img = '${c['img'] ?? ''}';
  return Listing(
    source: source.key,
    sourceId: '${c['id']}',
    url: '${c['href']}',
    address: address.isEmpty ? 'Home on ${source.label}' : address,
    postcode: postcodeIn(address) ?? '',
    price: price > 0 ? price : null,
    priceSuffix: rent ? 'pcm' : '',
    beds: studio ? 0 : (beds == null ? null : int.parse(beds.group(1)!)),
    baths: baths == null ? null : int.parse(baths.group(1)!),
    style: switch (style?.group(1)) {
      final String k => '${k[0].toUpperCase()}${k.substring(1).toLowerCase()}',
      null => '',
    },
    image: img.startsWith('https://') ? img : null,
    status: gone ? (rent ? 'letAgreed' : 'saleAgreed') : (rent ? 'toLet' : 'forSale'),
    description: lines.join('\n'),
  );
}

/// The results on a page of [source] the user has open: the site's own
/// data when the app knows its layout, else the advert cards on it.
/// [cards] is the result of [cardsScript] on the same page.
SourcePage readOpenPage(SourceId source, String html, String cards, {required bool rent}) {
  try {
    final page = switch (source) {
      SourceId.rightmove => parseRightmoveSearch(html, rent: rent),
      SourceId.onTheMarket => parseOnTheMarketSearch(html, rent: rent),
      SourceId.openRent => parseOpenRentSearch(html),
      SourceId.propertyPal => (items: parsePropertyPalPage(html), more: false),
      SourceId.zoopla || SourceId.facebook => null,
    };
    if (page != null && page.items.isNotEmpty) return page;
  } on Object {
    // Not the layout the app knows (a different page, or the site changed):
    // fall back to the cards.
  }
  return (items: listingsFromCards(source, cards, rent: rent), more: false);
}
