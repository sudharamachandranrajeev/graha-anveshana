import 'dart:convert';

import 'package:http/http.dart' as http;

import 'listing.dart';
import 'sources.dart';

/// The whole advert, read from the site's advert page so it can be shown in
/// the app: the description, every photo and floor plan, and the facts the
/// site lists (deposit, furnishing, council tax...).
class AdvertDetails {
  const AdvertDetails({
    this.description = '',
    this.photos = const [],
    this.floorplans = const [],
    this.features = const [],
    this.facts = const {},
    this.agent = '',
    this.phone = '',
  });
  final String description;
  final List<String> photos, floorplans, features;
  final Map<String, String> facts;
  final String agent, phone;
}

/// Plain text from an advert's HTML description.
String plainText(String html) => html
    .replaceAll(RegExp(r'<br\s*/?>|</p>|</h\d>|</li>', caseSensitive: false), '\n')
    .replaceAll(RegExp(r'<[^>]+>'), '')
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&amp;', '&')
    .replaceAll('&#39;', "'")
    .replaceAll('&quot;', '"')
    .replaceAll(RegExp(r'&#x?A3;|&pound;', caseSensitive: false), '£')
    .replaceAll(RegExp(r'[ \t]+'), ' ')
    .replaceAll(RegExp(r' *\n *'), '\n')
    .replaceAll(RegExp(r'\n{3,}'), '\n\n')
    .trim();

