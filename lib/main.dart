import 'dart:io';

import 'package:brahma_core/brahma_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'app/session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _start();
}

Future<void> _start() async {
  try {
    final session = await AppSession.open(KeyVault(const DeviceSecretStore(), anveshanaIdentity));
    final updater = await _updater();
    runApp(
      ProviderScope(
        overrides: [...anveshanaOverrides(session), updaterProvider.overrideWithValue(updater)],
        // Failures are shown with a retry button; silent retries would hide them.
        retry: (_, _) => null,
        child: const AnveshanaApp(),
      ),
    );
  } catch (e) {
    // Also in release builds' logs, where smoke tests look for it.
    debugPrint('Anveshana startup failed: $e');
    runApp(StartupFailure(e, appName: anveshanaIdentity.name, theme: anveshanaTheme, onRetry: _start));
  }
}

/// The standalone app, in a release build on a platform the releases publish
/// for, updates itself from GitHub (Settings > About, or the start-up banner).
/// Debug builds and the Brahma Suite's copy do not.
Future<AppUpdater?> _updater() async {
  if (!kReleaseMode || !const {'android', 'windows', 'linux'}.contains(Platform.operatingSystem)) return null;
  return AppUpdater(
    http.Client(),
    app: anveshanaIdentity,
    current: (await PackageInfo.fromPlatform()).version,
    // Android's FileProvider shares the APK from here (res/xml/file_paths.xml).
    dir: Directory('${(await getApplicationSupportDirectory()).path}${Platform.pathSeparator}updates'),
  );
}
