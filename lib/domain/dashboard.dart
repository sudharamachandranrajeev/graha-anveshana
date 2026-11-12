import '../db/database.dart';
import 'listing.dart' show distanceKm;
import 'pipeline.dart';

/// "Your hunt so far": every figure on the Dashboard, worked out from the
/// rows already on the device. Nothing here reads the network or the clock;
/// [today] comes in, so tests are exact.

/// A place homes are measured from: the home point or a Profile place.
typedef DashPlace = ({double lat, double lon, String label});

/// One step of the hunt and the homes that got at least that far.
class FunnelStep {
  const FunnelStep(this.stage, this.homes);
  final Stage stage;
  final List<Property> homes;
  int get count => homes.length;
}

/// One week (Monday first) of activity.
class WeekCount {
  const WeekCount(this.start, {this.added = 0, this.enquiries = 0, this.viewings = 0});
  final DateTime start;
  final int added, enquiries, viewings;
}

/// Prices of the homes in view, in [bins] of equal width.
class PriceSpread {
  const PriceSpread({
    required this.low,
    required this.median,
    required this.high,
    required this.bins,
    this.likedMedian,
    this.budget,
    this.overBudget = 0,
  });
  final int low, median, high;
  final int? likedMedian, budget;
  final int overBudget;
  final List<({int from, int to, int count})> bins;
}

/// What the user's own log says about one agent or landlord.
class AgentRecord {
  const AgentRecord({
    required this.name,
    required this.sent,
    required this.replies,
    required this.waiting,
    this.replyHours,
  });
  final String name;
  final int sent, replies;

  /// Messages sent over a week ago with no reply since.
  final int waiting;

  /// Average hours from a message to the next reply; null: no replies.
  final double? replyHours;
}

/// Something to do next, with the home it is about.
class ToDo {
  const ToDo(this.text, {this.propertyId, this.urgent = false});
  final String text;
  final String? propertyId;
  final bool urgent;
}

class HuntSummary {
  const HuntSummary({
    required this.kind,
    required this.homes,
    required this.liked,
    required this.enquired,
    required this.viewings,
    required this.addedThisWeek,
    required this.enquiriesThisWeek,
    required this.viewingsThisWeek,
    required this.daysHunting,
    required this.funnel,
    required this.dropped,
    required this.weeks,
    required this.prices,
    required this.beds,
    required this.distances,
    required this.districts,
    required this.agents,
    required this.gone,
    required this.goneBeforeEnquiry,
    required this.todo,
  });

  final PropertyKind kind;

  /// Homes to rent or buy in view, and those liked or further on.
  final List<Property> homes, liked;

  /// Homes asked about (a message sent, or the stage says so).
  final List<Property> enquired;

  /// Viewings booked or done (not cancelled).
  final int viewings;
  final int addedThisWeek, enquiriesThisWeek, viewingsThisWeek;

  /// Days since the first home was saved; null: none yet.
  final int? daysHunting;
  final List<FunnelStep> funnel;
  final List<Property> dropped;
  final List<WeekCount> weeks;
  final PriceSpread? prices;

  /// Bedrooms (0 = studio) and how many homes have that many.
  final List<({int beds, int count})> beds;

  /// Median distance of liked homes (all homes when none are liked) from each place.
  final List<({String place, double km})> distances;

  /// Postcode districts, most homes first.
  final List<({String district, int count})> districts;
  final List<AgentRecord> agents;

  /// Homes whose advert now says let or sold, and those of them never asked about.
  final List<Property> gone, goneBeforeEnquiry;
  final List<ToDo> todo;

  /// A few plain sentences about the hunt.
  List<String> get insights => _insights(this);

  bool get isEmpty => homes.isEmpty;
}

/// Dates as UTC midnights, so day counts do not slip across the clock change.
DateTime _day(String s) {
  final d = DateTime.tryParse(s.length >= 10 ? s.substring(0, 10) : s);
  return d == null ? DateTime.utc(1970) : DateTime.utc(d.year, d.month, d.day);
}

DateTime _monday(DateTime d) => DateTime.utc(d.year, d.month, d.day - (d.weekday - 1));

int _median(List<int> xs) {
  final s = [...xs]..sort();
  final m = s.length ~/ 2;
  return s.length.isOdd ? s[m] : ((s[m - 1] + s[m]) / 2).round();
}

double _medianD(List<double> xs) {
  final s = [...xs]..sort();
  final m = s.length ~/ 2;
  return s.length.isOdd ? s[m] : (s[m - 1] + s[m]) / 2;
}

