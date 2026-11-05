import 'package:anveshana/domain/price_check.dart';
import 'package:anveshana/domain/research.dart';
import 'package:flutter_test/flutter_test.dart';

Sale sale(String date, int price, String type) => Sale(date: date, price: price, address: 'x', type: type);
const doncaster = Place(postcode: 'DN1 1AA', lat: 53.5, lon: -1.1, country: 'England', district: 'Doncaster');

void main() {
  test('rent is compared with the ONS average for the size and with housing benefit', () {
    final lines = rentCheck(rent: 750, beds: 2, place: doncaster);
    expect(lines[0].value, '+17% on 641');
    expect(lines[0].verdict, Verdict.above);
    expect(lines[1].value, '£250 a month short');
    final cheap = rentCheck(rent: 480, beds: 2, place: doncaster);
    expect(cheap[0].verdict, Verdict.below);
    expect(cheap[1].value, 'covers the rent');
    const nowhere = Place(postcode: 'X', lat: 0, lon: 0, country: 'England');
    expect(rentCheck(rent: 500, place: nowhere), isEmpty);
  });

  test('a price is compared with similar recent sales, else with every type', () {
    final sales = [
      sale('2026-03-01', 100000, 'terraced'),
      sale('2025-05-01', 110000, 'terraced'),
      sale('2024-07-01', 120000, 'terraced'),
      sale('2026-01-01', 300000, 'detached'),
      sale('2018-01-01', 50000, 'terraced'),
    ];
    final same = priceCheck(price: 130000, style: 'Terrace', today: '2026-11-05', sales: sales);
    expect(same.single.label, contains('3 similar sales'));
    expect(same.single.value, '+18%');
    expect(same.single.verdict, Verdict.above);
    final mixed = priceCheck(price: 130000, style: 'Bungalow', today: '2026-11-05', sales: sales);
    expect(mixed.single.label, contains('4 sales'));
    expect(mixed.single.note, contains('Mixed types'));
  });

  test('the area average for the type is used when the index has it', () {
    const idx = PriceIndex(
      region: 'Doncaster',
      month: '2026-08',
      average: 173000,
      byType: {'Terraced': 135000},
    );
    final l = priceCheck(price: 135000, style: 'Terraced house', today: '2026-11-05', sales: [], index: idx);
    expect(l.last.verdict, Verdict.inLine);
    expect(l.last.label, contains('terraced average'));
    expect(l.first.value, '0', reason: 'no sales is said, not hidden');
    expect(l.first.verdict, Verdict.info);
  });

  test('move-in costs follow the five-week deposit cap', () {
    final c = moveInCosts(650);
    expect(c.holding, 150); // 650 * 12 / 52 = 150.0
    expect(c.deposit, 750);
    expect(c.total, 1400);
    expect(moveInCosts(5000).deposit, (5000 * 12 / 52 * 6).floor());
  });
}
