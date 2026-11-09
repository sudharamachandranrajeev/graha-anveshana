import 'listing.dart';
import 'search_request.dart';

/// A home the user kept or turned down, as the taste learns from it.
/// [weight] is how much they liked it: above 0 kept (more for a high rating
/// or a later stage), below 0 turned down.
typedef KeptHome = ({int? price, int? beds, String postcode, String text, double weight});

/// What the homes the user keeps have in common, learnt on the device from
/// the homes in their Hunt. It puts homes like them first in Search
/// ("For you") and marks the close ones. Nothing leaves the device.
class Taste {
  const Taste._({this.price, this.beds, this.districts = const {}, this.words = const {}, this.count = 0});

  static const none = Taste._();

  /// The middle price of the kept homes.
  final int? price;

  /// The bedrooms most kept homes have.
  final int? beds;

  /// Postcode districts, weighted by how much homes there were liked.
  final Map<String, double> districts;

  /// Features (garden, parking, flat...), weighted: below 0 when the user
  /// turns down homes that have them.
  final Map<String, double> words;

  /// Homes kept.
  final int count;

  /// Enough kept homes to sort by: three.
  bool get strong => count >= 3;

  static Taste learn(Iterable<KeptHome> homes) {
    final kept = homes.where((h) => h.weight > 0).toList();
    if (kept.isEmpty) return none;
    final prices = [for (final h in kept) ?h.price]..sort();
    final bedCount = <int, double>{};
    for (final h in kept) {
      if (h.beds != null) bedCount[h.beds!] = (bedCount[h.beds!] ?? 0) + h.weight;
    }
    final districts = <String, double>{};
    final words = <String, double>{};
    for (final h in homes) {
      final d = outcodeIn(h.postcode) ?? outcodeIn(h.text.split('\n').first);
      if (d != null) districts[d] = (districts[d] ?? 0) + h.weight;
      for (final w in featuresIn(h.text)) {
        words[w] = (words[w] ?? 0) + h.weight;
      }
    }
    return Taste._(
      price: prices.isEmpty ? null : prices[prices.length ~/ 2],
      beds: bedCount.isEmpty
          ? null
          : (bedCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first.key,
      districts: districts,
      words: words,
      count: kept.length,
    );
  }

  /// How like the kept homes a home is, from 0 to 1: its price, bedrooms,
  /// district and features. Parts the home does not say are left out.
  double likeness({int? price, int? beds, String postcode = '', String text = ''}) {
    if (count == 0) return 0;
    var sum = 0.0, weights = 0.0;
    void part(double score, double weight) {
      sum += score.clamp(0, 1) * weight;
      weights += weight;
    }

    if (this.price != null && price != null && this.price! > 0) {
      part(1 - (price - this.price!).abs() / this.price!, 0.35);
    }
    if (this.beds != null && beds != null) {
      part(switch ((beds - this.beds!).abs()) {
        0 => 1.0,
        1 => 0.5,
        _ => 0.0,
      }, 0.25);
    }
    final top = districts.values.fold(0.0, (a, b) => a > b ? a : b);
    final d = outcodeIn(postcode) ?? outcodeIn(text.split('\n').first);
    if (top > 0 && d != null) part((districts[d] ?? 0) / top, 0.2);
    final liked = words.values.where((v) => v > 0).fold(0.0, (a, b) => a + b);
    if (liked > 0) {
      final has = featuresIn(text);
      part(has.fold(0.0, (a, w) => a + (words[w] ?? 0)) / liked, 0.2);
    }
    return weights == 0 ? 0 : sum / weights;
  }
}

/// The asked-for features ([featureWords]) a home's text mentions.
Set<String> featuresIn(String text) => {
  for (final m in RegExp(r"[a-z][a-z'-]*").allMatches(text.toLowerCase()))
    if (featureWords.contains(m[0])) m[0]!,
};

/// The search the user makes most: of the place and kind searched most
/// often in [history] (newest first), the newest. Null for no history.
SearchRequest? usualSearch(List<SearchRequest> history) {
  final count = <String, int>{};
  String key(SearchRequest q) => '${q.area.toLowerCase()}|${q.rent}';
  for (final q in history) {
    if (!q.isEmpty) count[key(q)] = (count[key(q)] ?? 0) + 1;
  }
  if (count.isEmpty) return null;
  final best = count.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  return history.firstWhere((q) => key(q) == best);
}
