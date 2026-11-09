import 'dart:convert';

import 'package:brahma_core/brahma_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import '../domain/book.dart';
import '../domain/pipeline.dart';
import '../domain/property_search.dart';
import '../domain/search_request.dart';
import '../domain/sources.dart';
import '../domain/taste.dart';
import '../domain/trash.dart';
import 'providers.dart';

// What the Search tab remembers so the user need not start again: the
// searches they made (this device), the ones they saved (synced), and the
// taste learnt from the homes they keep.

const _historyKey = 'anveshana.search.history';
const _sortKey = 'anveshana.search.sort';

/// How many past searches are kept.
const historySize = 30;

/// The searches made on this device, newest first.
final searchHistoryProvider = FutureProvider<List<SearchRequest>>((ref) async {
  ref.watch(revisionProvider);
  final raw = await ref.watch(sessionProvider).db.localSetting(_historyKey);
  if (raw == null) return const [];
  try {
    return [
      for (final j in jsonDecode(raw) as List)
        if (j is Map) SearchRequest.fromJson(j.cast()),
    ];
  } on FormatException {
    return const [];
  }
});

/// Puts [q] first in the history. A change to the newest search (a filter
/// chip) replaces it rather than adding another.
Future<void> recordSearch(Ref ref, SearchRequest q) async {
  if (q.isEmpty) return;
  final old = await ref.read(searchHistoryProvider.future);
  final rest = [...old.where((o) => !o.sameAs(q))];
  final newest = rest.firstOrNull;
  if (newest != null && newest.area.toLowerCase() == q.area.toLowerCase() && newest.rent == q.rent) {
    rest.removeAt(0);
  }
  final next = [q, ...rest].take(historySize);
  await ref
      .read(sessionProvider)
      .db
      .setLocalSetting(_historyKey, jsonEncode([for (final r in next) r.toJson()]));
  ref.read(revisionProvider.notifier).bump();
}

/// The order the user last chose for Search results; null: not chosen.
final searchSortProvider = FutureProvider<HomeSort?>((ref) async {
  ref.watch(revisionProvider);
  return HomeSort.ofName(await ref.watch(sessionProvider).db.localSetting(_sortKey));
});

Future<void> rememberSort(Ref ref, HomeSort sort) async {
  await ref.read(sessionProvider).db.setLocalSetting(_sortKey, sort.name);
  ref.read(revisionProvider.notifier).bump();
}

/// A search the user saved to run again, with the order they chose.
typedef SavedSearch = ({String id, String name, SearchRequest request, HomeSort? sort});

/// The saved searches, in the order saved. Synced with the user's other devices.
final savedSearchesProvider = FutureProvider<List<SavedSearch>>((ref) async {
  ref.watch(revisionProvider);
  final raw = await ref.watch(sessionProvider).book.pref<List<Object?>>(PrefKeys.savedSearches, const []);
  return [
    for (final j in raw)
      if (j case {'id': final String id, 'name': final String name, 'request': final Map request})
        (
          id: id,
          name: name,
          request: SearchRequest.fromJson(request.cast()),
          sort: HomeSort.ofName(j['sort'] as String?),
        ),
  ];
});

Future<void> _putSaved(PropertyBook book, List<SavedSearch> all) => book.setPref(PrefKeys.savedSearches, [
  for (final s in all)
    {'id': s.id, 'name': s.name, 'request': s.request.toJson(), if (s.sort != null) 'sort': s.sort!.name},
]);

/// Saves [q] as [name]. The same search saved before is renamed and updated.
Future<void> saveSearch(
  PropertyBook book,
  List<SavedSearch> all,
  String name,
  SearchRequest q,
  HomeSort? sort,
) {
  final same = all.where((s) => s.request.sameAs(q) || s.name == name).firstOrNull;
  final saved = (id: same?.id ?? newId(), name: name, request: q, sort: sort);
  return _putSaved(book, [for (final s in all) s.id == same?.id ? saved : s, if (same == null) saved]);
}

Future<void> removeSavedSearch(PropertyBook book, List<SavedSearch> all, String id) =>
    _putSaved(book, [...all.where((s) => s.id != id)]);

/// The taste learnt from the Hunt's homes of one kind ('rent' or 'buy').
final tasteProvider = FutureProvider.family<Taste, String>((ref, kind) async {
  final all = await ref.watch(propertiesProvider.future);
  return Taste.learn([
    for (final p in all.where((p) => p.kind == kind))
      (
        price: p.price,
        beds: p.beds,
        postcode: p.postcode,
        text: [p.address, p.style, p.furnished, _description(p.meta)].join('\n'),
        weight: _weight(Stage.of(p.stage), p.rating),
      ),
  ]);
});

String _description(String meta) {
  try {
    return '${(jsonDecode(meta) as Map)['description'] ?? ''}';
  } on Object {
    return '';
  }
}

/// How much a kept home counts: turned down ones push away; a high rating
/// or a later stage counts more. A home rated 1 or 2 counts as turned down.
double _weight(Stage stage, int rating) {
  if (stage == Stage.dropped || (rating > 0 && rating <= 2)) return -1;
  return 1 + (rating > 0 ? (rating - 3) * 0.5 : 0) + Stage.values.indexOf(stage) * 0.25;
}

