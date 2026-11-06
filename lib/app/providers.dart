import 'package:brahma_core/brahma_core.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import '../db/database.dart';
import '../domain/book.dart';
import '../domain/contact_links.dart';
import '../domain/listing.dart';
import '../domain/watch_client.dart';
import '../ui/hints.dart';
import 'security_checks.dart';
import 'session.dart';
import 'tour.dart';

/// The open session; main() overrides this before the first frame.
final sessionProvider = Provider<AppSession>((ref) => throw StateError('No session'));

/// What main() and the tests override: the session, under both its Anveshana
/// and its shared type, and the app's identity and hints.
List<Override> anveshanaOverrides(AppSession session) => [
  sessionProvider.overrideWithValue(session),
  coreSessionProvider.overrideWithValue(session),
  appIdentityProvider.overrideWithValue(anveshanaIdentity),
  hintTextsProvider.overrideWithValue({...coreHints, ...anveshanaHints}),
  sentinelChecksProvider.overrideWithValue([...coreChecks, lockCheck, ...anveshanaChecks]),
  tourProvider.overrideWithValue(anveshanaTour),
];

extension Mutate on WidgetRef {
  /// Runs a write, refreshes the screens and queues a sync.
  Future<T> mutate<T>(Future<T> Function(AppSession s) write) async {
    final result = await write(read(sessionProvider));
    changed();
    return result;
  }
}

/// The rows of [table] that are not deleted, re-read after every write.
FutureProvider<List<D>> _rows<T extends SyncedRow, D>(
  TableInfo<T, D> Function(AppDatabase db) table, {
  List<OrderingTerm Function(T t)> orderBy = const [],
}) => FutureProvider<List<D>>((ref) {
  ref.watch(revisionProvider);
  final db = ref.watch(sessionProvider).db;
  final q = db.select(table(db))
    ..where((t) => t.deleted.not())
    ..orderBy(orderBy);
  return q.get();
});

final propertiesProvider = _rows<$PropertiesTable, Property>(
  (db) => db.properties,
  orderBy: [
    (p) => OrderingTerm.desc(p.added),
    (p) => OrderingTerm(expression: p.address),
  ],
);

final contactsProvider = _rows<$ContactsTable, Contact>(
  (db) => db.contacts,
  orderBy: [(c) => OrderingTerm(expression: c.name)],
);

final searchesProvider = _rows<$SearchesTable, Search>(
  (db) => db.searches,
  orderBy: [(s) => OrderingTerm(expression: s.name)],
);

final appraisalsProvider = _rows<$AppraisalsTable, Appraisal>(
  (db) => db.appraisals,
  orderBy: [(a) => OrderingTerm.desc(a.updated)],
);

final tenanciesProvider = _rows<$TenanciesTable, Tenancy>(
  (db) => db.tenancies,
  orderBy: [(t) => OrderingTerm.desc(t.start)],
);

final rentPaymentsProvider = _rows<$RentPaymentsTable, RentPayment>(
  (db) => db.rentPayments,
  orderBy: [(p) => OrderingTerm.desc(p.date)],
);

final complianceProvider = _rows<$ComplianceItemsTable, ComplianceItem>(
  (db) => db.complianceItems,
  orderBy: [(c) => OrderingTerm(expression: c.due)],
);

final areasProvider = _rows<$AreasTable, Area>(
  (db) => db.areas,
  orderBy: [(a) => OrderingTerm.desc(a.fetched)],
);

final researchesProvider = _rows<$ResearchesTable, ResearchJob>(
  (db) => db.researches,
  orderBy: [(r) => OrderingTerm.desc(r.created)],
);

/// Every catalog item of every research, in capture order (duplicate checks
/// keep the earlier one).
final catalogItemsProvider = _rows<$CatalogItemsTable, CatalogItem>(
  (db) => db.catalogItems,
  orderBy: [(i) => OrderingTerm(expression: i.captured)],
);

final interactionsProvider = _rows<$InteractionsTable, Interaction>(
  (db) => db.interactions,
  orderBy: [(i) => OrderingTerm.desc(i.at)],
);

final viewingsProvider = _rows<$ViewingsTable, Viewing>(
  (db) => db.viewings,
  orderBy: [(v) => OrderingTerm(expression: v.at)],
);

final homeProvider = FutureProvider<HomePoint?>((ref) {
  ref.watch(revisionProvider);
  return ref.watch(sessionProvider).book.home();
});

final applicantProvider = FutureProvider<Applicant>((ref) {
  ref.watch(revisionProvider);
  return ref.watch(sessionProvider).book.applicant();
});

/// The user's Brahma Watch, or null until its address and token are set.
final watchProvider = FutureProvider<WatchClient?>((ref) async {
  ref.watch(revisionProvider);
  final book = ref.watch(sessionProvider).book;
  final url = await book.pref<String>(PrefKeys.watchUrl, '');
  final token = await book.pref<String>(PrefKeys.watchToken, '');
  return url.isEmpty || token.isEmpty ? null : WatchClient(url, token);
});

/// Distance in km from the home point, when both ends are known.
double? distanceFromHome(HomePoint? home, double? lat, double? lon) =>
    home == null || lat == null || lon == null ? null : distanceKm(home.lat, home.lon, lat, lon);

/// Pulls Brahma Watch alerts since the last check into the hunt. Returns how
/// many properties were new. The check time is per device: each device
/// imports, and the import itself dedupes.
Future<int> pullWatchEvents(AppSession s, WatchClient watch) async {
  final since = await s.db.localSetting('watch.since');
  final events = await watch.events(since: since);
  var added = 0;
  for (final e in events) {
    if ((await s.book.importListing(e.listing)).added) added++;
  }
  if (events.isNotEmpty) await s.db.setLocalSetting('watch.since', events.last.at);
  return added;
}

/// Checks Brahma Watch once at start-up. Offline is fine: the Hunt page has
/// a button, and the next start tries again.
final watchAutoProvider = FutureProvider<void>((ref) async {
  final watch = await ref.read(watchProvider.future);
  if (watch == null) return;
  try {
    if (await pullWatchEvents(ref.read(sessionProvider), watch) > 0) {
      ref.read(revisionProvider.notifier).bump();
    }
  } on Object {
    return;
  }
});