/// "BT74" from "BT74 1AA"; null without a postcode.
String? district(String postcode) {
  final p = postcode.trim().toUpperCase();
  if (p.isEmpty) return null;
  final parts = p.split(RegExp(r'\s+'));
  // "BT741AA" without a space: the inward code is always the last three.
  if (parts.length == 1) return p.length > 4 ? p.substring(0, p.length - 3) : p;
  return parts.first;
}

/// A contact-log entry that is a message, not the user's own note.
bool _message(Interaction i) => i.channel != 'note';

HuntSummary summarise({
  required PropertyKind kind,
  required List<Property> properties,
  required List<Interaction> interactions,
  required List<Viewing> viewings,
  required List<Contact> contacts,
  required DateTime today,
  Set<String>? only,
  int? budget,
  List<DashPlace> places = const [],
}) {
  final now = DateTime.utc(today.year, today.month, today.day);
  // Viewing times are local wall-clock times.
  final nowLocal = DateTime(today.year, today.month, today.day);
  final homes = [
    for (final p in properties)
      if (p.kind == kind.name && (only == null || only.contains(p.id))) p,
  ];
  final byId = {for (final p in homes) p.id: p};
  final talk = [
    for (final i in interactions)
      if (_message(i) && (i.propertyId == null || byId.containsKey(i.propertyId))) i,
  ]..sort((a, b) => a.at.compareTo(b.at));
  final mine = [
    for (final i in talk)
      if (i.propertyId != null) i,
  ];
  final seen = [
    for (final v in viewings)
      if (v.status != 'cancelled' && byId.containsKey(v.propertyId)) v,
  ];

  final askedIds = {
    for (final i in mine)
      if (i.direction == 'out') i.propertyId!,
  };
  final viewedIds = {for (final v in seen) v.propertyId};

  // How far each home got. A home dropped later still counts for the steps
  // its log shows it reached.
  int reached(Property p) {
    final s = Stage.of(p.stage);
    if (s != Stage.dropped) return s.index;
    if (viewedIds.contains(p.id)) return Stage.viewing.index;
    if (askedIds.contains(p.id)) return Stage.enquired.index;
    return p.rating > 0 ? Stage.shortlisted.index : Stage.fresh.index;
  }

  final steps = [
    for (final s in Stage.values)
      if (s != Stage.dropped) s,
  ];
  final funnel = [
    for (final s in steps)
      FunnelStep(s, [
        for (final p in homes)
          if (reached(p) >= s.index) p,
      ]),
  ];
  final liked = funnel[Stage.shortlisted.index].homes;
  final enquired = funnel[Stage.enquired.index].homes;
  final dropped = [
    for (final p in homes)
      if (Stage.of(p.stage) == Stage.dropped) p,
  ];

  // The last twelve weeks, oldest first.
  final thisWeek = _monday(now);
  final weekStarts = [
    for (var w = 11; w >= 0; w--) DateTime.utc(thisWeek.year, thisWeek.month, thisWeek.day - 7 * w),
  ];
  int weekOf(DateTime d) {
    final m = _monday(d);
    return weekStarts.indexWhere((s) => s == m);
  }

  final added = List.filled(12, 0), asked = List.filled(12, 0), shown = List.filled(12, 0);
  for (final p in homes) {
    final w = weekOf(_day(p.added));
    if (w >= 0) added[w]++;
  }
  // Homes, like the tiles: each home in the week it was first asked about,
  // and in each week it had a viewing.
  final firstAsked = <String, String>{};
  for (final i in mine) {
    if (i.direction == 'out') firstAsked.putIfAbsent(i.propertyId!, () => i.at);
  }
  for (final at in firstAsked.values) {
    final w = weekOf(_day(at));
    if (w >= 0) asked[w]++;
  }
  for (final (w, _) in {for (final v in seen) (weekOf(_day(v.at)), v.propertyId)}) {
    if (w >= 0) shown[w]++;
  }
  final weeks = [
    for (var w = 0; w < 12; w++)
      WeekCount(weekStarts[w], added: added[w], enquiries: asked[w], viewings: shown[w]),
  ];

  // Prices.
  PriceSpread? prices;
  final priced = [for (final p in homes) ?p.price];
  if (priced.isNotEmpty) {
    final low = priced.reduce((a, b) => a < b ? a : b), high = priced.reduce((a, b) => a > b ? a : b);
    final likedPrices = [for (final p in liked) ?p.price];
    const n = 5;
    final width = high == low ? 1 : ((high - low) / n).ceil();
    final counts = List.filled(n, 0);
    for (final x in priced) {
      counts[((x - low) ~/ width).clamp(0, n - 1)]++;
    }
    final bins = [
      for (var b = 0; b < n; b++)
        if (high != low || b == 0)
          (
            from: low + b * width,
            to: high == low ? high : low + (b + 1) * width,
            count: high == low ? priced.length : counts[b],
          ),
    ];
    prices = PriceSpread(
      low: low,
      median: _median(priced),
      high: high,
      bins: bins,
      likedMedian: likedPrices.isEmpty ? null : _median(likedPrices),
      budget: budget,
      overBudget: budget == null ? 0 : priced.where((x) => x > budget).length,
    );
  }

  // Bedrooms.
  final bedCounts = <int, int>{};
  for (final p in homes) {
    if (p.beds case final b?) bedCounts[b] = (bedCounts[b] ?? 0) + 1;
  }
  final beds = [
    for (final e in (bedCounts.entries.toList()..sort((a, b) => a.key.compareTo(b.key))))
      (beds: e.key, count: e.value),
  ];

  // Distances, from the homes the user likes when there are any.
  final measured = liked.isNotEmpty ? liked : homes;
  final distances = <({String place, double km})>[];
  for (final pl in places) {
    final kms = [
      for (final p in measured)
        if (p.lat != null && p.lon != null) distanceKm(pl.lat, pl.lon, p.lat!, p.lon!),
    ];
    if (kms.isNotEmpty) distances.add((place: pl.label.isEmpty ? 'Home' : pl.label, km: _medianD(kms)));
  }

  // Districts.
  final districtCounts = <String, int>{};
  for (final p in homes) {
    if (district(p.postcode) case final d?) districtCounts[d] = (districtCounts[d] ?? 0) + 1;
  }
  final districts = [
    for (final e in (districtCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).take(5))
      (district: e.key, count: e.value),
  ];

  // Agents, from the log: each message to them, and the next reply.
  final names = {for (final c in contacts) c.id: c.organisation.isNotEmpty ? c.organisation : c.name};
  final byAgent = <String, List<Interaction>>{};
  for (final i in talk) {
    final agent = i.contactId ?? byId[i.propertyId]?.agentId;
    if (agent != null && names.containsKey(agent)) (byAgent[agent] ??= []).add(i);
  }
  final agents = <AgentRecord>[];
  for (final MapEntry(key: id, value: log) in byAgent.entries) {
    final sent = log.where((i) => i.direction == 'out').toList();
    if (sent.isEmpty) continue;
    final gaps = <double>[];
    var waiting = 0;
    for (final s in sent) {
      final sentAt = DateTime.tryParse(s.at);
      final reply = log.where((i) => i.direction == 'in' && i.at.compareTo(s.at) > 0).firstOrNull;
      final replyAt = reply == null ? null : DateTime.tryParse(reply.at);
      if (sentAt != null && replyAt != null) {
        gaps.add(replyAt.difference(sentAt).inMinutes / 60);
      } else if (reply == null && now.difference(_day(s.at)).inDays >= 7) {
        waiting++;
      }
    }
    agents.add(
      AgentRecord(
        name: names[id]!,
        sent: sent.length,
        replies: log.where((i) => i.direction == 'in').length,
        waiting: waiting,
        replyHours: gaps.isEmpty ? null : gaps.reduce((a, b) => a + b) / gaps.length,
      ),
    );
  }
  agents.sort((a, b) => b.sent.compareTo(a.sent));

  // Homes the advert says are gone, short of the user agreeing one.
  final gone = [
    for (final p in homes)
      if (listingGone(p.listingStatus) && Stage.of(p.stage) != Stage.agreed) p,
  ];
  final goneBeforeEnquiry = [
    for (final p in gone)
      if (!askedIds.contains(p.id) && reached(p) < Stage.enquired.index) p,
  ];

  // To do.
  final todayIso = now.toIso8601String().substring(0, 10);
  final todo = <ToDo>[];
  for (final i in talk) {
    final due = i.followUp;
    if (due == null || due.compareTo(todayIso) > 0) continue;
    final later = talk.any(
      (o) =>
          o.at.compareTo(i.at) > 0 &&
          ((i.propertyId != null && o.propertyId == i.propertyId) ||
              (i.contactId != null && o.contactId == i.contactId)),
    );
    if (later) continue;
    final where = byId[i.propertyId]?.address ?? names[i.contactId] ?? 'a contact';
    todo.add(
      ToDo(
        'Follow up: $where${due == todayIso ? ' (today)' : ' (due $due)'}',
        propertyId: i.propertyId,
        urgent: true,
      ),
    );
  }
  final soon = nowLocal.add(const Duration(days: 7));
  for (final v in seen) {
    final at = DateTime.tryParse(v.at);
    if (at == null) continue;
    final p = byId[v.propertyId]!;
    if (!at.isBefore(nowLocal) && at.isBefore(soon) && v.status == 'booked') {
      todo.add(ToDo('Viewing ${v.at.replaceFirst('T', ' ')}: ${p.address}', propertyId: p.id));
    } else if (at.isBefore(nowLocal) && v.status == 'booked') {
      todo.add(ToDo('Viewing passed: mark it done or cancelled: ${p.address}', propertyId: p.id));
    }
  }
  for (final p in homes) {
    if (Stage.of(p.stage) == Stage.shortlisted && !askedIds.contains(p.id) && !listingGone(p.listingStatus)) {
      todo.add(ToDo('Liked, not asked about yet: ${p.address}', propertyId: p.id));
    }
  }

  final firstAdded = homes.isEmpty
      ? null
      : homes.map((p) => _day(p.added)).reduce((a, b) => a.isBefore(b) ? a : b);
  return HuntSummary(
    kind: kind,
    homes: homes,
    liked: liked,
    enquired: enquired,
    viewings: seen.length,
    addedThisWeek: added.last,
    enquiriesThisWeek: asked.last,
    viewingsThisWeek: shown.last,
    daysHunting: firstAdded == null ? null : now.difference(firstAdded).inDays,
    funnel: funnel,
    dropped: dropped,
    weeks: weeks,
    prices: prices,
    beds: beds,
    distances: distances,
    districts: districts,
    agents: agents,
    gone: gone,
    goneBeforeEnquiry: goneBeforeEnquiry,
    todo: todo,
  );
}

