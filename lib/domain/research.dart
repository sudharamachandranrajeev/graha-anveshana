import 'dart:convert';

import 'package:brahma_core/brahma_core.dart';
import 'package:http/http.dart' as http;

import 'tax.dart';

class ResearchException implements Exception, UserFacingError {
  ResearchException(this.message);
  @override
  final String message;
  @override
  String toString() => message;
}

/// Where a postcode is (postcodes.io, ONS data, all four nations).
class Place {
  const Place({
    required this.postcode,
    required this.lat,
    required this.lon,
    required this.country,
    this.district = '',
    this.ward = '',
    this.constituency = '',
    this.region = '',
  });

  final String postcode;
  final double lat, lon;
  final String country, district, ward, constituency, region;

  Nation? get nation => Nation.fromCountry(country);

  Map<String, Object?> toJson() => {
    'postcode': postcode,
    'lat': lat,
    'lon': lon,
    'country': country,
    'district': district,
    'ward': ward,
    'constituency': constituency,
    'region': region,
  };

  factory Place.fromJson(Map<String, Object?> j) => Place(
    postcode: '${j['postcode']}',
    lat: (j['lat'] as num).toDouble(),
    lon: (j['lon'] as num).toDouble(),
    country: '${j['country'] ?? ''}',
    district: '${j['district'] ?? ''}',
    ward: '${j['ward'] ?? ''}',
    constituency: '${j['constituency'] ?? ''}',
    region: '${j['region'] ?? ''}',
  );
}

/// House prices for an area from the UK House Price Index (HM Land Registry
/// with ONS, Registers of Scotland and LPS in Northern Ireland).
class PriceIndex {
  const PriceIndex({
    required this.region,
    required this.month,
    required this.average,
    this.annualChange,
    this.byType = const {},
  });
  final String region, month;
  final int average;
  final double? annualChange;

  /// Average by property type where published (detached, flat...).
  final Map<String, int> byType;

  Map<String, Object?> toJson() => {
    'region': region,
    'month': month,
    'average': average,
    'annualChange': annualChange,
    'byType': byType,
  };

  factory PriceIndex.fromJson(Map<String, Object?> j) => PriceIndex(
    region: '${j['region']}',
    month: '${j['month']}',
    average: (j['average'] as num).round(),
    annualChange: (j['annualChange'] as num?)?.toDouble(),
    byType: {for (final e in ((j['byType'] as Map?) ?? {}).entries) '${e.key}': (e.value as num).round()},
  );
}

/// A sale from HM Land Registry Price Paid (England and Wales only).
class Sale {
  const Sale({
    required this.date,
    required this.price,
    required this.address,
    this.type = '',
    this.newBuild = false,
    this.street = '',
    this.town = '',
  });
  final String date, address, type, street, town;
  final int price;
  final bool newBuild;

  Map<String, Object?> toJson() => {
    'date': date,
    'price': price,
    'address': address,
    'type': type,
    'newBuild': newBuild,
    'street': street,
    'town': town,
  };

  factory Sale.fromJson(Map<String, Object?> j) => Sale(
    date: '${j['date']}',
    price: (j['price'] as num).round(),
    address: '${j['address']}',
    type: '${j['type'] ?? ''}',
    newBuild: j['newBuild'] == true,
    street: '${j['street'] ?? ''}',
    town: '${j['town'] ?? ''}',
  );
}

/// A live flood alert or warning from the Environment Agency (England).
class FloodWarning {
  const FloodWarning({required this.area, required this.severity, required this.level});
  final String area, severity;

  /// 1 severe warning, 2 warning, 3 alert.
  final int level;

  Map<String, Object?> toJson() => {'area': area, 'severity': severity, 'level': level};

  factory FloodWarning.fromJson(Map<String, Object?> j) =>
      FloodWarning(area: '${j['area']}', severity: '${j['severity']}', level: (j['level'] as num).toInt());
}

/// What one area report holds. Saved as JSON with the area.
class AreaReport {
  const AreaReport({
    required this.place,
    this.prices,
    this.regionPrices,
    this.crimeMonth,
    this.crimes = const {},
    this.sales = const [],
    this.floods,
    this.notes = const [],
  });

  final Place place;

  /// The local authority's index and the nation's, for comparison.
  final PriceIndex? prices, regionPrices;

