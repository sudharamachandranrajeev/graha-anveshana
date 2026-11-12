import 'package:anveshana/db/database.dart';
import 'package:anveshana/domain/book.dart';
import 'package:anveshana/domain/catalog_book.dart';
import 'package:anveshana/domain/listing.dart';
import 'package:anveshana/domain/pipeline.dart';
import 'package:anveshana/domain/viewing_plan.dart';
import 'package:brahma_core/brahma_core.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_harness.dart';
import 'dashboard_test.dart' show home, viewing;
import 'support.dart';

// Made-up homes, places and times only.

Property _at(String id, double lat, double lon, {String stage = 'viewing', String url = ''}) =>
    home(id, stage: stage, lat: lat, lon: lon).copyWith(url: url, notes: 'Agent said call 07000 000000');

void main() {
  group('viewing plan', () {
    // About 0.7 km apart, and about 11 km apart.
    final near1 = _at('a', 54.000, -7.000), near2 = _at('b', 54.006, -7.000), far = _at('c', 54.100, -7.000);

    test('days in order; past, cancelled and done viewings left out', () {
      final days = planViewings(
        [
          viewing('v1', 'a', '2026-11-14T12:00'),
          viewing('v2', 'b', '2026-11-14T10:00'),
          viewing('v3', 'c', '2026-11-13T09:00'),
          viewing('v4', 'a', '2026-11-10T09:00'),
          viewing('v5', 'c', '2026-11-15T09:00', status: 'cancelled'),
          viewing('v6', 'c', '2026-11-16T09:00', status: 'done'),
        ],
        [near1, near2, far],
        today: '2026-11-12',
      );
      expect(
        [
          for (final d in days) '${d.day}: ${[for (final b in d.viewings) b.viewing.id].join(' ')}',
        ],
        ['2026-11-13: v3', '2026-11-14: v2 v1'],
      );
      expect(days.every((d) => d.clashes.isEmpty), isTrue);
    });

    test('warns of overlaps and of too little time to travel', () {
      final days = planViewings(
        [
          viewing('v1', 'a', '2026-11-14T10:00'),
          viewing('v2', 'b', '2026-11-14T10:15'),
          viewing('v3', 'c', '2026-11-14T10:50'),
          viewing('v4', 'a', '2026-11-14T12:00'),
        ],
        [near1, near2, far],
        today: '2026-11-12',
      );
      expect(days.single.clashes, hasLength(2));
      expect(days.single.clashes.first, contains('overlap (10:00 and 10:15)'));
      expect(days.single.clashes.last, contains('b Sample Street to c Sample Street (10:15 and 10:50)'));
      expect(travelMinutes(11), 29);
      expect(travelMinutes(0.1), 5);
    });

    test('a calendar file with escaped, folded lines', () {
      final b = (
        viewing: viewing('v1', 'a', '2026-11-14T10:00', notes: 'Ask about parking, bins; keys'),
        home: near1.copyWith(address: '${'Long ' * 20}Road, Exampletown'),
      );
      final ics = viewingsIcs([b], stamp: DateTime.utc(2026, 11, 12, 8));
      expect(ics, startsWith('BEGIN:VCALENDAR\r\n'));
      expect(ics, contains('DTSTART:20261114T100000\r\n'));
      expect(ics, contains('DTEND:20261114T103000\r\n'));
      expect(ics, contains('DTSTAMP:20261112T080000Z'));
      expect(ics, contains(r'DESCRIPTION:Ask about parking\, bins\; keys'));
      expect(ics.split('\r\n').every((l) => l.length <= 75), isTrue);
      expect(ics, contains('\r\n '));
      expect(ics.trimRight(), endsWith('END:VCALENDAR'));
      final g = googleCalendarLink(b);
      expect(g.queryParameters['dates'], '20261114T100000/20261114T103000');
    });
  });

  test('the shared shortlist leaves out notes, phones and homes set aside', () {
    final text = shortlistText(
      [
        _at(
          'a',
          54,
          -7,
          stage: 'shortlisted',
          url: 'https://example.com/a',
        ).copyWith(price: const Value(800), rating: 4),
        _at('b', 54, -7).copyWith(beds: const Value(0)),
        _at('c', 54, -7, stage: 'dropped'),
        home('d', kind: 'buy', stage: 'shortlisted'),
      ],
      PropertyKind.rent,
      impressions: {'b': Impression.maybe},
      today: '2026-11-12',
    );
    expect(text, startsWith('Homes to rent on my shortlist (12 Nov 2026)'));
    expect(text, contains('Liked (1)\n- a Sample Street: £800 a month, 4 of 5\n  https://example.com/a'));
    expect(text, contains('Viewing (1)\n- b Sample Street: studio, after viewing: maybe'));
    expect(text, isNot(contains('07000')));
    expect(text, isNot(contains('c Sample Street')));
    expect(text, isNot(contains('d Sample Street')));
  });

  group('bulk writes', () {
    late AppDatabase db;
    late PropertyBook book;
    setUp(() async {
      db = memoryDatabase();
      book = PropertyBook(await Store.open(db));
    });
    tearDown(() => db.close());

    Future<List<String>> two() async => [
      for (final id in [101, 102])
        (await book.importListing(
          parsePropertyPalPage(nextData({'property': samplePropertyPal(id: id)})).single,
          today: '2026-11-01',
        )).id,
    ];

    test('moves several homes at once', () async {
      final ids = await two();
      await book.setStages(ids, Stage.shortlisted);
      expect((await db.select(db.properties).get()).map((p) => p.stage), everyElement(Stage.shortlisted.id));
    });

    test('adds homes to a collection once, linked to them', () async {
      final ids = await two();
      final homes = await db.select(db.properties).get();
      final r = await book.createResearch('Picks');
      expect(await book.addHomes(r, homes), 2);
      expect(await book.addHomes(r, homes), 0);
      final items = await db.select(db.catalogItems).get();
      expect(items.map((i) => i.propertyId).toSet(), ids.toSet());
      expect(items.first.title, homes.firstWhere((p) => p.id == items.first.propertyId).address);
    });
  });

  testWidgets('pick homes on the Shortlist, move them and compare them', (tester) async {
    final app = AppHarness(tester)..desktop();
    await app.open(
      seed: (book) async {
        for (final id in [101, 102]) {
          await book.importListing(
            parsePropertyPalPage(nextData({'property': samplePropertyPal(id: id, price: 600 + id)})).single,
            today: '2026-11-01',
          );
        }
      },
    );
    await app.run();
    await app.go('Shortlist');
    await app.tap(find.byTooltip('Pick homes to move, compare or add to a collection'));
    expect(find.text('Tap homes to pick them'), findsOneWidget);
    for (final c in [0, 1]) {
      await app.tap(find.byType(Checkbox).at(c));
    }
    expect(find.text('2 picked'), findsOneWidget);
    await app.tapText('Compare');
    expect(find.text('2 homes, cheapest first'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await app.settle();
    await app.tapText('Move to…');
    await app.tapText('Move to Liked');
    expect(find.text('Moved 2 homes to Liked.'), findsOneWidget);
    expect(find.text('Liked (2)'), findsOneWidget);
    await app.tap(find.byTooltip('More'));
    await app.tapText('Share the shortlist');
    expect(find.textContaining('Liked (2)\n- '), findsOneWidget);
    await app.close();
  });

  testWidgets('the viewings page lists the days and warns of a clash', (tester) async {
    final day = isoDate(DateTime.now().add(const Duration(days: 2)));
    final app = AppHarness(tester)..desktop();
    await app.open(
      seed: (book) async {
        for (final (id, at) in [(101, '10:00'), (102, '10:10')]) {
          final h = await book.importListing(
            parsePropertyPalPage(nextData({'property': samplePropertyPal(id: id)})).single,
          );
          await book.bookViewing(h.id, '${day}T$at');
        }
      },
    );
    await app.run();
    await app.go('Shortlist');
    await app.tap(find.byTooltip('More'));
    await app.tapText('Viewings, day by day');
    expect(find.text('10:00'), findsOneWidget);
    expect(find.text('10:10'), findsOneWidget);
    expect(find.textContaining('overlap (10:00 and 10:10)'), findsOneWidget);
    await app.close();
  });
}
