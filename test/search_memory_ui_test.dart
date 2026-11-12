import 'dart:convert';

import 'package:anveshana/app/search_controller.dart';
import 'package:anveshana/domain/book.dart';
import 'package:anveshana/domain/search_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'app_harness.dart';

/// Zoopla's results page as the hidden web view sees it: two advert cards.
const _zooplaCards =
    '[{"id":"70000001","href":"https://www.zoopla.co.uk/to-rent/details/70000001/",'
    '"text":"£850 pcm\\n2 bed flat to rent\\nCardigan Road, Leeds LS6","img":""},'
    '{"id":"70000002","href":"https://www.zoopla.co.uk/to-rent/details/70000002/",'
    '"text":"£700 pcm\\n2 bed flat to rent\\nOtley Road, Leeds LS16","img":""}]';

void main() {
  testWidgets('Zoopla is read in the hidden browser and joins the results; Facebook waits for a sign-in', (
    tester,
  ) async {
    final app = AppHarness(tester)..desktop();
    await app.open();
    final loaded = <Uri>[];
    await app.run(
      // The other sites do not know the place.
      overrides: [searchHttpProvider.overrideWithValue(MockClient((r) async => http.Response('', 404)))],
      pageLoader: (url) async {
        loaded.add(url);
        return url.host == 'www.zoopla.co.uk'
            ? (html: '<html></html>', cards: _zooplaCards)
            : (html: '<html>Log in to Facebook</html>', cards: '[]');
      },
    );
    // The app opens on the Dashboard.
    await app.go('Search');
    await tester.enterText(find.byType(TextField).first, '2 bed to rent in Leeds under £900');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await app.settle();
    expect(loaded.map((u) => u.host), containsAll(['www.zoopla.co.uk', 'www.facebook.com']));
    expect(find.text('Zoopla 2'), findsOneWidget);
    expect(find.text('Open Facebook Marketplace'), findsOneWidget);
    expect(find.text('2 homes answer'), findsOneWidget);
    // Cheapest first.
    await app.tap(find.text('Sort: Best match'));
    await app.tapText('Price, lowest first');
    expect(find.text('Sort: Price, lowest first'), findsOneWidget);
    final cheap = tester.getTopLeft(find.text('Otley Road, Leeds LS16')).dy;
    final dear = tester.getTopLeft(find.text('Cardigan Road, Leeds LS6')).dy;
    expect(cheap, lessThan(dear));
    // Saved under a name.
    await app.tapText('Save search');
    await app.enter('Name', 'Leeds flats');
    await app.tapText('Save');
    final saved = (await tester.runAsync(
      () => app.book.pref<List<Object?>>(PrefKeys.savedSearches, const []),
    ))!;
    expect(saved.single, containsPair('name', 'Leeds flats'));
    expect(saved.single, containsPair('sort', 'priceLow'));
    await app.close();
  });

  testWidgets('the start screen carries on the last search and lists saved ones', (tester) async {
    final app = AppHarness(tester)..desktop();
    final last = readRequest('2 bed to rent in Leeds under £900');
    await app.open(
      seed: (book) async {
        await book.db.setLocalSetting(
          'anveshana.search.history',
          jsonEncode([last.toJson(), readRequest('house for sale in York').toJson()]),
        );
        await book.setPref(PrefKeys.savedSearches, [
          {'id': 's1', 'name': 'York houses', 'request': readRequest('house for sale in York').toJson()},
        ]);
      },
    );
    await app.run(
      overrides: [searchHttpProvider.overrideWithValue(MockClient((r) async => http.Response('', 404)))],
    );
    // The app opens on the Dashboard.
    await app.go('Search');
    expect(find.text('Carry on: 2 bed to rent in Leeds under £900'), findsOneWidget);
    expect(find.text('York houses'), findsOneWidget);
    expect(find.text('house for sale in York'), findsOneWidget);
    await app.tapText('York houses');
    expect(find.text('York'), findsOneWidget);
    expect(find.text('Save search'), findsOneWidget);
    await app.close();
  });
}
