/// Reads one advert page the user has open in the app's browser and tapped
/// Save on: its photos, price, bedrooms and address. Portals change their
/// pages often, so it tries, in order: the page's structured data
/// (schema.org JSON-LD and the JSON the page is built from), photos on the
/// portal's own image server, then the page's title and preview tags.
/// Whatever it misses, the user types in.
library;

import 'dart:convert';

import 'listing.dart';
import 'portals.dart';

/// The advert on [html], the page of [advert]. Throws FormatException when the
/// page is not an advert (a search page, a login or a bot check).
Listing listingFromAdvertPage(PortalAdvert advert, String html) {
  final blobs = _jsonBlobs(html);
  final title = _unescape(_meta(html, 'og:title') ?? _title(html) ?? '');
  final description = _unescape(_meta(html, 'og:description') ?? _meta(html, 'description') ?? '');
  final words = '$title $description';

  final photos = _photos(advert, html, blobs);
  final price = _firstNum(blobs, const ['price', 'primaryPrice', 'amount']) ?? _priceIn(words);
  final beds =
      _firstNum(blobs, const ['numberOfBedrooms', 'bedrooms', 'numBedrooms', 'beds', 'num_beds'])?.toInt() ??
      _bedsIn(words);
  final address = _address(blobs) ?? _addressIn(title) ?? advert.address;
  if (photos.isEmpty && price == null) {
    throw const FormatException('This page has no advert to save. Open the advert itself, then tap Save.');
  }
  final rent = _isRent(advert, words, html);
  return Listing(
    source: advert.portal.name,
    sourceId: advert.id,
    url: advert.url.toString(),
    address: address.isEmpty ? advert.portal.label : address,
    postcode: postcodeIn(address) ?? postcodeIn(words) ?? '',
    price: price?.round(),
    priceSuffix: rent ? 'per month' : '',
    beds: beds,
    lat: _firstNum(blobs, const ['latitude', 'lat'])?.toDouble(),
    lon: _firstNum(blobs, const ['longitude', 'lng', 'lon'])?.toDouble(),
    images: photos,
    status: rent ? 'toLet' : 'forSale',
    description: description,
  );
}

const _maxPhotos = 60;

List<String> _photos(PortalAdvert advert, String html, List<Object?> blobs) {
  final out = <String>{};
  void add(String? u) {
    if (u == null) return;
    var url = _unescape(u.trim());
    if (url.startsWith('//')) url = 'https:$url';
    if (url.startsWith('http://')) url = 'https://${url.substring(7)}';
    if (!url.startsWith('https://') || _notPhoto.hasMatch(url)) return;
    if (!_belongs(advert, url)) return;
    if (out.length < _maxPhotos) out.add(url);
  }

  // 1. Structured data: the longest photo list wins (the gallery, not a
  //    "similar homes" strip), then JSON-LD image fields.
  final lists = <List<String>>[];
  for (final b in blobs) {
    _walk(b, (key, value) {
      if (value is List && const {'images', 'photos', 'propertyImages', 'image', 'media'}.contains(key)) {
        final urls = [for (final i in value) ?_imageUrl(i)];
        if (urls.isNotEmpty) lists.add(urls);
      } else if (key == 'image' && value is String) {
        lists.add([value]);
      }
    });
  }
  lists.sort((a, b) => b.length.compareTo(a.length));
  lists.firstOrNull?.forEach(add);

  // 2. Photos on the portal's image server, when it names the advert.
  if (out.length < 2) {
    if (_cdnPattern(advert) case final re?) {
      for (final m in re.allMatches(html)) {
        add(m.group(0));
      }
    }
  }

  // 3. The preview photo.
  if (out.isEmpty) {
    for (final m in _ogImage.allMatches(html)) {
      add(m.group(1));
    }
  }
  return out.toList();
}

final _notPhoto = RegExp(
  r'logo|icon|sprite|placeholder|staticmap|floorplan|/maps?/|\.svg',
  caseSensitive: false,
);
final _ogImage = RegExp(r'''<meta[^>]+property=["']og:image(?::url)?["'][^>]+content=["']([^"']+)''');

/// Photo servers that put the advert's number in the path, so photos of
/// other homes on the same page are left out.
RegExp? _cdnPattern(PortalAdvert a) => switch (a.portal) {
  Portal.openRent => RegExp('(?:https?:)?//imagescdn\\.openrent\\.co\\.uk/listings/${a.id}/[^"\'\\s)<>]+'),
  Portal.rightmove => RegExp('https?://media\\.rightmove\\.co\\.uk/[^"\'\\s)<>]*/${a.id}/[^"\'\\s)<>]+'),
  Portal.onTheMarket => RegExp('https?://media\\.onthemarket\\.com/properties/${a.id}/[^"\'\\s)<>]+'),
  _ => null,
};

/// False for a photo that names another advert on a server that numbers them.
bool _belongs(PortalAdvert a, String url) => switch (a.portal) {
  Portal.openRent when url.contains('/listings/') => url.contains('/listings/${a.id}/'),
  Portal.onTheMarket when url.contains('/properties/') => url.contains('/properties/${a.id}/'),
  _ => true,
};

String? _imageUrl(Object? i) => switch (i) {
  final String s when _looksLikeUrl(s) => s,
  {'url': final String s} when _looksLikeUrl(s) => s,
  {'contentUrl': final String s} when _looksLikeUrl(s) => s,
  {'src': final String s} when _looksLikeUrl(s) => s,
  {'original': final String s} when _looksLikeUrl(s) => s,
  {'large': final String s} when _looksLikeUrl(s) => s,
  _ => null,
};

bool _looksLikeUrl(String s) => s.startsWith('http') || s.startsWith('//');

