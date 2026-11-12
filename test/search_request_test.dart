import 'package:anveshana/domain/search_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a full request becomes its filters', () {
    final r = readRequest('2 bed to rent in Leeds under £900 within 2 miles with parking, no students');
    expect((r.area, r.rent, r.minBeds, r.maxBeds, r.maxPrice), ('Leeds', true, 2, null, 900));
    expect(r.radiusMiles, 2);
    expect(r.must, ['parking']);
    expect(r.mustNot, ['students']);
    expect(r.label, '2+ bed to rent in Leeds, up to £900, within 2 mi');
  });

  test('buying, ranges, k prices and kilometres', () {
    final r = readRequest('3-4 bedroom house for sale in York £200k to £275k within 5km');
    expect((r.area, r.rent, r.minBeds, r.maxBeds), ('York', false, 3, 4));
    expect((r.minPrice, r.maxPrice), (200000, 275000));
    expect(r.radiusMiles, closeTo(3.107, 0.01));
    expect(r.must, ['house']);
  });

  test('a place on its own, a postcode, and near somewhere else', () {
    expect(readRequest('Harrogate').area, 'Harrogate');
    final p = readRequest('studio near LS1 4AP up to £650 pcm');
    expect((p.area, p.near, p.minBeds, p.maxBeds, p.maxPrice), ('LS1 4AP', '', 0, 0, 650));
    final n = readRequest('flat in Sheffield near the train station under 800');
    expect((n.area, n.near, n.maxPrice), ('Sheffield', 'train station', 800));
  });

  test('weekly rents become monthly; words for numbers count', () {
    final r = readRequest('two bedroom flat in Bristol under £200 pw');
    expect((r.area, r.minBeds, r.maxPrice), ('Bristol', 2, 867));
  });

  test('the rent or buy default applies when the words say neither', () {
    expect(readRequest('2 bed in Leeds', rent: false).rent, isFalse);
    expect(readRequest('2 bed in Leeds').rent, isTrue);
  });

  test('a postcode district alone is the area', () {
    expect(readRequest('LS6 2 bed').area, 'LS6');
    expect(readRequest('cheap 1 bedroom flat Belfast bt9 £700').area, 'BT9');
    expect(readRequest('2 bed to rent in Leeds').area, 'Leeds');
  });

  test('distances, rooms and times are not read as prices', () {
    final miles = readRequest('2 bed to rent in Leeds up to 3 miles from the station');
    expect((miles.area, miles.near, miles.maxPrice, miles.radiusMiles), ('Leeds', 'station', null, 3));
    final rooms = readRequest('flat to rent in Leeds max 2 bedrooms');
    expect((rooms.minBeds, rooms.maxBeds, rooms.maxPrice), (null, 2, null));
    final both = readRequest('house to rent in York up to 3 bedrooms under £1200');
    expect((both.maxBeds, both.maxPrice), (3, 1200));
    final compare = readRequest('2 bed to rent in Leeds under £900 no more than 2 miles from work');
    expect((compare.area, compare.near, compare.maxPrice, compare.radiusMiles), ('Leeds', 'work', 900, 2));
    expect(compare.mustNot, isEmpty);
  });

  test('ten bedrooms are ten', () {
    expect(readRequest('10 bed house for sale in York').minBeds, 10);
  });
}
