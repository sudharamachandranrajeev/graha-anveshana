import 'package:anveshana/domain/catalog.dart';
import 'package:anveshana/domain/listing.dart';
import 'package:anveshana/domain/property_search.dart';
import 'package:anveshana/domain/search_request.dart';
import 'package:anveshana/domain/sources.dart';
import 'package:flutter_test/flutter_test.dart';

FoundHome _home(String id, {String furnished = '', String description = ''}) => FoundHome(
  Listing(
    source: 'rightmove',
    sourceId: id,
    url: 'https://www.rightmove.co.uk/properties/$id',
    address: '$id Road',
    furnished: furnished,
    description: description,
  ),
);

void main() {
  test('mentions matches whole words and plurals, not words inside others', () {
    expect(mentions('Unfurnished flat', 'furnished'), isFalse);
    expect(mentions('Furnished flat', 'furnished'), isTrue);
    expect(mentions('No pets allowed', 'pet'), isTrue);
    expect(mentions('Carpets throughout', 'pet'), isFalse);
  });

  test('furnishingOf reads the field first, then the words', () {
    expect(furnishingOf(_home('a', furnished: 'Unfurnished')), Furnishing.unfurnished);
    expect(furnishingOf(_home('b', furnished: 'Part furnished')), Furnishing.part);
    expect(furnishingOf(_home('c', description: 'A fully furnished flat')), Furnishing.furnished);
    expect(furnishingOf(_home('d', description: 'Furnished or unfurnished')), Furnishing.either);
    expect(furnishingOf(_home('e', description: 'Two bed flat')), isNull);
  });

  test('asking for furnished leaves out unfurnished homes, and the other way round', () {
    final furnished = readRequest('furnished flat to rent in Leeds');
    final unfurnished = readRequest('unfurnished flat to rent in Leeds');
    expect(furnished.must, contains('furnished'));
    expect(unfurnished.must, contains('unfurnished'));

    final un = _home('un', furnished: 'Unfurnished');
    final full = _home('full', description: 'Furnished throughout');
    final part = _home('part', furnished: 'Part furnished');
    final either = _home('either', furnished: 'Furnished or unfurnished');
    final unknown = _home('unknown');

    expect(meetsRequest(un, furnished), isFalse);
    expect(meetsRequest(full, furnished), isTrue);
    expect(meetsRequest(part, furnished), isTrue);
    expect(meetsRequest(either, furnished), isTrue);
    expect(meetsRequest(unknown, furnished), isTrue);

    expect(meetsRequest(un, unfurnished), isTrue);
    expect(meetsRequest(full, unfurnished), isFalse);
    expect(meetsRequest(part, unfurnished), isFalse);
    expect(meetsRequest(either, unfurnished), isTrue);
  });

  test('rankHomes drops unfurnished homes from a furnished search', () {
    final q = readRequest('furnished flat to rent in Leeds');
    final homes = [_home('un', furnished: 'Unfurnished'), _home('full', furnished: 'Furnished')];
    expect(rankHomes(homes, q).map((h) => h.main.sourceId), ['full']);
  });

  test('Zoopla asks the site for the furnishing too', () {
    final z = browserSearchUrl(SourceId.zoopla, readRequest('furnished flat to rent in Leeds'));
    expect(z.queryParameters['furnished_state'], 'furnished');
    final none = browserSearchUrl(SourceId.zoopla, readRequest('flat to rent in Leeds'));
    expect(none.queryParameters.containsKey('furnished_state'), isFalse);
  });

  test('Facebook sign-in goes to Marketplace after; Zoopla has no known sign-in cookie', () {
    expect(signInFor(SourceId.facebook).cookie, 'c_user');
    expect(signInFor(SourceId.facebook).page.queryParameters['next'], contains('/marketplace/'));
    expect(signInFor(SourceId.zoopla).cookie, isNull);
  });
}
