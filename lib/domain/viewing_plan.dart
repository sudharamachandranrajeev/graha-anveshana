import '../db/database.dart';
import 'listing.dart';
import 'pipeline.dart';

/// Viewings in order, day by day, with warnings where two are too close
/// to get from one to the next, and calendar files for them.

/// How long a viewing is taken to last, in minutes.
const viewingMinutes = 30;

/// A viewing with the home it is at.
typedef BookedViewing = ({Viewing viewing, Property home});

/// One day's viewings in time order, and what is wrong between them.
class ViewingDay {
  const ViewingDay(this.day, this.viewings, this.clashes);

  /// yyyy-MM-dd.
  final String day;
  final List<BookedViewing> viewings;

  /// Plain warnings, one per pair of viewings too close together.
  final List<String> clashes;
}

/// Minutes to travel [km] between two viewings: town driving, a little
/// slower than the map's straight line suggests, and never under 5.
int travelMinutes(double km) => (km * 1.3 / 30 * 60).round().clamp(5, 24 * 60);

/// The booked viewings from [today] on, by day, with clash warnings.
List<ViewingDay> planViewings(List<Viewing> viewings, List<Property> homes, {required String today}) {
  final byId = {for (final p in homes) p.id: p};
  final booked = [
    for (final v in viewings)
      if (v.status == 'booked' && v.at.length >= 16 && v.at.substring(0, 10).compareTo(today) >= 0)
        if (byId[v.propertyId] case final p?) (viewing: v, home: p),
  ]..sort((a, b) => a.viewing.at.compareTo(b.viewing.at));
  final days = <String, List<BookedViewing>>{};
  for (final b in booked) {
    (days[b.viewing.at.substring(0, 10)] ??= []).add(b);
  }
  return [
    for (final MapEntry(key: day, value: list) in days.entries)
      ViewingDay(day, list, [for (var i = 1; i < list.length; i++) ?_clash(list[i - 1], list[i])]),
  ];
}

String? _clash(BookedViewing a, BookedViewing b) {
  final gap = DateTime.parse(b.viewing.at).difference(DateTime.parse(a.viewing.at)).inMinutes;
  final (from, to) = (a.home, b.home);
  final km = from.lat == null || from.lon == null || to.lat == null || to.lon == null
      ? null
      : distanceKm(from.lat!, from.lon!, to.lat!, to.lon!);
  final travel = km == null ? 0 : travelMinutes(km);
  final need = viewingMinutes + travel;
  if (gap >= need) return null;
  final first = _street(from), second = _street(to);
  final when = '${a.viewing.at.substring(11, 16)} and ${b.viewing.at.substring(11, 16)}';
  if (gap < viewingMinutes) {
    return '$first and $second overlap ($when): a viewing takes about $viewingMinutes minutes.';
  }
  return '$first to $second ($when): $gap minutes between them, but the viewing and about $travel minutes '
      'of travel need $need.';
}

String _street(Property p) => p.address.split(',').first;

/// [items] as an iCalendar file any calendar app can import. Times are the
/// local wall-clock times the viewings were booked at.
String viewingsIcs(List<BookedViewing> items, {required DateTime stamp}) {
  String local(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}${_pad(d.month)}${_pad(d.day)}T${_pad(d.hour)}${_pad(d.minute)}00';
  final utc = stamp.toUtc();
  final lines = [
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'PRODID:-//Graha Anveshana//Viewings//EN',
    'CALSCALE:GREGORIAN',
    for (final (:viewing, :home) in items) ...[
      'BEGIN:VEVENT',
      'UID:${viewing.id}@anveshana',
      'DTSTAMP:${local(utc)}Z',
      'DTSTART:${local(DateTime.parse(viewing.at))}',
      'DTEND:${local(DateTime.parse(viewing.at).add(const Duration(minutes: viewingMinutes)))}',
      'SUMMARY:${_text('Viewing: ${_street(home)}')}',
      'LOCATION:${_text([home.address, if (home.postcode.isNotEmpty && !home.address.contains(home.postcode)) home.postcode].join(', '))}',
      if (home.url.isNotEmpty) 'URL:${home.url}',
      if (viewing.notes.isNotEmpty) 'DESCRIPTION:${_text(viewing.notes)}',
      'END:VEVENT',
    ],
    'END:VCALENDAR',
  ];
  return '${lines.map(_fold).join('\r\n')}\r\n';
}

String _pad(int n) => n.toString().padLeft(2, '0');

String _text(String s) => s
    .replaceAll(r'\', r'\\')
    .replaceAll(';', r'\;')
    .replaceAll(',', r'\,')
    .replaceAll(RegExp(r'\r?\n'), r'\n');

/// Lines over 75 characters continue on the next, after a space.
String _fold(String line) {
  if (line.length <= 75) return line;
  final parts = [line.substring(0, 75)];
  for (var i = 75; i < line.length; i += 74) {
    parts.add(' ${line.substring(i, i + 74 > line.length ? line.length : i + 74)}');
  }
  return parts.join('\r\n');
}

/// A Google Calendar page with the viewing filled in, for phones, where a
/// file is awkward to open.
Uri googleCalendarLink(BookedViewing b) {
  final start = DateTime.parse(b.viewing.at);
  String t(DateTime d) => '${d.year}${_pad(d.month)}${_pad(d.day)}T${_pad(d.hour)}${_pad(d.minute)}00';
  return Uri.https('calendar.google.com', '/calendar/render', {
    'action': 'TEMPLATE',
    'text': 'Viewing: ${_street(b.home)}',
    'dates': '${t(start)}/${t(start.add(const Duration(minutes: viewingMinutes)))}',
    'location': b.home.address,
    if (b.home.url.isNotEmpty) 'details': b.home.url,
  });
}

/// The shortlist as plain text to send to someone: homes in play by stage,
/// with price, size, rating, the verdict after a viewing and the advert
/// link. No agents, phone numbers or notes.
String shortlistText(
  List<Property> homes,
  PropertyKind kind, {
  Map<String, Impression> impressions = const {},
  required String today,
}) {
  final out = StringBuffer(
    'Homes ${kind == PropertyKind.rent ? 'to rent' : 'to buy'} on my shortlist (${_niceDay(today)})\n',
  );
  for (final stage in Stage.values) {
    if (!stage.active) continue;
    final rows = [
      for (final p in homes)
        if (p.kind == kind.name && Stage.of(p.stage) == stage) p,
    ]..sort((a, b) => b.rating.compareTo(a.rating));
    if (rows.isEmpty) continue;
    out.write('\n${stage.label(kind)} (${rows.length})\n');
    for (final p in rows) {
      final facts = [
        if (p.price != null) '£${p.price}${kind == PropertyKind.rent ? ' a month' : ''}',
        if (p.beds != null) p.beds == 0 ? 'studio' : '${p.beds} bed',
        if (p.style.isNotEmpty) p.style.toLowerCase(),
        if (p.rating > 0) '${p.rating} of 5',
        if (impressions[p.id] case final i?) 'after viewing: ${i.label.toLowerCase()}',
      ];
      out.write('- ${p.address}${facts.isEmpty ? '' : ': ${facts.join(', ')}'}\n');
      if (p.url.isNotEmpty) out.write('  ${p.url}\n');
    }
  }
  return out.toString();
}

String _niceDay(String iso) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final d = DateTime.parse(iso);
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}
