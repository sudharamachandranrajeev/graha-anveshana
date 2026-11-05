import 'package:anveshana/db/database.dart';
import 'package:anveshana/domain/hunt_filter.dart';
import 'package:flutter_test/flutter_test.dart';

Property home({int? beds, int? price, String notes = '', String address = '1 Test Road, Leeds LS6 1AA'}) =>
    Property(
      id: 'x',
      hlc: '',
      deleted: false,
      address: address,
      postcode: 'LS6 1AA',
      kind: 'rent',
      stage: 'new',
      price: price,
      beds: beds,
      style: 'Terraced',
      furnished: '',
      source: 'manual',
      url: '',
      listingStatus: '',
      rating: 0,
      notes: notes,
      added: '2026-11-05',
      meta: '{}',
    );

void main() {
  test('words match address, postcode and notes; -word hides', () {
    const f = HuntFilter(words: 'ls6 pets');
    expect(f.matches(home(notes: 'Pets OK, small dog')), isTrue);
    expect(f.matches(home()), isFalse);
    expect(const HuntFilter(words: '-damp').matches(home(notes: 'damp in bathroom')), isFalse);
    expect(const HuntFilter(words: '-damp terraced').matches(home()), isTrue);
    expect(const HuntFilter(words: ' - ').matches(home()), isTrue);
  });

  test('beds and price limits; unknown values do not pass a limit', () {
    expect(const HuntFilter(minBeds: 2).matches(home(beds: 2)), isTrue);
    expect(const HuntFilter(minBeds: 2).matches(home(beds: 1)), isFalse);
    expect(const HuntFilter(minBeds: 2).matches(home()), isFalse);
    expect(const HuntFilter(maxPrice: 900).matches(home(price: 900)), isTrue);
    expect(const HuntFilter(maxPrice: 900).matches(home(price: 950)), isFalse);
    expect(const HuntFilter(maxPrice: 900).matches(home()), isFalse);
    expect(const HuntFilter().isEmpty, isTrue);
  });
}
