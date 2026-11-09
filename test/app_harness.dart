import 'dart:io';

import 'package:anveshana/app/app.dart';
import 'package:anveshana/app/providers.dart';
import 'package:anveshana/app/search_controller.dart';
import 'package:anveshana/ui/homes_map.dart';
import 'package:anveshana/app/session.dart';
import 'package:anveshana/domain/book.dart';
import 'package:brahma_core/brahma_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

/// The whole app over a fresh in-memory database, for widget tests.
class AppHarness {
  AppHarness(this.tester);
  final WidgetTester tester;
  late AppSession session;

  PropertyBook get book => session.book;

  /// Opens the database; [seed] runs before the app starts.
  Future<void> open({Future<void> Function(PropertyBook book)? seed, bool offerTour = false}) async {
    await tester.runAsync(() async {
      final store = await Store.open(memoryDatabase());
      session = AppSession(KeyVault(MemorySecretStore(), anveshanaIdentity), store, PropertyBook(store));
      // Past the first-run choice between this device only and sync.
      await session.db.setLocalSetting('onboarding.sync', 'done');
      // And past the tour offer; tour_test covers it.
      if (!offerTour) await session.db.setLocalSetting('tour.offered', '1');
      await seed?.call(session.book);
    });
  }

  /// Starts the app; [overrides] replace providers (e.g. the sites' HTTP
  /// client). [pageLoader] stands in for the hidden web view. [maps] shows
  /// the maps; their tiles fail to load (no network), which is fine.
  Future<void> run({List<Override> overrides = const [], PageLoader? pageLoader, bool maps = false}) async {
    if (maps) {
      // The map's tile cache asks for a folder; tests have no plugins.
      final dir = Directory.systemTemp.createTempSync('anveshana-tiles').path;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (_) async => dir,
      );
    }
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...anveshanaOverrides(session),
          deviceFactsProvider.overrideWith((ref) async => const DeviceFacts()),
          // No web view or map tiles in widget tests.
          pageLoaderProvider.overrideWithValue(pageLoader),
          inlineMapsProvider.overrideWithValue(maps),
          ...overrides,
        ],
        retry: (_, _) => null,
        child: const AnveshanaApp(),
      ),
    );
    await settle();
  }

  Future<void> close() async {
    // Disposing the scope stops the sync timers.
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() => session.db.close());
  }

  /// Lets database work (real I/O) and animations finish.
  Future<void> settle() async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 400));
    }
  }

  Future<void> tap(Finder f) async {
    await tester.ensureVisible(f);
    await tester.pump();
    await tester.tap(f);
    await settle();
  }

  Future<void> tapText(String text) => tap(find.text(text).last);

  /// Types into the text field labelled [label].
  Future<void> enter(String label, String text) async {
    final f = find.widgetWithText(TextField, label).last;
    await tester.ensureVisible(f);
    await tester.enterText(f, text);
    await tester.pump();
  }

  /// Goes to a top-level page through the navigation rail (desktop sizes).
  Future<void> go(String page) =>
      tap(find.descendant(of: find.byType(NavigationRail), matching: find.text(page)));

  static Finder _within(String widget, Finder f) =>
      find.descendant(of: find.byWidgetPredicate((w) => '${w.runtimeType}' == widget), matching: f);

  /// Taps [page] in the phone dock, which scrolls it into view first.
  Future<void> dock(String page) => tap(_within('_Dock', find.byTooltip(page)));

  /// Swipes the page aside and picks [page] from the phone side panel.
  Future<void> panel(String page) async {
    await tester.flingFrom(const Offset(40, 400), const Offset(300, 0), 1000);
    await settle();
    await tap(_within('_SidePanel', find.text(page)));
  }

  void desktop() {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }
}