/// Rightmove's page model is flattened: every value is an index into one
/// list. This rebuilds the tree.
Object? _unflatten(List<Object?> data, [int at = 0, int depth = 0]) {
  if (depth > 60 || at < 0 || at >= data.length) return null;
  final v = data[at];
  return switch (v) {
    Map m => {
      for (final MapEntry(:key, :value) in m.entries)
        '$key': value is int ? _unflatten(data, value, depth + 1) : value,
    },
    List l => [for (final x in l) x is int ? _unflatten(data, x, depth + 1) : x],
    _ => v,
  };
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

/// The JSON object starting at [start], up to its matching brace.
String _objectAt(String s, int start) {
  if (start < 0) throw const FormatException('no object');
  var depth = 0;
  var inString = false;
  for (var k = start; k < s.length; k++) {
    final c = s.codeUnitAt(k);
    if (inString) {
      if (c == 0x5c) {
        k++; // Skip the escaped character.
      } else if (c == 0x22) {
        inString = false;
      }
    } else if (c == 0x22) {
      inString = true;
    } else if (c == 0x7b) {
      depth++;
    } else if (c == 0x7d && --depth == 0) {
      return s.substring(start, k + 1);
    }
  }
  throw const FormatException('unclosed object');
}

String _s(Object? o) => o == null ? '' : '$o'.trim();

AdvertDetails parseRightmoveAdvert(String html) {
  final i = html.indexOf('window.__PAGE_MODEL');
  if (i < 0) throw const FormatException('No advert on that Rightmove page');
  final start = html.indexOf('{', i);
  final Object? model;
  try {
    final raw = jsonDecode(_objectAt(html, start));
    final data = _at(raw, ['data']);
    model = data is List ? _unflatten(data) : (data is String ? _unflatten(jsonDecode(data) as List) : data);
  } on FormatException {
    throw const FormatException('Could not read that Rightmove page');
  }
  final p = _at(model, ['propertyData']);
  if (p is! Map) throw const FormatException('No advert on that Rightmove page');
  final lettings = (p['lettings'] as Map?) ?? const {};
  final tenure = _s(_at(p, ['tenure', 'tenureType']));
  final band = _s(_at(p, ['livingCosts', 'councilTaxBand']));
  // Leasehold material information, when the agent gave it.
  final years = _at(p, ['tenure', 'yearsRemainingOnLease']);
  final service = _at(p, ['livingCosts', 'annualServiceCharge']);
  final groundRent = _at(p, ['livingCosts', 'annualGroundRent']);
  return AdvertDetails(
    description: plainText(_s(_at(p, ['text', 'description']))),
    photos: [
      for (final im in (p['images'] as List?) ?? const [])
        if (_s(_at(im, ['url'])).isNotEmpty) _s(_at(im, ['url'])),
    ],
    floorplans: [
      for (final im in (p['floorplans'] as List?) ?? const [])
        if (_s(_at(im, ['url'])).isNotEmpty) _s(_at(im, ['url'])),
    ],
    features: [for (final f in (p['keyFeatures'] as List?) ?? const []) _s(f)],
    facts: {
      if (_s(lettings['letAvailableDate']).isNotEmpty) 'Available': _s(lettings['letAvailableDate']),
      if (lettings['deposit'] != null) 'Deposit': '£${lettings['deposit']}',
      if (_s(lettings['furnishType']).isNotEmpty) 'Furnishing': _s(lettings['furnishType']),
      if (_s(lettings['letType']).isNotEmpty) 'Let type': _s(lettings['letType']),
      if (lettings['minimumTermInMonths'] != null)
        'Minimum term': '${lettings['minimumTermInMonths']} months',
      if (tenure.isNotEmpty) 'Tenure': tenure,
      if (years is num) 'Lease': '$years years remaining',
      if (service is num) 'Service charge': '£${service.round()} per annum',
      if (groundRent is num) 'Ground rent': '£${groundRent.round()} per annum',
      if (band.isNotEmpty) 'Council tax': 'Band $band',
    },
    agent: _s(_at(p, ['customer', 'branchDisplayName'])),
    phone: _s(_at(p, ['contactInfo', 'telephoneNumbers', 'localNumber'])),
  );
}

AdvertDetails parseOnTheMarketAdvert(String html) {
  final p = _at(nextData(html), ['props', 'pageProps', 'initialReduxState', 'property']);
  if (p is! Map || p['id'] == null) throw const FormatException('No advert on that OnTheMarket page');
  final facts = <String, String>{};
  for (final k in (p['keyInfo'] as List?) ?? const []) {
    if (_s(_at(k, ['title'])).isNotEmpty && _s(_at(k, ['value'])).isNotEmpty) {
      facts[_s(_at(k, ['title']))] = _s(_at(k, ['value']));
    }
  }
  final epc = _s(_at(p, ['epc', 'rating']));
  if (epc.isNotEmpty) facts['EPC'] = epc;
  final letting = [
    for (final x in (_at(p, ['lettingDetails', 'items']) as List?) ?? const []) _s(x),
  ];
  return AdvertDetails(
    description: plainText(_s(p['description'])),
    photos: [
      for (final im in (p['images'] as List?) ?? const [])
        if (_s(_at(im, ['largeUrl'])).isNotEmpty) _s(_at(im, ['largeUrl'])),
    ],
    floorplans: [
      for (final im in (p['floorplans'] as List?) ?? const [])
        if (_s(_at(im, ['largeUrl']) ?? _at(im, ['url'])).isNotEmpty)
          _s(_at(im, ['largeUrl']) ?? _at(im, ['url'])),
    ],
    features: [
      ...letting,
      for (final f in (p['features'] as List?) ?? const []) _s(_at(f, ['feature']) ?? f),
    ],
    facts: facts,
    agent: _s(_at(p, ['agent', 'name'])),
    phone: _s(_at(p, ['agent', 'telephone'])),
  );
}

AdvertDetails parsePropertyPalAdvert(String html) {
  final p = _at(nextData(html), ['props', 'pageProps', 'property']);
  if (p is! Map) throw const FormatException('No advert on that PropertyPal page');
  final l = listingFromPropertyPal(p.cast());
  return AdvertDetails(
    description: plainText(_s(p['description'])),
    photos: [
      for (final im in (p['images'] as List?) ?? const [])
        if (_s(_at(im, ['url'])).isNotEmpty) _s(_at(im, ['url'])),
    ],
    floorplans: [
      for (final im in (p['floorPlans'] as List?) ?? const [])
        if (_s(_at(im, ['url'])).isNotEmpty) _s(_at(im, ['url'])),
    ],
    features: [
      for (final a in (p['attributes'] as List?) ?? const []) _s(_at(a, ['text'])),
    ],
    facts: {
      if (l.style.isNotEmpty) 'Style': l.style,
      if (l.furnished.isNotEmpty) 'Furnishing': l.furnished,
      if (l.heating.isNotEmpty) 'Heating': l.heating,
      if (_s(l.availableFrom).isNotEmpty) 'Available': _s(l.availableFrom),
    },
    agent: l.agent,
    phone: l.agentPhone,
  );
}

AdvertDetails parseOpenRentAdvert(String html) {
  final m = RegExp(
    r'<div[^>]*class="[^"]*description[^"]*"[^>]*>([\s\S]*?)</div>',
    caseSensitive: false,
  ).firstMatch(html);
  final facts = <String, String>{};
  // Rows of "<td class="fw-medium">Deposit</td> <td>£900</td>"; ticks and
  // crosses are pictures, read from their icon's name.
  for (final r in RegExp(
    r'<td[^>]*fw-medium[^>]*>([\s\S]{1,80}?)</td>\s*<td[^>]*>([\s\S]{0,600}?)</td>',
  ).allMatches(html)) {
    final label = plainText(r.group(1)!), cell = r.group(2)!;
    var value = plainText(cell);
    if (value.isEmpty) {
      if (RegExp(r'check|tick|yes', caseSensitive: false).hasMatch(cell)) value = 'Yes';
      if (RegExp(r'cross|times|close|no\b', caseSensitive: false).hasMatch(cell)) value = 'No';
    }
    if (label.isNotEmpty && value.isNotEmpty && label.length < 40 && value != 'View Offers') {
      facts[label] = value;
    }
  }
  // The advert's gallery: every photo the page opens full size, whatever
  // folder it is in (a landlord's photos can come from older listings).
  final gallery = {
    for (final g in RegExp(
      '<a[^>]+href="((?:https:)?//imagescdn\\.openrent\\.co\\.uk/listings/\\d+/[^"]+)"[^>]*data-pswp-width',
    ).allMatches(html))
      g.group(1)!.startsWith('//') ? 'https:${g.group(1)}' : g.group(1)!,
  }.toList();
  // No gallery: the photo folder is the landlord's listing number, not the
  // advert's; the first photo on the page is the advert's own, so its
  // folder is kept and any other homes' photos further down are not.
  final all = [
    for (final p in RegExp(
      '(?:https:)?//imagescdn\\.openrent\\.co\\.uk/listings/(\\d+)/[^"\'\\s)]+',
    ).allMatches(html))
      (folder: p.group(1)!, url: p.group(0)!.startsWith('//') ? 'https:${p.group(0)}' : p.group(0)!),
  ];
  final photos = gallery.isNotEmpty
      ? gallery
      : {
          for (final p in all)
            if (p.folder == all.first.folder && !p.url.contains('_thumb')) p.url,
        }.toList();
  if (m == null && photos.isEmpty) throw const FormatException('No advert on that OpenRent page');
  return AdvertDetails(
    description: m == null ? '' : plainText(m.group(1)!),
    photos: photos,
    facts: facts,
    agent: 'Private landlord (OpenRent)',
  );
}

/// Reads [l]'s advert page for its full details. Null for sites read only
/// in the browser (Zoopla, Facebook) and adverts with no page.
Future<AdvertDetails?> readAdvert(http.Client client, Listing l) async {
  final source = SourceId.ofKey(l.source);
  final url = Uri.tryParse(l.url);
  if (source == null || source.readInBrowser || url == null || url.scheme != 'https') return null;
  if (!url.host.endsWith(source.host)) return null;
  final r = await client
      .get(url, headers: {'user-agent': userAgent, 'accept': 'text/html'})
      .timeout(const Duration(seconds: 30));
  if (r.statusCode == 403 || r.statusCode == 429) throw SourceBlocked(source, url);
  if (r.statusCode != 200) throw FormatException('${source.label} answered with error ${r.statusCode}.');
  return switch (source) {
    SourceId.rightmove => parseRightmoveAdvert(r.body),
    SourceId.onTheMarket => parseOnTheMarketAdvert(r.body),
    SourceId.propertyPal => parsePropertyPalAdvert(r.body),
    SourceId.openRent => parseOpenRentAdvert(r.body),
    SourceId.zoopla || SourceId.facebook => null,
  };
}
