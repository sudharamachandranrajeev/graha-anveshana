import 'dart:convert';

import 'package:brahma_core/brahma_core.dart';
import 'package:drift/drift.dart';

import '../db/database.dart';
import 'book.dart';
import 'catalog.dart';
import 'listing.dart';
import 'pipeline.dart';

/// The duplicate-check view of a catalog item.
ItemKey keyOfItem(CatalogItem i) => ItemKey(
  id: i.id,
  url: i.url,
  source: i.source,
  sourceId: i.sourceId,
  address: i.address,
  postcode: i.postcode,
  price: i.price,
  beds: i.beds,
  imageHash: i.imageHash,
);

/// The duplicate-check view of a Hunt home.
ItemKey keyOfProperty(Property p) => ItemKey(
  id: p.id,
  url: p.url,
  source: p.source,
  sourceId: p.sourceId,
  address: p.address,
  postcode: p.postcode,
  price: p.price,
  beds: p.beds,
);

Map<String, Object?> fieldsOf(CatalogItem i) => (jsonDecode(i.fields) as Map).cast<String, Object?>();

/// Every link an item is known by: its own and the ones merged into it.
List<String> linksOf(CatalogItem i) =>
    {if (i.url.isNotEmpty) i.url, ...((fieldsOf(i)['links'] as List?) ?? const []).cast<String>()}.toList();

/// The details of an item as fields (columns and extras together).
ItemFields itemFields(CatalogItem i) => ItemFields.fromJson({
  ...fieldsOf(i),
  'address': i.address,
  'postcode': i.postcode,
  'price': i.price,
  'beds': i.beds,
  'baths': i.baths,
});

String _now() => DateTime.now().toIso8601String().substring(0, 19);

/// Researches and catalog writes. Like every write, they go through the
/// store so they sync.
extension CatalogWrites on PropertyBook {
  Future<String> createResearch(
    String name, {
    String kind = 'rent',
    ResearchCriteria? criteria,
    String notes = '',
  }) async {
    final id = newId();
    await save(
      db.researches,
      ResearchesCompanion.insert(
        id: id,
        name: name,
        kind: Value(kind),
        criteria: Value((criteria ?? const ResearchCriteria()).toJson()),
        notes: Value(notes),
        created: _now(),
      ),
      id,
    );
    return id;
  }

  Future<void> saveResearch(ResearchJob r) => save(db.researches, r, r.id);

  /// Adds an item to [researchId]'s catalog. [image] is kept on this device.
  Future<String> addItem(
    String researchId, {
    required String kind,
    String title = '',
    String url = '',
    String source = '',
    String? sourceId,
    ItemFields fields = const ItemFields(),
    String body = '',
    Uint8List? image,
    String? imageHash,
    String notes = '',
    String? captured,
  }) async {
    final id = newId();
    final at = captured ?? _now();
    await db.transaction(() async {
      await save(
        db.catalogItems,
        CatalogItemsCompanion.insert(
          id: id,
          researchId: researchId,
          kind: kind,
          title: Value(title),
          url: Value(url),
          source: Value(source),
          sourceId: Value(sourceId),
          address: Value(fields.address),
          postcode: Value(fields.postcode),
          price: Value(fields.price),
          beds: Value(fields.beds),
          baths: Value(fields.baths),
          fields: Value(
            jsonEncode({
              ...fields.extras,
              if (fields.price != null)
                'prices': [
                  {'at': at.substring(0, 10), 'price': fields.price},
                ],
            }),
          ),
          body: Value(body),
          imageHash: Value(imageHash),
          notes: Value(notes),
          captured: at,
        ),
        id,
      );
      if (image != null) await setImage(id, image);
    });
    return id;
  }

  /// Saves edited details: the columns and the extras.
  Future<void> saveItem(CatalogItem item, ItemFields f, {String? title, String? notes}) {
    final extras = {...fieldsOf(item)}
      ..removeWhere(
        (k, _) => const {
          'period',
          'councilTaxBand',
          'epc',
          'phone',
          'agent',
          'availableFrom',
          'status',
          'furnished',
        }.contains(k),
      )
      ..addAll(f.extras);
    return save(
      db.catalogItems,
      item.copyWith(
        title: title ?? item.title,
        notes: notes ?? item.notes,
        address: f.address,
        postcode: f.postcode,
        price: Value(f.price),
        beds: Value(f.beds),
        baths: Value(f.baths),
        fields: jsonEncode(extras),
      ),
      item.id,
    );
  }

  Future<void> setImage(String itemId, Uint8List bytes) => db
      .into(db.catalogImages)
      .insertOnConflictUpdate(CatalogImagesCompanion.insert(itemId: itemId, bytes: bytes));

  Future<Uint8List?> image(String itemId) async =>
      (await (db.select(db.catalogImages)..where((i) => i.itemId.equals(itemId))).getSingleOrNull())?.bytes;