  /// Street-level crime within about a mile, for the latest month.
  final String? crimeMonth;
  final Map<String, int> crimes;
  final List<Sale> sales;

  /// Flood alerts in force within 5 km right now; null when not checked
  /// (outside England, or the service did not answer).
  final List<FloodWarning>? floods;

  /// What could not be fetched, and why.
  final List<String> notes;

  int get crimeTotal => crimes.values.fold(0, (a, b) => a + b);

  Map<String, Object?> toJson() => {
    'place': place.toJson(),
    'prices': prices?.toJson(),
    'regionPrices': regionPrices?.toJson(),
    'crimeMonth': crimeMonth,
    'crimes': crimes,
    'sales': [for (final s in sales) s.toJson()],
    'floods': floods == null ? null : [for (final f in floods!) f.toJson()],
    'notes': notes,
  };

  factory AreaReport.fromJson(Map<String, Object?> j) => AreaReport(
    place: Place.fromJson((j['place'] as Map).cast()),
    prices: j['prices'] is Map ? PriceIndex.fromJson((j['prices'] as Map).cast()) : null,
    regionPrices: j['regionPrices'] is Map ? PriceIndex.fromJson((j['regionPrices'] as Map).cast()) : null,
    crimeMonth: j['crimeMonth'] as String?,
    crimes: {for (final e in ((j['crimes'] as Map?) ?? {}).entries) '${e.key}': (e.value as num).toInt()},
    sales: [for (final s in (j['sales'] as List?) ?? const []) Sale.fromJson((s as Map).cast())],
    floods: j['floods'] is List
        ? [for (final f in j['floods'] as List) FloodWarning.fromJson((f as Map).cast())]
        : null,
    notes: [for (final n in (j['notes'] as List?) ?? const []) '$n'],
  );
}

/// UK HPI region slug: "Fermanagh and Omagh" -> fermanagh-and-omagh.
String hpiSlug(String name) => name
    .toLowerCase()
    .replaceAll('&', 'and')
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-|-$'), '');

const _types = {
  'averagePriceDetached': 'Detached',
  'averagePriceSemiDetached': 'Semi-detached',
  'averagePriceTerraced': 'Terraced',
  'averagePriceFlatMaisonette': 'Flat or maisonette',
  'averagePriceFirstTimeBuyer': 'First-time buyers',
};

const _months = {
  'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6, //
  'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
};

/// "Tue, 29 May 2018" -> 2018-05-29.
String landRegistryDate(String s) {
  final m = RegExp(r'(\d{1,2}) (\w{3}) (\d{4})').firstMatch(s);
  if (m == null) return s;
  final month = _months[m.group(2)] ?? 1;
  return '${m.group(3)}-${month.toString().padLeft(2, '0')}-${m.group(1)!.padLeft(2, '0')}';
}

/// Fetches open data about a place. Every source is free and needs no key.
class Research {
  Research({http.Client? client, DateTime Function()? now})
    : _http = client ?? http.Client(),
      _now = now ?? DateTime.now;
  final http.Client _http;
  final DateTime Function() _now;

  Future<Object?> _get(Uri u) async {
    final res = await _http
        .get(u, headers: {'accept': 'application/json'})
        .timeout(const Duration(seconds: 30));
    if (res.statusCode == 404) return null;
    if (res.statusCode >= 400) throw ResearchException('${u.host} said ${res.statusCode}');
    return jsonDecode(res.body);
  }

  Future<Place> place(String postcode) async {
    // Uri encodes the path itself; encoding the postcode first sent "%2520".
    final body = await _get(
      Uri(scheme: 'https', host: 'api.postcodes.io', pathSegments: ['postcodes', postcode.trim()]),
    );
    final r = (body as Map?)?['result'] as Map?;
    if (r == null) throw ResearchException('$postcode is not a known postcode');
    return Place(
      postcode: '${r['postcode']}',
      lat: (r['latitude'] as num).toDouble(),
      lon: (r['longitude'] as num).toDouble(),
      country: '${r['country'] ?? ''}',
      district: '${r['admin_district'] ?? ''}',
      ward: '${r['admin_ward'] ?? ''}',
      constituency: '${r['parliamentary_constituency'] ?? ''}',
      region: '${r['region'] ?? ''}',
    );
  }

