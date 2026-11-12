import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:anveshana/app/app.dart';
import 'package:anveshana/app/providers.dart';
import 'package:anveshana/db/database.dart';
import 'package:anveshana/domain/book.dart';
import 'package:anveshana/domain/lettings.dart';
import 'package:brahma_core/brahma_core.dart' show addDays, addMonths, today;

import 'package:anveshana/ui/homes_map.dart';

import 'app_harness.dart';

/// Renders the main screens with the real fonts to PNG files, for checking
/// the look. Runs only when GRAHA_SHOTS names an output folder:
/// `GRAHA_SHOTS=/tmp/shots flutter test test/screenshots_test.dart`.
void main() {
  final out = Platform.environment['GRAHA_SHOTS'];

  Future<void> loadFonts() async {
    Future<void> family(String name, List<String> files) async {
      final loader = FontLoader(name);
      for (final f in files) {
        loader.addFont(Future.value(ByteData.sublistView(File(f).readAsBytesSync())));
      }
      await loader.load();
    }

    final inter = [
      for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) 'assets/fonts/Inter-$w.ttf',
    ];
    await family('Inter', inter);
    // A few list-tile trailing texts ask for the platform's Roboto, which the
    // test engine lacks (it draws boxes); stand Inter in for it.
    await family('Roboto', inter);
    final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? '';
    final icons = File('$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
    if (icons.existsSync()) await family('MaterialIcons', [icons.path]);
  }

  // Made-up homes: nothing here is anyone's data.
  Future<void> seed(PropertyBook book) async {
    Future<void> home(String id, PropertiesCompanion c) =>
        book.save(book.db.properties, c.copyWith(id: Value(id), added: const Value('2026-10-01')), id);
    await home(
      'a',
      const PropertiesCompanion(
        address: Value('12 Sample Street, Exampleton'),
        kind: Value('rent'),
        price: Value(650),
        beds: Value(2),
        stage: Value('shortlisted'),
        rating: Value(4),
      ),
    );
    await home(
      'b',
      const PropertiesCompanion(
        address: Value('Flat 3, 8 Placeholder Row'),
        kind: Value('rent'),
        price: Value(595),
        beds: Value(1),
        rating: Value(2),
      ),
    );
    await home(
      'c',
      const PropertiesCompanion(
        address: Value('27 Fictional Gardens'),
        kind: Value('rent'),
        price: Value(720),
        beds: Value(3),
        stage: Value('viewing'),
        rating: Value(5),
      ),
    );
    // A home owned and let out, so Lettings has something to show.
    await home(
      'd',
      const PropertiesCompanion(
        address: Value('4 Example Terrace, Sampletown'),
        kind: Value('owned'),
        price: Value(142000),
        beds: Value(3),
        stage: Value('agreed'),
      ),
    );
    final day = today();
    final start = addMonths(day, -14).replaceRange(8, 10, '01');
    await book.save(
      book.db.tenancies,
      TenanciesCompanion.insert(
        id: 't',
        propertyId: 'd',
        role: 'landlord',
        otherParty: const Value('Sam Placeholder'),
        start: start,
        rent: 795,
        deposit: const Value(795),
        depositScheme: const Value('TDS Northern Ireland'),
      ),
      't',
    );
    // Paid up but for the latest month.
    final dues = rentDueDates(start: start, day: 1, asOf: day);
    for (final (i, due) in dues.take(dues.length - 1).indexed) {
      await book.save(
        book.db.rentPayments,
        RentPaymentsCompanion.insert(id: 'r$i', tenancyId: 't', date: due, amount: 795),
        'r$i',
      );
    }
    for (final (kind, days) in [('gas', 18), ('alarms', 40), ('eicr', 600)]) {
      await book.save(
        book.db.complianceItems,
        ComplianceItemsCompanion.insert(id: kind, propertyId: 'd', kind: kind, due: addDays(day, days)),
        kind,
      );
    }
  }

  testWidgets('screenshots', skip: out == null, (tester) async {
    await tester.runAsync(loadFonts);
    debugDisableShadows = false;
    final key = GlobalKey();
    var n = 0;

    Future<void> shot(String name) async {
      final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final bytes = await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: tester.view.devicePixelRatio);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      File('$out/${(++n).toString().padLeft(2, '0')}-$name.png')
        ..createSync(recursive: true)
        ..writeAsBytesSync(bytes!.buffer.asUint8List());
    }

    for (final dark in [true, false]) {
      tester.platformDispatcher.platformBrightnessTestValue = dark ? Brightness.dark : Brightness.light;
      final app = AppHarness(tester);
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      await app.open(seed: seed);
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: ProviderScope(
            overrides: [...anveshanaOverrides(app.session), inlineMapsProvider.overrideWithValue(false)],
            retry: (_, _) => null,
            child: const AnveshanaApp(),
          ),
        ),
      );
      await app.settle();
      final mode = dark ? 'dark' : 'light';
      await shot('dashboard-$mode');
      await app.dock('Shortlist');
      await shot('hunt-$mode');
      for (final page in ['Invest', 'Lettings']) {
        await app.dock(page);
        await shot('${page.toLowerCase()}-$mode');
      }
      await tester.flingFrom(const Offset(40, 400), const Offset(300, 0), 1000);
      await app.settle();
      await shot('panel-$mode');
      await app.tap(find.text('Shortlist').last);
      await app.tap(find.text('27 Fictional Gardens').last);
      await shot('home-$mode');
      await app.close();
    }

    // One desktop-width shot: the navigation rail layout.
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    final app = AppHarness(tester);
    tester.view.physicalSize = const Size(2160, 1350);
    tester.view.devicePixelRatio = 1.5;
    await app.open(seed: seed);
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: ProviderScope(
          overrides: [...anveshanaOverrides(app.session), inlineMapsProvider.overrideWithValue(false)],
          retry: (_, _) => null,
          child: const AnveshanaApp(),
        ),
      ),
    );
    await app.settle();
    await shot('dashboard-desktop-light');
    await app.go('Shortlist');
    await shot('hunt-desktop-light');
    await app.go('Lettings');
    await shot('lettings-desktop-light');
    await app.close();
    tester.view.reset();
    debugDisableShadows = true;
  });
}
