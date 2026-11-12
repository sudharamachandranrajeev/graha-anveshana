import 'package:anveshana/db/database.dart';
import 'package:anveshana/domain/dashboard.dart';
import 'package:anveshana/domain/pipeline.dart';
import 'package:flutter_test/flutter_test.dart';

// Made-up homes, agents and dates only.

Property home(
  String id, {
  String kind = 'rent',
  String stage = 'new',
  int? price,
  int? beds,
  String postcode = '',
  double? lat,
  double? lon,
  String status = 'toLet',
  String? agent,
  int rating = 0,
  String added = '2026-11-02',
}) => Property(
  id: id,
  hlc: '',
  deleted: false,
  address: '$id Sample Street',
  postcode: postcode,
  lat: lat,
  lon: lon,
  kind: kind,
  stage: stage,
  price: price,
  beds: beds,
  style: '',
  furnished: '',
  source: 'manual',
  url: '',
  listingStatus: status,
  agentId: agent,
  rating: rating,
  notes: '',
  added: added,
  meta: '{}',
);

Interaction said(
  String id, {
  String? property,
  String? contact,
  required String at,
  String direction = 'out',
  String channel = 'email',
  String? followUp,
}) => Interaction(
  id: id,
  hlc: '',
  deleted: false,
  propertyId: property,
  contactId: contact,
  at: at,
  channel: channel,
  direction: direction,
  summary: '',
  followUp: followUp,
);

Viewing viewing(String id, String property, String at, {String status = 'booked', String notes = ''}) =>
    Viewing(
      id: id,
      hlc: '',
      deleted: false,
      propertyId: property,
      at: at,
      status: status,
      rating: 0,
      notes: notes,
    );

const agent = Contact(
  id: 'c1',
  hlc: '',
  deleted: false,
  name: 'Sam',
  role: 'agent',
  organisation: 'Example Lettings',
  phone: '',
  email: '',
  notes: '',
);

// Thursday 12 November 2026.
final today = DateTime(2026, 11, 12);

HuntSummary run({
  List<Property> homes = const [],
  List<Interaction> log = const [],
  List<Viewing> views = const [],
  PropertyKind kind = PropertyKind.rent,
  int? budget,
  Set<String>? only,
  List<DashPlace> places = const [],
}) => summarise(
  kind: kind,
  properties: homes,
  interactions: log,
  viewings: views,
  contacts: const [agent],
  today: today,
  budget: budget,
  only: only,
  places: places,
);

