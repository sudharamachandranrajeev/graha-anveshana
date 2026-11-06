import 'dart:io';

import 'package:anveshana/db/database.dart';
import 'package:anveshana/domain/book.dart';
import 'package:anveshana/domain/catalog.dart';
import 'package:anveshana/domain/catalog_book.dart';
import 'package:brahma_core/brahma_core.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

// Made-up adverts; no real addresses or numbers.
const _advert = '''
Apt 2, 14 Sample Street, Exampletown BT74 1AA
£650 pcm
2 bedroom apartment to let, unfurnished
1 bathroom
Council Tax Band: C
EPC rating D (61)
Available from 1st January 2027
Call 028 9000 0000
''';

void main() {
  group('reading fields', () {
    test('an advert gives its details', () {
      final f = readFields(_advert);
      expect(f.postcode, 'BT74 1AA');
      expect(f.address, 'Apt 2, 14 Sample Street, Exampletown BT74 1AA');
      expect((f.price, f.period, f.beds, f.baths), (650, 'pcm', 2, 1));
      expect((f.councilTaxBand, f.epc, f.furnished), ('C', 'D', 'unfurnished'));
      expect(f.availableFrom, '1st January 2027');
      expect(f.phone, '02890000000');
      expect(f.status, 'toLet');
    });

    test('weekly rents, sale prices, studios and gone adverts', () {
      final w = readFields('Studio flat £200 pw, let agreed');
      expect((w.price, w.period, w.monthly, w.beds, w.status), (200, 'pw', 867, 0, 'letAgreed'));
      final s = readFields('Three bed semi for sale. Offers over £185,000. Sold STC');
      expect((s.price, s.period, s.beds, s.status), (185000, '', 3, 'saleAgreed'));
      expect(readFields('Guide price £250k').price, 250000);
    });

    test('small sums are not prices; nothing found is empty', () {
      expect(readFields('Save £5 on your first month').price, isNull);
      expect(readFields('A photo of a garden').isEmpty, isTrue);
    });

    test('details from one source fill the gaps of another', () {
      final f = const ItemFields(price: 700).over(const ItemFields(price: 650, beds: 2, epc: 'C'));
      expect((f.price, f.beds, f.epc), (700, 2, 'C'));
    });
  });

  group('duplicates', () {
    test('the same advert, address, photo or near-same details', () {
      const a = ItemKey(
        id: 'a',
        source: 'rightmove',
        sourceId: '1',
        url: 'https://www.rightmove.co.uk/properties/1',
      );
      expect(sameHome(a, const ItemKey(id: 'b', source: 'rightmove', sourceId: '1')), MatchReason.sameAdvert);
      expect(
        sameHome(a, const ItemKey(id: 'b', url: 'https://rightmove.co.uk/properties/1/')),
        MatchReason.sameAdvert,
      );
      expect(
        sameHome(
          const ItemKey(id: 'a', address: 'Apartment 2, 14 Sample Street', postcode: 'BT74 1AA'),
          const ItemKey(id: 'b', address: 'apt 2 14 sample st', postcode: 'bt741aa'),
        ),
        MatchReason.sameAddress,
      );
      expect(
        sameHome(
          const ItemKey(id: 'a', imageHash: 'ffff0000ffff0000'),
          const ItemKey(id: 'b', imageHash: 'ffff0000ffff0003'),
        ),
        MatchReason.samePicture,
      );
      expect(
        sameHome(
          const ItemKey(id: 'a', postcode: 'BT74 1AA', beds: 2, price: 650),
          const ItemKey(id: 'b', postcode: 'BT74 1AA', beds: 2, price: 675),
        ),
        MatchReason.similar,
      );
    });

    test('different homes are not matched', () {
      expect(
        sameHome(
          const ItemKey(id: 'a', postcode: 'BT74 1AA', beds: 2, price: 650),
          const ItemKey(id: 'b', postcode: 'BT74 1AA', beds: 3, price: 650),
        ),
        isNull,
      );
      // A street name alone (no number) is not an address match.
      expect(
        sameHome(
          const ItemKey(id: 'a', address: 'Sample Street'),
          const ItemKey(id: 'b', address: 'Sample St'),
        ),
        isNull,
      );
      expect(hashDistance('ff', 'ffff'), isNull);
    });

    test('pairs come strongest first and keep the earlier capture', () {
      final pairs = findDuplicates(const [
        ItemKey(id: '1', postcode: 'BT74 1AA', beds: 2, price: 650),
        ItemKey(id: '2', postcode: 'BT74 1AA', beds: 2, price: 660),
        ItemKey(id: '3', url: 'https://example.com/x'),
        ItemKey(id: '4', url: 'https://example.com/x'),
      ]);
      expect(
        [for (final p in pairs) (p.keep.id, p.drop.id, p.reason)],
        [('3', '4', MatchReason.sameAdvert), ('1', '2', MatchReason.similar)],
      );
    });
  });

  test('fit counts only what is known', () {
    const c = ResearchCriteria(maxPrice: 700, minBeds: 2, radiusKm: 2, words: 'parking -damp');
    final good = fit(c, monthlyOrPrice: 650, beds: 2, km: 1.2, text: 'Off-street parking');
    expect(good.score, 1);
    final poor = fit(c, monthlyOrPrice: 750, beds: 1, text: 'some damp, no parking');
    expect(poor.misses, ['over £700', 'fewer than 2 bedrooms', 'mentions "damp"']);
    expect(fit(const ResearchCriteria(), monthlyOrPrice: 9999).score, 1);
    expect(ResearchCriteria.fromJson(c.toJson()).words, 'parking -damp');
  });

  group('catalog book', () {
    late AppDatabase db;
    late PropertyBook book;
    setUp(() async {
      db = memoryDatabase();
      book = PropertyBook(await Store.open(db));
    });
    tearDown(() => db.close());

    Future<List<CatalogItem>> items() => (db.select(db.catalogItems)..where((i) => i.deleted.not())).get();

    test('merging two items keeps every link, note, price and the first date', () async {
      final r = await book.createResearch('Rental');
      final a = await book.addItem(
        r,
        kind: 'link',
        url: 'https://example.com/a',
        fields: const ItemFields(postcode: 'BT74 1AA', price: 650, beds: 2),
        notes: 'Nice kitchen',
        captured: '2026-11-01T10:00:00',
      );
      final b = await book.addItem(
        r,
        kind: 'photo',
        url: 'https://example.org/b',
        fields: const ItemFields(postcode: 'BT74 1AA', price: 625, beds: 2, councilTaxBand: 'B'),
        notes: 'Damp in bathroom',
        image: Uint8List.fromList([1, 2, 3]),
        captured: '2026-10-20T09:00:00',
      );
      await book.mergeItems(a, b);
      final m = (await items()).single;
      expect(m.id, a);
      expect(m.captured, '2026-10-20T09:00:00');
      expect(linksOf(m), ['https://example.com/a', 'https://example.org/b']);
      expect(m.notes, 'Nice kitchen\n\nDamp in bathroom');
      expect(m.price, 650);
      expect(itemFields(m).councilTaxBand, 'B');
      expect([for (final p in fieldsOf(m)['prices'] as List) (p as Map)['price']], [625, 650]);
      expect(await book.image(a), [1, 2, 3]);
      expect(await book.image(b), isNull);
    });

    test('merging researches moves the catalog; removing one keeps Hunt homes', () async {
      final r1 = await book.createResearch('Rental A', notes: 'first');
      final r2 = await book.createResearch('Rental B', notes: 'second');
      await book.addItem(
        r1,
        kind: 'note',
        fields: const ItemFields(address: '1 Sample Road'),
      );
      final moved = await book.addItem(
        r2,
        kind: 'note',
        fields: const ItemFields(address: '2 Sample Road'),
      );
      await book.mergeResearches(r1, r2);
      expect((await items()).map((i) => i.researchId).toSet(), {r1});
      final researches = await (db.select(db.researches)..where((r) => r.deleted.not())).get();
      expect(researches.single.notes, 'first\n\nsecond');

      final item = (await items()).firstWhere((i) => i.id == moved);
      final home = await book.itemToHunt(item, rental: true);
      await book.removeResearch(r1);
      expect(await items(), isEmpty);
      final p = await (db.select(db.properties)..where((p) => p.id.equals(home))).getSingle();
      expect((p.address, p.deleted), ('2 Sample Road', false));
    });
  });

  test('a version 4 database gains researches and catalogs', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final dir = await Directory.systemTemp.createTemp('anveshana-migrate5');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/a.db');
    final old = AppDatabase(NativeDatabase(file));
    await old
        .into(old.properties)
        .insert(
          PropertiesCompanion.insert(id: 'p', address: '1 Sample Road', kind: 'rent', added: '2026-11-01'),
        );
    for (final t in ['property_researches', 'property_catalog_items', 'property_catalog_images']) {
      await old.customStatement('DROP TABLE $t');
    }
    await old.customStatement('PRAGMA user_version = 4');
    await old.close();

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);
    expect((await db.select(db.properties).getSingle()).address, '1 Sample Road');
    final book = PropertyBook(await Store.open(db));
    final r = await book.createResearch('After upgrade');
    await book.addItem(r, kind: 'note');
    expect(await db.select(db.catalogItems).get(), hasLength(1));
  });
}
