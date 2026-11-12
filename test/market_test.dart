import 'dart:convert';

import 'package:anveshana/db/database.dart';
import 'package:anveshana/domain/book.dart';
import 'package:anveshana/domain/dashboard.dart';
import 'package:anveshana/domain/listing.dart';
import 'package:anveshana/domain/pipeline.dart';
import 'package:anveshana/domain/price_log.dart';
import 'package:anveshana/domain/property_search.dart';
import 'package:anveshana/domain/search_request.dart';
import 'package:brahma_core/brahma_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

// Made-up homes, prices and dates only.

Listing _ad(
  String id, {
  int? price,
  String? listedOn,
  String? reducedOn,
  int? sqft,
  String description = '',
}) => Listing(
  source: 'rightmove',
  sourceId: id,
  url: 'https://www.rightmove.co.uk/properties/$id',
  address: '$id Sample Street, Exampletown',
  price: price,
  listedOn: listedOn,
  reducedOn: reducedOn,
  sqft: sqft,
  description: description,
);

Property _home(
  String id, {
  String stage = 'shortlisted',
  String status = 'toLet',
  Map<String, Object?> meta = const {},
}) => Property(
  id: id,
  hlc: '',
  deleted: false,
  address: '$id Sample Street',
  postcode: '',
  kind: 'rent',
  stage: stage,
  style: '',
  furnished: '',
  source: 'manual',
  url: '',
  listingStatus: status,
  rating: 0,
  notes: '',
  added: '2026-10-01',
  meta: jsonEncode(meta),
);

HuntSummary _run(List<Property> homes) => summarise(
  kind: PropertyKind.rent,
  properties: homes,
  interactions: const [],
  viewings: const [],
  contacts: const [],
  today: DateTime(2026, 11, 12),
);

