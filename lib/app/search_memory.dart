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

const _placesKey = 'anveshana.distance.places';

/// The places the user measured homes from, last used first (at most 6).
/// A home's page measures from the first by default.
final distancePlacesProvider = FutureProvider<List<NamedPoint>>((ref) async {
  ref.watch(revisionProvider);
  final raw = await ref.watch(sessionProvider).db.localSetting(_placesKey);
  return placesFromJson(raw);
});

List<NamedPoint> placesFromJson(String? raw) {
  if (raw == null || raw.isEmpty) return const [];
  try {
    return [
      for (final p in jsonDecode(raw) as List)
        if (p case {'lat': final num lat, 'lon': final num lon, 'label': final String label})
          (lat: lat.toDouble(), lon: lon.toDouble(), label: label),
    ];
  } on FormatException {
    return const [];
  }
}

/// [all] with [p] first, the same place (by name) not twice, at most 6.
List<NamedPoint> placesWith(List<NamedPoint> all, NamedPoint p) =>
    [p, ...all.where((o) => o.label.toLowerCase() != p.label.toLowerCase())].take(6).toList();

/// Remembers [p] as the place to measure from (first in the list).
Future<void> rememberPlace(WidgetRef ref, NamedPoint p) => _savePlaces(ref, (all) => placesWith(all, p));

/// Forgets [p].
Future<void> forgetPlace(WidgetRef ref, NamedPoint p) =>
    _savePlaces(ref, (all) => all.where((o) => o.label != p.label).toList());

Future<void> _savePlaces(WidgetRef ref, List<NamedPoint> Function(List<NamedPoint> all) change) async {
  final db = ref.read(sessionProvider).db;
  final next = change(placesFromJson(await db.localSetting(_placesKey)));
  await db.setLocalSetting(
    _placesKey,
    jsonEncode([
      for (final p in next) {'lat': p.lat, 'lon': p.lon, 'label': p.label},
    ]),
  );
  ref.read(revisionProvider.notifier).bump();
}
