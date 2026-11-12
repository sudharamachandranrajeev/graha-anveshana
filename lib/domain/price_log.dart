import 'dart:convert';

import 'listing.dart';

/// What the app learns about a saved home each time a site shows it: its
/// price over time, when it was last seen, when it first went on the
/// market and its floor area. Kept in the home's `meta` JSON, so it syncs
/// with the home and needs no table of its own.

typedef PricePoint = ({String at, int price});

/// The facts kept for one home.
class MarketFacts {
  const MarketFacts({this.prices = const [], this.seen, this.listedOn, this.sqft});

  /// Prices in the order seen; a new point only when the price changed.
  final List<PricePoint> prices;

  /// When a site last showed it, and first listed it (yyyy-MM-dd).
  final String? seen, listedOn;
  final int? sqft;

  static MarketFacts of(String meta) {
    final Object? j;
    try {
      j = jsonDecode(meta);
    } on FormatException {
      return const MarketFacts();
    }
    if (j is! Map) return const MarketFacts();
    return MarketFacts(
      prices: [
        if (j['prices'] case final List all)
          for (final p in all)
            if (p case {'at': final String at, 'price': final num price}) (at: at, price: price.round()),
      ],
      seen: j['seen'] as String?,
      listedOn: j['listedOn'] as String?,
      sqft: (j['sqft'] as num?)?.round(),
    );
  }

  /// The change from the first price seen to the last: negative is a cut.
  int? get change => prices.length < 2 ? null : prices.last.price - prices.first.price;

  /// "£50 less since 3 Nov", or null when the price has not changed.
  String? get changeText {
    final c = change;
    if (c == null || c == 0) return null;
    final d = DateTime.parse(prices.first.at);
    return '£${c.abs()} ${c < 0 ? 'less' : 'more'} since ${d.day} ${_months[d.month - 1]}';
  }

  /// No site has shown it for [days] days although it was still advertised:
  /// it may be gone. Homes the app has never seen in Search are not judged.
  bool mayBeGone(String today, {int days = 14}) =>
      seen != null && DateTime.parse(today).difference(DateTime.parse(seen!)).inDays >= days;
}

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// [meta] with [l] seen on [today]: the price logged when it changed, the
/// day seen, the earliest listing date and the floor area kept.
Map<String, Object?> withSeen(Map<String, Object?> meta, Listing l, String today) {
  final before = MarketFacts.of(jsonEncode(meta));
  final listed = [?before.listedOn, ?l.listedOn]..sort();
  return {
    ...meta,
    'seen': today,
    if (l.price != null && before.prices.lastOrNull?.price != l.price)
      'prices': [
        for (final p in before.prices) {'at': p.at, 'price': p.price},
        {'at': today, 'price': l.price},
      ],
    if (listed.isNotEmpty) 'listedOn': listed.first,
    if ((before.sqft ?? l.sqft ?? sqftIn(l.description)) case final int a) 'sqft': a,
  };
}