void main() {
  test('floor area from advert text, in square feet', () {
    expect(sqftIn('738 sq. ft.'), 738);
    expect(sqftIn('A roomy 1,050 sq ft house'), 1050);
    expect(sqftIn('about 65 m² inside'), 700);
    expect(sqftIn('70 sqm'), 753);
    expect(sqftIn('2 bed flat'), isNull);
    expect(sqftIn('5 sq ft'), isNull, reason: 'too small for a home');
  });

  test('a minimum size is read from the words, not taken as a price', () {
    final r = readRequest('2 bed to rent in Leeds at least 700 sq ft under £900');
    expect((r.minSqft, r.maxPrice), (700, 900));
    expect(readRequest('flat over 90 sqm in York').minSqft, 969);
    expect(readRequest('850+ sqft house in York').minSqft, 850);
    expect(SearchRequest.fromJson(readRequest('850+ sqft in York').toJson()).minSqft, 850);
  });

  test('a minimum size leaves out smaller homes, keeps unknown ones', () {
    const q = SearchRequest(area: 'Exampletown', minSqft: 700);
    expect(meetsRequest(FoundHome(_ad('1', sqft: 650)), q), isFalse);
    expect(meetsRequest(FoundHome(_ad('2', sqft: 800)), q), isTrue);
    expect(meetsRequest(FoundHome(_ad('3')), q), isTrue);
    expect(meetsRequest(FoundHome(_ad('4', description: 'Only 500 sq ft')), q), isFalse);
  });

  test('sorting by price per square foot and by newest', () {
    final a = FoundHome(_ad('a', price: 1000, sqft: 500, listedOn: '2026-10-01'));
    final b = FoundHome(_ad('b', price: 900, sqft: 900, listedOn: '2026-11-10'));
    final c = FoundHome(_ad('c', price: 800));
    expect(sortHomes([a, b, c], HomeSort.perSqft), [b, a, c]);
    expect(sortHomes([a, b, c], HomeSort.newest), [b, a, c]);
    expect(b.perSqft, 1.0);
    expect(c.perSqft, isNull);
  });

  test('the market line on a search card', () {
    final today = DateTime(2026, 11, 12);
    expect(marketLine('2026-11-01', '2026-11-03', today: today), 'On the market 11 days · Price cut 3 Nov');
    expect(marketLine('2026-11-12', null, today: today), 'New today');
    expect(marketLine('2026-11-11', null, today: today), 'On the market 1 day');
    expect(marketLine(null, null, today: today), isNull);
  });

  group('price log', () {
    test('a price is logged only when it changes', () {
      var meta = withSeen({}, _ad('1', price: 900, listedOn: '2026-10-20', sqft: 700), '2026-11-01');
      meta = withSeen(meta, _ad('1', price: 900), '2026-11-05');
      meta = withSeen(meta, _ad('1', price: 850, listedOn: '2026-10-25'), '2026-11-08');
      final f = MarketFacts.of(jsonEncode(meta));
      expect(f.prices, [(at: '2026-11-01', price: 900), (at: '2026-11-08', price: 850)]);
      expect((f.seen, f.listedOn, f.sqft), ('2026-11-08', '2026-10-20', 700));
      expect(f.change, -50);
      expect(f.changeText, '£50 less since 1 Nov');
    });

    test('a raise, no change, and bad meta', () {
      final up = MarketFacts(prices: [(at: '2026-11-01', price: 800), (at: '2026-11-02', price: 820)]);
      expect(up.changeText, '£20 more since 1 Nov');
      expect(const MarketFacts(prices: [(at: '2026-11-01', price: 800)]).changeText, isNull);
      expect(MarketFacts.of('not json').prices, isEmpty);
    });

    test('may be gone after two weeks unseen; never-seen homes are not judged', () {
      expect(const MarketFacts(seen: '2026-10-29').mayBeGone('2026-11-12'), isTrue);
      expect(const MarketFacts(seen: '2026-10-30').mayBeGone('2026-11-12'), isFalse);
      expect(const MarketFacts().mayBeGone('2026-11-12'), isFalse);
    });
  });

  group('noting saved homes seen in Search', () {
    late AppDatabase db;
    late PropertyBook book;
    setUp(() async {
      db = memoryDatabase();
      book = PropertyBook(await Store.open(db));
    });
    tearDown(() => db.close());

    Future<Property> only() async => (await db.select(db.properties).get()).single;

    test('writes only homes whose price or day seen changed', () async {
      final (:id, added: _) = await book.importListing(_ad('1', price: 900), today: '2026-11-01');
      expect(MarketFacts.of((await only()).meta).prices, [(at: '2026-11-01', price: 900)]);
      expect(await book.noteSeen({id: _ad('1', price: 900)}, '2026-11-01'), 0);
      expect(await book.noteSeen({id: _ad('1', price: 875), 'missing': _ad('2')}, '2026-11-04'), 1);
      final p = await only();
      final f = MarketFacts.of(p.meta);
      expect((f.prices.length, f.seen, f.change), (2, '2026-11-04', -25));
      expect(p.added, '2026-11-01');
    });
  });

  test('the dashboard reads the market from saved homes', () {
    final s = _run([
      _home(
        'cut',
        meta: {
          'seen': '2026-11-10',
          'prices': [
            {'at': '2026-10-01', 'price': 900},
            {'at': '2026-11-10', 'price': 850},
          ],
        },
      ),
      _home(
        'oldcut',
        meta: {
          'seen': '2026-11-10',
          'prices': [
            {'at': '2026-10-01', 'price': 900},
            {'at': '2026-10-20', 'price': 850},
          ],
        },
      ),
      _home('stale', meta: {'seen': '2026-10-20'}),
      _home('stalefresh', stage: 'new', meta: {'seen': '2026-10-20'}),
      _home('dropped', stage: 'dropped', meta: {'seen': '2026-10-01'}),
      _home('let1', status: 'letAgreed', meta: {'listedOn': '2026-10-01', 'seen': '2026-10-11'}),
      _home('let2', status: 'let', meta: {'listedOn': '2026-09-01', 'seen': '2026-10-01'}),
      _home('let3', status: 'let', meta: {'listedOn': '2026-10-01', 'seen': '2026-10-21'}),
    ]);
    final m = s.pulse;
    expect(m.cutThisWeek.map((p) => p.id), ['cut']);
    expect(m.mayBeGone.map((p) => p.id), ['stale', 'stalefresh']);
    expect((m.daysToGo, m.goneFast), (20, 1));
    final checks = s.todo.where((t) => t.text.startsWith('May be gone')).map((t) => t.propertyId);
    expect(checks, ['stale']);
    expect(s.insights.any((i) => i.contains('cut its price this week')), isTrue);
    expect(s.insights.any((i) => i.contains('about 20 days; 1 went within two weeks')), isTrue);
  });
}
