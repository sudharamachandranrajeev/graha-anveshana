import 'package:brahma_core/brahma_core.dart';
import 'package:drift/drift.dart';

// Table names are unique across the Brahma suite: every app on an account
// reads the same change log and applies only its own tables.

/// A property being looked at, bought or owned. Rents and prices are whole
/// pounds (a month's rent for lets).
@DataClassName('Property')
class Properties extends Table with SyncedRow {
  TextColumn get address => text()();
  TextColumn get postcode => text().withDefault(const Constant(''))();
  RealColumn get lat => real().nullable()();
  RealColumn get lon => real().nullable()();

  /// rent | buy | owned: what the user is doing with it.
  TextColumn get kind => text()();

  /// Where it is in the hunt (see domain/pipeline.dart).
  TextColumn get stage => text().withDefault(const Constant('new'))();
  IntColumn get price => integer().nullable()();
  IntColumn get beds => integer().nullable()();
  IntColumn get baths => integer().nullable()();
  TextColumn get style => text().withDefault(const Constant(''))();
  TextColumn get furnished => text().withDefault(const Constant(''))();
  TextColumn get availableFrom => text().nullable()();

  /// manual | propertypal; with the advert's id and link.
  TextColumn get source => text().withDefault(const Constant('manual'))();
  TextColumn get sourceId => text().nullable()();
  TextColumn get url => text().withDefault(const Constant(''))();
  TextColumn get imageUrl => text().nullable()();

  /// The advert's own status (toLet, letAgreed, forSale...).
  TextColumn get listingStatus => text().withDefault(const Constant(''))();
  TextColumn get agentId => text().nullable()();

  /// 0 (unrated) to 5.
  IntColumn get rating => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get added => text()();

  /// JSON extras: description, heating, purchase price and date when owned.
  TextColumn get meta => text().withDefault(const Constant('{}'))();
}

/// Agents, landlords, tenants, solicitors, brokers, trades.
@DataClassName('Contact')
class Contacts extends Table with SyncedRow {
  TextColumn get name => text()();
  TextColumn get role => text().withDefault(const Constant('agent'))();
  TextColumn get organisation => text().withDefault(const Constant(''))();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get email => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

/// The contact log: calls, messages, e-mails, notes.
@DataClassName('Interaction')
class Interactions extends Table with SyncedRow {
  TextColumn get propertyId => text().nullable()();
  TextColumn get contactId => text().nullable()();

  /// Local date and time, yyyy-MM-ddTHH:mm.
  TextColumn get at => text()();

  /// call | sms | whatsapp | email | visit | note
  TextColumn get channel => text()();

  /// out | in
  TextColumn get direction => text().withDefault(const Constant('out'))();
  TextColumn get summary => text().withDefault(const Constant(''))();

  /// Date to chase it up, yyyy-MM-dd.
  TextColumn get followUp => text().nullable()();
}

@DataClassName('Viewing')
class Viewings extends Table with SyncedRow {
  TextColumn get propertyId => text()();

  /// Local date and time, yyyy-MM-ddTHH:mm.
  TextColumn get at => text()();

  /// booked | done | cancelled
  TextColumn get status => text().withDefault(const Constant('booked'))();
  IntColumn get rating => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

/// Saved searches. Brahma Watch runs them in the cloud and pushes alerts.
@DataClassName('Search')
class Searches extends Table with SyncedRow {
  TextColumn get name => text()();

  /// propertypal: Watch reads a PropertyPal search. email: Watch reads the
  /// portal alert emails forwarded to it (England).
  TextColumn get source => text().withDefault(const Constant('propertypal'))();

  /// PropertyPal search path, e.g. /property-to-rent/enniskillen. Empty for email.
  TextColumn get path => text()();

  /// Email searches: rent | buy.
  TextColumn get kind => text().withDefault(const Constant(''))();

  /// Email searches: words the advert must mention, comma separated; a word
  /// starting with "-" must not appear.
  TextColumn get keywords => text().withDefault(const Constant(''))();
  IntColumn get maxPrice => integer().nullable()();
  IntColumn get minBeds => integer().nullable()();
  IntColumn get maxBeds => integer().nullable()();
  RealColumn get centreLat => real().nullable()();
  RealColumn get centreLon => real().nullable()();
  TextColumn get centreLabel => text().withDefault(const Constant(''))();
  RealColumn get radiusKm => real().nullable()();
  BoolColumn get includeUnpriced => boolean().withDefault(const Constant(true))();
  BoolColumn get paused => boolean().withDefault(const Constant(false))();
}

/// Saved what-ifs: buy-to-let, buying a home, a development.
@DataClassName('Appraisal')
class Appraisals extends Table with SyncedRow {
  TextColumn get name => text()();

  /// btl | home | dev
  TextColumn get kind => text()();
  TextColumn get propertyId => text().nullable()();

