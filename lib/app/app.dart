import 'package:brahma_core/brahma_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ui/look.dart';
import '../ui/share_inbox.dart';
import 'modules.dart';
import 'providers.dart';

ThemeData anveshanaTheme(Brightness b) => instrumentTheme(b);

class AnveshanaApp extends StatelessWidget {
  const AnveshanaApp({super.key, this.home = const _Root()});
  final Widget home;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Graha Anveshana',
    debugShowCheckedModeBanner: false,
    theme: anveshanaTheme(Brightness.light),
    darkTheme: anveshanaTheme(Brightness.dark),
    builder: (context, child) => AppLockGate(child: Backdrop(child: child ?? const SizedBox.shrink())),
    home: home,
  );
}

/// New listings from Brahma Watch since the last start.
void fetchWatch(WidgetRef ref) => Future.microtask(() => ref.read(watchAutoProvider.future)).ignore();

/// The app, opening the links the platform hands over (a scanned pairing
/// code, or an advert shared to it). There is no onboarding: every screen
/// works empty.
class _Root extends ConsumerWidget {
  const _Root();

  @override
  Widget build(BuildContext context, WidgetRef ref) => LinkHandler(
    child: ShareInbox(
      child: AppShell(destinations: allDestinations, onStart: fetchWatch, floating: true),
    ),
  );
}
