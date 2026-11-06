import 'dart:convert';

import 'package:brahma_core/brahma_core.dart';
import 'package:drift/drift.dart';

import '../db/database.dart';
import 'contact_links.dart';
import 'listing.dart';
import 'pipeline.dart';

/// Pref keys. The prefs table is shared by every Brahma app, so Anveshana's
/// keys carry its prefix.
abstract final class PrefKeys {
  static const applicant = 'anveshana.applicant';
  static const home = 'anveshana.home';
  static const watchUrl = 'anveshana.watch.url';
  static const watchToken = 'anveshana.watch.token';
}

/// Where distances are measured from (the user's home or work).
typedef HomePoint = ({double lat, double lon, String label});

/// Anveshana's write path and the reads screens share.
class PropertyBook {
  PropertyBook(this.store);
  final Store store;

  AppDatabase get db => store.db as AppDatabase;

  Future<T> pref<T>(String key, T fallback) async {
    final row = await (db.select(db.prefs)..where((p) => p.id.equals(key))).getSingleOrNull();
    if (row == null || row.deleted) return fallback;
    final v = jsonDecode(row.value);
    return v is T ? v : fallback;
  }

  Future<void> setPref(String key, Object value) => store.save(
    db.prefs,
    PrefsCompanion.insert(id: key, value: jsonEncode(value), deleted: const Value(false)),
    key,
  );

  Future<Applicant> applicant() async =>
      Applicant.fromJson(await pref<Map<String, Object?>>(PrefKeys.applicant, const {}));

  Future<HomePoint?> home() async {
    final j = await pref<Map<String, Object?>>(PrefKeys.home, const {});
    final lat = j['lat'], lon = j['lon'];
    if (lat is! num || lon is! num) return null;
    return (lat: lat.toDouble(), lon: lon.toDouble(), label: '${j['label'] ?? ''}');
  }

  Future<void> setHome(HomePoint h) => setPref(PrefKeys.home, {'lat': h.lat, 'lon': h.lon, 'label': h.label});

  /// Saves a row of any Anveshana table.
  Future<void> save<T extends Table, D>(TableInfo<T, D> table, Insertable<D> row, String id) =>
      store.save(table, row, id);

  Future<void> remove(TableInfo table, String id) => store.remove(table, id);

  /// Removes a property with its viewings, contact log, tenancies and checks.
  Future<void> removeProperty(String id) => db.transaction(() async {
    for (final (table, column) in <(TableInfo, String)>[
      (db.viewings, 'property_id'),
      (db.interactions, 'property_id'),
      (db.tenancies, 'property_id'),
      (db.complianceItems, 'property_id'),
    ]) {
      final rows = await db
          .customSelect(
            'SELECT id FROM "${table.actualTableName}" WHERE "$column" = ? AND deleted = 0',
            variables: [Variable(id)],
          )
          .get();
      for (final r in rows) {
        await store.remove(table, r.read<String>('id'));
      }
    }
    await store.remove(db.properties, id);
  });

  /// The agent contact for an advert, found by name or made.
  Future<String?> agentFor(Listing l) async {
    if (l.agent.isEmpty) return null;
    final existing =
        await (db.select(db.contacts)
              ..where((c) => c.deleted.not() & c.organisation.equals(l.agent))
              ..limit(1))
            .getSingleOrNull() ??
        await (db.select(db.contacts)
              ..where((c) => c.deleted.not() & c.name.equals(l.agent))
              ..limit(1))
            .getSingleOrNull();
    if (existing != null) {
      if (existing.phone.isEmpty && l.agentPhone.isNotEmpty) {
        await save(db.contacts, existing.copyWith(phone: l.agentPhone), existing.id);
      }
      return existing.id;
    }
    final id = newId();
    await save(
      db.contacts,
      ContactsCompanion.insert(
        id: id,
        name: l.agent,
        organisation: Value(l.agent),
        phone: Value(l.agentPhone),
        role: const Value('agent'),
      ),
      id,
    );
    return id;
  }