  /// The inputs as JSON (see domain/appraisal.dart).
  TextColumn get inputs => text().withDefault(const Constant('{}'))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get updated => text()();
}

/// A let: the user as landlord of an owned property, or as tenant.
@DataClassName('Tenancy')
class Tenancies extends Table with SyncedRow {
  TextColumn get propertyId => text()();

  /// landlord | tenant
  TextColumn get role => text()();

  /// The tenant (or the landlord, when the user rents).
  TextColumn get otherParty => text().withDefault(const Constant(''))();
  TextColumn get contactId => text().nullable()();
  TextColumn get start => text()();
  TextColumn get end => text().nullable()();

  /// A month's rent and the day of the month it is due.
  IntColumn get rent => integer()();
  IntColumn get rentDay => integer().withDefault(const Constant(1))();
  IntColumn get deposit => integer().withDefault(const Constant(0))();
  TextColumn get depositScheme => text().withDefault(const Constant(''))();
  TextColumn get depositRef => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

/// Rent received (or paid) on a tenancy.
@DataClassName('RentPayment')
class RentPayments extends Table with SyncedRow {
  TextColumn get tenancyId => text()();
  TextColumn get date => text()();
  IntColumn get amount => integer()();
  TextColumn get note => text().withDefault(const Constant(''))();
}

/// Landlord checks with due dates: gas safety, electrical, EPC, deposit...
@DataClassName('ComplianceItem')
class ComplianceItems extends Table with SyncedRow {
  TextColumn get propertyId => text()();
  TextColumn get kind => text()();
  TextColumn get due => text()();
  TextColumn get done => text().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

/// Saved area research for a postcode.
@DataClassName('Area')
class Areas extends Table with SyncedRow {
  TextColumn get postcode => text()();
  TextColumn get label => text().withDefault(const Constant(''))();

  /// AreaReport as JSON (see domain/research.dart).
  TextColumn get report => text().withDefault(const Constant('{}'))();
  TextColumn get fetched => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

/// One piece of research work ("Enniskillen rental, Jan 2027"), with its own
/// catalog of captured homes, pages, photos and documents.
@DataClassName('ResearchJob')
class Researches extends Table with SyncedRow {
  @override
  String get tableName => 'property_researches';

  TextColumn get name => text()();

  /// rent, buy, invest or area.
  TextColumn get kind => text().withDefault(const Constant('rent'))();

  /// ResearchCriteria as JSON (see domain/catalog.dart): what fits.
  TextColumn get criteria => text().withDefault(const Constant('{}'))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  TextColumn get created => text()();
}

/// A captured item in a research's catalog: a page, photo, screenshot, PDF,
/// link or note, with the details read from it.
@DataClassName('CatalogItem')
class CatalogItems extends Table with SyncedRow {
  @override
  String get tableName => 'property_catalog_items';

  TextColumn get researchId => text()();

  /// The Hunt home it became or was linked to.
  TextColumn get propertyId => text().nullable()();

  /// page, photo, document, link or note.
  TextColumn get kind => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get url => text().withDefault(const Constant(''))();

  /// The site and its advert number, when known.
  TextColumn get source => text().withDefault(const Constant(''))();
  TextColumn get sourceId => text().nullable()();
  TextColumn get address => text().withDefault(const Constant(''))();
  TextColumn get postcode => text().withDefault(const Constant(''))();
  IntColumn get price => integer().nullable()();
  IntColumn get beds => integer().nullable()();
  IntColumn get baths => integer().nullable()();

  /// ItemFields extras as JSON: price period, council tax band, EPC, agent,
  /// phone, available date, status, other links and the price history.
  TextColumn get fields => text().withDefault(const Constant('{}'))();

  /// The text the details were read from (page text or OCR).
  TextColumn get body => text().withDefault(const Constant(''))();

  /// Difference hash of the main picture, for spotting the same home.
  TextColumn get imageHash => text().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get captured => text()();
}

/// Pictures of catalog items, kept on this device inside the encrypted
/// database. Not synced: only the details and the picture's hash travel.
@DataClassName('CatalogImage')
class CatalogImages extends Table {
  @override
  String get tableName => 'property_catalog_images';

  TextColumn get itemId => text()();
  BlobColumn get bytes => blob()();

  @override
  Set<Column<Object>> get primaryKey => {itemId};
}

// The tables sync needs; their columns come from brahma_core.

@DataClassName('Pref')
class Prefs extends Table with SyncedRow, PrefColumns {}

@DataClassName('OutboxItem')
class Outbox extends Table with OutboxColumns {}

@DataClassName('SyncCursor')
class SyncCursors extends Table with SyncCursorColumns {}

@DataClassName('LocalSetting')
class LocalSettings extends Table with LocalSettingColumns {}
