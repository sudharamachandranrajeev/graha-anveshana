import 'package:anveshana/domain/advert_page.dart';
import 'package:anveshana/domain/portals.dart';
import 'package:anveshana/ui/share_inbox.dart';
import 'package:flutter_test/flutter_test.dart';

PortalAdvert advert(String link) => parsePortalLink(link)!;

void main() {
  test('OpenRent: every photo of this advert, none of the similar homes', () {
    // Shaped like the real page (issue #8): the preview tag names another
    // advert's photo, the gallery links this advert's, and similar homes
    // carry their own.
    const html = '''
<html><head>
<title>Leeds - 2 Bed Terraced House, Kepler Grove, LS8 - To Rent Now for &#xA3;925.00 p/m</title>
<meta name="description" content="Property: 2 Bed Terraced House, Kepler Grove, LS8, Available to Rent in Leeds. &#xA3;925.00 p/m." />
<meta property="og:image" content="http://staticcdn.openrent.co.uk/images/logos/meta/share-graphic-1.jpg" />
<meta property="og:image" content="http://imagescdn.openrent.co.uk/listings/2158924/o_other.JPG" />
</head><body>
<a href="//imagescdn.openrent.co.uk/listings/2197224/o_1.JPG"><img src="//imagescdn.openrent.co.uk/listings/2197224/o_1.JPG"></a>
<a href="//imagescdn.openrent.co.uk/listings/2197224/o_2.JPG"></a>
<a href="//imagescdn.openrent.co.uk/listings/2197224/o_3.JPG"></a>
<img src="//imagescdn.openrent.co.uk/staticMapPhotoForProperty/2197224mobile.JPG">
<img src="//imagescdn.openrent.co.uk/listings/815482/o_similar.JPG">
</body></html>''';
    final l = listingFromAdvertPage(
      advert(
        'https://www.openrent.co.uk/property-to-rent/leeds/2-bed-terraced-house-kepler-grove-ls8/2197224',
      ),
      html,
    );
    expect(l.images, [
      'https://imagescdn.openrent.co.uk/listings/2197224/o_1.JPG',
      'https://imagescdn.openrent.co.uk/listings/2197224/o_2.JPG',
      'https://imagescdn.openrent.co.uk/listings/2197224/o_3.JPG',
    ]);
    expect(l.price, 925);
    expect(l.beds, 2);
    expect(l.address, 'Kepler Grove, LS8');
    expect((l.source, l.sourceId), ('openRent', '2197224'));
    expect(l.isRental, isTrue);
  });

  test('Rightmove: the gallery from the page model', () {
    const html = '''
<html><head><title>2 bedroom terraced house to rent in Kepler Grove, Leeds, LS8</title></head><body>
<script>window.PAGE_MODEL = {"propertyData":{"id":"151622606","bedrooms":2,
"address":{"displayAddress":"Kepler Grove, Leeds, LS8 5AB"},
"prices":{"primaryPrice":"£1,100 pcm"},"location":{"latitude":53.81,"longitude":-1.52},
"images":[{"url":"https://media.rightmove.co.uk/dir/1/151622606/IMG_00.jpeg"},
{"url":"https://media.rightmove.co.uk/dir/1/151622606/IMG_01.jpeg"}],
"transactionType":"RENT"},"similar":[{"images":[{"url":"https://media.rightmove.co.uk/dir/9/999/IMG.jpeg"}]}]};
</script></body></html>''';
    final l = listingFromAdvertPage(advert('https://www.rightmove.co.uk/properties/151622606'), html);
    expect(l.images, hasLength(2));
    expect(l.images.first, endsWith('IMG_00.jpeg'));
    expect(l.address, 'Kepler Grove, Leeds, LS8 5AB');
    expect(l.postcode, 'LS8 5AB');
    expect(l.price, 1100);
    expect(l.beds, 2);
    expect(l.lat, 53.81);
    expect(l.isRental, isTrue);
  });

  test('Zoopla: schema.org data', () {
    const html = '''
<html><head>
<script type="application/ld+json">{"@type":"RealEstateListing","name":"3 bed semi-detached house for sale",
"image":["https://lid.zoocdn.com/u/1024/768/a.jpg","https://lid.zoocdn.com/u/1024/768/b.jpg"],
"offers":{"price":250000},"numberOfBedrooms":3,
"address":{"streetAddress":"Alma Road","addressLocality":"Leeds","postalCode":"LS6 3AA"}}</script>
</head></html>''';
    final l = listingFromAdvertPage(advert('https://www.zoopla.co.uk/for-sale/details/65432100/'), html);
    expect(l.images, hasLength(2));
    expect(l.price, 250000);
    expect(l.beds, 3);
    expect(l.address, 'Alma Road, Leeds, LS6 3AA');
    expect(l.isRental, isFalse);
  });

  test('Facebook Marketplace: title and preview photo', () {
    const html = '''
<html><head>
<meta property="og:title" content="2 bed house to rent - £850 pcm" />
<meta property="og:image" content="https://scontent.xx.fbcdn.net/v/t45/photo.jpg?x=1&amp;y=2" />
</head></html>''';
    final l = listingFromAdvertPage(
      advert('https://www.facebook.com/marketplace/item/1234567890123456/'),
      html,
    );
    expect(l.images, ['https://scontent.xx.fbcdn.net/v/t45/photo.jpg?x=1&y=2']);
    expect(l.price, 850);
    expect(l.beds, 2);
    expect(l.source, 'facebook');
    expect(l.isRental, isTrue);
  });

  test('a weekly rent becomes monthly', () {
    const html = '<meta property="og:title" content="Room, Hyde Park, Leeds - £150 pw" />';
    final l = listingFromAdvertPage(advert('https://www.zoopla.co.uk/to-rent/details/65432100/'), html);
    expect(l.price, 650);
  });

  test('a page with no advert on it is refused', () {
    expect(
      () => listingFromAdvertPage(
        advert('https://www.rightmove.co.uk/properties/151622606'),
        '<html><head><title>Just a moment...</title></head></html>',
      ),
      throwsFormatException,
    );
  });

  test('a shared link is found in the text a portal app shares', () {
    final u = sharedLink(
      'Look at this home on Rightmove! https://www.rightmove.co.uk/properties/151622606 ',
    )!;
    expect(portalOf(u), Portal.rightmove);
    expect(portalOf(sharedLink('https://m.facebook.com/marketplace/item/1/')!), Portal.facebook);
    expect(portalOf(Uri.parse('https://www.propertypal.com/x/1')), isNull);
    expect(sharedLink('no link here'), isNull);
  });
}