String _gbp(int v) {
  final s = v.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  return '£$s';
}

String _homes(int n) => n == 1 ? '1 home' : '$n homes';

List<String> _insights(HuntSummary s) {
  final kind = s.kind;
  final out = <String>[];
  final p = s.prices;
  if (p != null && p.budget != null && p.budget! > 0) {
    final ref = p.likedMedian ?? p.median;
    final who = p.likedMedian != null ? 'Homes you like' : 'Homes you saved';
    final diff = ((ref - p.budget!) / p.budget! * 100).round();
    out.add(
      diff == 0
          ? '$who sit right at your budget of ${_gbp(p.budget!)}.'
          : '$who are ${_gbp(ref)} at the middle, ${diff.abs()}% ${diff < 0 ? 'under' : 'over'} your budget of ${_gbp(p.budget!)}.',
    );
  } else if (p != null && p.low == p.high) {
    out.add('Every priced home you saved is ${_gbp(p.low)}.');
  } else if (p != null) {
    out.add('Prices run from ${_gbp(p.low)} to ${_gbp(p.high)}, ${_gbp(p.median)} in the middle.');
  }
  final asked = s.enquired.length;
  final viewed = s.funnel[Stage.viewing.index].count;
  if (asked > 0) out.add('$viewed of $asked ${asked == 1 ? 'enquiry' : 'enquiries'} led to a viewing.');
  if (s.goneBeforeEnquiry.isNotEmpty) {
    out.add(
      '${_homes(s.goneBeforeEnquiry.length)} you saved went ${kind == PropertyKind.rent ? 'let' : 'sold'} '
      'before you asked about ${s.goneBeforeEnquiry.length == 1 ? 'it' : 'them'}. Good homes go fast: ask sooner.',
    );
  }
  final silent = s.agents.where((a) => a.waiting > 0).length;
  if (silent > 0) out.add('$silent ${silent == 1 ? 'agent has' : 'agents have'} not replied in a week.');
  if (s.districts.isNotEmpty && s.homes.length >= 3) {
    final top = s.districts.first;
    out.add('Most of your homes are in ${top.district} (${top.count} of ${s.homes.length}).');
  }
  final recent = s.weeks.skip(8).fold(0, (n, w) => n + w.added);
  if (recent > 0) out.add('You saved ${_homes(recent)} in the last four weeks.');
  if (s.distances.isNotEmpty) {
    final d = s.distances.first;
    out.add(
      '${s.liked.isNotEmpty ? 'Liked homes' : 'Your homes'} are ${d.km.toStringAsFixed(1)} km from ${d.place} at the middle.',
    );
  }
  return out.take(5).toList();
}
