import '../db/database.dart';
import 'property_search.dart' show byKnown;

/// The orders the Hunt shows each stage's homes in.
enum HuntSort {
  nearest('Nearest home'),
  rating('Highest rated'),
  priceLow('Price, lowest first'),
  priceHigh('Price, highest first'),
  beds('Most bedrooms'),
  added('Newest added');

  const HuntSort(this.label);
  final String label;

  static HuntSort? ofName(String? name) => values.where((s) => s.name == name).firstOrNull;

  /// Compares two homes; [distance] is how far each is from home.
  int compare(Property a, Property b, double? Function(Property p) distance) {
    final c = switch (this) {
      nearest => byKnown(distance(a), distance(b)),
      rating => b.rating.compareTo(a.rating),
      priceLow => byKnown(a.price, b.price),
      priceHigh => byKnown(a.price, b.price, descending: true),
      beds => byKnown(a.beds, b.beds, descending: true),
      added => b.added.compareTo(a.added),
    };
    return c != 0 ? c : byKnown(distance(a), distance(b));
  }
}

/// Narrowing the saved homes on the Hunt page. The portals' own filters
/// cannot see what the user has learned (notes such as "pets ok" or "no
/// parking"), so the words are matched against the notes as well as the
/// address, postcode, type and furnishing.
class HuntFilter {
  const HuntFilter({this.words = '', this.minBeds, this.maxPrice});
  final String words;
  final int? minBeds, maxPrice;

  bool get isEmpty => words.trim().isEmpty && minBeds == null && maxPrice == null;

  /// Every word must appear; a word starting with "-" must not.
  bool matches(Property p) {
    if (minBeds != null && (p.beds ?? -1) < minBeds!) return false;
    if (maxPrice != null && (p.price == null || p.price! > maxPrice!)) return false;
    final hay = [p.address, p.postcode, p.style, p.furnished, p.notes].join(' ').toLowerCase();
    for (final w in words.toLowerCase().split(RegExp(r'\s+')).where((w) => w.isNotEmpty)) {
      if (w.startsWith('-')) {
        if (w.length > 1 && hay.contains(w.substring(1))) return false;
      } else if (!hay.contains(w)) {
        return false;
      }
    }
    return true;
  }
}
