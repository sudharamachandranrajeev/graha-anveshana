import 'dart:convert';

import 'package:anveshana/domain/page_reader.dart';
import 'package:anveshana/domain/sources.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Made-up cards, as cardsScript returns them from a page.
  final cards = jsonEncode([
    {
      'id': '70000001',
      'href': 'https://www.zoopla.co.uk/to-rent/details/70000001/',
      'text': '£195 pw\n£845 pcm\n2 bed flat\nFlat 3, Sample Court, Exampletown EX1 2AB\nParking',
      'img': 'https://media.example/z1.jpg',
    },
    {
      'id': '70000002',
      'href': 'https://www.zoopla.co.uk/to-rent/details/70000002/',
      'text': 'Let agreed\n£700 pcm\nStudio\nHigh Street, Exampletown',
      'img': 'http://insecure.example/z2.jpg',
    },
    {'id': '70000003', 'href': 'https://www.zoopla.co.uk/x', 'text': 'No price here'},
  ]);

  test('advert cards from an open page become listings', () {
    final l = listingsFromCards(SourceId.zoopla, cards, rent: true);
    expect(l, hasLength(2));
    expect((l[0].source, l[0].sourceId, l[0].price, l[0].beds), ('zoopla', '70000001', 845, 2));
    expect((l[0].address, l[0].postcode), ('Flat 3, Sample Court, Exampletown EX1 2AB', 'EX1 2AB'));
    expect(l[0].image, 'https://media.example/z1.jpg');
    expect((l[1].beds, l[1].status, l[1].image), (0, 'letAgreed', null));
  });

  test('a known site\'s own data wins over its cards; junk reads as nothing', () {
    expect(readOpenPage(SourceId.zoopla, '<html></html>', cards, rent: true).items, hasLength(2));
    expect(readOpenPage(SourceId.rightmove, '<html></html>', 'not json', rent: true).items, isEmpty);
  });
}
