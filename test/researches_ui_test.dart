import 'package:anveshana/domain/catalog.dart';
import 'package:anveshana/domain/catalog_book.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_harness.dart';

void main() {
  testWidgets('a collection: catalog, fit, duplicates merged, Hunt, help search', (tester) async {
    final app = AppHarness(tester)..desktop();
    late String research;
    await app.open(
      seed: (book) async {
        research = await book.createResearch(
          'Rental near work',
          criteria: const ResearchCriteria(maxPrice: 700, minBeds: 2),
        );
        await book.addItem(
          research,
          kind: 'link',
          title: '14 Sample Street',
          url: 'https://www.rightmove.co.uk/properties/100001',
          source: 'rightmove',
          sourceId: '100001',
          fields: const ItemFields(address: '14 Sample Street', postcode: 'BT74 1AA', price: 650, beds: 2),
          captured: '2026-11-01T09:00:00',
        );
        await book.addItem(
          research,
          kind: 'document',
          title: 'Brochure',
          fields: const ItemFields(
            address: '14 Sample St',
            postcode: 'BT74 1AA',
            price: 650,
            beds: 2,
            epc: 'C',
          ),
          captured: '2026-11-02T09:00:00',
        );
        await book.addItem(
          research,
          kind: 'note',
          title: 'Too dear',
          fields: const ItemFields(postcode: 'BT74 2BB', price: 900, beds: 1),
          captured: '2026-11-03T09:00:00',
        );
      },
    );
    await app.run();
    await app.go('Collections');
    expect(find.textContaining('3 items · 1 possible duplicate'), findsOneWidget);

    await app.tapText('Rental near work');
    expect(find.text('100%'), findsNWidgets(2));
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('over £700, fewer than 2 bedrooms'), findsOneWidget);

    await app.tapText('1 possible duplicate');
    expect(find.text('SAME ADDRESS'), findsOneWidget);
    await app.tapText('Merge');
    expect(find.text('No duplicates found'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await app.settle();

    final items = await tester.runAsync(
      () => (app.session.db.select(app.session.db.catalogItems)..where((i) => i.deleted.not())).get(),
    );
    expect(items!.length, 2);
    final merged = items.firstWhere((i) => i.sourceId == '100001');
    expect(itemFields(merged).epc, 'C');

    // Into Shortlist from the item's page.
    await app.tapText('14 Sample Street');
    await app.tapText('Add to Shortlist');
    expect(find.text('Open in Shortlist'), findsOneWidget);
    final homes = await tester.runAsync(() => app.session.db.select(app.session.db.properties).get());
    expect(homes!.single.address, '14 Sample Street');
    expect(tester.takeException(), isNull);

    // Help finds the feature offline and goes there.
    await tester.binding.handlePopRoute();
    await app.settle();
    await tester.binding.handlePopRoute();
    await app.settle();
    await app.go('Shortlist');
    await app.tap(find.byTooltip('Help: search this app or ask AI'));
    await tester.enterText(find.byType(TextField).last, 'merge duplicates');
    await app.settle();
    expect(find.textContaining('Find the same home captured twice'), findsOneWidget);
    await app.tap(find.text('Go there').first);
    expect(find.text('Rental near work'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    await app.close();
  });
}
