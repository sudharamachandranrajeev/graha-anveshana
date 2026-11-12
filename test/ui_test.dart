import 'dart:convert';

import 'package:anveshana/app/search_controller.dart';
import 'package:anveshana/app/tour.dart';
import 'package:anveshana/db/database.dart';
import 'package:anveshana/domain/book.dart';
import 'package:anveshana/domain/listing.dart';
import 'package:anveshana/domain/pipeline.dart';
import 'package:brahma_core/brahma_core.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:anveshana/ui/homes_map.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'app_harness.dart';
import 'support.dart';

/// Smoke tests: every page builds, with and without data, on phone and
/// desktop widths, without throwing or overflowing; and the main flows.
void main() {
  Future<void> seed(PropertyBook book) async {
    await book.setHome((lat: 54.344, lon: -7.638, label: 'Work'));
    final id = (await book.importListing(
      parsePropertyPalPage(nextData({'property': samplePropertyPal()})).single,
      today: '2026-10-20',
    )).id;
    await book.log(propertyId: id, channel: 'email', summary: 'Sent the enquiry', at: '2026-10-20T09:00');
    await book.bookViewing(id, '2026-10-24T11:00');
    final owned = newId();
    await book.save(
      book.db.properties,
      PropertiesCompanion.insert(
        id: owned,
        address: '9 Example Row, BT74 1AB',
        kind: PropertyKind.owned.name,
        added: '2025-01-01',
      ),
      owned,
    );
    final t = newId();
    await book.save(
      book.db.tenancies,
      TenanciesCompanion.insert(
        id: t,
        propertyId: owned,
        role: 'landlord',
        start: '2026-01-01',
        rent: 700,
        otherParty: const Value('A Tenant'),
      ),
      t,
    );
    final c = newId();
    await book.save(
      book.db.complianceItems,
      ComplianceItemsCompanion.insert(id: c, propertyId: owned, kind: 'gas', due: '2026-11-01'),
      c,
    );
    final s = newId();
    await book.save(
      book.db.searches,
      SearchesCompanion.insert(
        id: s,
        name: 'Rent near work',
        path: '/property-to-rent/enniskillen',
        maxPrice: const Value(700),
      ),
      s,
    );
  }

  const pages = [
    'Dashboard',
    'Search',
    'Invest',
    'Collections',
    'Areas',
    'Lettings',
    'Contacts',
    'Settings',
    'Shortlist',
  ];

  testWidgets('every page builds on a desktop window, empty and with data', (tester) async {
    for (final seeded in [false, true]) {
      final app = AppHarness(tester)..desktop();
      await app.open(seed: seeded ? seed : null);
      await app.run();
      for (final label in pages) {
        await app.go(label);
        expect(tester.takeException(), isNull, reason: '$label (seeded: $seeded)');
      }
      await app.close();
    }
  });

  testWidgets('every page builds on a phone', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final app = AppHarness(tester);
    await app.open(seed: seed);
    await app.run();
    // Half through the dock, half through the side panel.
    for (final (i, label) in pages.indexed) {
      await (i.isEven ? app.dock(label) : app.panel(label));
      expect(tester.takeException(), isNull, reason: label);
    }
    // Back closes the panel before anything else.
    await tester.flingFrom(const Offset(40, 400), const Offset(300, 0), 1000);
    await app.settle();
    expect(find.text('SCREENS'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await app.settle();
    expect(find.text('SCREENS'), findsNothing);
    // A property's page too.
    await app.tapText('Apt 1 Sample Street, Enniskillen, BT74 1AA');
    expect(find.text('Write an enquiry'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await app.close();
  });

  testWidgets('a pasted Rightmove link is saved as a property, once', (tester) async {
    final app = AppHarness(tester)..desktop();
    await app.open();
    await app.run();
    await app.go('Shortlist');
    for (final again in [false, true]) {
      await app.tapText('Add');
      await app.tapText('From a link');
      await app.enter('Link', 'https://www.rightmove.co.uk/properties/123456789#/?channel=RES_LET');
      await app.tapText('Add');
      expect(find.text('New property'), findsOneWidget);
      await app.enter('Address', '5 High Street, Pontefract WF8 1AA');
      await app.tapText('Save');
      expect(find.textContaining('already in your list'), again ? findsOneWidget : findsNothing);
      if (again) await app.tapText('Cancel');
    }
    final rows = (await tester.runAsync(() => app.session.db.select(app.session.db.properties).get()))!;
    expect(rows.single.source, 'rightmove');
    expect(rows.single.sourceId, '123456789');
    expect(rows.single.url, 'https://www.rightmove.co.uk/properties/123456789');
    await app.close();
  });

  testWidgets('a search in plain words lists the sites\' homes and opens one in the app', (tester) async {
    final app = AppHarness(tester)..desktop();
    await app.open();
    final asked = <Uri>[];
    await app.run(
      overrides: [
        searchHttpProvider.overrideWithValue(
          MockClient((r) async {
            asked.add(r.url);
            if (r.url.host == 'los.rightmove.co.uk') {
              return http.Response(
                jsonEncode({
                  'matches': [
                    {'id': '7', 'type': 'REGION'},
                  ],
                }),
                200,
              );
            }
            if (r.url.host == 'www.rightmove.co.uk' && r.url.path.endsWith('find.html')) {
              return http.Response(_rightmovePage, 200);
            }
            return http.Response('', 404);
          }),
        ),
      ],
      maps: true,
    );
    // The app opens on the Dashboard.
    await app.go('Search');
    // Search is the first screen.
    expect(find.text('Try'), findsOneWidget);
    await tester.enterText(
      find.byType(TextField).first,
      '2 bed to rent in Exampletown under £800, no students',
    );
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await app.settle();
    // The words became filters; a filter can be removed.
    expect(find.text('2 bed'), findsOneWidget);
    expect(find.text('Up to £800 pcm'), findsOneWidget);
    expect(find.text('No students'), findsOneWidget);
    expect(asked.firstWhere((u) => u.path.endsWith('find.html')).queryParameters['maxPrice'], '800');
    // One home answers; the let-agreed one and the dear one are left out.
    expect(find.text('1 home answers, of 3 read'), findsOneWidget);
    expect(find.text('Rightmove 3'), findsOneWidget);
    expect(find.text('Open Zoopla'), findsOneWidget);
    expect(find.text('14 Sample Street, Exampletown, EX1 1AA'), findsOneWidget);
    // Opening it reads the advert in the app; its page here is not found.
    await app.tap(find.text('14 Sample Street, Exampletown, EX1 1AA'));
    expect(find.text('Add to Shortlist'), findsOneWidget);
    expect(find.text('See it on Rightmove'), findsOneWidget);
    // The advert's page has its map, measured from the search's place.
    expect(find.byType(HomesMap), findsOneWidget);
    expect(find.text('Distance from your places'), findsOneWidget);
    await app.tapText('Add to Shortlist');
    final rows = (await tester.runAsync(() => app.session.db.select(app.session.db.properties).get()))!;
    expect((rows.single.source, rows.single.price, rows.single.kind), ('rightmove', 650, 'rent'));
    await app.close();
  });

  testWidgets('a home thrown out of Search stays out until restored from the Trash', (tester) async {
    final app = AppHarness(tester)..desktop();
    await app.open();
    await app.run(
      overrides: [
        searchHttpProvider.overrideWithValue(
          MockClient((r) async {
            if (r.url.host == 'los.rightmove.co.uk') {
              return http.Response(
                jsonEncode({
                  'matches': [
                    {'id': '7', 'type': 'REGION'},
                  ],
                }),
                200,
              );
            }
            if (r.url.host == 'www.rightmove.co.uk' && r.url.path.endsWith('find.html')) {
              return http.Response(_rightmovePage, 200);
            }
            return http.Response('', 404);
          }),
        ),
      ],
    );
    // The app opens on the Dashboard.
    await app.go('Search');
    Future<void> search() async {
      await tester.enterText(find.byType(TextField).first, '2 bed to rent in Exampletown under £800');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await app.settle();
    }

    await search();
    const address = '14 Sample Street, Exampletown, EX1 1AA';
    expect(find.text(address), findsOneWidget);
    await app.tap(find.byTooltip('Throw out: never show this home again'));
    expect(find.text(address), findsNothing);
    expect(find.textContaining('1 in your Trash'), findsOneWidget);

    // Undo works although the card has gone.
    await app.tapText('Undo');
    expect(find.text(address), findsOneWidget);
    await app.tap(find.byTooltip('Throw out: never show this home again'));
    expect(find.text(address), findsNothing);

    // A new search still leaves it out.
    await search();
    expect(find.text(address), findsNothing);

    // Profile > Trash lists it; Restore brings it back.
    await app.go('Profile');
    expect(find.text('1 home thrown out of Search.'), findsOneWidget);
    await app.tapText('Open');
    expect(find.text(address), findsOneWidget);
    await app.tapText('Restore');
    expect(find.text('The Trash is empty'), findsOneWidget);
    await app.tap(find.byType(BackButton));
    await app.go('Search');
    expect(find.text(address), findsOneWidget);
    await app.close();
  });

  testWidgets('the tour is offered once, skips at any step and runs again from Settings', (tester) async {
    final app = AppHarness(tester)..desktop();
    await app.open(offerTour: true);
    await app.run();
    expect(find.text('Take the tour'), findsOneWidget);
    await app.tapText('Take the tour');
    expect(find.text('Step 1 of ${anveshanaTour.length}'), findsOneWidget);
    await app.tapText('Next');
    expect(find.text('Your hunt so far'), findsOneWidget);
    await app.tapText('Next');
    expect(find.text('Search in your own words'), findsOneWidget);
    await app.tapText('Skip tour');
    expect(find.text('Search in your own words'), findsNothing);
    await app.go('Settings');
    await app.tap(find.text('Take the tour').last);
    expect(find.text('Welcome to Graha Anveshana'), findsOneWidget);
    await app.tapText('Skip tour');
    await app.close();
    // Not offered again.
    final again = AppHarness(tester)..desktop();
    await again.open(offerTour: true);
    await tester.runAsync(() => again.session.db.setLocalSetting('tour.offered', 'x'));
    await again.run();
    expect(find.text('Take the tour'), findsNothing);
    await again.close();
  });

  testWidgets('an email search is saved with its kind and words', (tester) async {
    final app = AppHarness(tester)..desktop();
    await app.open();
    await app.run();
    await app.go('Search');
    await app.tap(find.byTooltip('Saved searches and alerts'));
    await app.tapText('Add');
    await app.enter('Name', 'Leeds flats');
    await app.tapText('A PropertyPal search (Northern Ireland)');
    await app.tapText('Alert emails from Rightmove, Zoopla and others (England)');
    expect(find.widgetWithText(TextField, 'PropertyPal search'), findsNothing);
    // A distance needs a place to measure from.
    await app.enter('Within', '5');
    await app.tapText('Save');
    expect(find.text('Enter a place or postcode to measure the distance from.'), findsOneWidget);
    await app.enter('Within', '');
    await app.enter('Words', 'Garden, -retirement');
    await app.enter('Highest price', '1100');
    await app.tapText('Save');
    final rows = (await tester.runAsync(() => app.session.db.select(app.session.db.searches).get()))!;
    final s = rows.single;
    expect(
      (s.source, s.path, s.kind, s.keywords, s.maxPrice),
      ('email', '', 'rent', 'garden, -retirement', 1100),
    );
    expect(find.text('Alert emails, to rent · up to £1,100 · garden, -retirement'), findsOneWidget);
    await app.close();
  });

  testWidgets('advert wording is checked against the England rules', (tester) async {
    final app = AppHarness(tester)..desktop();
    await app.open(seed: seed);
    await app.run();
    await app.go('Shortlist');
    await app.tapText('Apt 1 Sample Street, Enniskillen, BT74 1AA');
    await app.tapText('Check advert wording');
    await app.enter('Advert text', 'Best offers over £700. No DSS.');
    expect(find.text('Rent bidding'), findsOneWidget);
    expect(find.text('Refuses tenants on benefits'), findsOneWidget);
    await app.close();
  });

  testWidgets('compare lines the shortlisted homes up side by side', (tester) async {
    final app = AppHarness(tester)..desktop();
    await app.open(
      seed: (book) async {
        for (final (i, price) in [(1, 650), (2, 600)]) {
          final id = newId();
          await book.save(
            book.db.properties,
            PropertiesCompanion.insert(
              id: id,
              address: '$i Test Road, Leeds LS1 4AP',
              kind: PropertyKind.rent.name,
              stage: Value(Stage.shortlisted.id),
              price: Value(price),
              added: '2026-11-01',
              meta: Value(i == 1 ? '{"councilTax": 120, "bills": 150}' : '{}'),
            ),
            id,
          );
        }
      },
    );
    await app.run();
    await app.go('Shortlist');
    await tester.tap(find.byIcon(Icons.compare_arrows));
    await app.settle();
    expect(find.text('2 homes, cheapest first'), findsOneWidget);
    expect(find.text('£600'), findsWidgets);
    expect(find.text('Needed on the day'), findsOneWidget);
    expect(find.text('£920'), findsOneWidget); // 650 + 120 + 150
    expect(find.text('All in a month'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await app.close();
  });

  testWidgets('the viewing checklist adds the problems to the notes', (tester) async {
    final app = AppHarness(tester)..desktop();
    await app.open(seed: seed);
    await app.run();
    await app.go('Shortlist');
    await app.tapText('Apt 1 Sample Street, Enniskillen, BT74 1AA');
    await app.tapText('Checklist');
    await app.tapText('Damp or mould');
    await app.tapText('Parking');
    await app.tapText('Add to notes');
    final p = (await tester.runAsync(() => app.session.db.select(app.session.db.properties).get()))!
        .firstWhere((x) => x.address.startsWith('Apt 1'));
    expect(p.notes, contains('problems: damp or mould; parking.'));
    await app.close();
  });

  testWidgets('the hunt filters by words, beds and price', (tester) async {
    final app = AppHarness(tester)..desktop();
    await app.open(seed: seed);
    await app.run();
    await app.go('Shortlist');
    expect(find.text('Viewing (1)'), findsOneWidget);
    await app.enter('Find', 'nowhere');
    expect(find.text('Viewing (1)'), findsNothing);
    expect(find.text('1 hidden by the filters.'), findsOneWidget);
    await app.enter('Find', 'enniskillen');
    expect(find.text('Viewing (1)'), findsOneWidget);
    await app.enter('Most a month', '600');
    expect(find.text('Viewing (1)'), findsNothing);
    await app.enter('Most a month', '650');
    expect(find.text('Viewing (1)'), findsOneWidget);
    await app.close();
  });

  testWidgets('the hunt groups by stage and measures from the home point', (tester) async {
    final app = AppHarness(tester)..desktop();
    await app.open(seed: seed);
    await app.run();
    await app.go('Shortlist');
    expect(find.text('Viewing (1)'), findsOneWidget);
    expect(find.textContaining('£650 pcm'), findsOneWidget);
    expect(find.text('0.5 km'), findsOneWidget);
    await app.close();
  });

  testWidgets('add a property by hand, move it on and log a call', (tester) async {
    final app = AppHarness(tester)..desktop();
    await app.open();
    await app.run();
    await app.go('Shortlist');
    await app.tapText('Add');
    await app.tapText('Type it in');
    await app.enter('Address', '3 Lake Road, Enniskillen BT74 7AA');
    await app.enter('Rent a month', '600');
    await app.enter('Bedrooms', '2');
    await app.tapText('Save');
    expect(find.text('New (1)'), findsOneWidget);

    await app.tapText('3 Lake Road, Enniskillen BT74 7AA');
    await app.tap(find.widgetWithText(ChoiceChip, 'Liked'));
    final p = (await tester.runAsync(() => app.session.db.select(app.session.db.properties).getSingle()))!;
    expect(p.stage, Stage.shortlisted.id);
    expect(p.postcode, 'BT74 7AA');
    expect(p.price, 600);

    await app.tap(find.widgetWithText(TextButton, 'Add').first);
    await app.enter('What was said', 'Landlord rang back; viewing Saturday');
    await app.tapText('Save');
    expect(find.text('Landlord rang back; viewing Saturday'), findsOneWidget);
    await app.close();
  });

  testWidgets('the enquiry carries the details from Profile', (tester) async {
    final app = AppHarness(tester)..desktop();
    await app.open(seed: seed);
    await app.run();
    await app.go('Profile');
    await app.tap(find.widgetWithText(TextButton, 'Edit').first);
    await app.enter('Name', 'A Tenant');
    await app.enter('Phone', '07700 900123');
    await app.enter('Move in', 'from January 2027');
    await app.tapText('Save');
    expect(find.textContaining('A Tenant'), findsOneWidget);

    await app.go('Shortlist');
    await app.tapText('Apt 1 Sample Street, Enniskillen, BT74 1AA');
    await app.tapText('Write an enquiry');
    expect(find.textContaining('Hello Example Lettings,'), findsOneWidget);
    expect(find.textContaining('Could a tenancy start from January 2027?'), findsOneWidget);
    expect(find.textContaining('A Tenant\n07700 900123'), findsOneWidget);
    await app.close();
  });

  testWidgets('appraisals recalculate and save', (tester) async {
    final app = AppHarness(tester)..desktop();
    await app.open();
    await app.run();
    await app.go('Invest');
    expect(find.text('Cash needed'), findsOneWidget);
    // Default buy-to-let in NI at £150,000 with the surcharge.
    expect(find.text('SDLT'), findsOneWidget);
    await app.enter('Price', '200000');
    // 2% of £75,000 plus the 5% surcharge on £200,000.
    expect(find.text('£11,500'), findsOneWidget);
    await app.tap(find.byIcon(Icons.bookmark_add_outlined));
    await app.enter('Name', 'Test flat');
    await app.tapText('Save');
    await app.tapText('Saved');
    expect(find.widgetWithText(ListTile, 'Test flat'), findsOneWidget);

    await app.tapText('Development');
    expect(find.text('Most to pay for the land'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await app.close();
  });

  testWidgets('a tenancy shows rent owed', (tester) async {
    final app = AppHarness(tester)..desktop();
    await app.open(seed: seed);
    await app.run();
    await app.go('Lettings');
    // Rent of £700 from 1 January with nothing recorded.
    expect(find.textContaining('owed'), findsOneWidget);
    expect(find.text('Gas safety certificate'), findsOneWidget);
    await app.close();
  });

  testWidgets('rent is imported from a pasted bank statement', (tester) async {
    final app = AppHarness(tester)..desktop();
    await app.open(seed: seed);
    await app.run();
    await app.go('Lettings');
    await app.tap(find.byType(ExpansionTile).first);
    await app.tapText('Import from bank');
    await app.enter(
      'Statement CSV',
      'Date,Description,Amount\n01/02/2026,RENT FEB,700.00\n02/02/2026,SHOP,-12.00\n01/03/2026,RENT MAR,700.00\n',
    );
    expect(find.byType(CheckboxListTile), findsNWidgets(2));
    await app.tap(find.byType(CheckboxListTile).last);
    await app.tapText('Record 1');
    final paid = (await tester.runAsync(() => app.session.db.select(app.session.db.rentPayments).get()))!;
    expect([for (final p in paid) (p.date, p.amount)], [('2026-02-01', 700)]);
    expect(find.text('Rent for tax returns'), findsOneWidget);
    await app.close();
  });
}

// A made-up Rightmove results page: one home that answers, one let agreed,
// one over the price.
final _rightmovePage =
    '<html><script id="__NEXT_DATA__" type="application/json">${jsonEncode({
      'props': {
        'pageProps': {
          'searchResults': {
            'properties': [
              {
                'id': 111,
                'bedrooms': 2,
                'displayAddress': '14 Sample Street, Exampletown, EX1 1AA',
                'price': {'amount': 150, 'frequency': 'weekly'},
                'summary': 'Bright flat with allocated parking',
              },
              {
                'id': 112,
                'bedrooms': 2,
                'displayAddress': 'Other Road, Exampletown',
                'price': {'amount': 700, 'frequency': 'monthly'},
                'displayStatus': 'Let agreed',
              },
              {
                'id': 113,
                'bedrooms': 2,
                'displayAddress': 'Dear Lane, Exampletown',
                'price': {'amount': 1500, 'frequency': 'monthly'},
              },
            ],
            'pagination': {'next': null},
          },
        },
      },
    })}</script></html>';
