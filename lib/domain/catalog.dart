import 'dart:convert';

import 'listing.dart';

/// Researches and their catalogs: reading details out of captured text,
/// finding the same home captured twice, and how well an item fits.

/// What a research is looking for. Every part is optional.
class ResearchCriteria {
  const ResearchCriteria({
    this.place = '',
    this.lat,
    this.lon,
    this.radiusKm,
    this.maxPrice,
    this.minBeds,
    this.words = '',
  });

  /// A postcode or place name, for the record ([lat]/[lon] do the measuring).
  final String place;
  final double? lat, lon, radiusKm;
  final int? maxPrice, minBeds;

  /// Words an item should mention; "-word" for words it must not.
  final String words;

  factory ResearchCriteria.fromJson(String json) {
    final j = (jsonDecode(json.isEmpty ? '{}' : json) as Map).cast<String, Object?>();
    return ResearchCriteria(
      place: '${j['place'] ?? ''}',
      lat: (j['lat'] as num?)?.toDouble(),
      lon: (j['lon'] as num?)?.toDouble(),
      radiusKm: (j['radiusKm'] as num?)?.toDouble(),
      maxPrice: (j['maxPrice'] as num?)?.toInt(),
      minBeds: (j['minBeds'] as num?)?.toInt(),
      words: '${j['words'] ?? ''}',
    );
  }

  String toJson() => jsonEncode({
    if (place.isNotEmpty) 'place': place,
    'lat': ?lat,
    'lon': ?lon,
    'radiusKm': ?radiusKm,
    'maxPrice': ?maxPrice,
    'minBeds': ?minBeds,
    if (words.isNotEmpty) 'words': words,
  });

  bool get isEmpty => radiusKm == null && maxPrice == null && minBeds == null && words.trim().isEmpty;
}

/// The details read from an advert's text, a page or a picture of one.
class ItemFields {
  const ItemFields({
    this.address = '',
    this.postcode = '',
    this.price,
    this.period = '',
    this.beds,
    this.baths,
    this.councilTaxBand = '',
    this.epc = '',
    this.phone = '',
    this.agent = '',
    this.availableFrom = '',
    this.status = '',
    this.furnished = '',
  });

  final String address, postcode;
  final int? price;

  /// pcm, pw or '' (a sale price).
  final String period;
  final int? beds, baths;
  final String councilTaxBand, epc, phone, agent, availableFrom, status, furnished;

  /// A weekly rent as a monthly one (52 weeks over 12 months).
  int? get monthly => price == null ? null : (period == 'pw' ? (price! * 52 / 12).round() : price);

  /// The extras that go in a catalog item's `fields` column.
  Map<String, Object?> get extras => {
    if (period.isNotEmpty) 'period': period,
    if (councilTaxBand.isNotEmpty) 'councilTaxBand': councilTaxBand,
    if (epc.isNotEmpty) 'epc': epc,
    if (phone.isNotEmpty) 'phone': phone,
    if (agent.isNotEmpty) 'agent': agent,
    if (availableFrom.isNotEmpty) 'availableFrom': availableFrom,
    if (status.isNotEmpty) 'status': status,
    if (furnished.isNotEmpty) 'furnished': furnished,
  };

  /// Fills what this lacks from [other] (this one wins where both have it).
  ItemFields over(ItemFields other) => ItemFields(
    address: address.isNotEmpty ? address : other.address,
    postcode: postcode.isNotEmpty ? postcode : other.postcode,
    price: price ?? other.price,
    period: price != null ? period : other.period,
    beds: beds ?? other.beds,
    baths: baths ?? other.baths,
    councilTaxBand: councilTaxBand.isNotEmpty ? councilTaxBand : other.councilTaxBand,
    epc: epc.isNotEmpty ? epc : other.epc,
    phone: phone.isNotEmpty ? phone : other.phone,
    agent: agent.isNotEmpty ? agent : other.agent,
    availableFrom: availableFrom.isNotEmpty ? availableFrom : other.availableFrom,
    status: status.isNotEmpty ? status : other.status,
    furnished: furnished.isNotEmpty ? furnished : other.furnished,
  );

