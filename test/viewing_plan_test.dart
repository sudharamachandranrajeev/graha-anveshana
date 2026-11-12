import 'package:anveshana/db/database.dart';
import 'package:anveshana/domain/book.dart';
import 'package:anveshana/domain/dashboard.dart';
import 'package:anveshana/domain/listing.dart';
import 'package:anveshana/domain/pipeline.dart';
import 'package:brahma_core/brahma_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dashboard_test.dart' show home, viewing;
import 'support.dart';

// Made-up homes, dates and notes only.

Viewing _seen(String id, String property, String at, Impression? i, {String notes = ''}) =>
    viewing(id, property, at, status: 'done', notes: notes).copyWith(rating: i?.rating ?? 0);

HuntSummary _run(List<Property> homes, {List<Viewing> views = const [], String? moveBy}) => summarise(
  kind: PropertyKind.rent,
  properties: homes,
  interactions: const [],
  viewings: views,
  contacts: const [],
  today: DateTime(2026, 11, 12),
  moveBy: moveBy,
);

void main() {
  test('an impression is kept in the viewing rating', () {
    for (final i in Impression.values) {
      expect(Impression.of(i.rating), i);
    }
    expect((Impression.of(0), Impression.of(4), Impression.of(2)), (null, Impression.loved, Impression.no));
  });

  test('a goal per kind round-trips through its JSON', () {
    var all = withGoal({}, PropertyKind.rent, (budget: 950, moveBy: '2027-01-15'));
    all = withGoal(all, PropertyKind.buy, (budget: null, moveBy: '2027-06-01'));
    expect(goalIn(all, PropertyKind.rent), (budget: 950, moveBy: '2027-01-15'));
    expect(goalIn(all, PropertyKind.buy), (budget: null, moveBy: '2027-06-01'));
    expect(goalIn(const {}, PropertyKind.rent), (budget: null, moveBy: null));
  });

  test('verdicts: the latest per home, newest first, done viewings only', () {
    final a = home('a', stage: 'viewing'), b = home('b', stage: 'viewing');
    final s = _run(
      [a, b],
      views: [
        _seen('v1', 'a', '2026-11-01T10:00', Impression.maybe),
        _seen('v2', 'a', '2026-11-08T10:00', Impression.loved, notes: ' Big garden '),
        _seen('v3', 'b', '2026-11-05T10:00', Impression.no, notes: 'Damp'),
        viewing('v4', 'b', '2026-11-20T10:00').copyWith(rating: 5),
        _seen('v5', 'b', '2026-11-06T10:00', null),
      ],
    );
    expect(
      [for (final v in s.verdicts) (v.home.id, v.verdict, v.notes)],
      [('a', Impression.loved, 'Big garden'), ('b', Impression.no, 'Damp')],
    );
    expect(s.insights, contains('After viewing 2 homes: 1 loved, 0 maybe, 1 not for you.'));
  });

  group('pace against the move-by date', () {
    // Saved 2026-11-02 by default: ten days of hunting by 12 November.
    final viewed = [home('a', stage: 'viewing'), home('b', stage: 'viewing'), home('c')];

    test('no date, no pace', () => expect(_run(viewed).pace, isNull));

    test('projects viewings at the pace so far', () {
      final s = _run(viewed, moveBy: '2026-12-12');
      expect((s.pace!.daysLeft, s.pace!.viewed, s.pace!.projected), (30, 2, 8));
      expect(
        s.insights.first,
        '30 days to the day you set to move by. At this pace you will have viewed about 8 homes by then.',
      );
    });

    test('too early to judge, none viewed, and a date passed', () {
      final early = _run([home('a', added: '2026-11-10')], moveBy: '2026-12-01').pace!;
      expect((early.daysLeft, early.projected), (19, null));
      expect(_run([home('a')], moveBy: '2026-12-01').insights.first, contains('book a viewing'));
      final passed = _run(viewed, moveBy: '2026-11-01');
      expect((passed.pace!.daysLeft, passed.pace!.projected), (-11, null));
      expect(passed.insights.first, contains('has passed'));
    });
  });

  group('recording a viewing', () {
    late AppDatabase db;
    late PropertyBook book;
    setUp(() async {
      db = memoryDatabase();
      book = PropertyBook(await Store.open(db));
    });
    tearDown(() => db.close());

    Future<String> booked() async {
      final id = (await book.importListing(
        parsePropertyPalPage(nextData({'property': samplePropertyPal()})).single,
        today: '2026-11-01',
      )).id;
      return book.bookViewing(id, '2026-11-05T11:00');
    }

    test('keeps the impression, notes and the home\'s rating', () async {
      await book.recordViewing(
        await booked(),
        impression: Impression.loved,
        notes: ' Quiet street ',
        rating: 4,
      );
      final v = (await db.select(db.viewings).get()).single;
      expect((v.status, Impression.of(v.rating), v.notes), ('done', Impression.loved, 'Quiet street'));
      final p = (await db.select(db.properties).get()).single;
      expect((p.rating, p.stage), (4, Stage.viewing.id));
    });

    test('can set the home aside', () async {
      await book.recordViewing(await booked(), impression: Impression.no, setAside: true);
      final p = (await db.select(db.properties).get()).single;
      expect((p.rating, p.stage), (0, Stage.dropped.id));
    });
  });
}
