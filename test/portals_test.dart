import 'package:anveshana/domain/portals.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const rent = PortalQuery(area: 'Pontefract', rent: true, maxPrice: 900, minBeds: 2, radiusMiles: 4);

  test('every portal builds a search for a rental', () {
    final links = {for (final l in portalSearches(rent)) l.portal: l.url};
    expect(links.keys, Portal.values);
    final rm = links[Portal.rightmove]!;
    expect(rm.path, '/property-to-rent/find.html');
    expect(rm.queryParameters['searchLocation'], 'Pontefract');
    expect(rm.queryParameters['radius'], '3.0'); // 4 miles snaps to a radius Rightmove accepts
    expect(rm.queryParameters['maxPrice'], '900');
    expect(links[Portal.onTheMarket]!.path, '/to-rent/property/pontefract/');
    expect(links[Portal.onTheMarket]!.queryParameters['max-price'], '900');
    expect(links[Portal.openRent]!.queryParameters['bedrooms_min'], '2');
    final zoopla = links[Portal.zoopla]!;
    expect(zoopla.path, '/to-rent/property/pontefract/');
    expect(zoopla.queryParameters, containsPair('beds_min', '2'));
    expect(zoopla.queryParameters, containsPair('price_max', '900'));
    expect(zoopla.queryParameters, containsPair('price_frequency', 'per_month'));
    expect(links[Portal.facebook]!.path, '/marketplace/pontefract/propertyrentals');
    expect(links[Portal.facebook]!.queryParameters['maxPrice'], '900');
  });

  test('OpenRent is left out for sales; postcodes and spaces slug cleanly', () {
    const sale = PortalQuery(area: 'LS1 4AP', rent: false);
    final links = portalSearches(sale);
    expect(links.map((l) => l.portal), isNot(contains(Portal.openRent)));
    expect(links.firstWhere((l) => l.portal == Portal.onTheMarket).url.path, '/for-sale/property/ls1-4ap/');
    expect(
      links.firstWhere((l) => l.portal == Portal.zoopla).url.queryParameters,
      isNot(contains('price_frequency')),
    );
    expect(
      links.firstWhere((l) => l.portal == Portal.facebook).url.path,
      '/marketplace/ls1-4ap/propertyforsale',
    );
    expect(portalSearches(const PortalQuery(area: '  ', rent: true)), isEmpty);
  });

  test('advert links are recognised without a fetch and tidied', () {
    final rm = parsePortalLink('https://www.rightmove.co.uk/properties/123456789#/?channel=RES_LET')!;
    expect((rm.portal, rm.id), (Portal.rightmove, '123456789'));
    expect(rm.url.toString(), 'https://www.rightmove.co.uk/properties/123456789');
    expect(
      parsePortalLink('https://www.zoopla.co.uk/to-rent/details/65432100/?search_identifier=x')?.id,
      '65432100',
    );
    expect(parsePortalLink('https://www.onthemarket.com/details/12345678/')?.portal, Portal.onTheMarket);
    final or = parsePortalLink(
      'https://www.openrent.co.uk/property-to-rent/leeds/2-bed-flat-high-street/2345678',
    )!;
    expect(or.id, '2345678');
    expect(or.address, '2 Bed Flat High Street');
    final fb = parsePortalLink('https://m.facebook.com/marketplace/item/1234567890123456/?ref=search')!;
    expect((fb.portal, fb.id), (Portal.facebook, '1234567890123456'));
    expect(fb.url.toString(), 'https://m.facebook.com/marketplace/item/1234567890123456');
  });

  test('other links are not adverts', () {
    expect(parsePortalLink('https://www.rightmove.co.uk/property-to-rent/find.html?x=1'), isNull);
    expect(parsePortalLink('http://www.rightmove.co.uk/properties/123456789'), isNull);
    expect(parsePortalLink('https://evilrightmove.co.uk/properties/123456789'), isNull);
    expect(parsePortalLink('not a link'), isNull);
    expect(parsePortalLink('https://www.facebook.com/marketplace/leeds/propertyrentals'), isNull);
  });
}