  bool get isEmpty => address.isEmpty && postcode.isEmpty && price == null && beds == null;

  factory ItemFields.fromJson(Map<String, Object?> j) => ItemFields(
    address: '${j['address'] ?? ''}',
    postcode: '${j['postcode'] ?? ''}',
    price: (j['price'] as num?)?.toInt(),
    period: '${j['period'] ?? ''}',
    beds: (j['beds'] as num?)?.toInt(),
    baths: (j['baths'] as num?)?.toInt(),
    councilTaxBand: '${j['councilTaxBand'] ?? ''}',
    epc: '${j['epc'] ?? ''}',
    phone: '${j['phone'] ?? ''}',
    agent: '${j['agent'] ?? ''}',
    availableFrom: '${j['availableFrom'] ?? ''}',
    status: '${j['status'] ?? ''}',
    furnished: '${j['furnished'] ?? ''}',
  );
}

final _money = RegExp(
  r'£\s?(\d{1,3}(?:,\d{3})+|\d+)(?:\.\d{2})?\s*(k\b)?\s*(pcm|per calendar month|per month|a month|/\s?month|p/?m\b|pw|per week|a week|/\s?week|p/?w\b)?',
  caseSensitive: false,
);
final _beds = RegExp(
  r'\b(\d{1,2}|one|two|three|four|five|six)[\s-]*(?:bed(?:room)?s?|br)\b',
  caseSensitive: false,
);
final _studio = RegExp(r'\bstudio\b', caseSensitive: false);
final _baths = RegExp(r'\b(\d)[\s-]*(?:bath(?:room)?s?)\b', caseSensitive: false);
final _band = RegExp(r'council tax\s*(?:band)?\s*[:\-]?\s*(?:band\s*)?([A-I])\b', caseSensitive: false);
final _epc = RegExp(
  r'\bEPC\s*(?:rating|band|grade)?\s*[:\-]?\s*([A-G])\b(?:\s*\(?\d{1,3}\)?)?',
  caseSensitive: false,
);
final _phone = RegExp(r'(?:\+44\s?\(?0?\)?|\b0)(?:\d[\s-]?){9,10}\b');
final _available = RegExp(
  r'available\s*(?:from)?\s*[:\-]?\s*(now|immediately|\d{1,2}(?:st|nd|rd|th)?\s+[A-Za-z]{3,9}(?:\s+\d{4})?|\d{1,2}/\d{1,2}/\d{2,4})',
  caseSensitive: false,
);
final _furnished = RegExp(r'\b(unfurnished|part[\s-]furnished|furnished)\b', caseSensitive: false);
final _agent = RegExp(r'(?:marketed by|listed by|agent)\s*[:\-]?\s*([A-Z][\w&\x27 ]{2,40}?)(?:[\n,.]|$)');
const _numberWords = {'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5, 'six': 6};

/// The advert's state, from words that say it is gone.
String _statusIn(String t) {
  final s = t.toLowerCase();
  if (s.contains('let agreed')) return 'letAgreed';
  if (RegExp(r'\bsold stc\b|\bsale agreed\b|\bunder offer\b').hasMatch(s)) return 'saleAgreed';
  if (RegExp(r'\bsold\b').hasMatch(s) && !s.contains('sold by')) return 'sold';
  if (RegExp(r'\bto let\b|\bto rent\b|\bfor rent\b').hasMatch(s)) return 'toLet';
  if (s.contains('for sale')) return 'forSale';
  return '';
}

/// The first line that looks like an address: has a postcode, or a number
/// and a street word.
String _addressIn(String text, String postcode) {
  final street = RegExp(
    r'\b(road|rd|street|st|avenue|ave|lane|drive|close|park|gardens|court|crescent|place|terrace|way|hill|square|row|walk|view)\b',
    caseSensitive: false,
  );
  for (final raw in const LineSplitter().convert(text)) {
    final line = raw.trim();
    if (line.length < 6 || line.length > 120 || line.contains('£')) continue;
    if (postcode.isNotEmpty &&
        line.toUpperCase().replaceAll(' ', '').contains(postcode.replaceAll(' ', ''))) {
      return line;
    }
  }
  for (final raw in const LineSplitter().convert(text)) {
    final line = raw.trim();
    if (line.length < 6 || line.length > 120 || line.contains('£')) continue;
    if (street.hasMatch(line) &&
        RegExp(r'^\s*(apt|apartment|flat|unit)?\s*\d').hasMatch(line.toLowerCase())) {
      return line;
    }
  }
  return '';
}

/// Reads an advert's details out of plain text: a page's words, OCR of a
/// screenshot or brochure, or an alert email. Takes the first of each.
ItemFields readFields(String text) {
  final postcode = postcodeIn(text) ?? '';
  int? price;
  var period = '';
  for (final m in _money.allMatches(text)) {
    var n = int.parse(m[1]!.replaceAll(',', ''));
    if (m[2] != null) n *= 1000;
    if (n < 50) continue; // "£5 off", fees
    price = n;
    final p = (m[3] ?? '').toLowerCase();
    period = p.isEmpty ? '' : (p.contains('w') ? 'pw' : 'pcm');
    break;
  }
  int? beds;
  final b = _beds.firstMatch(text);
  if (b != null) {
    beds = int.tryParse(b[1]!) ?? _numberWords[b[1]!.toLowerCase()];
  } else if (_studio.hasMatch(text)) {
    beds = 0;
  }
  final phone = _phone.firstMatch(text)?[0]?.replaceAll(RegExp(r'[\s-]'), '') ?? '';
  final f = _furnished.firstMatch(text)?[1]?.toLowerCase() ?? '';
  return ItemFields(
    address: _addressIn(text, postcode),
    postcode: postcode,
    price: price,
    period: period,
    beds: beds,
    baths: int.tryParse(_baths.firstMatch(text)?[1] ?? ''),
    councilTaxBand: _band.firstMatch(text)?[1]?.toUpperCase() ?? '',
    epc: _epc.firstMatch(text)?[1]?.toUpperCase() ?? '',
    phone: phone,
    agent: _agent.firstMatch(text)?[1]?.trim() ?? '',
    availableFrom: _available.firstMatch(text)?[1]?.trim() ?? '',
    status: _statusIn(text),
    furnished: f.startsWith('part') ? 'part' : f,
  );
}

/// An address made comparable: lower case, no punctuation, common words
/// shortened ("Flat 2, 11 East Bridge Street" = "flat 2 11 east bridge st").
String normaliseAddress(String address) {
  const short = {
    'street': 'st',
    'road': 'rd',
    'avenue': 'ave',
    'apartment': 'flat',
    'apt': 'flat',
    'drive': 'dr',
    'lane': 'ln',
    'close': 'cl',
    'crescent': 'cres',
    'gardens': 'gdns',
    'court': 'ct',
    'place': 'pl',
    'terrace': 'ter',
    'square': 'sq',
    'number': '',
    'no': '',
  };
  final words = address.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), ' ').split(RegExp(r'\s+'));
  return [
    for (final w in words)
      if (w.isNotEmpty && (short[w] ?? w).isNotEmpty) short[w] ?? w,
  ].join(' ');
}