/// JSON-LD blocks, Next.js data and Rightmove's PAGE_MODEL.
List<Object?> _jsonBlobs(String html) {
  final out = <Object?>[];
  void decode(String text) {
    try {
      out.add(jsonDecode(text));
    } on FormatException {
      // Not JSON after all; the other sources still count.
    }
  }

  for (final m in RegExp(
    r'''<script[^>]+type=["']application/ld\+json["'][^>]*>([\s\S]*?)</script>''',
  ).allMatches(html)) {
    decode(m.group(1)!);
  }
  for (final m in RegExp(r'<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)</script>').allMatches(html)) {
    decode(m.group(1)!);
  }
  for (final m in RegExp(r'window\.(?:PAGE_MODEL|__PRELOADED_STATE__|adInfo)\s*=\s*').allMatches(html)) {
    if (_balanced(html, m.end) case final text?) decode(text);
  }
  return out;
}

/// The JSON object starting at [start], by matching braces outside strings.
String? _balanced(String s, int start) {
  if (start >= s.length || s[start] != '{') return null;
  var depth = 0;
  var inString = false;
  for (var i = start; i < s.length; i++) {
    final c = s[i];
    if (inString) {
      if (c == r'\') {
        i++;
      } else if (c == '"') {
        inString = false;
      }
    } else if (c == '"') {
      inString = true;
    } else if (c == '{') {
      depth++;
    } else if (c == '}' && --depth == 0) {
      return s.substring(start, i + 1);
    }
  }
  return null;
}

void _walk(Object? node, void Function(String key, Object? value) visit) {
  if (node is Map) {
    for (final e in node.entries) {
      visit('${e.key}', e.value);
      _walk(e.value, visit);
    }
  } else if (node is List) {
    for (final v in node) {
      _walk(v, visit);
    }
  }
}

/// The first number under any of [keys], as a number or text like "£1,100 pcm".
num? _firstNum(List<Object?> blobs, List<String> keys) {
  for (final k in keys) {
    num? found;
    for (final b in blobs) {
      _walk(b, (key, value) {
        if (found != null || key != k) return;
        found = switch (value) {
          final num n when n > 0 => n,
          final String s => num.tryParse(s.replaceAll(RegExp(r'[£,\s]'), '')) ?? _priceIn(s),
          {'amount': final num n} when n > 0 => n,
          _ => null,
        };
      });
    }
    if (found != null) return found;
  }
  return null;
}

String? _address(List<Object?> blobs) {
  String? found;
  for (final b in blobs) {
    _walk(b, (key, value) {
      if (found != null) return;
      if (key == 'displayAddress' && value is String && value.trim().isNotEmpty) {
        found = value.trim();
      } else if (key == 'address' && value is Map) {
        final parts = [
          for (final k in const ['streetAddress', 'addressLocality', 'postalCode'])
            if (value[k] case final String v when v.trim().isNotEmpty) v.trim(),
        ];
        if (parts.isNotEmpty) found = parts.join(', ');
      } else if (key == 'address' && value is String && value.contains(',')) {
        found = value.trim();
      }
    });
    if (found != null) break;
  }
  return found;
}

final _price = RegExp(
  r'£\s*([\d,]+(?:\.\d{1,2})?)\s*(pcm|p/m|pm|per month|a month|pw|p/w|per week|a week)?',
  caseSensitive: false,
);

num? _priceIn(String text) {
  final m = _price.firstMatch(text);
  if (m == null) return null;
  final n = num.tryParse(m.group(1)!.replaceAll(',', ''));
  if (n == null) return null;
  final weekly = RegExp(r'w', caseSensitive: false).hasMatch(m.group(2) ?? '');
  return weekly ? n * 52 / 12 : n;
}

int? _bedsIn(String text) =>
    int.tryParse(RegExp(r'(\d+)\s*-?\s*bed', caseSensitive: false).firstMatch(text)?.group(1) ?? '');

/// The part of a title like "Leeds - 2 Bed Terraced House, Kepler Grove, LS8 -
/// To Rent Now for £925.00 p/m" that reads like an address.
String? _addressIn(String title) {
  for (final part in title.split(RegExp(r'\s+[-|–]\s+'))) {
    if (!part.contains(',') || part.contains('£')) continue;
    // Drop "2 Bed Terraced House, " in front of the street.
    final street = part.replaceFirst(RegExp(r'^\s*\d+\s*bed[^,]*,\s*', caseSensitive: false), '');
    return street.trim();
  }
  return null;
}

bool _isRent(PortalAdvert a, String words, String html) {
  if (a.portal.lettingsOnly) return true;
  final path = a.url.path;
  if (path.contains('to-rent') || path.contains('rent')) return true;
  if (path.contains('for-sale') || path.contains('sale')) return false;
  return RegExp(r'to rent|to let|pcm|p/m|per month|propertyrentals', caseSensitive: false).hasMatch(words) ||
      html.contains('"transactionType":"RENT"') ||
      html.contains('"channel":"RES_LET"');
}

String? _meta(String html, String name) => RegExp(
  '<meta[^>]+(?:property|name)=["\']${RegExp.escape(name)}["\'][^>]+content=["\']([^"\']*)',
  caseSensitive: false,
).firstMatch(html)?.group(1);

String? _title(String html) => RegExp(r'<title[^>]*>([^<]*)').firstMatch(html)?.group(1)?.trim();

String _unescape(String s) => s
    .replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (m) => String.fromCharCode(int.parse(m[1]!, radix: 16)))
    .replaceAllMapped(RegExp(r'&#(\d+);'), (m) => String.fromCharCode(int.parse(m[1]!)))
    .replaceAll('&amp;', '&')
    .replaceAll('&quot;', '"')
    .replaceAll('&#39;', "'")
    .replaceAll('&apos;', "'")
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>');
