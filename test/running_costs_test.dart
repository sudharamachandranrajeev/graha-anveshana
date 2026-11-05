import 'dart:convert';

import 'package:anveshana/domain/running_costs.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hunt_filter_test.dart' show home;

void main() {
  test('running costs live in the extras and keep other keys', () {
    final meta = withRunningCosts('{"description":"Nice"}', councilTax: 120, bills: 150);
    expect(jsonDecode(meta), {'description': 'Nice', 'councilTax': 120, 'bills': 150});
    expect(jsonDecode(withRunningCosts(meta, councilTax: 120)), {'description': 'Nice', 'councilTax': 120});
    expect(withRunningCosts('not json', councilTax: 5), '{"councilTax":5}');
    final p = home(price: 650).copyWith(meta: meta);
    expect(runningCosts(p), (councilTax: 120, bills: 150));
    expect(allInMonthly(p), 920);
    expect(allInMonthly(home()), isNull);
    expect(allInMonthly(home(price: 500)), 500);
  });
}