/// What duplicate checks look at, from a catalog row or a Hunt home.
class ItemKey {
  const ItemKey({
    required this.id,
    this.url = '',
    this.source = '',
    this.sourceId,
    this.address = '',
    this.postcode = '',
    this.price,
    this.beds,
    this.imageHash,
  });
  final String id, url, source, address, postcode;
  final String? sourceId, imageHash;
  final int? price, beds;
}

/// How sure a match is, strongest first.
enum MatchReason {
  sameAdvert('Same advert'),
  sameAddress('Same address'),
  samePicture('Same main photo'),
  similar('Same postcode, bedrooms and price');

  const MatchReason(this.label);
  final String label;
}

/// Bits that differ between two 64-bit picture hashes (hex), or null when
/// either is missing or unreadable.
int? hashDistance(String? a, String? b) {
  if (a == null || b == null || a.length != b.length) return null;
  final x = BigInt.tryParse(a, radix: 16), y = BigInt.tryParse(b, radix: 16);
  if (x == null || y == null) return null;
  var d = x ^ y, n = 0;
  while (d > BigInt.zero) {
    if ((d & BigInt.one) == BigInt.one) n++;
    d >>= 1;
  }
  return n;
}

String _cleanUrl(String url) {
  final u = Uri.tryParse(url.trim());
  if (u == null || u.host.isEmpty) return '';
  return '${u.host.replaceFirst('www.', '')}${u.path.replaceAll(RegExp(r'/+$'), '')}'.toLowerCase();
}

