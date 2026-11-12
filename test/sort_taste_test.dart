import 'dart:convert';

import 'package:anveshana/db/database.dart';
import 'package:anveshana/domain/hunt_filter.dart';
import 'package:anveshana/domain/listing.dart';
import 'package:anveshana/domain/page_reader.dart';
import 'package:anveshana/domain/property_search.dart';
import 'package:anveshana/domain/research.dart';
import 'package:anveshana/domain/search_request.dart';
import 'package:anveshana/domain/sources.dart';
import 'package:anveshana/domain/taste.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

FoundHome _home(String id, {int? price, int? beds, double? km, String? from, String address = ''}) =>
    FoundHome(
      Listing(
        source: 'rightmove',
        sourceId: id,
        url: 'https://www.rightmove.co.uk/properties/$id',
        address: address.isEmpty ? '$id Road' : address,
        price: price,
        beds: beds,
        availableFrom: from,
      ),
    )..km = km;

Property _property(String id, {int? price, int? beds, int rating = 0, String added = '2026-11-01'}) =>
    Property(
      id: id,
      hlc: '',
      deleted: false,
      address: '$id Road',
      postcode: '',
      kind: 'rent',
      stage: 'new',
      price: price,
      beds: beds,
      style: '',
      furnished: '',
      source: 'manual',
      url: '',
      listingStatus: '',
      rating: rating,
      notes: '',
      added: added,
      meta: '{}',
    );

