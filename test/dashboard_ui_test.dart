import 'package:anveshana/domain/book.dart';
import 'package:anveshana/domain/dashboard.dart';
import 'package:anveshana/domain/listing.dart';
import 'package:anveshana/domain/pipeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_harness.dart';
import 'support.dart';

// Made-up homes and agents only.
void main() {
  Future<void> seed(PropertyBook book) async {
    final id = (await book.importListing(
      parsePropertyPalPage(nextData({'property': samplePropertyPal()})).single,
      today: '2026-10-20',
    )).id;
    await book.log(propertyId: id, channel: 'email', summary: 'Sent the enquiry', at: '2026-10-20T09:00');
    await book.bookViewing(id, '2026-10-24T11:00');
  }

  testWidgets('the app opens on the Dashboard, which sums up the hunt', (tester) async {
    final app = AppHarness(tester)..desktop();
    await app.open(seed: seed);
    await app.run();
    expect(find.text('Dashboard'), findsWidgets);
    // Headings are set in capitals.
    expect(find.text('HOMES SAVED'), findsWidgets);
    expect(find.text('HOW FAR YOUR HOMES GOT'), findsOneWidget);
    expect(find.text('Example Lettings'), findsOneWidget);
    expect(find.textContaining('1 of 1 enquiry led to a viewing.'), findsOneWidget);
    // A step opens the homes behind it.
    await app.tap(find.text('Viewing').last);
    expect(find.text('Viewing · 1'), findsOneWidget);
    await app.close();
  });

  testWidgets('the plan is set on the Dashboard; figures explain themselves', (tester) async {
    final app = AppHarness(tester)..desktop();
    await app.open(seed: seed);
    await app.run();
    expect(find.text('Your plan'), findsOneWidget);
    await app.tap(find.text('Set'));
    await app.enter('Most rent a month', '950');
    await app.tapText('Save');
    expect(find.text('£950'), findsWidgets);
    expect(find.text('Change'), findsOneWidget);
    expect(
      goalIn(await app.book.pref(PrefKeys.huntGoals, const <String, Object?>{}), PropertyKind.rent).budget,
      950,
    );

    await app.tap(find.text('DAYS HUNTING'));
    expect(find.textContaining('Days since you saved your first home'), findsOneWidget);
    await app.tapText('OK');
    await app.close();
  });

  testWidgets('a viewing marked done asks how it went', (tester) async {
    final app = AppHarness(tester)..desktop();
    await app.open(seed: seed);
    await app.run();
    await app.tap(find.textContaining('Viewing passed').first);
    await app.tap(find.byTooltip('Viewing: done, cancelled or add to calendar'));
    await app.tapText('Done');
    expect(find.text('How was the viewing?'), findsOneWidget);
    await app.tapText('Loved it');
    await app.enter('What you liked or did not', 'Bright rooms');
    await app.tapText('Save');
    final v = (await app.book.db.select(app.book.db.viewings).get()).single;
    expect((v.status, Impression.of(v.rating), v.notes), ('done', Impression.loved, 'Bright rooms'));
    expect(find.text('Loved it · Bright rooms'), findsOneWidget);
    await app.close();
  });

  testWidgets('an empty Dashboard says what will show', (tester) async {
    final app = AppHarness(tester)..desktop();
    await app.open();
    await app.run();
    expect(find.text('Your hunt shows here'), findsOneWidget);
    await app.close();
  });

  testWidgets('every page has the Feedback button at the top right', (tester) async {
    final app = AppHarness(tester)..desktop();
    await app.open();
    await app.run();
    const tip = 'Feedback: report a problem or suggest a feature';
    expect(find.byTooltip(tip), findsOneWidget);
    await app.go('Search');
    await app.tap(find.byTooltip(tip));
    expect(find.text('Suggest a feature'), findsOneWidget);
    expect(find.text('Continue on GitHub'), findsOneWidget);
    await app.tap(find.text('Cancel'));
    expect(find.byType(AlertDialog), findsNothing);
    await app.close();
  });
}
