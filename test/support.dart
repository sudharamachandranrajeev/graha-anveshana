import 'dart:convert';

import 'package:anveshana/db/database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

/// A page carrying [pageProps] the way PropertyPal's Next.js pages do.
String nextData(Map<String, Object?> pageProps) =>
    '<html><script id="__NEXT_DATA__" type="application/json">'
    '${jsonEncode({
      'props': {'pageProps': pageProps},
    })}</script></html>';

/// A made-up PropertyPal property in the site's shape.
Map<String, Object?> samplePropertyPal({int id = 101, int? price = 650, String status = 'toLet'}) => {
  'pathId': id,
  'path': '/apt-1-sample-street-enniskillen/$id',
  'displayAddress': 'Apt 1 Sample Street, Enniskillen, BT74 1AA',
  'postcode': 'BT74 1AA',
  'price': price == null ? {'priceHidden': true} : {'price': price, 'priceSuffix': 'per month'},
  'numBedrooms': 1,
  'numBathrooms': 1,
  'style': {'text': 'Apartment'},
  'furnishedType': {'text': 'Furnished'},
  'heatingType': {'text': 'Oil'},
  'dateAvailableFrom': '2027-01-01',
  'coordinate': {'latitude': 54.3485, 'longitude': -7.638},
  'account': {
    'organisation': 'Example Lettings',
    'officePhone': {'international': '+44 28 9649 6000'},
  },
  'images': [
    {'url': 'https://example.com/$id.jpg'},
    {'url': 'https://example.com/$id-kitchen.jpg'},
  ],
  'status': {'key': status},
};

/// A fresh in-memory database (the bundled SQLite3MultipleCiphers works
/// unkeyed in memory).
AppDatabase memoryDatabase() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}
