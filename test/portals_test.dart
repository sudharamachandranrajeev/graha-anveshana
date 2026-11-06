import 'package:anveshana/domain/portals.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
  });

  test('other links are not adverts', () {
    expect(parsePortalLink('https://www.rightmove.co.uk/property-to-rent/find.html?x=1'), isNull);
    expect(parsePortalLink('http://www.rightmove.co.uk/properties/123456789'), isNull);
    expect(parsePortalLink('https://evilrightmove.co.uk/properties/123456789'), isNull);
    expect(parsePortalLink('not a link'), isNull);
  });
}