  /// The latest published month of the UK HPI for [region]; the index runs
  /// about two months behind, so it steps back until a month has data.
  Future<PriceIndex?> priceIndex(String region) async {
    final slug = hpiSlug(region);
    var month = DateTime(_now().year, _now().month);
    for (var tries = 0; tries < 6; tries++) {
      final ym = '${month.year}-${month.month.toString().padLeft(2, '0')}';
      final body = await _get(
        Uri.https('landregistry.data.gov.uk', '/data/ukhpi/region/$slug/month/$ym.json'),
      );
      // A month with no data answers "elda:missingEndpoint", a string.
      final t = (((body as Map?)?['result'] as Map?)?['primaryTopic']);
      if (t is Map && t['averagePrice'] is num) {
        return PriceIndex(
          region: region,
          month: ym,
          average: (t['averagePrice'] as num).round(),
          annualChange: (t['percentageAnnualChange'] as num?)?.toDouble(),
          byType: {
            for (final e in _types.entries)
              if (t[e.key] is num) e.value: (t[e.key] as num).round(),
          },
        );
      }
      month = DateTime(month.year, month.month - 1);
    }
    return null;
  }

  /// Street-level crime around a point for the latest month (England, Wales
  /// and Northern Ireland; Scotland's police do not publish to it).
  Future<({String? month, Map<String, int> counts})> crime(double lat, double lon) async {
    final body = await _get(
      Uri.https('data.police.uk', '/api/crimes-street/all-crime', {'lat': '$lat', 'lng': '$lon'}),
    );
    final counts = <String, int>{};
    String? month;
    for (final c in (body as List?) ?? const []) {
      final cat = '${(c as Map)['category']}'.replaceAll('-', ' ');
      counts[cat] = (counts[cat] ?? 0) + 1;
      month ??= c['month'] as String?;
    }
    return (month: month, counts: counts);
  }

  /// Flood alerts and warnings in force within [km] of a point (England; the
  /// Environment Agency, free, no key). Warnings no longer in force are left out.
  Future<List<FloodWarning>> floods(double lat, double lon, {int km = 5}) async {
    final body = await _get(
      Uri.https('environment.data.gov.uk', '/flood-monitoring/id/floods', {
        'lat': '$lat',
        'long': '$lon',
        'dist': '$km',
      }),
    );
    return [
      for (final i in (((body as Map?)?['items'] as List?) ?? const []).cast<Map>())
        if (num.tryParse('${i['severityLevel']}') case final l? when l >= 1 && l <= 3)
          FloodWarning(
            area: '${(i['floodArea'] as Map?)?['county'] ?? ''} ${i['description'] ?? ''}'.trim(),
            severity: '${i['severity'] ?? ''}',
            level: l.toInt(),
          ),
    ]..sort((a, b) => a.level.compareTo(b.level));
  }

  /// Recent sales in a postcode from Price Paid, newest first.
  Future<List<Sale>> sales(String postcode) =>
      _sales({'propertyAddress.postcode': postcode.toUpperCase(), '_pageSize': '50'});

  /// Sales on one street from Price Paid, newest first: a postcode holds
  /// only about fifteen homes, too few to compare a price with.
  Future<List<Sale>> salesOnStreet(String street, String town) => _sales({
    'propertyAddress.street': street.toUpperCase(),
    'propertyAddress.town': town.toUpperCase(),
    '_pageSize': '100',
    '_sort': '-transactionDate',
  });

  Future<List<Sale>> _sales(Map<String, String> query) async {
    final body = await _get(
      Uri.https('landregistry.data.gov.uk', '/data/ppi/transaction-record.json', query),
    );
    final items = (((body as Map?)?['result'] as Map?)?['items'] as List?) ?? const [];
    String label(Object? o) => switch (o) {
      [{'_value': final String v}, ...] => v,
      {'prefLabel': [{'_value': final String v}, ...]} => v,
      _ => '',
    };
    final out = [
      for (final i in items.cast<Map>())
        Sale(
          date: landRegistryDate('${i['transactionDate']}'),
          price: (i['pricePaid'] as num).round(),
          address: [
            for (final k in ['saon', 'paon', 'street', 'town'])
              if ((i['propertyAddress'] as Map?)?[k] case final String v when v.isNotEmpty) v,
          ].join(', '),
          type: label(i['propertyType']),
          newBuild: i['newBuild'] == true,
          street: '${(i['propertyAddress'] as Map?)?['street'] ?? ''}',
          town: '${(i['propertyAddress'] as Map?)?['town'] ?? ''}',
        ),
    ]..sort((a, b) => b.date.compareTo(a.date));
    return out;
  }

