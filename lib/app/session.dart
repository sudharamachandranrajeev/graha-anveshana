import 'package:brahma_core/brahma_core.dart';

import '../db/database.dart';
import '../domain/book.dart';

/// Graha Anveshana in Brahma's terms: the app's id, name and Android package.
const anveshanaIdentity = AppIdentity(
  id: 'anveshana',
  name: 'Graha Anveshana',
  androidPackage: 'dev.brahma.anveshana',
  releases: 'sudharamachandranrajeev/graha-anveshana-property-search',
);

/// Everything a running app needs: keys, the encrypted database and the
/// property book on top of it. Opened once at start-up.
class AppSession extends CoreSession {
  AppSession(super.keys, super.store, this.book, {super.deviceName});

  final PropertyBook book;

  @override
  AppDatabase get db => store.db as AppDatabase;

  static Future<AppSession> open(KeyVault keys) => CoreSession.open(
    anveshanaIdentity,
    keys,
    openDatabase: AppDatabase.open,
    build: (store, deviceName) => AppSession(keys, store, PropertyBook(store), deviceName: deviceName),
  );
}