  /// Adds an advert, or refreshes the one already saved (price, status,
  /// photo), keeping the user's stage, rating and notes. Returns its id and
  /// whether it was new.
  Future<({String id, bool added})> importListing(Listing l, {PropertyKind? kind, String? today}) =>
      db.transaction(() async {
        final existing =
            await (db.select(db.properties)
                  ..where((p) => p.source.equals(l.source) & p.sourceId.equals(l.sourceId) & p.deleted.not())
                  ..limit(1))
                .getSingleOrNull();
        final agentId = await agentFor(l);
        final meta = <String, Object?>{
          if (existing != null) ...(jsonDecode(existing.meta) as Map).cast<String, Object?>(),
          if (l.description.isNotEmpty) 'description': l.description,
          if (l.heating.isNotEmpty) 'heating': l.heating,
          if (l.priceSuffix.isNotEmpty) 'priceSuffix': l.priceSuffix,
          // Every photo; imageUrl keeps the main one for lists and older versions.
          if (l.images.isNotEmpty) 'images': l.images,
        };
        final id = existing?.id ?? newId();
        final row = PropertiesCompanion(
          id: Value(id),
          address: Value(l.address),
          postcode: Value(
            l.postcode.isNotEmpty ? l.postcode : (postcodeIn(l.address) ?? existing?.postcode ?? ''),
          ),
          lat: Value(l.lat ?? existing?.lat),
          lon: Value(l.lon ?? existing?.lon),
          kind: Value(existing?.kind ?? (kind ?? (l.isRental ? PropertyKind.rent : PropertyKind.buy)).name),
          price: Value(l.price ?? existing?.price),
          beds: Value(l.beds ?? existing?.beds),
          baths: Value(l.baths ?? existing?.baths),
          style: Value(l.style.isNotEmpty ? l.style : existing?.style ?? ''),
          furnished: Value(l.furnished.isNotEmpty ? l.furnished : existing?.furnished ?? ''),
          availableFrom: Value(l.availableFrom ?? existing?.availableFrom),
          source: Value(l.source),
          sourceId: Value(l.sourceId),
          url: Value(l.url),
          imageUrl: Value(l.image ?? existing?.imageUrl),
          listingStatus: Value(l.status),
          agentId: Value(existing?.agentId ?? agentId),
          added: Value(existing?.added ?? today ?? DateTime.now().toIso8601String().substring(0, 10)),
          meta: Value(jsonEncode(meta)),
        );
        await save(db.properties, row, id);
        return (id: id, added: existing == null);
      });

  Future<void> setStage(String propertyId, Stage stage) async {
    final p = await (db.select(db.properties)..where((p) => p.id.equals(propertyId))).getSingle();
    await save(db.properties, p.copyWith(stage: stage.id), p.id);
  }

  /// Records a call, message or note.
  Future<String> log({
    String? propertyId,
    String? contactId,
    required String channel,
    String direction = 'out',
    String summary = '',
    String? followUp,
    required String at,
  }) async {
    final id = newId();
    await save(
      db.interactions,
      InteractionsCompanion.insert(
        id: id,
        propertyId: Value(propertyId),
        contactId: Value(contactId),
        at: at,
        channel: channel,
        direction: Value(direction),
        summary: Value(summary),
        followUp: Value(followUp),
      ),
      id,
    );
    // A first enquiry moves a new or shortlisted property along.
    if (propertyId != null && direction == 'out' && channel != 'note') {
      final p = await (db.select(db.properties)..where((p) => p.id.equals(propertyId))).getSingleOrNull();
      if (p != null && Stage.of(p.stage).index < Stage.enquired.index) {
        await save(db.properties, p.copyWith(stage: Stage.enquired.id), p.id);
      }
    }
    return id;
  }

  /// Books a viewing and moves the property to Viewing.
  Future<String> bookViewing(String propertyId, String at, {String notes = ''}) async {
    final id = newId();
    await save(
      db.viewings,
      ViewingsCompanion.insert(id: id, propertyId: propertyId, at: at, notes: Value(notes)),
      id,
    );
    final p = await (db.select(db.properties)..where((p) => p.id.equals(propertyId))).getSingle();
    if (Stage.of(p.stage).index < Stage.viewing.index) {
      await save(db.properties, p.copyWith(stage: Stage.viewing.id), p.id);
    }
    return id;
  }
}

/// Every photo of [p], the main one first: the list an advert brought in, or
/// the single photo older versions kept.
List<String> photosOf(Property p) {
  try {
    if (jsonDecode(p.meta) case {'images': final List l}) {
      final urls = [
        for (final i in l)
          if (i is String && i.isNotEmpty) i,
      ];
      if (urls.isNotEmpty) return urls;
    }
  } on FormatException {
    // A damaged meta falls back to the main photo.
  }
  return [?p.imageUrl];
}