  Future<void> removeItem(String id) => db.transaction(() async {
    await (db.delete(db.catalogImages)..where((i) => i.itemId.equals(id))).go();
    await remove(db.catalogItems, id);
  });

  /// Removes a research with everything in its catalog. Hunt homes made
  /// from it stay.
  Future<void> removeResearch(String id) => db.transaction(() async {
    for (final i in await _items(id)) {
      await removeItem(i.id);
    }
    await remove(db.researches, id);
  });

  Future<List<CatalogItem>> _items(String researchId) =>
      (db.select(db.catalogItems)
            ..where((i) => i.researchId.equals(researchId) & i.deleted.not())
            ..orderBy([(i) => OrderingTerm(expression: i.captured)]))
          .get();

  /// Merges [dropId] into [keepId]: every link, note and price seen is kept,
  /// the earliest capture date wins and details [keepId] lacks are filled
  /// in. [dropId] is then removed. The two may be in different researches;
  /// the merged item stays in [keepId]'s.
  Future<void> mergeItems(String keepId, String dropId) => db.transaction(() async {
    final keep = await (db.select(db.catalogItems)..where((i) => i.id.equals(keepId))).getSingle();
    final drop = await (db.select(db.catalogItems)..where((i) => i.id.equals(dropId))).getSingle();
    final kf = fieldsOf(keep), df = fieldsOf(drop);
    final prices = [
      ...((kf['prices'] as List?) ?? const []),
      ...((df['prices'] as List?) ?? const []),
    ].cast<Map>().toList()..sort((a, b) => '${a['at']}'.compareTo('${b['at']}'));
    final seen = <String>{};
    final history = [
      for (final p in prices)
        if (seen.add('${p['at']}|${p['price']}')) p,
    ];
    final links = {...linksOf(keep), ...linksOf(drop)}..remove(keep.url);
    final merged = itemFields(keep).over(itemFields(drop));
    final extras = {...df, ...kf, ...merged.extras, 'links': links.toList(), 'prices': history}
      ..removeWhere((_, v) => v is List && v.isEmpty);
    final notes = [keep.notes, drop.notes].where((n) => n.trim().isNotEmpty).toSet().join('\n\n');
    await save(
      db.catalogItems,
      keep.copyWith(
        propertyId: Value(keep.propertyId ?? drop.propertyId),
        title: keep.title.isNotEmpty ? keep.title : drop.title,
        source: keep.source.isNotEmpty ? keep.source : drop.source,
        sourceId: Value(keep.sourceId ?? drop.sourceId),
        address: merged.address,
        postcode: merged.postcode,
        price: Value(merged.price),
        beds: Value(merged.beds),
        baths: Value(merged.baths),
        fields: jsonEncode(extras),
        body: [keep.body, drop.body].where((b) => b.isNotEmpty).join('\n\n'),
        imageHash: Value(keep.imageHash ?? drop.imageHash),
        notes: notes,
        captured: keep.captured.compareTo(drop.captured) <= 0 ? keep.captured : drop.captured,
      ),
      keep.id,
    );
    if (await image(keep.id) == null) {
      final pic = await image(drop.id);
      if (pic != null) await setImage(keep.id, pic);
    }
    await removeItem(drop.id);
  });

  /// Moves every item of research [fromId] into [intoId], joins the notes and
  /// removes [fromId]. Duplicates are left for the user to merge.
  Future<void> mergeResearches(String intoId, String fromId) => db.transaction(() async {
    final into = await (db.select(db.researches)..where((r) => r.id.equals(intoId))).getSingle();
    final from = await (db.select(db.researches)..where((r) => r.id.equals(fromId))).getSingle();
    for (final i in await _items(fromId)) {
      await save(db.catalogItems, i.copyWith(researchId: intoId), i.id);
    }
    final notes = [into.notes, from.notes].where((n) => n.trim().isNotEmpty).join('\n\n');
    await save(db.researches, into.copyWith(notes: notes), into.id);
    await remove(db.researches, fromId);
  });

  /// Adds the item to Hunt (or refreshes the home it matches) and links them.
  Future<String> itemToHunt(CatalogItem item, {required bool rental}) async {
    final f = itemFields(item);
    final listing = Listing(
      source: item.source.isNotEmpty ? item.source : 'catalog',
      sourceId: item.sourceId ?? item.id,
      url: item.url,
      address: f.address.isNotEmpty ? f.address : (item.title.isNotEmpty ? item.title : 'Home from research'),
      postcode: f.postcode,
      price: f.monthly ?? f.price,
      priceSuffix: rental ? 'per month' : '',
      beds: f.beds,
      baths: f.baths,
      furnished: f.furnished,
      availableFrom: f.availableFrom.isEmpty ? null : f.availableFrom,
      agent: f.agent,
      agentPhone: f.phone,
      status: f.status,
      description: item.notes,
    );
    final r = await importListing(listing, kind: rental ? PropertyKind.rent : PropertyKind.buy);
    await save(db.catalogItems, item.copyWith(propertyId: Value(r.id)), item.id);
    return r.id;
  }
}
