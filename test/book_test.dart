import 'package:anveshana/db/database.dart';
import 'package:anveshana/domain/book.dart';
import 'package:anveshana/domain/contact_links.dart';
import 'package:anveshana/domain/listing.dart';
import 'package:anveshana/domain/pipeline.dart';
import 'package:brahma_core/brahma_core.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  late AppDatabase db;
  late PropertyBook book;

  setUp(() async {
    db = memoryDatabase();
    book = PropertyBook(await Store.open(db));
  });
  tearDown(() => db.close());

  Listing advert({int? price = 650, String status = 'toLet'}) =>
      parsePropertyPalPage(nextData({'property': samplePropertyPal(price: price, status: status)})).single;

  Future<Property> only() async => (await db.select(db.properties).get()).single;

  test('importing twice refreshes the advert and keeps the user\'s own fields', () async {
    final first = await book.importListing(advert(), today: '2026-10-21');
    expect(first.added, isTrue);
    var p = await only();
    expect(p.kind, PropertyKind.rent.name);
    expect(p.stage, Stage.fresh.id);
    expect(p.added, '2026-10-21');

    await book.setStage(p.id, Stage.shortlisted);
    await book.save(
      db.properties,
      p.copyWith(rating: 4, notes: 'Near work', stage: Stage.shortlisted.id),
      p.id,
    );

    final again = await book.importListing(advert(price: 625, status: 'letAgreed'), today: '2026-10-25');
    expect(again, (id: first.id, added: false));
    p = await only();
    expect(p.price, 625);
    expect(p.listingStatus, 'letAgreed');
    expect(p.rating, 4);
    expect(p.notes, 'Near work');
    expect(p.stage, Stage.shortlisted.id);
    expect(p.added, '2026-10-21');
  });

  test('every photo is kept; the main one stays the list photo', () async {
    await book.importListing(advert());
    final p = await only();
    expect(p.imageUrl, 'https://example.com/101.jpg');
    expect(photosOf(p), ['https://example.com/101.jpg', 'https://example.com/101-kitchen.jpg']);
    // A home saved by an older version has only its main photo.
    expect(photosOf(p.copyWith(meta: '{}')), ['https://example.com/101.jpg']);
    expect(photosOf(p.copyWith(meta: 'not json', imageUrl: const Value(null))), isEmpty);
  });

  test('the agent becomes one contact, shared by its adverts', () async {
    await book.importListing(advert());
    await book.importListing(parsePropertyPalPage(nextData({'property': samplePropertyPal(id: 102)})).single);
    final contacts = await db.select(db.contacts).get();
    expect(contacts.single.name, 'Example Lettings');
    expect(contacts.single.phone, '+44 28 9649 6000');
    final props = await db.select(db.properties).get();
    expect(props.map((p) => p.agentId).toSet(), {contacts.single.id});
  });

  test('contacting moves a property to Enquired, a viewing to Viewing; a note does neither', () async {
    final id = (await book.importListing(advert())).id;
    await book.log(propertyId: id, channel: 'note', summary: 'Looks nice', at: '2026-10-21T09:00');
    expect((await only()).stage, Stage.fresh.id);
    await book.log(propertyId: id, channel: 'email', at: '2026-10-21T09:05');
    expect((await only()).stage, Stage.enquired.id);
    await book.bookViewing(id, '2026-10-24T11:00');
    expect((await only()).stage, Stage.viewing.id);
    // A later call does not move it back.
    await book.log(propertyId: id, channel: 'call', at: '2026-10-25T10:00');
    expect((await only()).stage, Stage.viewing.id);
  });

  test('removing a property removes its viewings and log', () async {
    final id = (await book.importListing(advert())).id;
    await book.log(propertyId: id, channel: 'call', at: '2026-10-21T09:00');
    await book.bookViewing(id, '2026-10-24T11:00');
    await book.removeProperty(id);
    expect((await only()).deleted, isTrue);
    expect((await db.select(db.viewings).get()).every((v) => v.deleted), isTrue);
    expect((await db.select(db.interactions).get()).every((i) => i.deleted), isTrue);
  });

  test('prefs: applicant and home point', () async {
    expect(await book.home(), isNull);
    await book.setHome((lat: 54.3, lon: -7.6, label: 'Work'));
    expect(await book.home(), (lat: 54.3, lon: -7.6, label: 'Work'));
    await book.setPref(PrefKeys.applicant, const Applicant(name: 'A Tenant', moveIn: 'in March').toJson());
    expect((await book.applicant()).moveIn, 'in March');
    final pref = await (db.select(db.prefs)..where((p) => p.id.equals(PrefKeys.home))).getSingle();
    expect(pref.id, startsWith('anveshana.'));
  });
}
