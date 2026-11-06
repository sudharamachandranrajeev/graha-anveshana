import '../db/database.dart';

/// Narrowing the saved homes on the Homes page. The portals' own filters
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