/// Why [a] and [b] look like the same home, or null.
MatchReason? sameHome(ItemKey a, ItemKey b) {
  if (a.sourceId != null && a.sourceId!.isNotEmpty && a.source == b.source && a.sourceId == b.sourceId) {
    return MatchReason.sameAdvert;
  }
  final ua = _cleanUrl(a.url);
  if (ua.isNotEmpty && ua == _cleanUrl(b.url)) return MatchReason.sameAdvert;
  final pa = a.postcode.replaceAll(' ', '').toUpperCase(), pb = b.postcode.replaceAll(' ', '').toUpperCase();
  final na = normaliseAddress(a.address), nb = normaliseAddress(b.address);
  if (na.isNotEmpty && na == nb && (pa.isEmpty || pb.isEmpty || pa == pb) && RegExp(r'\d').hasMatch(na)) {
    return MatchReason.sameAddress;
  }
  final d = hashDistance(a.imageHash, b.imageHash);
  if (d != null && d <= 6) return MatchReason.samePicture;
  if (pa.isNotEmpty && pa == pb && a.beds != null && a.beds == b.beds && a.price != null && b.price != null) {
    final hi = a.price! > b.price! ? a.price! : b.price!;
    if ((a.price! - b.price!).abs() <= hi * 0.05) return MatchReason.similar;
  }
  return null;
}

/// A likely duplicate: [keep] is the one captured first.
typedef DuplicatePair = ({ItemKey keep, ItemKey drop, MatchReason reason});

/// Every pair in [items] that looks like the same home, strongest first.
/// [items] is in capture order, so the earlier one is kept.
List<DuplicatePair> findDuplicates(List<ItemKey> items) {
  final pairs = <DuplicatePair>[];
  for (var i = 0; i < items.length; i++) {
    for (var j = i + 1; j < items.length; j++) {
      final r = sameHome(items[i], items[j]);
      if (r != null) pairs.add((keep: items[i], drop: items[j], reason: r));
    }
  }
  pairs.sort((a, b) => a.reason.index.compareTo(b.reason.index));
  return pairs;
}

/// How well an item fits a research, 0 to 1, with the reasons it misses.
/// Unknown details neither help nor count against.
({double score, List<String> misses}) fit(
  ResearchCriteria c, {
  int? monthlyOrPrice,
  int? beds,
  double? km,
  String text = '',
}) {
  if (c.isEmpty) return (score: 1, misses: const []);
  var checks = 0, passed = 0;
  final misses = <String>[];
  void check(bool? ok, String miss) {
    if (ok == null) return;
    checks++;
    ok ? passed++ : misses.add(miss);
  }

  if (c.maxPrice != null) {
    check(monthlyOrPrice == null ? null : monthlyOrPrice <= c.maxPrice!, 'over £${c.maxPrice}');
  }
  if (c.minBeds != null) check(beds == null ? null : beds >= c.minBeds!, 'fewer than ${c.minBeds} bedrooms');
  if (c.radiusKm != null) {
    check(km == null ? null : km <= c.radiusKm!, 'more than ${c.radiusKm!.toStringAsFixed(1)} km away');
  }
  final lower = text.toLowerCase();
  for (final w in c.words.split(RegExp(r'[\s,]+')).where((w) => w.isNotEmpty)) {
    if (w.startsWith('-') && w.length > 1) {
      check(!lower.contains(w.substring(1).toLowerCase()), 'mentions "${w.substring(1)}"');
    } else {
      check(lower.contains(w.toLowerCase()), 'does not mention "$w"');
    }
  }
  return (score: checks == 0 ? 1 : passed / checks, misses: misses);
}