String _connectKey(SourceId s) => 'anveshana.connect.${s.key}';

/// When the user connected [s] (signed in to it through the app), as
/// yyyy-MM-dd; null when not connected. Local to the device, as the
/// sign-in itself is.
final siteConnectionProvider = FutureProvider.family<String?, SourceId>((ref, s) async {
  ref.watch(revisionProvider);
  final v = await ref.watch(sessionProvider).db.localSetting(_connectKey(s));
  return v == null || v.isEmpty ? null : v;
});

/// Records that [s] is connected (on [date]) or not (null).
Future<void> markConnected(AppDatabase db, SourceId s, String? date) =>
    db.setLocalSetting(_connectKey(s), date ?? '');

/// A named point on the map: a postcode, a town, the user's work.
typedef NamedPoint = ({double lat, double lon, String label});

/// Places kept on this device by 0.10.1, before they moved to the profile.
const _localPlacesKey = 'anveshana.distance.places';

/// The place last picked to measure homes from, on this device.
const _lastPlaceKey = 'anveshana.distance.last';

/// The user's places (Profile): work, family, a school. Every home shows how
/// far it is from each. Synced with the user's other devices.
final profilePlacesProvider = FutureProvider<List<NamedPoint>>((ref) async {
  ref.watch(revisionProvider);
  final session = ref.watch(sessionProvider);
  final synced = await session.book.pref<List<Object?>>(PrefKeys.places, const []);
  if (synced.isNotEmpty) return placesFromJson(synced);
  return placesFromJson(jsonDecodeOr(await session.db.localSetting(_localPlacesKey)));
});

/// The label of the place last picked on a home's page; null: none yet.
final lastPlaceProvider = FutureProvider<String?>((ref) async {
  ref.watch(revisionProvider);
  final v = await ref.watch(sessionProvider).db.localSetting(_lastPlaceKey);
  return v == null || v.isEmpty ? null : v;
});

Object? jsonDecodeOr(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  try {
    return jsonDecode(raw);
  } on FormatException {
    return null;
  }
}

List<NamedPoint> placesFromJson(Object? raw) => [
  if (raw is List)
    for (final p in raw)
      if (p case {'lat': final num lat, 'lon': final num lon, 'label': final String label})
        (lat: lat.toDouble(), lon: lon.toDouble(), label: label),
];

/// [all] with [p] added, or put in place of the one with its name.
List<NamedPoint> placesWith(List<NamedPoint> all, NamedPoint p) {
  final at = all.indexWhere((o) => o.label.toLowerCase() == p.label.toLowerCase());
  return [for (final (i, o) in all.indexed) i == at ? p : o, if (at < 0) p];
}

/// Adds [p] to the profile's places (or updates the one with its name).
Future<void> addPlace(WidgetRef ref, NamedPoint p) => _savePlaces(ref, (all) => placesWith(all, p));

/// Removes [p] from the profile's places.
Future<void> removePlace(WidgetRef ref, NamedPoint p) =>
    _savePlaces(ref, (all) => all.where((o) => o.label != p.label).toList());

/// Remembers [p] as the place to measure the next home from.
Future<void> pickPlace(WidgetRef ref, NamedPoint p) async {
  await ref.read(sessionProvider).db.setLocalSetting(_lastPlaceKey, p.label);
  ref.read(revisionProvider.notifier).bump();
}

Future<void> _savePlaces(WidgetRef ref, List<NamedPoint> Function(List<NamedPoint> all) change) async {
  final all = await ref.read(profilePlacesProvider.future);
  await ref.mutate(
    (s) => s.book.setPref(PrefKeys.places, [
      for (final p in change(all)) {'lat': p.lat, 'lon': p.lon, 'label': p.label},
    ]),
  );
}

/// The homes thrown out of Search (see [TrashedHome]), newest first. Synced.
final trashProvider = FutureProvider<List<TrashedHome>>((ref) async {
  ref.watch(revisionProvider);
  final raw = await ref.watch(sessionProvider).book.pref<List<Object?>>(PrefKeys.trash, const []);
  return [for (final j in raw) ?TrashedHome.fromJson(j)];
});

/// Throws [h] out of Search for good (until restored).
Future<void> trashHome(WidgetRef ref, FoundHome h) async {
  final all = await ref.read(trashProvider.future);
  final t = TrashedHome.of(h, isoDate(DateTime.now()));
  await _saveTrash(ref, [t, ...all.where((o) => o.id != t.id)]);
}

/// Brings [t] back into Search.
Future<void> restoreHome(WidgetRef ref, TrashedHome t) async {
  final all = await ref.read(trashProvider.future);
  await _saveTrash(ref, [...all.where((o) => o.id != t.id)]);
}

/// Empties the Trash: everything in it may show again.
Future<void> emptyTrash(WidgetRef ref) => _saveTrash(ref, const []);

Future<void> _saveTrash(WidgetRef ref, List<TrashedHome> all) =>
    ref.mutate((s) => s.book.setPref(PrefKeys.trash, [for (final t in all) t.toJson()]));