void main() {
  test('an empty hunt is empty, with no insights', () {
    final s = run();
    expect(s.isEmpty, isTrue);
    expect(s.daysHunting, isNull);
    expect(s.prices, isNull);
    expect(s.insights, isEmpty);
    expect(s.weeks, hasLength(12));
  });

  test('the funnel counts how far each home got, dropped homes by their log', () {
    final s = run(
      homes: [
        home('a'),
        home('b', stage: 'shortlisted'),
        home('c', stage: 'enquired'),
        home('d', stage: 'viewing'),
        home('e', stage: 'dropped'),
        home('f', kind: 'buy', stage: 'agreed'),
      ],
      log: [said('i1', property: 'e', at: '2026-11-03T10:00')],
      views: [viewing('v1', 'e', '2026-11-05T12:00', notes: 'Damp')],
    );
    expect(s.homes, hasLength(5), reason: 'the buy home is in the other view');
    expect([for (final f in s.funnel) f.count], [5, 4, 3, 2, 0, 0]);
    expect(s.funnel.first.stage, Stage.fresh);
    expect(s.dropped.single.id, 'e');
    expect(s.liked, hasLength(4));
    expect(s.enquired, hasLength(3));
    expect(s.viewings, 1);
  });

  test('weeks run Monday to Sunday, the last one this week', () {
    final s = run(
      homes: [
        home('a', added: '2026-11-09'),
        home('b', added: '2026-11-08'),
        home('c', added: '2026-08-01'),
      ],
      log: [said('i1', property: 'a', at: '2026-11-10T09:00')],
    );
    expect(s.weeks.last.start, DateTime(2026, 11, 9));
    expect(s.weeks.last.added, 1);
    expect(s.weeks[10].added, 1);
    expect(s.addedThisWeek, 1);
    expect(s.enquiriesThisWeek, 1);
    expect(s.weeks.fold(0, (n, w) => n + w.added), 2, reason: 'August is before the twelve weeks');
    expect(s.daysHunting, 103);
  });

  test('prices: spread, bins, budget and the insight', () {
    final s = run(
      homes: [
        home('a', price: 600, stage: 'shortlisted'),
        home('b', price: 650, stage: 'shortlisted'),
        home('c', price: 700),
        home('d', price: 850),
        home('e'),
      ],
      budget: 700,
    );
    final p = s.prices!;
    expect((p.low, p.median, p.high), (600, 675, 850));
    expect(p.likedMedian, 625);
    expect(p.overBudget, 1);
    expect(p.bins.fold(0, (n, b) => n + b.count), 4);
    expect(p.bins.first.from, 600);
    expect(s.insights.first, 'Homes you like are £625 at the middle, 11% under your budget of £700.');
  });

  test('one price makes one bin', () {
    final p = run(homes: [home('a', price: 700), home('b', price: 700)]).prices!;
    expect(p.bins, [(from: 700, to: 700, count: 2)]);
  });

  test('beds, districts and distance from each place', () {
    final s = run(
      homes: [
        home('a', beds: 2, postcode: 'BT74 1AA', lat: 54.35, lon: -7.64, stage: 'shortlisted'),
        home('b', beds: 2, postcode: 'bt74 2bb', lat: 54.36, lon: -7.64),
        home('c', beds: 1, postcode: 'BT925CC'),
      ],
      places: [(lat: 54.35, lon: -7.64, label: 'Work')],
    );
    expect(s.beds, [(beds: 1, count: 1), (beds: 2, count: 2)]);
    expect(s.districts, [(district: 'BT74', count: 2), (district: 'BT92', count: 1)]);
    expect(s.distances.single.place, 'Work');
    expect(s.distances.single.km, 0, reason: 'measured from the liked home only');
    expect(s.insights, contains('Most of your homes are in BT74 (2 of 3).'));
  });

  test('agents: replies, reply time and messages waiting over a week', () {
    final s = run(
      homes: [
        home('a', agent: 'c1'),
        home('b', agent: 'c1'),
      ],
      log: [
        said('i1', property: 'a', at: '2026-11-02T10:00'),
        said('i2', property: 'a', at: '2026-11-02T14:00', direction: 'in'),
        said('i3', property: 'b', at: '2026-11-04T09:00'),
        said('n1', property: 'b', at: '2026-11-04T09:30', channel: 'note', direction: 'in'),
      ],
    );
    final a = s.agents.single;
    expect(a.name, 'Example Lettings');
    expect((a.sent, a.replies), (2, 1));
    expect(a.replyHours, 4);
    expect(a.waiting, 1, reason: 'i3 has had no reply since; a note is not a reply');
    expect(s.insights, contains('1 agent has not replied in a week.'));
  });

  test('gone homes, and those lost before an enquiry', () {
    final s = run(
      homes: [
        home('a', status: 'letAgreed'),
        home('b', status: 'letAgreed', stage: 'enquired'),
        home('c', status: 'letAgreed', stage: 'agreed'),
        home('d'),
      ],
    );
    expect([for (final p in s.gone) p.id], ['a', 'b']);
    expect(s.goneBeforeEnquiry.single.id, 'a');
    expect(s.insights, contains(startsWith('1 home you saved went let before you asked about it.')));
  });

  test('to do: follow-ups due, viewings soon or without notes, liked homes not asked about', () {
    final s = run(
      homes: [
        home('a'),
        home('b', stage: 'shortlisted'),
        home('c', stage: 'shortlisted', status: 'letAgreed'),
      ],
      log: [
        said('i1', property: 'a', at: '2026-11-01T10:00', followUp: '2026-11-10'),
        said('i2', contact: 'c1', at: '2026-11-03T10:00', followUp: '2026-11-12'),
        said('i3', contact: 'c1', at: '2026-11-04T10:00', direction: 'in'),
      ],
      views: [
        viewing('v1', 'a', '2026-11-14T11:00'),
        viewing('v2', 'a', '2026-11-08T11:00', status: 'done'),
        viewing('v3', 'a', '2026-11-13T11:00', status: 'cancelled'),
      ],
    );
    expect(
      [for (final t in s.todo) t.text],
      [
        'Follow up: a Sample Street (due 2026-11-10)',
        'Viewing 2026-11-14 11:00: a Sample Street',
        'Note how the viewing went: a Sample Street',
        'Liked, not asked about yet: b Sample Street',
      ],
    );
    expect(s.todo.first.urgent, isTrue);
  });

  test('a collection narrows the view to its homes', () {
    final s = run(homes: [home('a'), home('b')], only: {'b'});
    expect(s.homes.single.id, 'b');
  });

  test('district reads postcodes with and without the space', () {
    expect(district('BT74 1AA'), 'BT74');
    expect(district('ls11ab'), 'LS1');
    expect(district('  '), isNull);
  });
}