void main() {
  test('map pins: full postcodes in one bulk lookup, districts one by one', () async {
    final asked = <String>[];
    final r = Research(
      client: MockClient((req) async {
        asked.add('${req.method} ${req.url.path}');
        if (req.method == 'POST') {
          expect(jsonDecode(req.body), {
            'postcodes': ['LS6 1AA', 'ZZ1 1ZZ'],
          });
          return http.Response(
            jsonEncode({
              'result': [
                {
                  'query': 'LS6 1AA',
                  'result': {'latitude': 53.82, 'longitude': -1.58},
                },
                {'query': 'ZZ1 1ZZ', 'result': null},
              ],
            }),
            200,
          );
        }
        return http.Response(
          jsonEncode({
            'result': {'latitude': 53.6, 'longitude': -1.3, 'outcode': 'WF8'},
          }),
          200,
        );
      }),
    );
    final got = await r.pointsFor(['LS6 1AA', 'ZZ1 1ZZ', 'WF8']);
    expect(got.keys, unorderedEquals(['LS6 1AA', 'WF8']));
    expect(got['LS6 1AA']!.lat, 53.82);
    expect(asked, ['POST /postcodes', 'GET /outcodes/WF8']);
  });

  group('sorting Search results', () {
    final homes = [
      _home('a', price: 900, beds: 2, km: 3, from: '2026-12-01'),
      _home('b', beds: 3, km: 1),
      _home('c', price: 700, beds: 1, from: '2026-11-15'),
      _home('d', price: 800, beds: 2, km: 2),
    ];
    List<String> ids(HomeSort s, [double Function(FoundHome)? like]) => [
      for (final h in sortHomes(homes, s, likeness: like)) h.main.sourceId,
    ];

    test('best match keeps the ranking', () => expect(ids(HomeSort.best), ['a', 'b', 'c', 'd']));
    test('price either way, unknown prices last', () {
      expect(ids(HomeSort.priceLow), ['c', 'd', 'a', 'b']);
      expect(ids(HomeSort.priceHigh), ['a', 'd', 'c', 'b']);
    });
    test('bedrooms, distance and availability; ties keep the ranking', () {
      expect(ids(HomeSort.beds), ['b', 'a', 'd', 'c']);
      expect(ids(HomeSort.nearest), ['b', 'd', 'a', 'c']);
      expect(ids(HomeSort.soonest), ['c', 'a', 'b', 'd']);
    });
    test('for you follows the likeness, and is best match without one', () {
      expect(ids(HomeSort.forYou, (h) => h.main.sourceId == 'd' ? 1 : 0), ['d', 'a', 'b', 'c']);
      expect(ids(HomeSort.forYou), ['a', 'b', 'c', 'd']);
    });
  });

  test('the Hunt sorts each stage by distance, rating, price, beds or date added', () {
    final rows = [
      _property('a', price: 900, beds: 1, rating: 2, added: '2026-11-03'),
      _property('b', price: 700, beds: 3, rating: 5, added: '2026-11-01'),
      _property('c', beds: 2, added: '2026-11-02'),
    ];
    final far = {'a': 1.0, 'b': 5.0};
    List<String> ids(HuntSort s) => [
      for (final p in [...rows]..sort((x, y) => s.compare(x, y, (p) => far[p.id]))) p.id,
    ];
    expect(ids(HuntSort.nearest), ['a', 'b', 'c']);
    expect(ids(HuntSort.rating), ['b', 'a', 'c']);
    expect(ids(HuntSort.priceLow), ['b', 'a', 'c']);
    expect(ids(HuntSort.priceHigh), ['a', 'b', 'c']);
    expect(ids(HuntSort.beds), ['b', 'c', 'a']);
    expect(ids(HuntSort.added), ['a', 'c', 'b']);
  });

  group('taste', () {
    KeptHome kept(int price, int beds, String postcode, String text, double weight) =>
        (price: price, beds: beds, postcode: postcode, text: text, weight: weight);

    test('learns price, beds, district and features from kept homes', () {
      final t = Taste.learn([
        kept(800, 2, 'LS6 1AA', 'Flat with parking', 1),
        kept(850, 2, 'LS6 2BB', 'Flat, garden, parking', 2),
        kept(900, 3, 'LS6 3CC', 'House with garden', 1),
        kept(700, 1, 'LS9 1AA', 'Flat, no parking, students', -1),
      ]);
      expect((t.price, t.beds, t.count, t.strong), (850, 2, 3, true));
      final close = t.likeness(
        price: 840,
        beds: 2,
        postcode: 'LS6 9ZZ',
        text: 'Flat with garden and parking',
      );
      final far = t.likeness(price: 1600, beds: 5, postcode: 'LS9 4AA', text: 'Bungalow');
      expect(close, greaterThan(0.8));
      expect(far, lessThan(0.2));
    });

    test('knows nothing until a home is kept', () {
      expect(Taste.learn([kept(700, 1, '', 'Flat', -1)]).count, 0);
      expect(Taste.none.likeness(price: 800, beds: 2), 0);
    });

    test('the usual search is the place searched most, its newest form', () {
      final a1 = readRequest('2 bed to rent in Leeds under £900');
      final b = readRequest('house for sale in York');
      final a2 = readRequest('3 bed to rent in Leeds');
      expect(usualSearch([a2, b, a1])?.minBeds, 3);
      expect(usualSearch(const []), isNull);
    });
  });

  test('a request survives saving, and the same search is spotted however typed', () {
    final q = readRequest('2-3 bed flat to rent in Leeds £700 to £900 within 2 miles, no students');
    final back = SearchRequest.fromJson(q.toJson());
    expect(back.toJson(), q.toJson());
    expect(
      back.sameAs(readRequest('flat 2-3 beds to rent in leeds £700-£900 within 2 miles no students')),
      isTrue,
    );
    expect(back.sameAs(q.copyWith(maxPrice: () => 950)), isFalse);
  });

  test('postcode districts from addresses', () {
    expect(outcodeIn('Cardigan Road, Headingley, Leeds LS6'), 'LS6');
    expect(outcodeIn('1 High St, Leeds LS6 1AA'), 'LS6');
    expect(outcodeIn('Headingley, Leeds'), isNull);
  });

  group('sites read in a hidden browser', () {
    final q = readRequest('2 bed to rent in Leeds under £900 within 1 mile');

    test('Zoopla and Facebook searches carry the filters', () {
      final z = browserSearchUrl(SourceId.zoopla, q, page: 1);
      expect((z.host, z.path), ('www.zoopla.co.uk', '/to-rent/property/leeds/'));
      expect(z.queryParameters, containsPair('beds_min', '2'));
      expect(z.queryParameters, containsPair('price_max', '900'));
      expect(z.queryParameters, containsPair('pn', '2'));
      final f = browserSearchUrl(SourceId.facebook, readRequest('house for sale in Newcastle upon Tyne'));
      expect((f.host, f.path), ('www.facebook.com', '/marketplace/newcastleupontyne/propertyforsale'));
      expect(SourceId.values.where((s) => s.readInBrowser), [SourceId.zoopla, SourceId.facebook]);
    });

    test('Zoopla has more pages when it links the next one; Marketplace scrolls', () {
      expect(browserHasMore(SourceId.zoopla, '<a href="?pn=3">Next</a>', 1), isTrue);
      expect(browserHasMore(SourceId.zoopla, '<a href="?pn=2">2</a>', 1), isFalse);
      expect(browserHasMore(SourceId.facebook, '?pn=2', 0), isFalse);
    });

    test('Marketplace cards become homes', () {
      const cards =
          '[{"id":"1234567890123456","href":"https://www.facebook.com/marketplace/item/1234567890123456/",'
          '"text":"£850 / Month\\n2 beds 1 bath Flat\\nLeeds, United Kingdom","img":"https://scontent.example/x.jpg"}]';
      final l = readOpenPage(SourceId.facebook, '<html></html>', cards, rent: true).items.single;
      expect(
        (l.source, l.sourceId, l.price, l.beds, l.address),
        ('facebook', '1234567890123456', 850, 2, 'Leeds, United Kingdom'),
      );
      expect(cardsScript, contains(r'marketplace\/item'));
      expect((l.baths, l.style), (1, 'Flat'));
    });

    test('Marketplace: a town Facebook names by number is remembered and used', () {
      final q = readRequest('2 bed to rent in Bishop Auckland');
      expect(marketplaceSlug(q.area), 'bishopauckland');
      expect(browserSearchUrl(SourceId.facebook, q).path, '/marketplace/bishopauckland/propertyrentals');
      final picked = Uri.parse(
        'https://www.facebook.com/marketplace/108095519210311/propertyrentals?exact=false',
      );
      expect(marketplacePlaceIn(picked), '108095519210311');
      expect(
        browserSearchUrl(SourceId.facebook, q, places: {'bishopauckland': '108095519210311'}).path,
        '/marketplace/108095519210311/propertyrentals',
      );
      expect(marketplacePlaceIn(Uri.parse('https://www.facebook.com/marketplace/item/123/')), isNull);
      expect(marketplacePlaceIn(Uri.parse('https://www.facebook.com/marketplace/leeds/vehicles')), isNull);
      expect(SourceId.ofUrl(picked), SourceId.facebook);
      expect(SourceId.ofUrl(Uri.parse('https://m.facebook.com/x')), SourceId.facebook);
      expect(SourceId.ofUrl(Uri.parse('https://notfacebook.com/')), isNull);
    });
  });
}
