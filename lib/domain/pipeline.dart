import 'package:brahma_core/brahma_core.dart' show daysBetween;

/// What the user is doing with a property.
enum PropertyKind {
  rent('To rent'),
  buy('To buy'),
  owned('Owned');

  const PropertyKind(this.label);
  final String label;

  static PropertyKind of(String name) => values.where((k) => k.name == name).firstOrNull ?? rent;
}

/// Steps of a hunt, in order. Lets and purchases share them; a few read
/// differently for each.
enum Stage {
  fresh('new'),
  shortlisted('shortlisted'),
  enquired('enquired'),
  viewing('viewing'),
  applied('applied'),
  agreed('agreed'),
  dropped('dropped');

  const Stage(this.id);
  final String id;

  static Stage of(String id) => values.where((s) => s.id == id).firstOrNull ?? fresh;

  String label(PropertyKind kind) => switch (this) {
    fresh => 'New',
    shortlisted => 'Liked',
    enquired => 'Enquired',
    viewing => 'Viewing',
    applied => kind == PropertyKind.buy ? 'Offer made' : 'Applied',
    agreed => kind == PropertyKind.buy ? 'Sale agreed' : 'Let agreed',
    dropped => 'Not for us',
  };

  /// Still in play.
  bool get active => this != dropped;
}

/// Readable advert status ("toLet" -> "To let").
String listingStatusLabel(String key) => switch (key) {
  'toLet' => 'To let',
  'letAgreed' => 'Let agreed',
  'let' => 'Let',
  'forSale' => 'For sale',
  'saleAgreed' => 'Sale agreed',
  'sold' => 'Sold',
  '' => '',
  _ => key,
};

/// Whether an advert says the property is gone.
bool listingGone(String key) => const {'letAgreed', 'let', 'saleAgreed', 'sold', 'withdrawn'}.contains(key);

/// How many days it is since you last contacted an agent about a property
/// with nothing back, or null when they replied or you have not written.
/// [log] holds (channel, direction, local time yyyy-MM-ddTHH:mm); notes and
/// visits are not messages. [today] is yyyy-MM-dd.
int? daysWithoutReply(Iterable<({String channel, String direction, String at})> log, String today) {
  const messages = {'call', 'sms', 'whatsapp', 'email'};
  String? lastOut, lastIn;
  for (final i in log) {
    if (!messages.contains(i.channel)) continue;
    final day = i.at.substring(0, 10);
    if (i.direction == 'in') {
      if (lastIn == null || day.compareTo(lastIn) > 0) lastIn = day;
    } else if (lastOut == null || day.compareTo(lastOut) > 0) {
      lastOut = day;
    }
  }
  if (lastOut == null || (lastIn != null && lastIn.compareTo(lastOut) >= 0)) return null;
  return daysBetween(today, lastOut);
}

/// A chase is worth suggesting after this many days of silence.
const chaseAfterDays = 4;