  /// Everything for one postcode. A source that fails leaves a note
  /// instead of failing the report.
  Future<AreaReport> report(String postcode) async {
    final p = await place(postcode);
    final notes = <String>[];
    Future<T?> attempt<T>(String what, Future<T> Function() f) async {
      try {
        return await f();
      } catch (e) {
        notes.add('$what: ${describeError(e)}');
        return null;
      }
    }

    final national = switch (p.nation) {
      Nation.england => 'England',
      Nation.wales => 'Wales',
      Nation.scotland => 'Scotland',
      Nation.northernIreland => 'Northern Ireland',
      null => 'United Kingdom',
    };
    final local = p.district.isEmpty ? null : await attempt('House prices', () => priceIndex(p.district));
    final region = await attempt('National prices', () => priceIndex(national));
    final crimes = p.nation == Nation.scotland ? null : await attempt('Crime', () => crime(p.lat, p.lon));
    final sold = p.nation == Nation.england || p.nation == Nation.wales
        ? await attempt('Sold prices', () => sales(p.postcode))
        : null;
    final alerts = p.nation == Nation.england
        ? await attempt('Flood warnings', () => floods(p.lat, p.lon))
        : null;
    if (p.nation == Nation.scotland) notes.add('Crime: Police Scotland does not publish street-level data');
    if (p.nation == Nation.northernIreland || p.nation == Nation.scotland) {
      notes.add('Sold prices: Price Paid covers England and Wales only. See the links for $national.');
    }
    return AreaReport(
      place: p,
      prices: local,
      regionPrices: region,
      crimeMonth: crimes?.month,
      crimes: crimes?.counts ?? const {},
      sales: sold ?? const [],
      floods: alerts,
      notes: notes,
    );
  }
}

/// Where to look further, by nation.
List<({String label, Uri url})> researchLinks(Place p) {
  final pc = Uri.encodeComponent(p.postcode);
  return [
    (
      label: 'Flood risk',
      url: switch (p.nation) {
        Nation.northernIreland => Uri.parse('https://dfi-ni.maps.arcgis.com/apps/webappviewer/index.html'),
        Nation.scotland => Uri.parse('https://map.sepa.org.uk/floodmaps'),
        Nation.wales => Uri.parse('https://flood-risk-maps.naturalresources.wales/'),
        _ => Uri.parse('https://check-long-term-flood-risk.service.gov.uk/postcode'),
      },
    ),
    (
      label: 'Energy certificates (EPC)',
      url: switch (p.nation) {
        Nation.northernIreland => Uri.parse('https://www.epbniregister.com/'),
        Nation.scotland => Uri.parse('https://www.scottishepcregister.org.uk/'),
        _ => Uri.parse(
          'https://find-energy-certificate.service.gov.uk/find-a-certificate/search-by-postcode?postcode=$pc',
        ),
      },
    ),
    (
      label: 'Planning applications',
      url: switch (p.nation) {
        Nation.northernIreland => Uri.parse('https://planningregister.planningsystemni.gov.uk/'),
        Nation.scotland => Uri.parse('https://www.gov.scot/collections/planning-applications/'),
        _ => Uri.parse('https://www.planning.data.gov.uk/'),
      },
    ),
    (label: 'Broadband and mobile', url: Uri.parse('https://checker.ofcom.org.uk/en-gb/broadband-coverage')),
    (label: 'Sold prices nearby (PropertyPal)', url: Uri.parse('https://www.propertypal.com/house-prices')),
    if (p.nation == Nation.northernIreland)
      (
        label: 'NI house price index (LPS)',
        url: Uri.parse(
          'https://www.finance-ni.gov.uk/topics/statistics-and-research/northern-ireland-house-price-index',
        ),
      ),
    (
      label: 'Private rents (ONS)',
      url: Uri.parse(
        'https://www.ons.gov.uk/economy/inflationandpriceindices/bulletins/privaterentandhousepricesuk/latest',
      ),
    ),
  ];
}
