import 'dart:convert';

import 'package:anveshana/app/providers.dart';
import 'package:anveshana/app/security_checks.dart';
import 'package:anveshana/domain/contact_links.dart';
import 'package:anveshana/domain/lettings.dart';
import 'package:anveshana/domain/listing.dart';
import 'package:anveshana/domain/pipeline.dart';
import 'package:anveshana/domain/research.dart';
import 'package:anveshana/domain/tax.dart';
import 'package:anveshana/domain/watch_client.dart';
import 'package:brahma_core/brahma_core.dart' show addMonths;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'support.dart';

void main() {
  group('listings', () {
    test('a PropertyPal listing page gives one listing', () {
      final l = parsePropertyPalPage(nextData({'property': samplePropertyPal()})).single;
      expect(l.sourceId, '101');
      expect(l.url, 'https://www.propertypal.com/apt-1-sample-street-enniskillen/101');
      expect(l.address, 'Apt 1 Sample Street, Enniskillen, BT74 1AA');
      expect(l.postcode, 'BT74 1AA');
      expect(l.price, 650);
      expect(l.beds, 1);
      expect(l.agent, 'Example Lettings');
      expect(l.agentPhone, '+44 28 9649 6000');
      expect(l.status, 'toLet');
      expect(l.isRental, isTrue);
      expect(l.lat, 54.3485);
    });

    test('a search page gives every result; hidden prices are null', () {
      final page = nextData({
        'initialState': {
          'properties': {
            'data': {
              'results': [samplePropertyPal(), samplePropertyPal(id: 102, price: null)],
            },
          },
        },
      });
      final ls = parsePropertyPalPage(page);
      expect(ls.map((l) => l.sourceId), ['101', '102']);
      expect(ls[1].price, isNull);
    });

    test('a bot check is refused', () {
      expect(() => parsePropertyPalPage('<title>Just a moment...</title>'), throwsFormatException);
    });

    test('a Brahma Watch listing', () {
      final l = listingFromWatch({
        'id': '7',
        'url': 'https://www.propertypal.com/x/7',
        'address': '7 Lake View, Enniskillen, BT74 6AA',
        'price': 600,
        'priceSuffix': 'per month',
        'beds': 2,
        'agent': 'A',
        'agentPhone': '028',
        'status': 'toLet',
      });
      expect(l.postcode, 'BT74 6AA');
      expect(l.price, 600);
      expect(l.isRental, isTrue);
    });

    test('links are fetched from PropertyPal only, and a bot check is an error', () async {
      final asked = <Uri>[];
      final client = MockClient((req) async {
        asked.add(req.url);
        return http.Response(
          req.url.path == '/blocked'
              ? '<title>Just a moment...</title>'
              : nextData({'property': samplePropertyPal()}),
          200,
        );
      });
      final ls = await fetchPropertyPal(' https://www.propertypal.com/apt-1/101 ', client: client);
      expect(ls.single.sourceId, '101');
      expect(asked.single.host, 'www.propertypal.com');
      await expectLater(
        fetchPropertyPal('https://www.propertypal.com/blocked', client: client),
        throwsFormatException,
      );
      for (final bad in [
        'http://www.propertypal.com/x',
        'https://evilpropertypal.com/x',
        'https://example.com/',
      ]) {
        await expectLater(fetchPropertyPal(bad, client: client), throwsFormatException, reason: bad);
      }
      expect(asked, hasLength(2));
    });

    test('postcodes and distances', () {
      expect(postcodeIn('Flat 2, bt747hh'), 'BT74 7HH');
      expect(postcodeIn('no postcode here'), isNull);
      // Enniskillen to Belfast is about 115 km as the crow flies.
      expect(distanceKm(54.3446, -7.639, 54.5973, -5.9301), closeTo(113, 3));
    });
  });

  group('contact links', () {
    test('call, text, WhatsApp and e-mail', () {
      expect('${callUri('028 6634 1347')}', 'tel:02866341347');
      expect('${callUri('+44 28 6634 1347')}', 'tel:+442866341347');
      expect('${smsUri('07700 900123', body: 'Hi there')}', 'sms:07700900123?body=Hi%20there');
      expect('${whatsAppUri('07700 900123', text: 'Hi')}', 'https://wa.me/447700900123?text=Hi');
      expect(
        '${mailUri('a@b.co', subject: 'Flat 1', body: 'Is it free?')}',
        'mailto:a@b.co?subject=Flat%201&body=Is%20it%20free%3F',
      );
    });

    test('an enquiry carries the questions and the applicant', () {
      const a = Applicant(
        name: 'A Tenant',
        phone: '07700 900123',
        household: 'Two adults, no pets',
        moveIn: 'in January 2027',
      );
      final text = rentalEnquiry(a, address: '1 Sample Street', agent: 'Example Lettings');
      expect(text, startsWith('Hello Example Lettings,'));
      expect(text, contains('Is it still available?'));
      expect(text, contains('Could a tenancy start in January 2027?'));
      expect(text, contains('viewing'));
      expect(text, contains('About us: Two adults, no pets'));
      expect(text, endsWith('A Tenant\n07700 900123'));
    });
  });

  group('pipeline', () {
    test('silence after your message is counted until they reply', () {
      ({String channel, String direction, String at}) m(String c, String d, String at) =>
          (channel: c, direction: d, at: at);
      expect(daysWithoutReply([m('email', 'out', '2026-11-01T09:00')], '2026-11-06'), 5);
      expect(
        daysWithoutReply([
          m('email', 'out', '2026-11-01T09:00'),
          m('call', 'in', '2026-11-02T10:00'),
        ], '2026-11-06'),
        isNull,
      );
      expect(
        daysWithoutReply([
          m('email', 'out', '2026-11-01T09:00'),
          m('email', 'out', '2026-11-04T09:00'),
        ], '2026-11-06'),
        2,
        reason: 'counted from the latest message',
      );
      expect(daysWithoutReply([m('note', 'out', '2026-10-01T09:00')], '2026-11-06'), isNull);
      expect(daysWithoutReply(const [], '2026-11-06'), isNull);
    });

    test('the rent record is a safe CSV, oldest first', () {
      final csv = rentRecordCsv(
        address: '1 High St, Leeds',
        tenant: '=HYPERLINK("x")',
        payments: [
          (date: '2026-02-01', amount: 650, note: 'Feb'),
          (date: '2026-01-01', amount: 650, note: 'say "hi"'),
        ],
      );
      expect(csv.split('\n'), [
        'Date,Property,Tenant,Amount (GBP),Note',
        '2026-01-01,"1 High St, Leeds","\'=HYPERLINK(""x"")",650,"say ""hi"""',
        '2026-02-01,"1 High St, Leeds","\'=HYPERLINK(""x"")",650,Feb',
      ]);
    });

    test('tax quarters run from 6 April', () {
      expect(taxQuarter('2026-04-05'), (taxYear: 2025, quarter: 4));
      expect(taxQuarter('2026-04-06'), (taxYear: 2026, quarter: 1));
      expect(taxQuarter('2026-07-05'), (taxYear: 2026, quarter: 1));
      expect(taxQuarter('2026-07-06'), (taxYear: 2026, quarter: 2));
      expect(taxQuarter('2026-10-06'), (taxYear: 2026, quarter: 3));
      expect(taxQuarter('2027-01-05'), (taxYear: 2026, quarter: 3));
      expect(taxQuarter('2027-01-06'), (taxYear: 2026, quarter: 4));
      expect(taxQuarterDates(2026, 4), (from: '2027-01-06', to: '2027-04-05'));
      expect(taxYearLabel(2099), '2099-00');
    });

    test('rent by tax quarter adds up per property', () {
      final csv = rentByQuarterCsv([
        (date: '2026-05-01', property: 'B Flat', amount: 500),
        (date: '2026-04-06', property: 'A House, Leeds', amount: 700),
        (date: '2026-05-06', property: 'A House, Leeds', amount: 700),
        (date: '2026-04-01', property: 'A House, Leeds', amount: 700),
      ]);
      expect(csv.split('\n'), [
        'Tax year,Quarter,From,To,Property,Rent received (GBP)',
        '2025-26,Q4,2026-01-06,2026-04-05,"A House, Leeds",700',
        '2026-27,Q1,2026-04-06,2026-07-05,"A House, Leeds",1400',
        '2026-27,Q1,2026-04-06,2026-07-05,B Flat,500',
      ]);
    });
  });

  group('lettings', () {
    test('a rent rise waits for two months notice and a year since the last', () {
      expect(
        earliestRentIncrease(noticeServed: '2026-11-05', lastIncreaseOrStart: '2025-10-01'),
        '2027-01-05',
      );
      expect(
        earliestRentIncrease(noticeServed: '2026-11-05', lastIncreaseOrStart: '2026-06-15'),
        '2027-06-15',
      );
      expect(
        earliestRentIncrease(noticeServed: '2026-12-31', lastIncreaseOrStart: '2020-01-01'),
        '2027-02-28',
      );
    });

    test('rent falls due monthly, on short months at the month end', () {
      expect(rentDueDates(start: '2026-01-15', day: 15, asOf: '2026-04-14'), [
        '2026-01-15',
        '2026-02-15',
        '2026-03-15',
      ]);
      expect(rentDueDates(start: '2026-01-31', day: 31, asOf: '2026-03-31'), [
        '2026-01-31',
        '2026-02-28',
        '2026-03-31',
      ]);
      expect(rentDueDates(start: '2026-05-01', day: 1, asOf: '2026-04-01'), isEmpty);
      expect(rentDueDates(start: '2026-01-01', end: '2026-02-15', day: 1, asOf: '2026-06-01'), [
        '2026-01-01',
        '2026-02-01',
      ]);
    });

    test('arrears are rent due less rent paid', () {
      expect(rentBalance(start: '2026-01-01', day: 1, rent: 650, paid: [650, 650], asOf: '2026-03-02'), 650);
    });

    test('months roll over year ends and short months', () {
      expect(addMonths('2026-11-30', 3), '2027-02-28');
      expect(addMonths('2026-01-15', 12), '2027-01-15');
    });
  });

  group('Brahma Watch client', () {
    test('sends searches with the token, reads events', () async {
      late http.Request sent;
      final client = MockClient((req) async {
        sent = req;
        if (req.url.path == '/events') {
          expect(req.url.queryParameters['since'], '2026-10-20T00:00:00Z');
          return http.Response(
            jsonEncode([
              {
                'at': '2026-10-21T08:00:00Z',
                'watchId': 'w1',
                'kind': 'new',
                'distanceKm': 0.7,
                'listing': {
                  'id': '5',
                  'url': 'u',
                  'address': 'Flat 5, BT74 7HH',
                  'price': 650,
                  'status': 'toLet',
                },
              },
            ]),
            200,
          );
        }
        return http.Response(req.body, 200);
      });
      final w = WatchClient('https://watch.example.workers.dev/', 'secret', client: client);
      await w.putSearches(const [
        WatchSearch(
          id: 'w1',
          name: 'Rent',
          path: '/property-to-rent/enniskillen',
          maxPrice: 700,
          centreLat: 54.3,
          centreLon: -7.6,
          radiusKm: 2,
        ),
      ]);
      expect(sent.method, 'PUT');
      expect(sent.headers['authorization'], 'Bearer secret');
      final body = (jsonDecode(sent.body) as List).single as Map;
      expect(body['source'], 'propertypal');
      expect(body['centre'], {'lat': 54.3, 'lon': -7.6, 'label': ''});
      expect(body.containsKey('minBeds'), isFalse);
      expect(WatchSearch.fromWatchJson(body.cast()).toWatchJson(), body);

      final events = await w.events(since: '2026-10-20T00:00:00Z');
      expect(events.single.listing.postcode, 'BT74 7HH');
      expect(events.single.distanceKm, .7);
    });

    test('a refused token says so', () async {
      final w = WatchClient(
        'https://w.example',
        'bad',
        client: MockClient((_) async => http.Response('{}', 401)),
      );
      expect(
        w.runNow(),
        throwsA(isA<WatchException>().having((e) => e.message, 'message', contains('token'))),
      );
    });

    test('Sentinel reports a Watch reached without https', () async {
      Future<List<String>> ids(WatchClient? w) async {
        final c = ProviderContainer(overrides: [watchProvider.overrideWithValue(AsyncData(w))]);
        addTearDown(c.dispose);
        return [for (final f in await c.read(watchCheck.findings.future)) f.id];
      }

      expect(await ids(null), isEmpty);
      expect(await ids(WatchClient('https://w.example', 't')), isEmpty);
      expect(await ids(WatchClient('http://w.example', 't')), ['anveshana.watch.http']);
    });

    test('search paths are checked like the Worker does', () {
      expect(isSearchPath('/property-to-rent/enniskillen'), isTrue);
      expect(isSearchPath('/property-for-sale/belfast/bt9'), isTrue);
      expect(isSearchPath('/property-to-rent/enniskillen?maxPrice=700'), isFalse);
      expect(isSearchPath('https://www.propertypal.com/property-to-rent/enniskillen'), isFalse);
    });
  });

  group('research', () {
    test('an area report for Northern Ireland', () async {
      final asked = <String>[];
      final client = MockClient((req) async {
        asked.add(req.url.toString());
        final path = req.url.path;
        if (req.url.host == 'api.postcodes.io') {
          // The real API 404s a double-encoded space ("%2520").
          if (req.url.path != '/postcodes/bt74%207hh') return http.Response('{"status":404}', 404);
          return http.Response(
            jsonEncode({
              'result': {
                'postcode': 'BT74 7HH',
                'latitude': 54.3468,
                'longitude': -7.6442,
                'country': 'Northern Ireland',
                'admin_district': 'Fermanagh and Omagh',
                'admin_ward': 'Portora',
                'parliamentary_constituency': 'Fermanagh and South Tyrone',
                'region': null,
              },
            }),
            200,
          );
        }
        if (path.contains('/ukhpi/')) {
          // Only July has data. Later months answer as the real API does before
          // publication: primaryTopic is the string "elda:missingEndpoint".
          if (!path.endsWith('2026-07.json')) {
            return http.Response('{"result":{"primaryTopic":"elda:missingEndpoint"}}', 200);
          }
          return http.Response(
            jsonEncode({
              'result': {
                'primaryTopic': {
                  'averagePrice': 201732,
                  'percentageAnnualChange': 11.0,
                  'averagePriceDetached': 300000,
                },
              },
            }),
            200,
          );
        }
        if (req.url.host == 'data.police.uk') {
          return http.Response(
            jsonEncode([
              {'category': 'anti-social-behaviour', 'month': '2026-08'},
              {'category': 'burglary', 'month': '2026-08'},
              {'category': 'burglary', 'month': '2026-08'},
            ]),
            200,
          );
        }
        return http.Response('not expected', 500);
      });
      final r = await Research(client: client, now: () => DateTime(2026, 10, 21)).report('bt74 7hh');
      expect(r.place.nation, Nation.northernIreland);
      expect(r.prices!.region, 'Fermanagh and Omagh');
      expect(r.prices!.month, '2026-07');
      expect(r.prices!.byType, {'Detached': 300000});
      expect(r.regionPrices!.region, 'Northern Ireland');
      expect(r.crimes, {'anti social behaviour': 1, 'burglary': 2});
      expect(r.crimeTotal, 3);
      expect(r.sales, isEmpty);
      expect(r.notes.single, contains('England and Wales only'));
      expect(asked.any((u) => u.contains('fermanagh-and-omagh/month/2026-07')), isTrue);
      expect(asked.any((u) => u.contains('/ppi/')), isFalse, reason: 'no Price Paid for NI');
      expect(AreaReport.fromJson(jsonDecode(jsonEncode(r.toJson()))).toJson(), r.toJson());
    });

    test('flood warnings keep only those in force, most severe first', () async {
      Uri? asked;
      final client = MockClient((req) async {
        asked = req.url;
        return http.Response(
          jsonEncode({
            'items': [
              {'description': 'River Aire at Leeds', 'severity': 'Flood alert', 'severityLevel': 3},
              {'description': 'Old one', 'severity': 'Warning no longer in force', 'severityLevel': 4},
              {
                'description': 'River Calder',
                'severity': 'Flood warning',
                'severityLevel': 2,
                'floodArea': {'county': 'West Yorkshire'},
              },
            ],
          }),
          200,
        );
      });
      final f = await Research(client: client).floods(53.8, -1.55);
      expect(asked!.queryParameters, {'lat': '53.8', 'long': '-1.55', 'dist': '5'});
      expect(f.map((x) => x.area), ['West Yorkshire River Calder', 'River Aire at Leeds']);
      expect(f.first.level, 2);
      expect(FloodWarning.fromJson(f.first.toJson()).area, f.first.area);
    });

    test('street sales ask for the street and town, newest first', () async {
      Uri? asked;
      final client = MockClient((req) async {
        asked = req.url;
        return http.Response(
          jsonEncode({
            'result': {
              'items': [
                {
                  'transactionDate': 'Tue, 29 May 2018',
                  'pricePaid': 100000,
                  'propertyAddress': {'paon': '3', 'street': 'ALMA ROAD', 'town': 'LEEDS'},
                  'propertyType': [
                    {'_value': 'terraced'},
                  ],
                },
                {
                  'transactionDate': 'Thu, 28 Aug 2025',
                  'pricePaid': 120000,
                  'propertyAddress': {'paon': '5', 'street': 'ALMA ROAD', 'town': 'LEEDS'},
                  'propertyType': [
                    {'_value': 'terraced'},
                  ],
                },
              ],
            },
          }),
          200,
        );
      });
      final sales = await Research(client: client).salesOnStreet('Alma Road', 'Leeds');
      expect(asked!.queryParameters['propertyAddress.street'], 'ALMA ROAD');
      expect(asked!.queryParameters['propertyAddress.town'], 'LEEDS');
      expect(sales.map((s) => s.date), ['2025-08-28', '2018-05-29']);
      expect((sales.first.street, sales.first.town), ('ALMA ROAD', 'LEEDS'));
    });

    test('sold prices in England, newest first', () async {
      final client = MockClient(
        (req) async => http.Response(
          jsonEncode({
            'result': {
              'items': [
                {
                  'transactionDate': 'Tue, 29 May 2018',
                  'pricePaid': 600000,
                  'newBuild': false,
                  'propertyType': [
                    {'_value': 'detached'},
                  ],
                  'propertyAddress': {'paon': '35', 'street': 'OTLEY ROAD', 'town': 'LEEDS'},
                },
                {
                  'transactionDate': 'Fri, 03 Jan 2020',
                  'pricePaid': 250000,
                  'newBuild': true,
                  'propertyAddress': {'saon': 'FLAT 2', 'paon': '1', 'street': 'A STREET', 'town': 'LEEDS'},
                },
              ],
            },
          }),
          200,
        ),
      );
      final sales = await Research(client: client).sales('LS6 3AA');
      expect(sales.map((s) => s.date), ['2020-01-03', '2018-05-29']);
      expect(sales.first.address, 'FLAT 2, 1, A STREET, LEEDS');
      expect(sales.last.type, 'detached');
    });

    test('region slugs', () {
      expect(hpiSlug('Fermanagh and Omagh'), 'fermanagh-and-omagh');
      expect(hpiSlug('Armagh City, Banbridge & Craigavon'), 'armagh-city-banbridge-and-craigavon');
    });
  });
}
