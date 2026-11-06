import 'dart:convert';

import 'package:anveshana/domain/advert.dart';
import 'package:flutter_test/flutter_test.dart';

// Made-up advert pages shaped like each site's own.
void main() {
  test('Rightmove: the flattened page model is rebuilt', () {
    // Every value is an index into the list, as Rightmove sends it.
    final data = [
      {'propertyData': 1},
      {'text': 2, 'images': 4, 'floorplans': 7, 'keyFeatures': 8, 'lettings': 10, 'customer': 13},
      {'description': 3},
      '<p>Bright flat.<br>Near the park &amp; shops.</p>',
      [5],
      {'url': 6},
      'https://media.example/1.jpg',
      <Object?>[],
      [9],
      'Parking',
      {'deposit': 11, 'furnishType': 12},
      900,
      'Furnished',
      {'branchDisplayName': 14},
      'Example Lettings',
    ];
    final html =
        '<script>window.__PAGE_MODEL = ${jsonEncode({'data': data, 'encoding': 'on'})};window.x={};</script>';
    final a = parseRightmoveAdvert(html);
    expect(a.description, 'Bright flat.\nNear the park & shops.');
    expect(a.photos, ['https://media.example/1.jpg']);
    expect(a.features, ['Parking']);
    expect(a.facts, {'Deposit': '£900', 'Furnishing': 'Furnished'});
    expect(a.agent, 'Example Lettings');
  });

  test('OnTheMarket and OpenRent adverts', () {
    final otm =
        '<script id="__NEXT_DATA__" type="application/json">${jsonEncode({
          'props': {
            'pageProps': {
              'initialReduxState': {
                'property': {
                  'id': '1',
                  'description': '<p>Two bed flat.</p>',
                  'images': [
                    {'largeUrl': 'https://media.example/a.jpg'},
                  ],
                  'features': [
                    {'feature': 'Garden'},
                  ],
                  'keyInfo': [
                    {'title': 'Council tax', 'value': 'Band B'},
                  ],
                  'epc': {'rating': 'C'},
                  'lettingDetails': {
                    'items': ['Available now'],
                  },
                  'agent': {'name': 'Example Homes', 'telephone': '0100 000 000'},
                },
              },
            },
          },
        })}</script>';
    final a = parseOnTheMarketAdvert(otm);
    expect(
      (a.description, a.photos.single, a.phone),
      ('Two bed flat.', 'https://media.example/a.jpg', '0100 000 000'),
    );
    expect(a.features, ['Available now', 'Garden']);
    expect(a.facts, {'Council tax': 'Band B', 'EPC': 'C'});

    const openRent = '''
<div class="description">A quiet one bed flat.</div>
<img src="//imagescdn.openrent.co.uk/listings/12/photo1.jpg">
<table><tr> <td class="fw-medium">Deposit</td> <td>&#xA3;800.00</td> </tr>
<tr> <td class="fw-medium">Furnishing</td> <td>Unfurnished</td> </tr></table>''';
    final o = parseOpenRentAdvert(openRent);
    expect(o.description, 'A quiet one bed flat.');
    expect(o.photos, ['https://imagescdn.openrent.co.uk/listings/12/photo1.jpg']);
    expect(o.facts, {'Deposit': '£800.00', 'Furnishing': 'Unfurnished'});
  });

  test('a page with no advert is an error, not an empty advert', () {
    expect(() => parseRightmoveAdvert('<html></html>'), throwsFormatException);
    expect(() => parseOnTheMarketAdvert('<html></html>'), throwsFormatException);
  });
}
