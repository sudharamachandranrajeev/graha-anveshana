import 'catalog.dart';
import 'listing.dart';
import 'search_request.dart';

/// One home in the search results, with every site that lists it.
class FoundHome {
  FoundHome(Listing first) : copies = [first];

  /// Each site's advert for this home; the first is the one shown.
  final List<Listing> copies;
  Listing get main => copies.first;

  double? km;
  double score = 1;
  List<String> misses = const [];

  /// Sites listing it, for the card ("Rightmove, OpenRent").
  Set<String> get sources => {for (final c in copies) c.source};

  /// The details all copies say, gaps in one filled from another.
  int? get price => copies.map((c) => c.price).nonNulls.firstOrNull;
  int? get beds => copies.map((c) => c.beds).nonNulls.firstOrNull;
  String? get image => copies.map((c) => c.image).nonNulls.firstOrNull;
  double? get lat => copies.map((c) => c.lat).nonNulls.firstOrNull;
  double? get lon => copies.map((c) => c.lon).nonNulls.firstOrNull;
  String get text =>
      copies.map((c) => '${c.address}\n${c.style}\n${c.furnished}\n${c.description}').join('\n');
  bool get gone => copies.every((c) => c.status.contains('Agreed') || c.status == 'sold');
}

ItemKey _key(Listing l) => ItemKey(
  id: '${l.source}:${l.sourceId}',
  url: l.url,
  source: l.source,
  sourceId: l.sourceId,
  address: l.address,
  postcode: l.postcode,
  price: l.price,
  beds: l.beds,
);

/// The same home on two sites: the shared rules (same advert, address,
/// postcode with beds and price), or the same spot on the map with the same
/// bedrooms and nearly the same price, as the sites rarely share a full address.
bool sameListedHome(Listing a, Listing b) {
  // One site does not list a home twice: its own ids decide.
  if (a.source == b.source) return a.sourceId == b.sourceId;
  if (sameHome(_key(a), _key(b)) != null) return true;
  if (a.lat == null || b.lat == null || a.beds == null || a.beds != b.beds) return false;
  if (a.price == null || b.price == null) return false;
  final hi = a.price! > b.price! ? a.price! : b.price!;
  if ((a.price! - b.price!).abs() > hi * 0.05) return false;
  return distanceKm(a.lat!, a.lon!, b.lat!, b.lon!) <= 0.04;
}

/// Adds [items] to [homes], folding each into the home it duplicates.
void mergeListings(List<FoundHome> homes, Iterable<Listing> items) {
  for (final l in items) {
    final same = homes.where((h) => h.copies.any((c) => sameListedHome(c, l))).firstOrNull;
    if (same == null) {
      homes.add(FoundHome(l));
    } else if (!same.copies.any((c) => c.source == l.source && c.sourceId == l.sourceId)) {
      same.copies.add(l);
    }
  }
}

/// Whether [h] answers [q] at all: the hard limits (price, bedrooms,
/// distance, words it must not mention, let or sold). Unknown details pass.
bool meetsRequest(FoundHome h, SearchRequest q) {
  if (!q.includeGone && h.gone) return false;
  final price = h.price, beds = h.beds;
  if (q.maxPrice != null && price != null && price > q.maxPrice!) return false;
  if (q.minPrice != null && price != null && price < q.minPrice!) return false;
  if (q.minBeds != null && beds != null && beds < q.minBeds!) return false;
  if (q.maxBeds != null && beds != null && beds > q.maxBeds!) return false;
  if (q.radiusMiles != null && h.km != null && h.km! > q.radiusMiles! * 1.609344) return false;
  final text = h.text.toLowerCase();
  if (q.mustNot.any((w) => text.contains(w))) return false;
  return true;
}

/// The homes that answer [q], best first: those that mention every asked-for
/// word, then nearest, then cheapest. [centreLat]/[centreLon] measure distance.
List<FoundHome> rankHomes(List<FoundHome> homes, SearchRequest q, {double? centreLat, double? centreLon}) {
  final c = q.criteria(lat: centreLat, lon: centreLon);
  for (final h in homes) {
    h.km = centreLat == null || h.lat == null ? null : distanceKm(centreLat, centreLon!, h.lat!, h.lon!);
    final f = fit(c, monthlyOrPrice: h.price, beds: h.beds, km: h.km, text: h.text);
    h
      ..score = f.score
      ..misses = f.misses;
  }
  final kept = homes.where((h) => meetsRequest(h, q)).toList();
  kept.sort((a, b) {
    final s = b.score.compareTo(a.score);
    if (s != 0) return s;
    if (a.km != null && b.km != null) {
      final d = a.km!.compareTo(b.km!);
      if (d != 0) return d;
    }
    return (a.price ?? 1 << 30).compareTo(b.price ?? 1 << 30);
  });
  return kept;
}
