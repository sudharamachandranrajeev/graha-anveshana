import 'package:anveshana/domain/advert_check.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> titles(String text, {int? rent}) => [
  for (final f in checkAdvertText(text, monthlyRent: rent)) f.title,
];

void main() {
  test('a clean advert has no flags', () {
    expect(
      titles('Bright 2 bed flat near the station. £750 pcm. Deposit £865. Available now.', rent: 750),
      isEmpty,
    );
  });

  test('bidding, benefits and family bans are caught', () {
    expect(titles('Best offers over £800 considered'), ['Rent bidding']);
    expect(titles('Sorry, no DSS. No children.'), [
      'Refuses tenants on benefits',
      'Refuses families with children',
    ]);
    expect(titles('Professionals only, no families'), contains('Refuses families with children'));
  });

  test('advance rent and fees are caught', () {
    expect(titles('Six months rent in advance required'), ['More than a month of rent in advance']);
    expect(titles('1 month rent in advance'), isEmpty);
    expect(titles('Referencing fee £250, admin fee £100'), ['A fee that tenants cannot be charged']);
  });

  test('scam signs are caught', () {
    expect(titles('Landlord is abroad, keys will be posted after deposit'), ['The home cannot be viewed']);
    expect(titles('Pay deposit before viewing by bank transfer'), [
      'Asks for money before you can see the home',
    ]);
  });

  test('the deposit and holding deposit are tested against the legal limits', () {
    // £650 a month: a week is £150, so five weeks is £750.
    expect(titles('Deposit of £750. Holding deposit £150.', rent: 650), isEmpty);
    expect(titles('Deposit: £1,300', rent: 650), ['Deposit above the legal limit']);
    expect(titles('Holding deposit of £325 to reserve', rent: 650), [
      'Holding deposit above one week\'s rent',
    ]);
    expect(titles('Deposit £1,300'), isEmpty, reason: 'no rent, no test');
  });

  test('old tenancy wording is marked out of date', () {
    expect(titles('12 month fixed term AST'), ['Old-style tenancy wording']);
  });
}
