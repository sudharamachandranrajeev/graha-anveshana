// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PropertiesTable extends Properties with TableInfo<$PropertiesTable, Property> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PropertiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _addressMeta = const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _postcodeMeta = const VerificationMeta('postcode');
  @override
  late final GeneratedColumn<String> postcode = GeneratedColumn<String>(
    'postcode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
    'lon',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stageMeta = const VerificationMeta('stage');
  @override
  late final GeneratedColumn<String> stage = GeneratedColumn<String>(
    'stage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('new'),
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<int> price = GeneratedColumn<int>(
    'price',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bedsMeta = const VerificationMeta('beds');
  @override
  late final GeneratedColumn<int> beds = GeneratedColumn<int>(
    'beds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bathsMeta = const VerificationMeta('baths');
  @override
  late final GeneratedColumn<int> baths = GeneratedColumn<int>(
    'baths',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _styleMeta = const VerificationMeta('style');
  @override
  late final GeneratedColumn<String> style = GeneratedColumn<String>(
    'style',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _furnishedMeta = const VerificationMeta('furnished');
  @override
  late final GeneratedColumn<String> furnished = GeneratedColumn<String>(
    'furnished',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _availableFromMeta = const VerificationMeta('availableFrom');
  @override
  late final GeneratedColumn<String> availableFrom = GeneratedColumn<String>(
    'available_from',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _listingStatusMeta = const VerificationMeta('listingStatus');
  @override
  late final GeneratedColumn<String> listingStatus = GeneratedColumn<String>(
    'listing_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _agentIdMeta = const VerificationMeta('agentId');
  @override
  late final GeneratedColumn<String> agentId = GeneratedColumn<String>(
    'agent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _addedMeta = const VerificationMeta('added');
  @override
  late final GeneratedColumn<String> added = GeneratedColumn<String>(
    'added',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metaMeta = const VerificationMeta('meta');
  @override
  late final GeneratedColumn<String> meta = GeneratedColumn<String>(
    'meta',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    hlc,
    deleted,
    address,
    postcode,
    lat,
    lon,
    kind,
    stage,
    price,
    beds,
    baths,
    style,
    furnished,
    availableFrom,
    source,
    sourceId,
    url,
    imageUrl,
    listingStatus,
    agentId,
    rating,
    notes,
    added,
    meta,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'properties';
  @override
  VerificationContext validateIntegrity(Insertable<Property> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(_hlcMeta, hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta));
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta, deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta, address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('postcode')) {
      context.handle(_postcodeMeta, postcode.isAcceptableOrUnknown(data['postcode']!, _postcodeMeta));
    }
    if (data.containsKey('lat')) {
      context.handle(_latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    }
    if (data.containsKey('lon')) {
      context.handle(_lonMeta, lon.isAcceptableOrUnknown(data['lon']!, _lonMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(_kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('stage')) {
      context.handle(_stageMeta, stage.isAcceptableOrUnknown(data['stage']!, _stageMeta));
    }
    if (data.containsKey('price')) {
      context.handle(_priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    }
    if (data.containsKey('beds')) {
      context.handle(_bedsMeta, beds.isAcceptableOrUnknown(data['beds']!, _bedsMeta));
    }
    if (data.containsKey('baths')) {
      context.handle(_bathsMeta, baths.isAcceptableOrUnknown(data['baths']!, _bathsMeta));
    }
    if (data.containsKey('style')) {
      context.handle(_styleMeta, style.isAcceptableOrUnknown(data['style']!, _styleMeta));
    }
    if (data.containsKey('furnished')) {
      context.handle(_furnishedMeta, furnished.isAcceptableOrUnknown(data['furnished']!, _furnishedMeta));
    }
    if (data.containsKey('available_from')) {
      context.handle(
        _availableFromMeta,
        availableFrom.isAcceptableOrUnknown(data['available_from']!, _availableFromMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta, source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta, sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    }
    if (data.containsKey('url')) {
      context.handle(_urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta, imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('listing_status')) {
      context.handle(
        _listingStatusMeta,
        listingStatus.isAcceptableOrUnknown(data['listing_status']!, _listingStatusMeta),
      );
    }
    if (data.containsKey('agent_id')) {
      context.handle(_agentIdMeta, agentId.isAcceptableOrUnknown(data['agent_id']!, _agentIdMeta));
    }
    if (data.containsKey('rating')) {
      context.handle(_ratingMeta, rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('added')) {
      context.handle(_addedMeta, added.isAcceptableOrUnknown(data['added']!, _addedMeta));
    } else if (isInserting) {
      context.missing(_addedMeta);
    }
    if (data.containsKey('meta')) {
      context.handle(_metaMeta, meta.isAcceptableOrUnknown(data['meta']!, _metaMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Property map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Property(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      hlc: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}hlc'])!,
      deleted: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      address: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      postcode: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}postcode'])!,
      lat: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}lat']),
      lon: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}lon']),
      kind: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      stage: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}stage'])!,
      price: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}price']),
      beds: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}beds']),
      baths: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}baths']),
      style: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}style'])!,
      furnished: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}furnished'])!,
      availableFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}available_from'],
      ),
      source: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      sourceId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}source_id']),
      url: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      imageUrl: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}image_url']),
      listingStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}listing_status'],
      )!,
      agentId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}agent_id']),
      rating: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}rating'])!,
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      added: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}added'])!,
      meta: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}meta'])!,
    );
  }

  @override
  $PropertiesTable createAlias(String alias) {
    return $PropertiesTable(attachedDatabase, alias);
  }
}

class Property extends DataClass implements Insertable<Property> {
  final String id;
  final String hlc;
  final bool deleted;
  final String address;
  final String postcode;
  final double? lat;
  final double? lon;

  /// rent | buy | owned: what the user is doing with it.
  final String kind;

  /// Where it is in the hunt (see domain/pipeline.dart).
  final String stage;
  final int? price;
  final int? beds;
  final int? baths;
  final String style;
  final String furnished;
  final String? availableFrom;

  /// manual | propertypal; with the advert's id and link.
  final String source;
  final String? sourceId;
  final String url;
  final String? imageUrl;

  /// The advert's own status (toLet, letAgreed, forSale...).
  final String listingStatus;
  final String? agentId;

  /// 0 (unrated) to 5.
  final int rating;
  final String notes;
  final String added;

  /// JSON extras: description, heating, purchase price and date when owned.
  final String meta;
  const Property({
    required this.id,
    required this.hlc,
    required this.deleted,
    required this.address,
    required this.postcode,
    this.lat,
    this.lon,
    required this.kind,
    required this.stage,
    this.price,
    this.beds,
    this.baths,
    required this.style,
    required this.furnished,
    this.availableFrom,
    required this.source,
    this.sourceId,
    required this.url,
    this.imageUrl,
    required this.listingStatus,
    this.agentId,
    required this.rating,
    required this.notes,
    required this.added,
    required this.meta,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['hlc'] = Variable<String>(hlc);
    map['deleted'] = Variable<bool>(deleted);
    map['address'] = Variable<String>(address);
    map['postcode'] = Variable<String>(postcode);
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lon != null) {
      map['lon'] = Variable<double>(lon);
    }
    map['kind'] = Variable<String>(kind);
    map['stage'] = Variable<String>(stage);
    if (!nullToAbsent || price != null) {
      map['price'] = Variable<int>(price);
    }
    if (!nullToAbsent || beds != null) {
      map['beds'] = Variable<int>(beds);
    }
    if (!nullToAbsent || baths != null) {
      map['baths'] = Variable<int>(baths);
    }
    map['style'] = Variable<String>(style);
    map['furnished'] = Variable<String>(furnished);
    if (!nullToAbsent || availableFrom != null) {
      map['available_from'] = Variable<String>(availableFrom);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['listing_status'] = Variable<String>(listingStatus);
    if (!nullToAbsent || agentId != null) {
      map['agent_id'] = Variable<String>(agentId);
    }
    map['rating'] = Variable<int>(rating);
    map['notes'] = Variable<String>(notes);
    map['added'] = Variable<String>(added);
    map['meta'] = Variable<String>(meta);
    return map;
  }

  PropertiesCompanion toCompanion(bool nullToAbsent) {
    return PropertiesCompanion(
      id: Value(id),
      hlc: Value(hlc),
      deleted: Value(deleted),
      address: Value(address),
      postcode: Value(postcode),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lon: lon == null && nullToAbsent ? const Value.absent() : Value(lon),
      kind: Value(kind),
      stage: Value(stage),
      price: price == null && nullToAbsent ? const Value.absent() : Value(price),
      beds: beds == null && nullToAbsent ? const Value.absent() : Value(beds),
      baths: baths == null && nullToAbsent ? const Value.absent() : Value(baths),
      style: Value(style),
      furnished: Value(furnished),
      availableFrom: availableFrom == null && nullToAbsent ? const Value.absent() : Value(availableFrom),
      source: Value(source),
      sourceId: sourceId == null && nullToAbsent ? const Value.absent() : Value(sourceId),
      url: Value(url),
      imageUrl: imageUrl == null && nullToAbsent ? const Value.absent() : Value(imageUrl),
      listingStatus: Value(listingStatus),
      agentId: agentId == null && nullToAbsent ? const Value.absent() : Value(agentId),
      rating: Value(rating),
      notes: Value(notes),
      added: Value(added),
      meta: Value(meta),
    );
  }

  factory Property.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Property(
      id: serializer.fromJson<String>(json['id']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      address: serializer.fromJson<String>(json['address']),
      postcode: serializer.fromJson<String>(json['postcode']),
      lat: serializer.fromJson<double?>(json['lat']),
      lon: serializer.fromJson<double?>(json['lon']),
      kind: serializer.fromJson<String>(json['kind']),
      stage: serializer.fromJson<String>(json['stage']),
      price: serializer.fromJson<int?>(json['price']),
      beds: serializer.fromJson<int?>(json['beds']),
      baths: serializer.fromJson<int?>(json['baths']),
      style: serializer.fromJson<String>(json['style']),
      furnished: serializer.fromJson<String>(json['furnished']),
      availableFrom: serializer.fromJson<String?>(json['availableFrom']),
      source: serializer.fromJson<String>(json['source']),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
      url: serializer.fromJson<String>(json['url']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      listingStatus: serializer.fromJson<String>(json['listingStatus']),
      agentId: serializer.fromJson<String?>(json['agentId']),
      rating: serializer.fromJson<int>(json['rating']),
      notes: serializer.fromJson<String>(json['notes']),
      added: serializer.fromJson<String>(json['added']),
      meta: serializer.fromJson<String>(json['meta']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hlc': serializer.toJson<String>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'address': serializer.toJson<String>(address),
      'postcode': serializer.toJson<String>(postcode),
      'lat': serializer.toJson<double?>(lat),
      'lon': serializer.toJson<double?>(lon),
      'kind': serializer.toJson<String>(kind),
      'stage': serializer.toJson<String>(stage),
      'price': serializer.toJson<int?>(price),
      'beds': serializer.toJson<int?>(beds),
      'baths': serializer.toJson<int?>(baths),
      'style': serializer.toJson<String>(style),
      'furnished': serializer.toJson<String>(furnished),
      'availableFrom': serializer.toJson<String?>(availableFrom),
      'source': serializer.toJson<String>(source),
      'sourceId': serializer.toJson<String?>(sourceId),
      'url': serializer.toJson<String>(url),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'listingStatus': serializer.toJson<String>(listingStatus),
      'agentId': serializer.toJson<String?>(agentId),
      'rating': serializer.toJson<int>(rating),
      'notes': serializer.toJson<String>(notes),
      'added': serializer.toJson<String>(added),
      'meta': serializer.toJson<String>(meta),
    };
  }

  Property copyWith({
    String? id,
    String? hlc,
    bool? deleted,
    String? address,
    String? postcode,
    Value<double?> lat = const Value.absent(),
    Value<double?> lon = const Value.absent(),
    String? kind,
    String? stage,
    Value<int?> price = const Value.absent(),
    Value<int?> beds = const Value.absent(),
    Value<int?> baths = const Value.absent(),
    String? style,
    String? furnished,
    Value<String?> availableFrom = const Value.absent(),
    String? source,
    Value<String?> sourceId = const Value.absent(),
    String? url,
    Value<String?> imageUrl = const Value.absent(),
    String? listingStatus,
    Value<String?> agentId = const Value.absent(),
    int? rating,
    String? notes,
    String? added,
    String? meta,
  }) => Property(
    id: id ?? this.id,
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    address: address ?? this.address,
    postcode: postcode ?? this.postcode,
    lat: lat.present ? lat.value : this.lat,
    lon: lon.present ? lon.value : this.lon,
    kind: kind ?? this.kind,
    stage: stage ?? this.stage,
    price: price.present ? price.value : this.price,
    beds: beds.present ? beds.value : this.beds,
    baths: baths.present ? baths.value : this.baths,
    style: style ?? this.style,
    furnished: furnished ?? this.furnished,
    availableFrom: availableFrom.present ? availableFrom.value : this.availableFrom,
    source: source ?? this.source,
    sourceId: sourceId.present ? sourceId.value : this.sourceId,
    url: url ?? this.url,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    listingStatus: listingStatus ?? this.listingStatus,
    agentId: agentId.present ? agentId.value : this.agentId,
    rating: rating ?? this.rating,
    notes: notes ?? this.notes,
    added: added ?? this.added,
    meta: meta ?? this.meta,
  );
  Property copyWithCompanion(PropertiesCompanion data) {
    return Property(
      id: data.id.present ? data.id.value : this.id,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      address: data.address.present ? data.address.value : this.address,
      postcode: data.postcode.present ? data.postcode.value : this.postcode,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      kind: data.kind.present ? data.kind.value : this.kind,
      stage: data.stage.present ? data.stage.value : this.stage,
      price: data.price.present ? data.price.value : this.price,
      beds: data.beds.present ? data.beds.value : this.beds,
      baths: data.baths.present ? data.baths.value : this.baths,
      style: data.style.present ? data.style.value : this.style,
      furnished: data.furnished.present ? data.furnished.value : this.furnished,
      availableFrom: data.availableFrom.present ? data.availableFrom.value : this.availableFrom,
      source: data.source.present ? data.source.value : this.source,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      url: data.url.present ? data.url.value : this.url,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      listingStatus: data.listingStatus.present ? data.listingStatus.value : this.listingStatus,
      agentId: data.agentId.present ? data.agentId.value : this.agentId,
      rating: data.rating.present ? data.rating.value : this.rating,
      notes: data.notes.present ? data.notes.value : this.notes,
      added: data.added.present ? data.added.value : this.added,
      meta: data.meta.present ? data.meta.value : this.meta,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Property(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('address: $address, ')
          ..write('postcode: $postcode, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('kind: $kind, ')
          ..write('stage: $stage, ')
          ..write('price: $price, ')
          ..write('beds: $beds, ')
          ..write('baths: $baths, ')
          ..write('style: $style, ')
          ..write('furnished: $furnished, ')
          ..write('availableFrom: $availableFrom, ')
          ..write('source: $source, ')
          ..write('sourceId: $sourceId, ')
          ..write('url: $url, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('listingStatus: $listingStatus, ')
          ..write('agentId: $agentId, ')
          ..write('rating: $rating, ')
          ..write('notes: $notes, ')
          ..write('added: $added, ')
          ..write('meta: $meta')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    hlc,
    deleted,
    address,
    postcode,
    lat,
    lon,
    kind,
    stage,
    price,
    beds,
    baths,
    style,
    furnished,
    availableFrom,
    source,
    sourceId,
    url,
    imageUrl,
    listingStatus,
    agentId,
    rating,
    notes,
    added,
    meta,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Property &&
          other.id == this.id &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.address == this.address &&
          other.postcode == this.postcode &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.kind == this.kind &&
          other.stage == this.stage &&
          other.price == this.price &&
          other.beds == this.beds &&
          other.baths == this.baths &&
          other.style == this.style &&
          other.furnished == this.furnished &&
          other.availableFrom == this.availableFrom &&
          other.source == this.source &&
          other.sourceId == this.sourceId &&
          other.url == this.url &&
          other.imageUrl == this.imageUrl &&
          other.listingStatus == this.listingStatus &&
          other.agentId == this.agentId &&
          other.rating == this.rating &&
          other.notes == this.notes &&
          other.added == this.added &&
          other.meta == this.meta);
}

class PropertiesCompanion extends UpdateCompanion<Property> {
  final Value<String> id;
  final Value<String> hlc;
  final Value<bool> deleted;
  final Value<String> address;
  final Value<String> postcode;
  final Value<double?> lat;
  final Value<double?> lon;
  final Value<String> kind;
  final Value<String> stage;
  final Value<int?> price;
  final Value<int?> beds;
  final Value<int?> baths;
  final Value<String> style;
  final Value<String> furnished;
  final Value<String?> availableFrom;
  final Value<String> source;
  final Value<String?> sourceId;
  final Value<String> url;
  final Value<String?> imageUrl;
  final Value<String> listingStatus;
  final Value<String?> agentId;
  final Value<int> rating;
  final Value<String> notes;
  final Value<String> added;
  final Value<String> meta;
  final Value<int> rowid;
  const PropertiesCompanion({
    this.id = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.address = const Value.absent(),
    this.postcode = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.kind = const Value.absent(),
    this.stage = const Value.absent(),
    this.price = const Value.absent(),
    this.beds = const Value.absent(),
    this.baths = const Value.absent(),
    this.style = const Value.absent(),
    this.furnished = const Value.absent(),
    this.availableFrom = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.url = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.listingStatus = const Value.absent(),
    this.agentId = const Value.absent(),
    this.rating = const Value.absent(),
    this.notes = const Value.absent(),
    this.added = const Value.absent(),
    this.meta = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PropertiesCompanion.insert({
    required String id,
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    required String address,
    this.postcode = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    required String kind,
    this.stage = const Value.absent(),
    this.price = const Value.absent(),
    this.beds = const Value.absent(),
    this.baths = const Value.absent(),
    this.style = const Value.absent(),
    this.furnished = const Value.absent(),
    this.availableFrom = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.url = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.listingStatus = const Value.absent(),
    this.agentId = const Value.absent(),
    this.rating = const Value.absent(),
    this.notes = const Value.absent(),
    required String added,
    this.meta = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       address = Value(address),
       kind = Value(kind),
       added = Value(added);
  static Insertable<Property> custom({
    Expression<String>? id,
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<String>? address,
    Expression<String>? postcode,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<String>? kind,
    Expression<String>? stage,
    Expression<int>? price,
    Expression<int>? beds,
    Expression<int>? baths,
    Expression<String>? style,
    Expression<String>? furnished,
    Expression<String>? availableFrom,
    Expression<String>? source,
    Expression<String>? sourceId,
    Expression<String>? url,
    Expression<String>? imageUrl,
    Expression<String>? listingStatus,
    Expression<String>? agentId,
    Expression<int>? rating,
    Expression<String>? notes,
    Expression<String>? added,
    Expression<String>? meta,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (address != null) 'address': address,
      if (postcode != null) 'postcode': postcode,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (kind != null) 'kind': kind,
      if (stage != null) 'stage': stage,
      if (price != null) 'price': price,
      if (beds != null) 'beds': beds,
      if (baths != null) 'baths': baths,
      if (style != null) 'style': style,
      if (furnished != null) 'furnished': furnished,
      if (availableFrom != null) 'available_from': availableFrom,
      if (source != null) 'source': source,
      if (sourceId != null) 'source_id': sourceId,
      if (url != null) 'url': url,
      if (imageUrl != null) 'image_url': imageUrl,
      if (listingStatus != null) 'listing_status': listingStatus,
      if (agentId != null) 'agent_id': agentId,
      if (rating != null) 'rating': rating,
      if (notes != null) 'notes': notes,
      if (added != null) 'added': added,
      if (meta != null) 'meta': meta,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PropertiesCompanion copyWith({
    Value<String>? id,
    Value<String>? hlc,
    Value<bool>? deleted,
    Value<String>? address,
    Value<String>? postcode,
    Value<double?>? lat,
    Value<double?>? lon,
    Value<String>? kind,
    Value<String>? stage,
    Value<int?>? price,
    Value<int?>? beds,
    Value<int?>? baths,
    Value<String>? style,
    Value<String>? furnished,
    Value<String?>? availableFrom,
    Value<String>? source,
    Value<String?>? sourceId,
    Value<String>? url,
    Value<String?>? imageUrl,
    Value<String>? listingStatus,
    Value<String?>? agentId,
    Value<int>? rating,
    Value<String>? notes,
    Value<String>? added,
    Value<String>? meta,
    Value<int>? rowid,
  }) {
    return PropertiesCompanion(
      id: id ?? this.id,
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      address: address ?? this.address,
      postcode: postcode ?? this.postcode,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      kind: kind ?? this.kind,
      stage: stage ?? this.stage,
      price: price ?? this.price,
      beds: beds ?? this.beds,
      baths: baths ?? this.baths,
      style: style ?? this.style,
      furnished: furnished ?? this.furnished,
      availableFrom: availableFrom ?? this.availableFrom,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      listingStatus: listingStatus ?? this.listingStatus,
      agentId: agentId ?? this.agentId,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      added: added ?? this.added,
      meta: meta ?? this.meta,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (postcode.present) {
      map['postcode'] = Variable<String>(postcode.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (stage.present) {
      map['stage'] = Variable<String>(stage.value);
    }
    if (price.present) {
      map['price'] = Variable<int>(price.value);
    }
    if (beds.present) {
      map['beds'] = Variable<int>(beds.value);
    }
    if (baths.present) {
      map['baths'] = Variable<int>(baths.value);
    }
    if (style.present) {
      map['style'] = Variable<String>(style.value);
    }
    if (furnished.present) {
      map['furnished'] = Variable<String>(furnished.value);
    }
    if (availableFrom.present) {
      map['available_from'] = Variable<String>(availableFrom.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (listingStatus.present) {
      map['listing_status'] = Variable<String>(listingStatus.value);
    }
    if (agentId.present) {
      map['agent_id'] = Variable<String>(agentId.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (added.present) {
      map['added'] = Variable<String>(added.value);
    }
    if (meta.present) {
      map['meta'] = Variable<String>(meta.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PropertiesCompanion(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('address: $address, ')
          ..write('postcode: $postcode, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('kind: $kind, ')
          ..write('stage: $stage, ')
          ..write('price: $price, ')
          ..write('beds: $beds, ')
          ..write('baths: $baths, ')
          ..write('style: $style, ')
          ..write('furnished: $furnished, ')
          ..write('availableFrom: $availableFrom, ')
          ..write('source: $source, ')
          ..write('sourceId: $sourceId, ')
          ..write('url: $url, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('listingStatus: $listingStatus, ')
          ..write('agentId: $agentId, ')
          ..write('rating: $rating, ')
          ..write('notes: $notes, ')
          ..write('added: $added, ')
          ..write('meta: $meta, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContactsTable extends Contacts with TableInfo<$ContactsTable, Contact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('agent'),
  );
  static const VerificationMeta _organisationMeta = const VerificationMeta('organisation');
  @override
  late final GeneratedColumn<String> organisation = GeneratedColumn<String>(
    'organisation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [id, hlc, deleted, name, role, organisation, phone, email, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contacts';
  @override
  VerificationContext validateIntegrity(Insertable<Contact> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(_hlcMeta, hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta));
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta, deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('role')) {
      context.handle(_roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    if (data.containsKey('organisation')) {
      context.handle(
        _organisationMeta,
        organisation.isAcceptableOrUnknown(data['organisation']!, _organisationMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(_phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('email')) {
      context.handle(_emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Contact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Contact(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      hlc: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}hlc'])!,
      deleted: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      role: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      organisation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}organisation'],
      )!,
      phone: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      email: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
    );
  }

  @override
  $ContactsTable createAlias(String alias) {
    return $ContactsTable(attachedDatabase, alias);
  }
}

class Contact extends DataClass implements Insertable<Contact> {
  final String id;
  final String hlc;
  final bool deleted;
  final String name;
  final String role;
  final String organisation;
  final String phone;
  final String email;
  final String notes;
  const Contact({
    required this.id,
    required this.hlc,
    required this.deleted,
    required this.name,
    required this.role,
    required this.organisation,
    required this.phone,
    required this.email,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['hlc'] = Variable<String>(hlc);
    map['deleted'] = Variable<bool>(deleted);
    map['name'] = Variable<String>(name);
    map['role'] = Variable<String>(role);
    map['organisation'] = Variable<String>(organisation);
    map['phone'] = Variable<String>(phone);
    map['email'] = Variable<String>(email);
    map['notes'] = Variable<String>(notes);
    return map;
  }

  ContactsCompanion toCompanion(bool nullToAbsent) {
    return ContactsCompanion(
      id: Value(id),
      hlc: Value(hlc),
      deleted: Value(deleted),
      name: Value(name),
      role: Value(role),
      organisation: Value(organisation),
      phone: Value(phone),
      email: Value(email),
      notes: Value(notes),
    );
  }

  factory Contact.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Contact(
      id: serializer.fromJson<String>(json['id']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      name: serializer.fromJson<String>(json['name']),
      role: serializer.fromJson<String>(json['role']),
      organisation: serializer.fromJson<String>(json['organisation']),
      phone: serializer.fromJson<String>(json['phone']),
      email: serializer.fromJson<String>(json['email']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hlc': serializer.toJson<String>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'name': serializer.toJson<String>(name),
      'role': serializer.toJson<String>(role),
      'organisation': serializer.toJson<String>(organisation),
      'phone': serializer.toJson<String>(phone),
      'email': serializer.toJson<String>(email),
      'notes': serializer.toJson<String>(notes),
    };
  }

  Contact copyWith({
    String? id,
    String? hlc,
    bool? deleted,
    String? name,
    String? role,
    String? organisation,
    String? phone,
    String? email,
    String? notes,
  }) => Contact(
    id: id ?? this.id,
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    name: name ?? this.name,
    role: role ?? this.role,
    organisation: organisation ?? this.organisation,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    notes: notes ?? this.notes,
  );
  Contact copyWithCompanion(ContactsCompanion data) {
    return Contact(
      id: data.id.present ? data.id.value : this.id,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      name: data.name.present ? data.name.value : this.name,
      role: data.role.present ? data.role.value : this.role,
      organisation: data.organisation.present ? data.organisation.value : this.organisation,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Contact(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('organisation: $organisation, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, hlc, deleted, name, role, organisation, phone, email, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Contact &&
          other.id == this.id &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.name == this.name &&
          other.role == this.role &&
          other.organisation == this.organisation &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.notes == this.notes);
}

class ContactsCompanion extends UpdateCompanion<Contact> {
  final Value<String> id;
  final Value<String> hlc;
  final Value<bool> deleted;
  final Value<String> name;
  final Value<String> role;
  final Value<String> organisation;
  final Value<String> phone;
  final Value<String> email;
  final Value<String> notes;
  final Value<int> rowid;
  const ContactsCompanion({
    this.id = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.name = const Value.absent(),
    this.role = const Value.absent(),
    this.organisation = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContactsCompanion.insert({
    required String id,
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    required String name,
    this.role = const Value.absent(),
    this.organisation = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Contact> custom({
    Expression<String>? id,
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<String>? name,
    Expression<String>? role,
    Expression<String>? organisation,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (name != null) 'name': name,
      if (role != null) 'role': role,
      if (organisation != null) 'organisation': organisation,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContactsCompanion copyWith({
    Value<String>? id,
    Value<String>? hlc,
    Value<bool>? deleted,
    Value<String>? name,
    Value<String>? role,
    Value<String>? organisation,
    Value<String>? phone,
    Value<String>? email,
    Value<String>? notes,
    Value<int>? rowid,
  }) {
    return ContactsCompanion(
      id: id ?? this.id,
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      name: name ?? this.name,
      role: role ?? this.role,
      organisation: organisation ?? this.organisation,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (organisation.present) {
      map['organisation'] = Variable<String>(organisation.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactsCompanion(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('organisation: $organisation, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InteractionsTable extends Interactions with TableInfo<$InteractionsTable, Interaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InteractionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _propertyIdMeta = const VerificationMeta('propertyId');
  @override
  late final GeneratedColumn<String> propertyId = GeneratedColumn<String>(
    'property_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contactIdMeta = const VerificationMeta('contactId');
  @override
  late final GeneratedColumn<String> contactId = GeneratedColumn<String>(
    'contact_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<String> at = GeneratedColumn<String>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _channelMeta = const VerificationMeta('channel');
  @override
  late final GeneratedColumn<String> channel = GeneratedColumn<String>(
    'channel',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta('direction');
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('out'),
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta('summary');
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _followUpMeta = const VerificationMeta('followUp');
  @override
  late final GeneratedColumn<String> followUp = GeneratedColumn<String>(
    'follow_up',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    hlc,
    deleted,
    propertyId,
    contactId,
    at,
    channel,
    direction,
    summary,
    followUp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'interactions';
  @override
  VerificationContext validateIntegrity(Insertable<Interaction> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(_hlcMeta, hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta));
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta, deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('property_id')) {
      context.handle(
        _propertyIdMeta,
        propertyId.isAcceptableOrUnknown(data['property_id']!, _propertyIdMeta),
      );
    }
    if (data.containsKey('contact_id')) {
      context.handle(_contactIdMeta, contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta));
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('channel')) {
      context.handle(_channelMeta, channel.isAcceptableOrUnknown(data['channel']!, _channelMeta));
    } else if (isInserting) {
      context.missing(_channelMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(_directionMeta, direction.isAcceptableOrUnknown(data['direction']!, _directionMeta));
    }
    if (data.containsKey('summary')) {
      context.handle(_summaryMeta, summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta));
    }
    if (data.containsKey('follow_up')) {
      context.handle(_followUpMeta, followUp.isAcceptableOrUnknown(data['follow_up']!, _followUpMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Interaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Interaction(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      hlc: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}hlc'])!,
      deleted: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      propertyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}property_id'],
      ),
      contactId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}contact_id']),
      at: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}at'])!,
      channel: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}channel'])!,
      direction: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}direction'])!,
      summary: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}summary'])!,
      followUp: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}follow_up']),
    );
  }

  @override
  $InteractionsTable createAlias(String alias) {
    return $InteractionsTable(attachedDatabase, alias);
  }
}

class Interaction extends DataClass implements Insertable<Interaction> {
  final String id;
  final String hlc;
  final bool deleted;
  final String? propertyId;
  final String? contactId;

  /// Local date and time, yyyy-MM-ddTHH:mm.
  final String at;

  /// call | sms | whatsapp | email | visit | note
  final String channel;

  /// out | in
  final String direction;
  final String summary;

  /// Date to chase it up, yyyy-MM-dd.
  final String? followUp;
  const Interaction({
    required this.id,
    required this.hlc,
    required this.deleted,
    this.propertyId,
    this.contactId,
    required this.at,
    required this.channel,
    required this.direction,
    required this.summary,
    this.followUp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['hlc'] = Variable<String>(hlc);
    map['deleted'] = Variable<bool>(deleted);
    if (!nullToAbsent || propertyId != null) {
      map['property_id'] = Variable<String>(propertyId);
    }
    if (!nullToAbsent || contactId != null) {
      map['contact_id'] = Variable<String>(contactId);
    }
    map['at'] = Variable<String>(at);
    map['channel'] = Variable<String>(channel);
    map['direction'] = Variable<String>(direction);
    map['summary'] = Variable<String>(summary);
    if (!nullToAbsent || followUp != null) {
      map['follow_up'] = Variable<String>(followUp);
    }
    return map;
  }

  InteractionsCompanion toCompanion(bool nullToAbsent) {
    return InteractionsCompanion(
      id: Value(id),
      hlc: Value(hlc),
      deleted: Value(deleted),
      propertyId: propertyId == null && nullToAbsent ? const Value.absent() : Value(propertyId),
      contactId: contactId == null && nullToAbsent ? const Value.absent() : Value(contactId),
      at: Value(at),
      channel: Value(channel),
      direction: Value(direction),
      summary: Value(summary),
      followUp: followUp == null && nullToAbsent ? const Value.absent() : Value(followUp),
    );
  }

  factory Interaction.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Interaction(
      id: serializer.fromJson<String>(json['id']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      propertyId: serializer.fromJson<String?>(json['propertyId']),
      contactId: serializer.fromJson<String?>(json['contactId']),
      at: serializer.fromJson<String>(json['at']),
      channel: serializer.fromJson<String>(json['channel']),
      direction: serializer.fromJson<String>(json['direction']),
      summary: serializer.fromJson<String>(json['summary']),
      followUp: serializer.fromJson<String?>(json['followUp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hlc': serializer.toJson<String>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'propertyId': serializer.toJson<String?>(propertyId),
      'contactId': serializer.toJson<String?>(contactId),
      'at': serializer.toJson<String>(at),
      'channel': serializer.toJson<String>(channel),
      'direction': serializer.toJson<String>(direction),
      'summary': serializer.toJson<String>(summary),
      'followUp': serializer.toJson<String?>(followUp),
    };
  }

  Interaction copyWith({
    String? id,
    String? hlc,
    bool? deleted,
    Value<String?> propertyId = const Value.absent(),
    Value<String?> contactId = const Value.absent(),
    String? at,
    String? channel,
    String? direction,
    String? summary,
    Value<String?> followUp = const Value.absent(),
  }) => Interaction(
    id: id ?? this.id,
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    propertyId: propertyId.present ? propertyId.value : this.propertyId,
    contactId: contactId.present ? contactId.value : this.contactId,
    at: at ?? this.at,
    channel: channel ?? this.channel,
    direction: direction ?? this.direction,
    summary: summary ?? this.summary,
    followUp: followUp.present ? followUp.value : this.followUp,
  );
  Interaction copyWithCompanion(InteractionsCompanion data) {
    return Interaction(
      id: data.id.present ? data.id.value : this.id,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      propertyId: data.propertyId.present ? data.propertyId.value : this.propertyId,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      at: data.at.present ? data.at.value : this.at,
      channel: data.channel.present ? data.channel.value : this.channel,
      direction: data.direction.present ? data.direction.value : this.direction,
      summary: data.summary.present ? data.summary.value : this.summary,
      followUp: data.followUp.present ? data.followUp.value : this.followUp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Interaction(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('propertyId: $propertyId, ')
          ..write('contactId: $contactId, ')
          ..write('at: $at, ')
          ..write('channel: $channel, ')
          ..write('direction: $direction, ')
          ..write('summary: $summary, ')
          ..write('followUp: $followUp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, hlc, deleted, propertyId, contactId, at, channel, direction, summary, followUp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Interaction &&
          other.id == this.id &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.propertyId == this.propertyId &&
          other.contactId == this.contactId &&
          other.at == this.at &&
          other.channel == this.channel &&
          other.direction == this.direction &&
          other.summary == this.summary &&
          other.followUp == this.followUp);
}

class InteractionsCompanion extends UpdateCompanion<Interaction> {
  final Value<String> id;
  final Value<String> hlc;
  final Value<bool> deleted;
  final Value<String?> propertyId;
  final Value<String?> contactId;
  final Value<String> at;
  final Value<String> channel;
  final Value<String> direction;
  final Value<String> summary;
  final Value<String?> followUp;
  final Value<int> rowid;
  const InteractionsCompanion({
    this.id = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.propertyId = const Value.absent(),
    this.contactId = const Value.absent(),
    this.at = const Value.absent(),
    this.channel = const Value.absent(),
    this.direction = const Value.absent(),
    this.summary = const Value.absent(),
    this.followUp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InteractionsCompanion.insert({
    required String id,
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.propertyId = const Value.absent(),
    this.contactId = const Value.absent(),
    required String at,
    required String channel,
    this.direction = const Value.absent(),
    this.summary = const Value.absent(),
    this.followUp = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       at = Value(at),
       channel = Value(channel);
  static Insertable<Interaction> custom({
    Expression<String>? id,
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<String>? propertyId,
    Expression<String>? contactId,
    Expression<String>? at,
    Expression<String>? channel,
    Expression<String>? direction,
    Expression<String>? summary,
    Expression<String>? followUp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (propertyId != null) 'property_id': propertyId,
      if (contactId != null) 'contact_id': contactId,
      if (at != null) 'at': at,
      if (channel != null) 'channel': channel,
      if (direction != null) 'direction': direction,
      if (summary != null) 'summary': summary,
      if (followUp != null) 'follow_up': followUp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InteractionsCompanion copyWith({
    Value<String>? id,
    Value<String>? hlc,
    Value<bool>? deleted,
    Value<String?>? propertyId,
    Value<String?>? contactId,
    Value<String>? at,
    Value<String>? channel,
    Value<String>? direction,
    Value<String>? summary,
    Value<String?>? followUp,
    Value<int>? rowid,
  }) {
    return InteractionsCompanion(
      id: id ?? this.id,
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      propertyId: propertyId ?? this.propertyId,
      contactId: contactId ?? this.contactId,
      at: at ?? this.at,
      channel: channel ?? this.channel,
      direction: direction ?? this.direction,
      summary: summary ?? this.summary,
      followUp: followUp ?? this.followUp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (propertyId.present) {
      map['property_id'] = Variable<String>(propertyId.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<String>(contactId.value);
    }
    if (at.present) {
      map['at'] = Variable<String>(at.value);
    }
    if (channel.present) {
      map['channel'] = Variable<String>(channel.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (followUp.present) {
      map['follow_up'] = Variable<String>(followUp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InteractionsCompanion(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('propertyId: $propertyId, ')
          ..write('contactId: $contactId, ')
          ..write('at: $at, ')
          ..write('channel: $channel, ')
          ..write('direction: $direction, ')
          ..write('summary: $summary, ')
          ..write('followUp: $followUp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ViewingsTable extends Viewings with TableInfo<$ViewingsTable, Viewing> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ViewingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _propertyIdMeta = const VerificationMeta('propertyId');
  @override
  late final GeneratedColumn<String> propertyId = GeneratedColumn<String>(
    'property_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<String> at = GeneratedColumn<String>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('booked'),
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [id, hlc, deleted, propertyId, at, status, rating, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'viewings';
  @override
  VerificationContext validateIntegrity(Insertable<Viewing> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(_hlcMeta, hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta));
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta, deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('property_id')) {
      context.handle(
        _propertyIdMeta,
        propertyId.isAcceptableOrUnknown(data['property_id']!, _propertyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_propertyIdMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta, status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('rating')) {
      context.handle(_ratingMeta, rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Viewing map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Viewing(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      hlc: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}hlc'])!,
      deleted: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      propertyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}property_id'],
      )!,
      at: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}at'])!,
      status: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      rating: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}rating'])!,
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
    );
  }

  @override
  $ViewingsTable createAlias(String alias) {
    return $ViewingsTable(attachedDatabase, alias);
  }
}

class Viewing extends DataClass implements Insertable<Viewing> {
  final String id;
  final String hlc;
  final bool deleted;
  final String propertyId;

  /// Local date and time, yyyy-MM-ddTHH:mm.
  final String at;

  /// booked | done | cancelled
  final String status;
  final int rating;
  final String notes;
  const Viewing({
    required this.id,
    required this.hlc,
    required this.deleted,
    required this.propertyId,
    required this.at,
    required this.status,
    required this.rating,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['hlc'] = Variable<String>(hlc);
    map['deleted'] = Variable<bool>(deleted);
    map['property_id'] = Variable<String>(propertyId);
    map['at'] = Variable<String>(at);
    map['status'] = Variable<String>(status);
    map['rating'] = Variable<int>(rating);
    map['notes'] = Variable<String>(notes);
    return map;
  }

  ViewingsCompanion toCompanion(bool nullToAbsent) {
    return ViewingsCompanion(
      id: Value(id),
      hlc: Value(hlc),
      deleted: Value(deleted),
      propertyId: Value(propertyId),
      at: Value(at),
      status: Value(status),
      rating: Value(rating),
      notes: Value(notes),
    );
  }

  factory Viewing.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Viewing(
      id: serializer.fromJson<String>(json['id']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      propertyId: serializer.fromJson<String>(json['propertyId']),
      at: serializer.fromJson<String>(json['at']),
      status: serializer.fromJson<String>(json['status']),
      rating: serializer.fromJson<int>(json['rating']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hlc': serializer.toJson<String>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'propertyId': serializer.toJson<String>(propertyId),
      'at': serializer.toJson<String>(at),
      'status': serializer.toJson<String>(status),
      'rating': serializer.toJson<int>(rating),
      'notes': serializer.toJson<String>(notes),
    };
  }

  Viewing copyWith({
    String? id,
    String? hlc,
    bool? deleted,
    String? propertyId,
    String? at,
    String? status,
    int? rating,
    String? notes,
  }) => Viewing(
    id: id ?? this.id,
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    propertyId: propertyId ?? this.propertyId,
    at: at ?? this.at,
    status: status ?? this.status,
    rating: rating ?? this.rating,
    notes: notes ?? this.notes,
  );
  Viewing copyWithCompanion(ViewingsCompanion data) {
    return Viewing(
      id: data.id.present ? data.id.value : this.id,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      propertyId: data.propertyId.present ? data.propertyId.value : this.propertyId,
      at: data.at.present ? data.at.value : this.at,
      status: data.status.present ? data.status.value : this.status,
      rating: data.rating.present ? data.rating.value : this.rating,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Viewing(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('propertyId: $propertyId, ')
          ..write('at: $at, ')
          ..write('status: $status, ')
          ..write('rating: $rating, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, hlc, deleted, propertyId, at, status, rating, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Viewing &&
          other.id == this.id &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.propertyId == this.propertyId &&
          other.at == this.at &&
          other.status == this.status &&
          other.rating == this.rating &&
          other.notes == this.notes);
}

class ViewingsCompanion extends UpdateCompanion<Viewing> {
  final Value<String> id;
  final Value<String> hlc;
  final Value<bool> deleted;
  final Value<String> propertyId;
  final Value<String> at;
  final Value<String> status;
  final Value<int> rating;
  final Value<String> notes;
  final Value<int> rowid;
  const ViewingsCompanion({
    this.id = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.propertyId = const Value.absent(),
    this.at = const Value.absent(),
    this.status = const Value.absent(),
    this.rating = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ViewingsCompanion.insert({
    required String id,
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    required String propertyId,
    required String at,
    this.status = const Value.absent(),
    this.rating = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       propertyId = Value(propertyId),
       at = Value(at);
  static Insertable<Viewing> custom({
    Expression<String>? id,
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<String>? propertyId,
    Expression<String>? at,
    Expression<String>? status,
    Expression<int>? rating,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (propertyId != null) 'property_id': propertyId,
      if (at != null) 'at': at,
      if (status != null) 'status': status,
      if (rating != null) 'rating': rating,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ViewingsCompanion copyWith({
    Value<String>? id,
    Value<String>? hlc,
    Value<bool>? deleted,
    Value<String>? propertyId,
    Value<String>? at,
    Value<String>? status,
    Value<int>? rating,
    Value<String>? notes,
    Value<int>? rowid,
  }) {
    return ViewingsCompanion(
      id: id ?? this.id,
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      propertyId: propertyId ?? this.propertyId,
      at: at ?? this.at,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (propertyId.present) {
      map['property_id'] = Variable<String>(propertyId.value);
    }
    if (at.present) {
      map['at'] = Variable<String>(at.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ViewingsCompanion(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('propertyId: $propertyId, ')
          ..write('at: $at, ')
          ..write('status: $status, ')
          ..write('rating: $rating, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SearchesTable extends Searches with TableInfo<$SearchesTable, Search> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SearchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('propertypal'),
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _keywordsMeta = const VerificationMeta('keywords');
  @override
  late final GeneratedColumn<String> keywords = GeneratedColumn<String>(
    'keywords',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _maxPriceMeta = const VerificationMeta('maxPrice');
  @override
  late final GeneratedColumn<int> maxPrice = GeneratedColumn<int>(
    'max_price',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minBedsMeta = const VerificationMeta('minBeds');
  @override
  late final GeneratedColumn<int> minBeds = GeneratedColumn<int>(
    'min_beds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxBedsMeta = const VerificationMeta('maxBeds');
  @override
  late final GeneratedColumn<int> maxBeds = GeneratedColumn<int>(
    'max_beds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _centreLatMeta = const VerificationMeta('centreLat');
  @override
  late final GeneratedColumn<double> centreLat = GeneratedColumn<double>(
    'centre_lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _centreLonMeta = const VerificationMeta('centreLon');
  @override
  late final GeneratedColumn<double> centreLon = GeneratedColumn<double>(
    'centre_lon',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _centreLabelMeta = const VerificationMeta('centreLabel');
  @override
  late final GeneratedColumn<String> centreLabel = GeneratedColumn<String>(
    'centre_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _radiusKmMeta = const VerificationMeta('radiusKm');
  @override
  late final GeneratedColumn<double> radiusKm = GeneratedColumn<double>(
    'radius_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _includeUnpricedMeta = const VerificationMeta('includeUnpriced');
  @override
  late final GeneratedColumn<bool> includeUnpriced = GeneratedColumn<bool>(
    'include_unpriced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("include_unpriced" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _pausedMeta = const VerificationMeta('paused');
  @override
  late final GeneratedColumn<bool> paused = GeneratedColumn<bool>(
    'paused',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("paused" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    hlc,
    deleted,
    name,
    source,
    path,
    kind,
    keywords,
    maxPrice,
    minBeds,
    maxBeds,
    centreLat,
    centreLon,
    centreLabel,
    radiusKm,
    includeUnpriced,
    paused,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'searches';
  @override
  VerificationContext validateIntegrity(Insertable<Search> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(_hlcMeta, hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta));
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta, deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta, source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('path')) {
      context.handle(_pathMeta, path.isAcceptableOrUnknown(data['path']!, _pathMeta));
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(_kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    }
    if (data.containsKey('keywords')) {
      context.handle(_keywordsMeta, keywords.isAcceptableOrUnknown(data['keywords']!, _keywordsMeta));
    }
    if (data.containsKey('max_price')) {
      context.handle(_maxPriceMeta, maxPrice.isAcceptableOrUnknown(data['max_price']!, _maxPriceMeta));
    }
    if (data.containsKey('min_beds')) {
      context.handle(_minBedsMeta, minBeds.isAcceptableOrUnknown(data['min_beds']!, _minBedsMeta));
    }
    if (data.containsKey('max_beds')) {
      context.handle(_maxBedsMeta, maxBeds.isAcceptableOrUnknown(data['max_beds']!, _maxBedsMeta));
    }
    if (data.containsKey('centre_lat')) {
      context.handle(_centreLatMeta, centreLat.isAcceptableOrUnknown(data['centre_lat']!, _centreLatMeta));
    }
    if (data.containsKey('centre_lon')) {
      context.handle(_centreLonMeta, centreLon.isAcceptableOrUnknown(data['centre_lon']!, _centreLonMeta));
    }
    if (data.containsKey('centre_label')) {
      context.handle(
        _centreLabelMeta,
        centreLabel.isAcceptableOrUnknown(data['centre_label']!, _centreLabelMeta),
      );
    }
    if (data.containsKey('radius_km')) {
      context.handle(_radiusKmMeta, radiusKm.isAcceptableOrUnknown(data['radius_km']!, _radiusKmMeta));
    }
    if (data.containsKey('include_unpriced')) {
      context.handle(
        _includeUnpricedMeta,
        includeUnpriced.isAcceptableOrUnknown(data['include_unpriced']!, _includeUnpricedMeta),
      );
    }
    if (data.containsKey('paused')) {
      context.handle(_pausedMeta, paused.isAcceptableOrUnknown(data['paused']!, _pausedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Search map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Search(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      hlc: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}hlc'])!,
      deleted: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      source: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      path: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}path'])!,
      kind: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      keywords: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}keywords'])!,
      maxPrice: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}max_price']),
      minBeds: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}min_beds']),
      maxBeds: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}max_beds']),
      centreLat: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}centre_lat']),
      centreLon: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}centre_lon']),
      centreLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}centre_label'],
      )!,
      radiusKm: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}radius_km']),
      includeUnpriced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}include_unpriced'],
      )!,
      paused: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}paused'])!,
    );
  }

  @override
  $SearchesTable createAlias(String alias) {
    return $SearchesTable(attachedDatabase, alias);
  }
}

class Search extends DataClass implements Insertable<Search> {
  final String id;
  final String hlc;
  final bool deleted;
  final String name;

  /// propertypal: Watch reads a PropertyPal search. email: Watch reads the
  /// portal alert emails forwarded to it (England).
  final String source;

  /// PropertyPal search path, e.g. /property-to-rent/enniskillen. Empty for email.
  final String path;

  /// Email searches: rent | buy.
  final String kind;

  /// Email searches: words the advert must mention, comma separated; a word
  /// starting with "-" must not appear.
  final String keywords;
  final int? maxPrice;
  final int? minBeds;
  final int? maxBeds;
  final double? centreLat;
  final double? centreLon;
  final String centreLabel;
  final double? radiusKm;
  final bool includeUnpriced;
  final bool paused;
  const Search({
    required this.id,
    required this.hlc,
    required this.deleted,
    required this.name,
    required this.source,
    required this.path,
    required this.kind,
    required this.keywords,
    this.maxPrice,
    this.minBeds,
    this.maxBeds,
    this.centreLat,
    this.centreLon,
    required this.centreLabel,
    this.radiusKm,
    required this.includeUnpriced,
    required this.paused,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['hlc'] = Variable<String>(hlc);
    map['deleted'] = Variable<bool>(deleted);
    map['name'] = Variable<String>(name);
    map['source'] = Variable<String>(source);
    map['path'] = Variable<String>(path);
    map['kind'] = Variable<String>(kind);
    map['keywords'] = Variable<String>(keywords);
    if (!nullToAbsent || maxPrice != null) {
      map['max_price'] = Variable<int>(maxPrice);
    }
    if (!nullToAbsent || minBeds != null) {
      map['min_beds'] = Variable<int>(minBeds);
    }
    if (!nullToAbsent || maxBeds != null) {
      map['max_beds'] = Variable<int>(maxBeds);
    }
    if (!nullToAbsent || centreLat != null) {
      map['centre_lat'] = Variable<double>(centreLat);
    }
    if (!nullToAbsent || centreLon != null) {
      map['centre_lon'] = Variable<double>(centreLon);
    }
    map['centre_label'] = Variable<String>(centreLabel);
    if (!nullToAbsent || radiusKm != null) {
      map['radius_km'] = Variable<double>(radiusKm);
    }
    map['include_unpriced'] = Variable<bool>(includeUnpriced);
    map['paused'] = Variable<bool>(paused);
    return map;
  }

  SearchesCompanion toCompanion(bool nullToAbsent) {
    return SearchesCompanion(
      id: Value(id),
      hlc: Value(hlc),
      deleted: Value(deleted),
      name: Value(name),
      source: Value(source),
      path: Value(path),
      kind: Value(kind),
      keywords: Value(keywords),
      maxPrice: maxPrice == null && nullToAbsent ? const Value.absent() : Value(maxPrice),
      minBeds: minBeds == null && nullToAbsent ? const Value.absent() : Value(minBeds),
      maxBeds: maxBeds == null && nullToAbsent ? const Value.absent() : Value(maxBeds),
      centreLat: centreLat == null && nullToAbsent ? const Value.absent() : Value(centreLat),
      centreLon: centreLon == null && nullToAbsent ? const Value.absent() : Value(centreLon),
      centreLabel: Value(centreLabel),
      radiusKm: radiusKm == null && nullToAbsent ? const Value.absent() : Value(radiusKm),
      includeUnpriced: Value(includeUnpriced),
      paused: Value(paused),
    );
  }

  factory Search.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Search(
      id: serializer.fromJson<String>(json['id']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      name: serializer.fromJson<String>(json['name']),
      source: serializer.fromJson<String>(json['source']),
      path: serializer.fromJson<String>(json['path']),
      kind: serializer.fromJson<String>(json['kind']),
      keywords: serializer.fromJson<String>(json['keywords']),
      maxPrice: serializer.fromJson<int?>(json['maxPrice']),
      minBeds: serializer.fromJson<int?>(json['minBeds']),
      maxBeds: serializer.fromJson<int?>(json['maxBeds']),
      centreLat: serializer.fromJson<double?>(json['centreLat']),
      centreLon: serializer.fromJson<double?>(json['centreLon']),
      centreLabel: serializer.fromJson<String>(json['centreLabel']),
      radiusKm: serializer.fromJson<double?>(json['radiusKm']),
      includeUnpriced: serializer.fromJson<bool>(json['includeUnpriced']),
      paused: serializer.fromJson<bool>(json['paused']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hlc': serializer.toJson<String>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'name': serializer.toJson<String>(name),
      'source': serializer.toJson<String>(source),
      'path': serializer.toJson<String>(path),
      'kind': serializer.toJson<String>(kind),
      'keywords': serializer.toJson<String>(keywords),
      'maxPrice': serializer.toJson<int?>(maxPrice),
      'minBeds': serializer.toJson<int?>(minBeds),
      'maxBeds': serializer.toJson<int?>(maxBeds),
      'centreLat': serializer.toJson<double?>(centreLat),
      'centreLon': serializer.toJson<double?>(centreLon),
      'centreLabel': serializer.toJson<String>(centreLabel),
      'radiusKm': serializer.toJson<double?>(radiusKm),
      'includeUnpriced': serializer.toJson<bool>(includeUnpriced),
      'paused': serializer.toJson<bool>(paused),
    };
  }

  Search copyWith({
    String? id,
    String? hlc,
    bool? deleted,
    String? name,
    String? source,
    String? path,
    String? kind,
    String? keywords,
    Value<int?> maxPrice = const Value.absent(),
    Value<int?> minBeds = const Value.absent(),
    Value<int?> maxBeds = const Value.absent(),
    Value<double?> centreLat = const Value.absent(),
    Value<double?> centreLon = const Value.absent(),
    String? centreLabel,
    Value<double?> radiusKm = const Value.absent(),
    bool? includeUnpriced,
    bool? paused,
  }) => Search(
    id: id ?? this.id,
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    name: name ?? this.name,
    source: source ?? this.source,
    path: path ?? this.path,
    kind: kind ?? this.kind,
    keywords: keywords ?? this.keywords,
    maxPrice: maxPrice.present ? maxPrice.value : this.maxPrice,
    minBeds: minBeds.present ? minBeds.value : this.minBeds,
    maxBeds: maxBeds.present ? maxBeds.value : this.maxBeds,
    centreLat: centreLat.present ? centreLat.value : this.centreLat,
    centreLon: centreLon.present ? centreLon.value : this.centreLon,
    centreLabel: centreLabel ?? this.centreLabel,
    radiusKm: radiusKm.present ? radiusKm.value : this.radiusKm,
    includeUnpriced: includeUnpriced ?? this.includeUnpriced,
    paused: paused ?? this.paused,
  );
  Search copyWithCompanion(SearchesCompanion data) {
    return Search(
      id: data.id.present ? data.id.value : this.id,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      name: data.name.present ? data.name.value : this.name,
      source: data.source.present ? data.source.value : this.source,
      path: data.path.present ? data.path.value : this.path,
      kind: data.kind.present ? data.kind.value : this.kind,
      keywords: data.keywords.present ? data.keywords.value : this.keywords,
      maxPrice: data.maxPrice.present ? data.maxPrice.value : this.maxPrice,
      minBeds: data.minBeds.present ? data.minBeds.value : this.minBeds,
      maxBeds: data.maxBeds.present ? data.maxBeds.value : this.maxBeds,
      centreLat: data.centreLat.present ? data.centreLat.value : this.centreLat,
      centreLon: data.centreLon.present ? data.centreLon.value : this.centreLon,
      centreLabel: data.centreLabel.present ? data.centreLabel.value : this.centreLabel,
      radiusKm: data.radiusKm.present ? data.radiusKm.value : this.radiusKm,
      includeUnpriced: data.includeUnpriced.present ? data.includeUnpriced.value : this.includeUnpriced,
      paused: data.paused.present ? data.paused.value : this.paused,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Search(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('source: $source, ')
          ..write('path: $path, ')
          ..write('kind: $kind, ')
          ..write('keywords: $keywords, ')
          ..write('maxPrice: $maxPrice, ')
          ..write('minBeds: $minBeds, ')
          ..write('maxBeds: $maxBeds, ')
          ..write('centreLat: $centreLat, ')
          ..write('centreLon: $centreLon, ')
          ..write('centreLabel: $centreLabel, ')
          ..write('radiusKm: $radiusKm, ')
          ..write('includeUnpriced: $includeUnpriced, ')
          ..write('paused: $paused')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    hlc,
    deleted,
    name,
    source,
    path,
    kind,
    keywords,
    maxPrice,
    minBeds,
    maxBeds,
    centreLat,
    centreLon,
    centreLabel,
    radiusKm,
    includeUnpriced,
    paused,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Search &&
          other.id == this.id &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.name == this.name &&
          other.source == this.source &&
          other.path == this.path &&
          other.kind == this.kind &&
          other.keywords == this.keywords &&
          other.maxPrice == this.maxPrice &&
          other.minBeds == this.minBeds &&
          other.maxBeds == this.maxBeds &&
          other.centreLat == this.centreLat &&
          other.centreLon == this.centreLon &&
          other.centreLabel == this.centreLabel &&
          other.radiusKm == this.radiusKm &&
          other.includeUnpriced == this.includeUnpriced &&
          other.paused == this.paused);
}

class SearchesCompanion extends UpdateCompanion<Search> {
  final Value<String> id;
  final Value<String> hlc;
  final Value<bool> deleted;
  final Value<String> name;
  final Value<String> source;
  final Value<String> path;
  final Value<String> kind;
  final Value<String> keywords;
  final Value<int?> maxPrice;
  final Value<int?> minBeds;
  final Value<int?> maxBeds;
  final Value<double?> centreLat;
  final Value<double?> centreLon;
  final Value<String> centreLabel;
  final Value<double?> radiusKm;
  final Value<bool> includeUnpriced;
  final Value<bool> paused;
  final Value<int> rowid;
  const SearchesCompanion({
    this.id = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.name = const Value.absent(),
    this.source = const Value.absent(),
    this.path = const Value.absent(),
    this.kind = const Value.absent(),
    this.keywords = const Value.absent(),
    this.maxPrice = const Value.absent(),
    this.minBeds = const Value.absent(),
    this.maxBeds = const Value.absent(),
    this.centreLat = const Value.absent(),
    this.centreLon = const Value.absent(),
    this.centreLabel = const Value.absent(),
    this.radiusKm = const Value.absent(),
    this.includeUnpriced = const Value.absent(),
    this.paused = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SearchesCompanion.insert({
    required String id,
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    required String name,
    this.source = const Value.absent(),
    required String path,
    this.kind = const Value.absent(),
    this.keywords = const Value.absent(),
    this.maxPrice = const Value.absent(),
    this.minBeds = const Value.absent(),
    this.maxBeds = const Value.absent(),
    this.centreLat = const Value.absent(),
    this.centreLon = const Value.absent(),
    this.centreLabel = const Value.absent(),
    this.radiusKm = const Value.absent(),
    this.includeUnpriced = const Value.absent(),
    this.paused = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       path = Value(path);
  static Insertable<Search> custom({
    Expression<String>? id,
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<String>? name,
    Expression<String>? source,
    Expression<String>? path,
    Expression<String>? kind,
    Expression<String>? keywords,
    Expression<int>? maxPrice,
    Expression<int>? minBeds,
    Expression<int>? maxBeds,
    Expression<double>? centreLat,
    Expression<double>? centreLon,
    Expression<String>? centreLabel,
    Expression<double>? radiusKm,
    Expression<bool>? includeUnpriced,
    Expression<bool>? paused,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (name != null) 'name': name,
      if (source != null) 'source': source,
      if (path != null) 'path': path,
      if (kind != null) 'kind': kind,
      if (keywords != null) 'keywords': keywords,
      if (maxPrice != null) 'max_price': maxPrice,
      if (minBeds != null) 'min_beds': minBeds,
      if (maxBeds != null) 'max_beds': maxBeds,
      if (centreLat != null) 'centre_lat': centreLat,
      if (centreLon != null) 'centre_lon': centreLon,
      if (centreLabel != null) 'centre_label': centreLabel,
      if (radiusKm != null) 'radius_km': radiusKm,
      if (includeUnpriced != null) 'include_unpriced': includeUnpriced,
      if (paused != null) 'paused': paused,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SearchesCompanion copyWith({
    Value<String>? id,
    Value<String>? hlc,
    Value<bool>? deleted,
    Value<String>? name,
    Value<String>? source,
    Value<String>? path,
    Value<String>? kind,
    Value<String>? keywords,
    Value<int?>? maxPrice,
    Value<int?>? minBeds,
    Value<int?>? maxBeds,
    Value<double?>? centreLat,
    Value<double?>? centreLon,
    Value<String>? centreLabel,
    Value<double?>? radiusKm,
    Value<bool>? includeUnpriced,
    Value<bool>? paused,
    Value<int>? rowid,
  }) {
    return SearchesCompanion(
      id: id ?? this.id,
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      name: name ?? this.name,
      source: source ?? this.source,
      path: path ?? this.path,
      kind: kind ?? this.kind,
      keywords: keywords ?? this.keywords,
      maxPrice: maxPrice ?? this.maxPrice,
      minBeds: minBeds ?? this.minBeds,
      maxBeds: maxBeds ?? this.maxBeds,
      centreLat: centreLat ?? this.centreLat,
      centreLon: centreLon ?? this.centreLon,
      centreLabel: centreLabel ?? this.centreLabel,
      radiusKm: radiusKm ?? this.radiusKm,
      includeUnpriced: includeUnpriced ?? this.includeUnpriced,
      paused: paused ?? this.paused,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (keywords.present) {
      map['keywords'] = Variable<String>(keywords.value);
    }
    if (maxPrice.present) {
      map['max_price'] = Variable<int>(maxPrice.value);
    }
    if (minBeds.present) {
      map['min_beds'] = Variable<int>(minBeds.value);
    }
    if (maxBeds.present) {
      map['max_beds'] = Variable<int>(maxBeds.value);
    }
    if (centreLat.present) {
      map['centre_lat'] = Variable<double>(centreLat.value);
    }
    if (centreLon.present) {
      map['centre_lon'] = Variable<double>(centreLon.value);
    }
    if (centreLabel.present) {
      map['centre_label'] = Variable<String>(centreLabel.value);
    }
    if (radiusKm.present) {
      map['radius_km'] = Variable<double>(radiusKm.value);
    }
    if (includeUnpriced.present) {
      map['include_unpriced'] = Variable<bool>(includeUnpriced.value);
    }
    if (paused.present) {
      map['paused'] = Variable<bool>(paused.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchesCompanion(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('source: $source, ')
          ..write('path: $path, ')
          ..write('kind: $kind, ')
          ..write('keywords: $keywords, ')
          ..write('maxPrice: $maxPrice, ')
          ..write('minBeds: $minBeds, ')
          ..write('maxBeds: $maxBeds, ')
          ..write('centreLat: $centreLat, ')
          ..write('centreLon: $centreLon, ')
          ..write('centreLabel: $centreLabel, ')
          ..write('radiusKm: $radiusKm, ')
          ..write('includeUnpriced: $includeUnpriced, ')
          ..write('paused: $paused, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppraisalsTable extends Appraisals with TableInfo<$AppraisalsTable, Appraisal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppraisalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _propertyIdMeta = const VerificationMeta('propertyId');
  @override
  late final GeneratedColumn<String> propertyId = GeneratedColumn<String>(
    'property_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inputsMeta = const VerificationMeta('inputs');
  @override
  late final GeneratedColumn<String> inputs = GeneratedColumn<String>(
    'inputs',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedMeta = const VerificationMeta('updated');
  @override
  late final GeneratedColumn<String> updated = GeneratedColumn<String>(
    'updated',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, hlc, deleted, name, kind, propertyId, inputs, notes, updated];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'appraisals';
  @override
  VerificationContext validateIntegrity(Insertable<Appraisal> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(_hlcMeta, hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta));
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta, deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(_kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('property_id')) {
      context.handle(
        _propertyIdMeta,
        propertyId.isAcceptableOrUnknown(data['property_id']!, _propertyIdMeta),
      );
    }
    if (data.containsKey('inputs')) {
      context.handle(_inputsMeta, inputs.isAcceptableOrUnknown(data['inputs']!, _inputsMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('updated')) {
      context.handle(_updatedMeta, updated.isAcceptableOrUnknown(data['updated']!, _updatedMeta));
    } else if (isInserting) {
      context.missing(_updatedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Appraisal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Appraisal(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      hlc: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}hlc'])!,
      deleted: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      kind: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      propertyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}property_id'],
      ),
      inputs: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}inputs'])!,
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      updated: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}updated'])!,
    );
  }

  @override
  $AppraisalsTable createAlias(String alias) {
    return $AppraisalsTable(attachedDatabase, alias);
  }
}

class Appraisal extends DataClass implements Insertable<Appraisal> {
  final String id;
  final String hlc;
  final bool deleted;
  final String name;

  /// btl | home | dev
  final String kind;
  final String? propertyId;

  /// The inputs as JSON (see domain/appraisal.dart).
  final String inputs;
  final String notes;
  final String updated;
  const Appraisal({
    required this.id,
    required this.hlc,
    required this.deleted,
    required this.name,
    required this.kind,
    this.propertyId,
    required this.inputs,
    required this.notes,
    required this.updated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['hlc'] = Variable<String>(hlc);
    map['deleted'] = Variable<bool>(deleted);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || propertyId != null) {
      map['property_id'] = Variable<String>(propertyId);
    }
    map['inputs'] = Variable<String>(inputs);
    map['notes'] = Variable<String>(notes);
    map['updated'] = Variable<String>(updated);
    return map;
  }

  AppraisalsCompanion toCompanion(bool nullToAbsent) {
    return AppraisalsCompanion(
      id: Value(id),
      hlc: Value(hlc),
      deleted: Value(deleted),
      name: Value(name),
      kind: Value(kind),
      propertyId: propertyId == null && nullToAbsent ? const Value.absent() : Value(propertyId),
      inputs: Value(inputs),
      notes: Value(notes),
      updated: Value(updated),
    );
  }

  factory Appraisal.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Appraisal(
      id: serializer.fromJson<String>(json['id']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      propertyId: serializer.fromJson<String?>(json['propertyId']),
      inputs: serializer.fromJson<String>(json['inputs']),
      notes: serializer.fromJson<String>(json['notes']),
      updated: serializer.fromJson<String>(json['updated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hlc': serializer.toJson<String>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'propertyId': serializer.toJson<String?>(propertyId),
      'inputs': serializer.toJson<String>(inputs),
      'notes': serializer.toJson<String>(notes),
      'updated': serializer.toJson<String>(updated),
    };
  }

  Appraisal copyWith({
    String? id,
    String? hlc,
    bool? deleted,
    String? name,
    String? kind,
    Value<String?> propertyId = const Value.absent(),
    String? inputs,
    String? notes,
    String? updated,
  }) => Appraisal(
    id: id ?? this.id,
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    propertyId: propertyId.present ? propertyId.value : this.propertyId,
    inputs: inputs ?? this.inputs,
    notes: notes ?? this.notes,
    updated: updated ?? this.updated,
  );
  Appraisal copyWithCompanion(AppraisalsCompanion data) {
    return Appraisal(
      id: data.id.present ? data.id.value : this.id,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      propertyId: data.propertyId.present ? data.propertyId.value : this.propertyId,
      inputs: data.inputs.present ? data.inputs.value : this.inputs,
      notes: data.notes.present ? data.notes.value : this.notes,
      updated: data.updated.present ? data.updated.value : this.updated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Appraisal(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('propertyId: $propertyId, ')
          ..write('inputs: $inputs, ')
          ..write('notes: $notes, ')
          ..write('updated: $updated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, hlc, deleted, name, kind, propertyId, inputs, notes, updated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Appraisal &&
          other.id == this.id &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.propertyId == this.propertyId &&
          other.inputs == this.inputs &&
          other.notes == this.notes &&
          other.updated == this.updated);
}

class AppraisalsCompanion extends UpdateCompanion<Appraisal> {
  final Value<String> id;
  final Value<String> hlc;
  final Value<bool> deleted;
  final Value<String> name;
  final Value<String> kind;
  final Value<String?> propertyId;
  final Value<String> inputs;
  final Value<String> notes;
  final Value<String> updated;
  final Value<int> rowid;
  const AppraisalsCompanion({
    this.id = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.propertyId = const Value.absent(),
    this.inputs = const Value.absent(),
    this.notes = const Value.absent(),
    this.updated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppraisalsCompanion.insert({
    required String id,
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    required String name,
    required String kind,
    this.propertyId = const Value.absent(),
    this.inputs = const Value.absent(),
    this.notes = const Value.absent(),
    required String updated,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       kind = Value(kind),
       updated = Value(updated);
  static Insertable<Appraisal> custom({
    Expression<String>? id,
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? propertyId,
    Expression<String>? inputs,
    Expression<String>? notes,
    Expression<String>? updated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (propertyId != null) 'property_id': propertyId,
      if (inputs != null) 'inputs': inputs,
      if (notes != null) 'notes': notes,
      if (updated != null) 'updated': updated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppraisalsCompanion copyWith({
    Value<String>? id,
    Value<String>? hlc,
    Value<bool>? deleted,
    Value<String>? name,
    Value<String>? kind,
    Value<String?>? propertyId,
    Value<String>? inputs,
    Value<String>? notes,
    Value<String>? updated,
    Value<int>? rowid,
  }) {
    return AppraisalsCompanion(
      id: id ?? this.id,
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      propertyId: propertyId ?? this.propertyId,
      inputs: inputs ?? this.inputs,
      notes: notes ?? this.notes,
      updated: updated ?? this.updated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (propertyId.present) {
      map['property_id'] = Variable<String>(propertyId.value);
    }
    if (inputs.present) {
      map['inputs'] = Variable<String>(inputs.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (updated.present) {
      map['updated'] = Variable<String>(updated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppraisalsCompanion(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('propertyId: $propertyId, ')
          ..write('inputs: $inputs, ')
          ..write('notes: $notes, ')
          ..write('updated: $updated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TenanciesTable extends Tenancies with TableInfo<$TenanciesTable, Tenancy> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TenanciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _propertyIdMeta = const VerificationMeta('propertyId');
  @override
  late final GeneratedColumn<String> propertyId = GeneratedColumn<String>(
    'property_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _otherPartyMeta = const VerificationMeta('otherParty');
  @override
  late final GeneratedColumn<String> otherParty = GeneratedColumn<String>(
    'other_party',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _contactIdMeta = const VerificationMeta('contactId');
  @override
  late final GeneratedColumn<String> contactId = GeneratedColumn<String>(
    'contact_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startMeta = const VerificationMeta('start');
  @override
  late final GeneratedColumn<String> start = GeneratedColumn<String>(
    'start',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMeta = const VerificationMeta('end');
  @override
  late final GeneratedColumn<String> end = GeneratedColumn<String>(
    'end',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rentMeta = const VerificationMeta('rent');
  @override
  late final GeneratedColumn<int> rent = GeneratedColumn<int>(
    'rent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rentDayMeta = const VerificationMeta('rentDay');
  @override
  late final GeneratedColumn<int> rentDay = GeneratedColumn<int>(
    'rent_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _depositMeta = const VerificationMeta('deposit');
  @override
  late final GeneratedColumn<int> deposit = GeneratedColumn<int>(
    'deposit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _depositSchemeMeta = const VerificationMeta('depositScheme');
  @override
  late final GeneratedColumn<String> depositScheme = GeneratedColumn<String>(
    'deposit_scheme',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _depositRefMeta = const VerificationMeta('depositRef');
  @override
  late final GeneratedColumn<String> depositRef = GeneratedColumn<String>(
    'deposit_ref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    hlc,
    deleted,
    propertyId,
    role,
    otherParty,
    contactId,
    start,
    end,
    rent,
    rentDay,
    deposit,
    depositScheme,
    depositRef,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tenancies';
  @override
  VerificationContext validateIntegrity(Insertable<Tenancy> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(_hlcMeta, hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta));
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta, deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('property_id')) {
      context.handle(
        _propertyIdMeta,
        propertyId.isAcceptableOrUnknown(data['property_id']!, _propertyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_propertyIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(_roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('other_party')) {
      context.handle(
        _otherPartyMeta,
        otherParty.isAcceptableOrUnknown(data['other_party']!, _otherPartyMeta),
      );
    }
    if (data.containsKey('contact_id')) {
      context.handle(_contactIdMeta, contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta));
    }
    if (data.containsKey('start')) {
      context.handle(_startMeta, start.isAcceptableOrUnknown(data['start']!, _startMeta));
    } else if (isInserting) {
      context.missing(_startMeta);
    }
    if (data.containsKey('end')) {
      context.handle(_endMeta, end.isAcceptableOrUnknown(data['end']!, _endMeta));
    }
    if (data.containsKey('rent')) {
      context.handle(_rentMeta, rent.isAcceptableOrUnknown(data['rent']!, _rentMeta));
    } else if (isInserting) {
      context.missing(_rentMeta);
    }
    if (data.containsKey('rent_day')) {
      context.handle(_rentDayMeta, rentDay.isAcceptableOrUnknown(data['rent_day']!, _rentDayMeta));
    }
    if (data.containsKey('deposit')) {
      context.handle(_depositMeta, deposit.isAcceptableOrUnknown(data['deposit']!, _depositMeta));
    }
    if (data.containsKey('deposit_scheme')) {
      context.handle(
        _depositSchemeMeta,
        depositScheme.isAcceptableOrUnknown(data['deposit_scheme']!, _depositSchemeMeta),
      );
    }
    if (data.containsKey('deposit_ref')) {
      context.handle(
        _depositRefMeta,
        depositRef.isAcceptableOrUnknown(data['deposit_ref']!, _depositRefMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tenancy map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tenancy(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      hlc: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}hlc'])!,
      deleted: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      propertyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}property_id'],
      )!,
      role: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      otherParty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}other_party'],
      )!,
      contactId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}contact_id']),
      start: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}start'])!,
      end: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}end']),
      rent: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}rent'])!,
      rentDay: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}rent_day'])!,
      deposit: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}deposit'])!,
      depositScheme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deposit_scheme'],
      )!,
      depositRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deposit_ref'],
      )!,
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
    );
  }

  @override
  $TenanciesTable createAlias(String alias) {
    return $TenanciesTable(attachedDatabase, alias);
  }
}

class Tenancy extends DataClass implements Insertable<Tenancy> {
  final String id;
  final String hlc;
  final bool deleted;
  final String propertyId;

  /// landlord | tenant
  final String role;

  /// The tenant (or the landlord, when the user rents).
  final String otherParty;
  final String? contactId;
  final String start;
  final String? end;

  /// A month's rent and the day of the month it is due.
  final int rent;
  final int rentDay;
  final int deposit;
  final String depositScheme;
  final String depositRef;
  final String notes;
  const Tenancy({
    required this.id,
    required this.hlc,
    required this.deleted,
    required this.propertyId,
    required this.role,
    required this.otherParty,
    this.contactId,
    required this.start,
    this.end,
    required this.rent,
    required this.rentDay,
    required this.deposit,
    required this.depositScheme,
    required this.depositRef,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['hlc'] = Variable<String>(hlc);
    map['deleted'] = Variable<bool>(deleted);
    map['property_id'] = Variable<String>(propertyId);
    map['role'] = Variable<String>(role);
    map['other_party'] = Variable<String>(otherParty);
    if (!nullToAbsent || contactId != null) {
      map['contact_id'] = Variable<String>(contactId);
    }
    map['start'] = Variable<String>(start);
    if (!nullToAbsent || end != null) {
      map['end'] = Variable<String>(end);
    }
    map['rent'] = Variable<int>(rent);
    map['rent_day'] = Variable<int>(rentDay);
    map['deposit'] = Variable<int>(deposit);
    map['deposit_scheme'] = Variable<String>(depositScheme);
    map['deposit_ref'] = Variable<String>(depositRef);
    map['notes'] = Variable<String>(notes);
    return map;
  }

  TenanciesCompanion toCompanion(bool nullToAbsent) {
    return TenanciesCompanion(
      id: Value(id),
      hlc: Value(hlc),
      deleted: Value(deleted),
      propertyId: Value(propertyId),
      role: Value(role),
      otherParty: Value(otherParty),
      contactId: contactId == null && nullToAbsent ? const Value.absent() : Value(contactId),
      start: Value(start),
      end: end == null && nullToAbsent ? const Value.absent() : Value(end),
      rent: Value(rent),
      rentDay: Value(rentDay),
      deposit: Value(deposit),
      depositScheme: Value(depositScheme),
      depositRef: Value(depositRef),
      notes: Value(notes),
    );
  }

  factory Tenancy.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tenancy(
      id: serializer.fromJson<String>(json['id']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      propertyId: serializer.fromJson<String>(json['propertyId']),
      role: serializer.fromJson<String>(json['role']),
      otherParty: serializer.fromJson<String>(json['otherParty']),
      contactId: serializer.fromJson<String?>(json['contactId']),
      start: serializer.fromJson<String>(json['start']),
      end: serializer.fromJson<String?>(json['end']),
      rent: serializer.fromJson<int>(json['rent']),
      rentDay: serializer.fromJson<int>(json['rentDay']),
      deposit: serializer.fromJson<int>(json['deposit']),
      depositScheme: serializer.fromJson<String>(json['depositScheme']),
      depositRef: serializer.fromJson<String>(json['depositRef']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hlc': serializer.toJson<String>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'propertyId': serializer.toJson<String>(propertyId),
      'role': serializer.toJson<String>(role),
      'otherParty': serializer.toJson<String>(otherParty),
      'contactId': serializer.toJson<String?>(contactId),
      'start': serializer.toJson<String>(start),
      'end': serializer.toJson<String?>(end),
      'rent': serializer.toJson<int>(rent),
      'rentDay': serializer.toJson<int>(rentDay),
      'deposit': serializer.toJson<int>(deposit),
      'depositScheme': serializer.toJson<String>(depositScheme),
      'depositRef': serializer.toJson<String>(depositRef),
      'notes': serializer.toJson<String>(notes),
    };
  }

  Tenancy copyWith({
    String? id,
    String? hlc,
    bool? deleted,
    String? propertyId,
    String? role,
    String? otherParty,
    Value<String?> contactId = const Value.absent(),
    String? start,
    Value<String?> end = const Value.absent(),
    int? rent,
    int? rentDay,
    int? deposit,
    String? depositScheme,
    String? depositRef,
    String? notes,
  }) => Tenancy(
    id: id ?? this.id,
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    propertyId: propertyId ?? this.propertyId,
    role: role ?? this.role,
    otherParty: otherParty ?? this.otherParty,
    contactId: contactId.present ? contactId.value : this.contactId,
    start: start ?? this.start,
    end: end.present ? end.value : this.end,
    rent: rent ?? this.rent,
    rentDay: rentDay ?? this.rentDay,
    deposit: deposit ?? this.deposit,
    depositScheme: depositScheme ?? this.depositScheme,
    depositRef: depositRef ?? this.depositRef,
    notes: notes ?? this.notes,
  );
  Tenancy copyWithCompanion(TenanciesCompanion data) {
    return Tenancy(
      id: data.id.present ? data.id.value : this.id,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      propertyId: data.propertyId.present ? data.propertyId.value : this.propertyId,
      role: data.role.present ? data.role.value : this.role,
      otherParty: data.otherParty.present ? data.otherParty.value : this.otherParty,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      start: data.start.present ? data.start.value : this.start,
      end: data.end.present ? data.end.value : this.end,
      rent: data.rent.present ? data.rent.value : this.rent,
      rentDay: data.rentDay.present ? data.rentDay.value : this.rentDay,
      deposit: data.deposit.present ? data.deposit.value : this.deposit,
      depositScheme: data.depositScheme.present ? data.depositScheme.value : this.depositScheme,
      depositRef: data.depositRef.present ? data.depositRef.value : this.depositRef,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tenancy(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('propertyId: $propertyId, ')
          ..write('role: $role, ')
          ..write('otherParty: $otherParty, ')
          ..write('contactId: $contactId, ')
          ..write('start: $start, ')
          ..write('end: $end, ')
          ..write('rent: $rent, ')
          ..write('rentDay: $rentDay, ')
          ..write('deposit: $deposit, ')
          ..write('depositScheme: $depositScheme, ')
          ..write('depositRef: $depositRef, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    hlc,
    deleted,
    propertyId,
    role,
    otherParty,
    contactId,
    start,
    end,
    rent,
    rentDay,
    deposit,
    depositScheme,
    depositRef,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tenancy &&
          other.id == this.id &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.propertyId == this.propertyId &&
          other.role == this.role &&
          other.otherParty == this.otherParty &&
          other.contactId == this.contactId &&
          other.start == this.start &&
          other.end == this.end &&
          other.rent == this.rent &&
          other.rentDay == this.rentDay &&
          other.deposit == this.deposit &&
          other.depositScheme == this.depositScheme &&
          other.depositRef == this.depositRef &&
          other.notes == this.notes);
}

class TenanciesCompanion extends UpdateCompanion<Tenancy> {
  final Value<String> id;
  final Value<String> hlc;
  final Value<bool> deleted;
  final Value<String> propertyId;
  final Value<String> role;
  final Value<String> otherParty;
  final Value<String?> contactId;
  final Value<String> start;
  final Value<String?> end;
  final Value<int> rent;
  final Value<int> rentDay;
  final Value<int> deposit;
  final Value<String> depositScheme;
  final Value<String> depositRef;
  final Value<String> notes;
  final Value<int> rowid;
  const TenanciesCompanion({
    this.id = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.propertyId = const Value.absent(),
    this.role = const Value.absent(),
    this.otherParty = const Value.absent(),
    this.contactId = const Value.absent(),
    this.start = const Value.absent(),
    this.end = const Value.absent(),
    this.rent = const Value.absent(),
    this.rentDay = const Value.absent(),
    this.deposit = const Value.absent(),
    this.depositScheme = const Value.absent(),
    this.depositRef = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TenanciesCompanion.insert({
    required String id,
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    required String propertyId,
    required String role,
    this.otherParty = const Value.absent(),
    this.contactId = const Value.absent(),
    required String start,
    this.end = const Value.absent(),
    required int rent,
    this.rentDay = const Value.absent(),
    this.deposit = const Value.absent(),
    this.depositScheme = const Value.absent(),
    this.depositRef = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       propertyId = Value(propertyId),
       role = Value(role),
       start = Value(start),
       rent = Value(rent);
  static Insertable<Tenancy> custom({
    Expression<String>? id,
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<String>? propertyId,
    Expression<String>? role,
    Expression<String>? otherParty,
    Expression<String>? contactId,
    Expression<String>? start,
    Expression<String>? end,
    Expression<int>? rent,
    Expression<int>? rentDay,
    Expression<int>? deposit,
    Expression<String>? depositScheme,
    Expression<String>? depositRef,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (propertyId != null) 'property_id': propertyId,
      if (role != null) 'role': role,
      if (otherParty != null) 'other_party': otherParty,
      if (contactId != null) 'contact_id': contactId,
      if (start != null) 'start': start,
      if (end != null) 'end': end,
      if (rent != null) 'rent': rent,
      if (rentDay != null) 'rent_day': rentDay,
      if (deposit != null) 'deposit': deposit,
      if (depositScheme != null) 'deposit_scheme': depositScheme,
      if (depositRef != null) 'deposit_ref': depositRef,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TenanciesCompanion copyWith({
    Value<String>? id,
    Value<String>? hlc,
    Value<bool>? deleted,
    Value<String>? propertyId,
    Value<String>? role,
    Value<String>? otherParty,
    Value<String?>? contactId,
    Value<String>? start,
    Value<String?>? end,
    Value<int>? rent,
    Value<int>? rentDay,
    Value<int>? deposit,
    Value<String>? depositScheme,
    Value<String>? depositRef,
    Value<String>? notes,
    Value<int>? rowid,
  }) {
    return TenanciesCompanion(
      id: id ?? this.id,
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      propertyId: propertyId ?? this.propertyId,
      role: role ?? this.role,
      otherParty: otherParty ?? this.otherParty,
      contactId: contactId ?? this.contactId,
      start: start ?? this.start,
      end: end ?? this.end,
      rent: rent ?? this.rent,
      rentDay: rentDay ?? this.rentDay,
      deposit: deposit ?? this.deposit,
      depositScheme: depositScheme ?? this.depositScheme,
      depositRef: depositRef ?? this.depositRef,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (propertyId.present) {
      map['property_id'] = Variable<String>(propertyId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (otherParty.present) {
      map['other_party'] = Variable<String>(otherParty.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<String>(contactId.value);
    }
    if (start.present) {
      map['start'] = Variable<String>(start.value);
    }
    if (end.present) {
      map['end'] = Variable<String>(end.value);
    }
    if (rent.present) {
      map['rent'] = Variable<int>(rent.value);
    }
    if (rentDay.present) {
      map['rent_day'] = Variable<int>(rentDay.value);
    }
    if (deposit.present) {
      map['deposit'] = Variable<int>(deposit.value);
    }
    if (depositScheme.present) {
      map['deposit_scheme'] = Variable<String>(depositScheme.value);
    }
    if (depositRef.present) {
      map['deposit_ref'] = Variable<String>(depositRef.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TenanciesCompanion(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('propertyId: $propertyId, ')
          ..write('role: $role, ')
          ..write('otherParty: $otherParty, ')
          ..write('contactId: $contactId, ')
          ..write('start: $start, ')
          ..write('end: $end, ')
          ..write('rent: $rent, ')
          ..write('rentDay: $rentDay, ')
          ..write('deposit: $deposit, ')
          ..write('depositScheme: $depositScheme, ')
          ..write('depositRef: $depositRef, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RentPaymentsTable extends RentPayments with TableInfo<$RentPaymentsTable, RentPayment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RentPaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _tenancyIdMeta = const VerificationMeta('tenancyId');
  @override
  late final GeneratedColumn<String> tenancyId = GeneratedColumn<String>(
    'tenancy_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [id, hlc, deleted, tenancyId, date, amount, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rent_payments';
  @override
  VerificationContext validateIntegrity(Insertable<RentPayment> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(_hlcMeta, hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta));
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta, deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('tenancy_id')) {
      context.handle(_tenancyIdMeta, tenancyId.isAcceptableOrUnknown(data['tenancy_id']!, _tenancyIdMeta));
    } else if (isInserting) {
      context.missing(_tenancyIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(_dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta, amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('note')) {
      context.handle(_noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RentPayment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RentPayment(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      hlc: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}hlc'])!,
      deleted: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      tenancyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenancy_id'],
      )!,
      date: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      amount: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      note: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}note'])!,
    );
  }

  @override
  $RentPaymentsTable createAlias(String alias) {
    return $RentPaymentsTable(attachedDatabase, alias);
  }
}

class RentPayment extends DataClass implements Insertable<RentPayment> {
  final String id;
  final String hlc;
  final bool deleted;
  final String tenancyId;
  final String date;
  final int amount;
  final String note;
  const RentPayment({
    required this.id,
    required this.hlc,
    required this.deleted,
    required this.tenancyId,
    required this.date,
    required this.amount,
    required this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['hlc'] = Variable<String>(hlc);
    map['deleted'] = Variable<bool>(deleted);
    map['tenancy_id'] = Variable<String>(tenancyId);
    map['date'] = Variable<String>(date);
    map['amount'] = Variable<int>(amount);
    map['note'] = Variable<String>(note);
    return map;
  }

  RentPaymentsCompanion toCompanion(bool nullToAbsent) {
    return RentPaymentsCompanion(
      id: Value(id),
      hlc: Value(hlc),
      deleted: Value(deleted),
      tenancyId: Value(tenancyId),
      date: Value(date),
      amount: Value(amount),
      note: Value(note),
    );
  }

  factory RentPayment.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RentPayment(
      id: serializer.fromJson<String>(json['id']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      tenancyId: serializer.fromJson<String>(json['tenancyId']),
      date: serializer.fromJson<String>(json['date']),
      amount: serializer.fromJson<int>(json['amount']),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hlc': serializer.toJson<String>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'tenancyId': serializer.toJson<String>(tenancyId),
      'date': serializer.toJson<String>(date),
      'amount': serializer.toJson<int>(amount),
      'note': serializer.toJson<String>(note),
    };
  }

  RentPayment copyWith({
    String? id,
    String? hlc,
    bool? deleted,
    String? tenancyId,
    String? date,
    int? amount,
    String? note,
  }) => RentPayment(
    id: id ?? this.id,
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    tenancyId: tenancyId ?? this.tenancyId,
    date: date ?? this.date,
    amount: amount ?? this.amount,
    note: note ?? this.note,
  );
  RentPayment copyWithCompanion(RentPaymentsCompanion data) {
    return RentPayment(
      id: data.id.present ? data.id.value : this.id,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      tenancyId: data.tenancyId.present ? data.tenancyId.value : this.tenancyId,
      date: data.date.present ? data.date.value : this.date,
      amount: data.amount.present ? data.amount.value : this.amount,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RentPayment(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('tenancyId: $tenancyId, ')
          ..write('date: $date, ')
          ..write('amount: $amount, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, hlc, deleted, tenancyId, date, amount, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RentPayment &&
          other.id == this.id &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.tenancyId == this.tenancyId &&
          other.date == this.date &&
          other.amount == this.amount &&
          other.note == this.note);
}

class RentPaymentsCompanion extends UpdateCompanion<RentPayment> {
  final Value<String> id;
  final Value<String> hlc;
  final Value<bool> deleted;
  final Value<String> tenancyId;
  final Value<String> date;
  final Value<int> amount;
  final Value<String> note;
  final Value<int> rowid;
  const RentPaymentsCompanion({
    this.id = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.tenancyId = const Value.absent(),
    this.date = const Value.absent(),
    this.amount = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RentPaymentsCompanion.insert({
    required String id,
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    required String tenancyId,
    required String date,
    required int amount,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenancyId = Value(tenancyId),
       date = Value(date),
       amount = Value(amount);
  static Insertable<RentPayment> custom({
    Expression<String>? id,
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<String>? tenancyId,
    Expression<String>? date,
    Expression<int>? amount,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (tenancyId != null) 'tenancy_id': tenancyId,
      if (date != null) 'date': date,
      if (amount != null) 'amount': amount,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RentPaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? hlc,
    Value<bool>? deleted,
    Value<String>? tenancyId,
    Value<String>? date,
    Value<int>? amount,
    Value<String>? note,
    Value<int>? rowid,
  }) {
    return RentPaymentsCompanion(
      id: id ?? this.id,
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      tenancyId: tenancyId ?? this.tenancyId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (tenancyId.present) {
      map['tenancy_id'] = Variable<String>(tenancyId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RentPaymentsCompanion(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('tenancyId: $tenancyId, ')
          ..write('date: $date, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ComplianceItemsTable extends ComplianceItems with TableInfo<$ComplianceItemsTable, ComplianceItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ComplianceItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _propertyIdMeta = const VerificationMeta('propertyId');
  @override
  late final GeneratedColumn<String> propertyId = GeneratedColumn<String>(
    'property_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueMeta = const VerificationMeta('due');
  @override
  late final GeneratedColumn<String> due = GeneratedColumn<String>(
    'due',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<String> done = GeneratedColumn<String>(
    'done',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [id, hlc, deleted, propertyId, kind, due, done, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'compliance_items';
  @override
  VerificationContext validateIntegrity(Insertable<ComplianceItem> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(_hlcMeta, hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta));
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta, deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('property_id')) {
      context.handle(
        _propertyIdMeta,
        propertyId.isAcceptableOrUnknown(data['property_id']!, _propertyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_propertyIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(_kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('due')) {
      context.handle(_dueMeta, due.isAcceptableOrUnknown(data['due']!, _dueMeta));
    } else if (isInserting) {
      context.missing(_dueMeta);
    }
    if (data.containsKey('done')) {
      context.handle(_doneMeta, done.isAcceptableOrUnknown(data['done']!, _doneMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ComplianceItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ComplianceItem(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      hlc: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}hlc'])!,
      deleted: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      propertyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}property_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      due: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}due'])!,
      done: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}done']),
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
    );
  }

  @override
  $ComplianceItemsTable createAlias(String alias) {
    return $ComplianceItemsTable(attachedDatabase, alias);
  }
}

class ComplianceItem extends DataClass implements Insertable<ComplianceItem> {
  final String id;
  final String hlc;
  final bool deleted;
  final String propertyId;
  final String kind;
  final String due;
  final String? done;
  final String notes;
  const ComplianceItem({
    required this.id,
    required this.hlc,
    required this.deleted,
    required this.propertyId,
    required this.kind,
    required this.due,
    this.done,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['hlc'] = Variable<String>(hlc);
    map['deleted'] = Variable<bool>(deleted);
    map['property_id'] = Variable<String>(propertyId);
    map['kind'] = Variable<String>(kind);
    map['due'] = Variable<String>(due);
    if (!nullToAbsent || done != null) {
      map['done'] = Variable<String>(done);
    }
    map['notes'] = Variable<String>(notes);
    return map;
  }

  ComplianceItemsCompanion toCompanion(bool nullToAbsent) {
    return ComplianceItemsCompanion(
      id: Value(id),
      hlc: Value(hlc),
      deleted: Value(deleted),
      propertyId: Value(propertyId),
      kind: Value(kind),
      due: Value(due),
      done: done == null && nullToAbsent ? const Value.absent() : Value(done),
      notes: Value(notes),
    );
  }

  factory ComplianceItem.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ComplianceItem(
      id: serializer.fromJson<String>(json['id']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      propertyId: serializer.fromJson<String>(json['propertyId']),
      kind: serializer.fromJson<String>(json['kind']),
      due: serializer.fromJson<String>(json['due']),
      done: serializer.fromJson<String?>(json['done']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hlc': serializer.toJson<String>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'propertyId': serializer.toJson<String>(propertyId),
      'kind': serializer.toJson<String>(kind),
      'due': serializer.toJson<String>(due),
      'done': serializer.toJson<String?>(done),
      'notes': serializer.toJson<String>(notes),
    };
  }

  ComplianceItem copyWith({
    String? id,
    String? hlc,
    bool? deleted,
    String? propertyId,
    String? kind,
    String? due,
    Value<String?> done = const Value.absent(),
    String? notes,
  }) => ComplianceItem(
    id: id ?? this.id,
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    propertyId: propertyId ?? this.propertyId,
    kind: kind ?? this.kind,
    due: due ?? this.due,
    done: done.present ? done.value : this.done,
    notes: notes ?? this.notes,
  );
  ComplianceItem copyWithCompanion(ComplianceItemsCompanion data) {
    return ComplianceItem(
      id: data.id.present ? data.id.value : this.id,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      propertyId: data.propertyId.present ? data.propertyId.value : this.propertyId,
      kind: data.kind.present ? data.kind.value : this.kind,
      due: data.due.present ? data.due.value : this.due,
      done: data.done.present ? data.done.value : this.done,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ComplianceItem(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('propertyId: $propertyId, ')
          ..write('kind: $kind, ')
          ..write('due: $due, ')
          ..write('done: $done, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, hlc, deleted, propertyId, kind, due, done, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ComplianceItem &&
          other.id == this.id &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.propertyId == this.propertyId &&
          other.kind == this.kind &&
          other.due == this.due &&
          other.done == this.done &&
          other.notes == this.notes);
}

class ComplianceItemsCompanion extends UpdateCompanion<ComplianceItem> {
  final Value<String> id;
  final Value<String> hlc;
  final Value<bool> deleted;
  final Value<String> propertyId;
  final Value<String> kind;
  final Value<String> due;
  final Value<String?> done;
  final Value<String> notes;
  final Value<int> rowid;
  const ComplianceItemsCompanion({
    this.id = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.propertyId = const Value.absent(),
    this.kind = const Value.absent(),
    this.due = const Value.absent(),
    this.done = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ComplianceItemsCompanion.insert({
    required String id,
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    required String propertyId,
    required String kind,
    required String due,
    this.done = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       propertyId = Value(propertyId),
       kind = Value(kind),
       due = Value(due);
  static Insertable<ComplianceItem> custom({
    Expression<String>? id,
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<String>? propertyId,
    Expression<String>? kind,
    Expression<String>? due,
    Expression<String>? done,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (propertyId != null) 'property_id': propertyId,
      if (kind != null) 'kind': kind,
      if (due != null) 'due': due,
      if (done != null) 'done': done,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ComplianceItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? hlc,
    Value<bool>? deleted,
    Value<String>? propertyId,
    Value<String>? kind,
    Value<String>? due,
    Value<String?>? done,
    Value<String>? notes,
    Value<int>? rowid,
  }) {
    return ComplianceItemsCompanion(
      id: id ?? this.id,
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      propertyId: propertyId ?? this.propertyId,
      kind: kind ?? this.kind,
      due: due ?? this.due,
      done: done ?? this.done,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (propertyId.present) {
      map['property_id'] = Variable<String>(propertyId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (due.present) {
      map['due'] = Variable<String>(due.value);
    }
    if (done.present) {
      map['done'] = Variable<String>(done.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ComplianceItemsCompanion(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('propertyId: $propertyId, ')
          ..write('kind: $kind, ')
          ..write('due: $due, ')
          ..write('done: $done, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AreasTable extends Areas with TableInfo<$AreasTable, Area> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AreasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _postcodeMeta = const VerificationMeta('postcode');
  @override
  late final GeneratedColumn<String> postcode = GeneratedColumn<String>(
    'postcode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _reportMeta = const VerificationMeta('report');
  @override
  late final GeneratedColumn<String> report = GeneratedColumn<String>(
    'report',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _fetchedMeta = const VerificationMeta('fetched');
  @override
  late final GeneratedColumn<String> fetched = GeneratedColumn<String>(
    'fetched',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [id, hlc, deleted, postcode, label, report, fetched, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'areas';
  @override
  VerificationContext validateIntegrity(Insertable<Area> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(_hlcMeta, hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta));
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta, deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('postcode')) {
      context.handle(_postcodeMeta, postcode.isAcceptableOrUnknown(data['postcode']!, _postcodeMeta));
    } else if (isInserting) {
      context.missing(_postcodeMeta);
    }
    if (data.containsKey('label')) {
      context.handle(_labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    }
    if (data.containsKey('report')) {
      context.handle(_reportMeta, report.isAcceptableOrUnknown(data['report']!, _reportMeta));
    }
    if (data.containsKey('fetched')) {
      context.handle(_fetchedMeta, fetched.isAcceptableOrUnknown(data['fetched']!, _fetchedMeta));
    } else if (isInserting) {
      context.missing(_fetchedMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Area map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Area(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      hlc: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}hlc'])!,
      deleted: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      postcode: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}postcode'])!,
      label: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      report: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}report'])!,
      fetched: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}fetched'])!,
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
    );
  }

  @override
  $AreasTable createAlias(String alias) {
    return $AreasTable(attachedDatabase, alias);
  }
}

class Area extends DataClass implements Insertable<Area> {
  final String id;
  final String hlc;
  final bool deleted;
  final String postcode;
  final String label;

  /// AreaReport as JSON (see domain/research.dart).
  final String report;
  final String fetched;
  final String notes;
  const Area({
    required this.id,
    required this.hlc,
    required this.deleted,
    required this.postcode,
    required this.label,
    required this.report,
    required this.fetched,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['hlc'] = Variable<String>(hlc);
    map['deleted'] = Variable<bool>(deleted);
    map['postcode'] = Variable<String>(postcode);
    map['label'] = Variable<String>(label);
    map['report'] = Variable<String>(report);
    map['fetched'] = Variable<String>(fetched);
    map['notes'] = Variable<String>(notes);
    return map;
  }

  AreasCompanion toCompanion(bool nullToAbsent) {
    return AreasCompanion(
      id: Value(id),
      hlc: Value(hlc),
      deleted: Value(deleted),
      postcode: Value(postcode),
      label: Value(label),
      report: Value(report),
      fetched: Value(fetched),
      notes: Value(notes),
    );
  }

  factory Area.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Area(
      id: serializer.fromJson<String>(json['id']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      postcode: serializer.fromJson<String>(json['postcode']),
      label: serializer.fromJson<String>(json['label']),
      report: serializer.fromJson<String>(json['report']),
      fetched: serializer.fromJson<String>(json['fetched']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hlc': serializer.toJson<String>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'postcode': serializer.toJson<String>(postcode),
      'label': serializer.toJson<String>(label),
      'report': serializer.toJson<String>(report),
      'fetched': serializer.toJson<String>(fetched),
      'notes': serializer.toJson<String>(notes),
    };
  }

  Area copyWith({
    String? id,
    String? hlc,
    bool? deleted,
    String? postcode,
    String? label,
    String? report,
    String? fetched,
    String? notes,
  }) => Area(
    id: id ?? this.id,
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    postcode: postcode ?? this.postcode,
    label: label ?? this.label,
    report: report ?? this.report,
    fetched: fetched ?? this.fetched,
    notes: notes ?? this.notes,
  );
  Area copyWithCompanion(AreasCompanion data) {
    return Area(
      id: data.id.present ? data.id.value : this.id,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      postcode: data.postcode.present ? data.postcode.value : this.postcode,
      label: data.label.present ? data.label.value : this.label,
      report: data.report.present ? data.report.value : this.report,
      fetched: data.fetched.present ? data.fetched.value : this.fetched,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Area(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('postcode: $postcode, ')
          ..write('label: $label, ')
          ..write('report: $report, ')
          ..write('fetched: $fetched, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, hlc, deleted, postcode, label, report, fetched, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Area &&
          other.id == this.id &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.postcode == this.postcode &&
          other.label == this.label &&
          other.report == this.report &&
          other.fetched == this.fetched &&
          other.notes == this.notes);
}

class AreasCompanion extends UpdateCompanion<Area> {
  final Value<String> id;
  final Value<String> hlc;
  final Value<bool> deleted;
  final Value<String> postcode;
  final Value<String> label;
  final Value<String> report;
  final Value<String> fetched;
  final Value<String> notes;
  final Value<int> rowid;
  const AreasCompanion({
    this.id = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.postcode = const Value.absent(),
    this.label = const Value.absent(),
    this.report = const Value.absent(),
    this.fetched = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AreasCompanion.insert({
    required String id,
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    required String postcode,
    this.label = const Value.absent(),
    this.report = const Value.absent(),
    required String fetched,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       postcode = Value(postcode),
       fetched = Value(fetched);
  static Insertable<Area> custom({
    Expression<String>? id,
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<String>? postcode,
    Expression<String>? label,
    Expression<String>? report,
    Expression<String>? fetched,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (postcode != null) 'postcode': postcode,
      if (label != null) 'label': label,
      if (report != null) 'report': report,
      if (fetched != null) 'fetched': fetched,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AreasCompanion copyWith({
    Value<String>? id,
    Value<String>? hlc,
    Value<bool>? deleted,
    Value<String>? postcode,
    Value<String>? label,
    Value<String>? report,
    Value<String>? fetched,
    Value<String>? notes,
    Value<int>? rowid,
  }) {
    return AreasCompanion(
      id: id ?? this.id,
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      postcode: postcode ?? this.postcode,
      label: label ?? this.label,
      report: report ?? this.report,
      fetched: fetched ?? this.fetched,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (postcode.present) {
      map['postcode'] = Variable<String>(postcode.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (report.present) {
      map['report'] = Variable<String>(report.value);
    }
    if (fetched.present) {
      map['fetched'] = Variable<String>(fetched.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AreasCompanion(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('postcode: $postcode, ')
          ..write('label: $label, ')
          ..write('report: $report, ')
          ..write('fetched: $fetched, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ResearchesTable extends Researches with TableInfo<$ResearchesTable, ResearchJob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResearchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('rent'),
  );
  static const VerificationMeta _criteriaMeta = const VerificationMeta('criteria');
  @override
  late final GeneratedColumn<String> criteria = GeneratedColumn<String>(
    'criteria',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta('archived');
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("archived" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdMeta = const VerificationMeta('created');
  @override
  late final GeneratedColumn<String> created = GeneratedColumn<String>(
    'created',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, hlc, deleted, name, kind, criteria, notes, archived, created];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'property_researches';
  @override
  VerificationContext validateIntegrity(Insertable<ResearchJob> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(_hlcMeta, hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta));
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta, deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(_kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    }
    if (data.containsKey('criteria')) {
      context.handle(_criteriaMeta, criteria.isAcceptableOrUnknown(data['criteria']!, _criteriaMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('archived')) {
      context.handle(_archivedMeta, archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta));
    }
    if (data.containsKey('created')) {
      context.handle(_createdMeta, created.isAcceptableOrUnknown(data['created']!, _createdMeta));
    } else if (isInserting) {
      context.missing(_createdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ResearchJob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResearchJob(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      hlc: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}hlc'])!,
      deleted: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      kind: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      criteria: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}criteria'])!,
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      archived: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}archived'])!,
      created: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}created'])!,
    );
  }

  @override
  $ResearchesTable createAlias(String alias) {
    return $ResearchesTable(attachedDatabase, alias);
  }
}

class ResearchJob extends DataClass implements Insertable<ResearchJob> {
  final String id;
  final String hlc;
  final bool deleted;
  final String name;

  /// rent, buy, invest or area.
  final String kind;

  /// ResearchCriteria as JSON (see domain/catalog.dart): what fits.
  final String criteria;
  final String notes;
  final bool archived;
  final String created;
  const ResearchJob({
    required this.id,
    required this.hlc,
    required this.deleted,
    required this.name,
    required this.kind,
    required this.criteria,
    required this.notes,
    required this.archived,
    required this.created,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['hlc'] = Variable<String>(hlc);
    map['deleted'] = Variable<bool>(deleted);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['criteria'] = Variable<String>(criteria);
    map['notes'] = Variable<String>(notes);
    map['archived'] = Variable<bool>(archived);
    map['created'] = Variable<String>(created);
    return map;
  }

  ResearchesCompanion toCompanion(bool nullToAbsent) {
    return ResearchesCompanion(
      id: Value(id),
      hlc: Value(hlc),
      deleted: Value(deleted),
      name: Value(name),
      kind: Value(kind),
      criteria: Value(criteria),
      notes: Value(notes),
      archived: Value(archived),
      created: Value(created),
    );
  }

  factory ResearchJob.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResearchJob(
      id: serializer.fromJson<String>(json['id']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      criteria: serializer.fromJson<String>(json['criteria']),
      notes: serializer.fromJson<String>(json['notes']),
      archived: serializer.fromJson<bool>(json['archived']),
      created: serializer.fromJson<String>(json['created']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hlc': serializer.toJson<String>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'criteria': serializer.toJson<String>(criteria),
      'notes': serializer.toJson<String>(notes),
      'archived': serializer.toJson<bool>(archived),
      'created': serializer.toJson<String>(created),
    };
  }

  ResearchJob copyWith({
    String? id,
    String? hlc,
    bool? deleted,
    String? name,
    String? kind,
    String? criteria,
    String? notes,
    bool? archived,
    String? created,
  }) => ResearchJob(
    id: id ?? this.id,
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    criteria: criteria ?? this.criteria,
    notes: notes ?? this.notes,
    archived: archived ?? this.archived,
    created: created ?? this.created,
  );
  ResearchJob copyWithCompanion(ResearchesCompanion data) {
    return ResearchJob(
      id: data.id.present ? data.id.value : this.id,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      criteria: data.criteria.present ? data.criteria.value : this.criteria,
      notes: data.notes.present ? data.notes.value : this.notes,
      archived: data.archived.present ? data.archived.value : this.archived,
      created: data.created.present ? data.created.value : this.created,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResearchJob(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('criteria: $criteria, ')
          ..write('notes: $notes, ')
          ..write('archived: $archived, ')
          ..write('created: $created')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, hlc, deleted, name, kind, criteria, notes, archived, created);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResearchJob &&
          other.id == this.id &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.criteria == this.criteria &&
          other.notes == this.notes &&
          other.archived == this.archived &&
          other.created == this.created);
}

class ResearchesCompanion extends UpdateCompanion<ResearchJob> {
  final Value<String> id;
  final Value<String> hlc;
  final Value<bool> deleted;
  final Value<String> name;
  final Value<String> kind;
  final Value<String> criteria;
  final Value<String> notes;
  final Value<bool> archived;
  final Value<String> created;
  final Value<int> rowid;
  const ResearchesCompanion({
    this.id = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.criteria = const Value.absent(),
    this.notes = const Value.absent(),
    this.archived = const Value.absent(),
    this.created = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ResearchesCompanion.insert({
    required String id,
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    required String name,
    this.kind = const Value.absent(),
    this.criteria = const Value.absent(),
    this.notes = const Value.absent(),
    this.archived = const Value.absent(),
    required String created,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       created = Value(created);
  static Insertable<ResearchJob> custom({
    Expression<String>? id,
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? criteria,
    Expression<String>? notes,
    Expression<bool>? archived,
    Expression<String>? created,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (criteria != null) 'criteria': criteria,
      if (notes != null) 'notes': notes,
      if (archived != null) 'archived': archived,
      if (created != null) 'created': created,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ResearchesCompanion copyWith({
    Value<String>? id,
    Value<String>? hlc,
    Value<bool>? deleted,
    Value<String>? name,
    Value<String>? kind,
    Value<String>? criteria,
    Value<String>? notes,
    Value<bool>? archived,
    Value<String>? created,
    Value<int>? rowid,
  }) {
    return ResearchesCompanion(
      id: id ?? this.id,
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      criteria: criteria ?? this.criteria,
      notes: notes ?? this.notes,
      archived: archived ?? this.archived,
      created: created ?? this.created,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (criteria.present) {
      map['criteria'] = Variable<String>(criteria.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (created.present) {
      map['created'] = Variable<String>(created.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResearchesCompanion(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('criteria: $criteria, ')
          ..write('notes: $notes, ')
          ..write('archived: $archived, ')
          ..write('created: $created, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogItemsTable extends CatalogItems with TableInfo<$CatalogItemsTable, CatalogItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _researchIdMeta = const VerificationMeta('researchId');
  @override
  late final GeneratedColumn<String> researchId = GeneratedColumn<String>(
    'research_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _propertyIdMeta = const VerificationMeta('propertyId');
  @override
  late final GeneratedColumn<String> propertyId = GeneratedColumn<String>(
    'property_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _postcodeMeta = const VerificationMeta('postcode');
  @override
  late final GeneratedColumn<String> postcode = GeneratedColumn<String>(
    'postcode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<int> price = GeneratedColumn<int>(
    'price',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bedsMeta = const VerificationMeta('beds');
  @override
  late final GeneratedColumn<int> beds = GeneratedColumn<int>(
    'beds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bathsMeta = const VerificationMeta('baths');
  @override
  late final GeneratedColumn<int> baths = GeneratedColumn<int>(
    'baths',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fieldsMeta = const VerificationMeta('fields');
  @override
  late final GeneratedColumn<String> fields = GeneratedColumn<String>(
    'fields',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _imageHashMeta = const VerificationMeta('imageHash');
  @override
  late final GeneratedColumn<String> imageHash = GeneratedColumn<String>(
    'image_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _capturedMeta = const VerificationMeta('captured');
  @override
  late final GeneratedColumn<String> captured = GeneratedColumn<String>(
    'captured',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    hlc,
    deleted,
    researchId,
    propertyId,
    kind,
    title,
    url,
    source,
    sourceId,
    address,
    postcode,
    price,
    beds,
    baths,
    fields,
    body,
    imageHash,
    notes,
    captured,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'property_catalog_items';
  @override
  VerificationContext validateIntegrity(Insertable<CatalogItem> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(_hlcMeta, hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta));
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta, deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('research_id')) {
      context.handle(
        _researchIdMeta,
        researchId.isAcceptableOrUnknown(data['research_id']!, _researchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_researchIdMeta);
    }
    if (data.containsKey('property_id')) {
      context.handle(
        _propertyIdMeta,
        propertyId.isAcceptableOrUnknown(data['property_id']!, _propertyIdMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(_kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('url')) {
      context.handle(_urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta, source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta, sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta, address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('postcode')) {
      context.handle(_postcodeMeta, postcode.isAcceptableOrUnknown(data['postcode']!, _postcodeMeta));
    }
    if (data.containsKey('price')) {
      context.handle(_priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    }
    if (data.containsKey('beds')) {
      context.handle(_bedsMeta, beds.isAcceptableOrUnknown(data['beds']!, _bedsMeta));
    }
    if (data.containsKey('baths')) {
      context.handle(_bathsMeta, baths.isAcceptableOrUnknown(data['baths']!, _bathsMeta));
    }
    if (data.containsKey('fields')) {
      context.handle(_fieldsMeta, fields.isAcceptableOrUnknown(data['fields']!, _fieldsMeta));
    }
    if (data.containsKey('body')) {
      context.handle(_bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    }
    if (data.containsKey('image_hash')) {
      context.handle(_imageHashMeta, imageHash.isAcceptableOrUnknown(data['image_hash']!, _imageHashMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('captured')) {
      context.handle(_capturedMeta, captured.isAcceptableOrUnknown(data['captured']!, _capturedMeta));
    } else if (isInserting) {
      context.missing(_capturedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogItem(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      hlc: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}hlc'])!,
      deleted: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      researchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}research_id'],
      )!,
      propertyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}property_id'],
      ),
      kind: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      url: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      source: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      sourceId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}source_id']),
      address: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      postcode: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}postcode'])!,
      price: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}price']),
      beds: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}beds']),
      baths: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}baths']),
      fields: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}fields'])!,
      body: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      imageHash: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}image_hash']),
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      captured: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}captured'])!,
    );
  }

  @override
  $CatalogItemsTable createAlias(String alias) {
    return $CatalogItemsTable(attachedDatabase, alias);
  }
}

class CatalogItem extends DataClass implements Insertable<CatalogItem> {
  final String id;
  final String hlc;
  final bool deleted;
  final String researchId;

  /// The Hunt home it became or was linked to.
  final String? propertyId;

  /// page, photo, document, link or note.
  final String kind;
  final String title;
  final String url;

  /// The site and its advert number, when known.
  final String source;
  final String? sourceId;
  final String address;
  final String postcode;
  final int? price;
  final int? beds;
  final int? baths;

  /// ItemFields extras as JSON: price period, council tax band, EPC, agent,
  /// phone, available date, status, other links and the price history.
  final String fields;

  /// The text the details were read from (page text or OCR).
  final String body;

  /// Difference hash of the main picture, for spotting the same home.
  final String? imageHash;
  final String notes;
  final String captured;
  const CatalogItem({
    required this.id,
    required this.hlc,
    required this.deleted,
    required this.researchId,
    this.propertyId,
    required this.kind,
    required this.title,
    required this.url,
    required this.source,
    this.sourceId,
    required this.address,
    required this.postcode,
    this.price,
    this.beds,
    this.baths,
    required this.fields,
    required this.body,
    this.imageHash,
    required this.notes,
    required this.captured,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['hlc'] = Variable<String>(hlc);
    map['deleted'] = Variable<bool>(deleted);
    map['research_id'] = Variable<String>(researchId);
    if (!nullToAbsent || propertyId != null) {
      map['property_id'] = Variable<String>(propertyId);
    }
    map['kind'] = Variable<String>(kind);
    map['title'] = Variable<String>(title);
    map['url'] = Variable<String>(url);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    map['address'] = Variable<String>(address);
    map['postcode'] = Variable<String>(postcode);
    if (!nullToAbsent || price != null) {
      map['price'] = Variable<int>(price);
    }
    if (!nullToAbsent || beds != null) {
      map['beds'] = Variable<int>(beds);
    }
    if (!nullToAbsent || baths != null) {
      map['baths'] = Variable<int>(baths);
    }
    map['fields'] = Variable<String>(fields);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || imageHash != null) {
      map['image_hash'] = Variable<String>(imageHash);
    }
    map['notes'] = Variable<String>(notes);
    map['captured'] = Variable<String>(captured);
    return map;
  }

  CatalogItemsCompanion toCompanion(bool nullToAbsent) {
    return CatalogItemsCompanion(
      id: Value(id),
      hlc: Value(hlc),
      deleted: Value(deleted),
      researchId: Value(researchId),
      propertyId: propertyId == null && nullToAbsent ? const Value.absent() : Value(propertyId),
      kind: Value(kind),
      title: Value(title),
      url: Value(url),
      source: Value(source),
      sourceId: sourceId == null && nullToAbsent ? const Value.absent() : Value(sourceId),
      address: Value(address),
      postcode: Value(postcode),
      price: price == null && nullToAbsent ? const Value.absent() : Value(price),
      beds: beds == null && nullToAbsent ? const Value.absent() : Value(beds),
      baths: baths == null && nullToAbsent ? const Value.absent() : Value(baths),
      fields: Value(fields),
      body: Value(body),
      imageHash: imageHash == null && nullToAbsent ? const Value.absent() : Value(imageHash),
      notes: Value(notes),
      captured: Value(captured),
    );
  }

  factory CatalogItem.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogItem(
      id: serializer.fromJson<String>(json['id']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      researchId: serializer.fromJson<String>(json['researchId']),
      propertyId: serializer.fromJson<String?>(json['propertyId']),
      kind: serializer.fromJson<String>(json['kind']),
      title: serializer.fromJson<String>(json['title']),
      url: serializer.fromJson<String>(json['url']),
      source: serializer.fromJson<String>(json['source']),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
      address: serializer.fromJson<String>(json['address']),
      postcode: serializer.fromJson<String>(json['postcode']),
      price: serializer.fromJson<int?>(json['price']),
      beds: serializer.fromJson<int?>(json['beds']),
      baths: serializer.fromJson<int?>(json['baths']),
      fields: serializer.fromJson<String>(json['fields']),
      body: serializer.fromJson<String>(json['body']),
      imageHash: serializer.fromJson<String?>(json['imageHash']),
      notes: serializer.fromJson<String>(json['notes']),
      captured: serializer.fromJson<String>(json['captured']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hlc': serializer.toJson<String>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'researchId': serializer.toJson<String>(researchId),
      'propertyId': serializer.toJson<String?>(propertyId),
      'kind': serializer.toJson<String>(kind),
      'title': serializer.toJson<String>(title),
      'url': serializer.toJson<String>(url),
      'source': serializer.toJson<String>(source),
      'sourceId': serializer.toJson<String?>(sourceId),
      'address': serializer.toJson<String>(address),
      'postcode': serializer.toJson<String>(postcode),
      'price': serializer.toJson<int?>(price),
      'beds': serializer.toJson<int?>(beds),
      'baths': serializer.toJson<int?>(baths),
      'fields': serializer.toJson<String>(fields),
      'body': serializer.toJson<String>(body),
      'imageHash': serializer.toJson<String?>(imageHash),
      'notes': serializer.toJson<String>(notes),
      'captured': serializer.toJson<String>(captured),
    };
  }

  CatalogItem copyWith({
    String? id,
    String? hlc,
    bool? deleted,
    String? researchId,
    Value<String?> propertyId = const Value.absent(),
    String? kind,
    String? title,
    String? url,
    String? source,
    Value<String?> sourceId = const Value.absent(),
    String? address,
    String? postcode,
    Value<int?> price = const Value.absent(),
    Value<int?> beds = const Value.absent(),
    Value<int?> baths = const Value.absent(),
    String? fields,
    String? body,
    Value<String?> imageHash = const Value.absent(),
    String? notes,
    String? captured,
  }) => CatalogItem(
    id: id ?? this.id,
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    researchId: researchId ?? this.researchId,
    propertyId: propertyId.present ? propertyId.value : this.propertyId,
    kind: kind ?? this.kind,
    title: title ?? this.title,
    url: url ?? this.url,
    source: source ?? this.source,
    sourceId: sourceId.present ? sourceId.value : this.sourceId,
    address: address ?? this.address,
    postcode: postcode ?? this.postcode,
    price: price.present ? price.value : this.price,
    beds: beds.present ? beds.value : this.beds,
    baths: baths.present ? baths.value : this.baths,
    fields: fields ?? this.fields,
    body: body ?? this.body,
    imageHash: imageHash.present ? imageHash.value : this.imageHash,
    notes: notes ?? this.notes,
    captured: captured ?? this.captured,
  );
  CatalogItem copyWithCompanion(CatalogItemsCompanion data) {
    return CatalogItem(
      id: data.id.present ? data.id.value : this.id,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      researchId: data.researchId.present ? data.researchId.value : this.researchId,
      propertyId: data.propertyId.present ? data.propertyId.value : this.propertyId,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      url: data.url.present ? data.url.value : this.url,
      source: data.source.present ? data.source.value : this.source,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      address: data.address.present ? data.address.value : this.address,
      postcode: data.postcode.present ? data.postcode.value : this.postcode,
      price: data.price.present ? data.price.value : this.price,
      beds: data.beds.present ? data.beds.value : this.beds,
      baths: data.baths.present ? data.baths.value : this.baths,
      fields: data.fields.present ? data.fields.value : this.fields,
      body: data.body.present ? data.body.value : this.body,
      imageHash: data.imageHash.present ? data.imageHash.value : this.imageHash,
      notes: data.notes.present ? data.notes.value : this.notes,
      captured: data.captured.present ? data.captured.value : this.captured,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogItem(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('researchId: $researchId, ')
          ..write('propertyId: $propertyId, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('source: $source, ')
          ..write('sourceId: $sourceId, ')
          ..write('address: $address, ')
          ..write('postcode: $postcode, ')
          ..write('price: $price, ')
          ..write('beds: $beds, ')
          ..write('baths: $baths, ')
          ..write('fields: $fields, ')
          ..write('body: $body, ')
          ..write('imageHash: $imageHash, ')
          ..write('notes: $notes, ')
          ..write('captured: $captured')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    hlc,
    deleted,
    researchId,
    propertyId,
    kind,
    title,
    url,
    source,
    sourceId,
    address,
    postcode,
    price,
    beds,
    baths,
    fields,
    body,
    imageHash,
    notes,
    captured,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogItem &&
          other.id == this.id &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.researchId == this.researchId &&
          other.propertyId == this.propertyId &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.url == this.url &&
          other.source == this.source &&
          other.sourceId == this.sourceId &&
          other.address == this.address &&
          other.postcode == this.postcode &&
          other.price == this.price &&
          other.beds == this.beds &&
          other.baths == this.baths &&
          other.fields == this.fields &&
          other.body == this.body &&
          other.imageHash == this.imageHash &&
          other.notes == this.notes &&
          other.captured == this.captured);
}

class CatalogItemsCompanion extends UpdateCompanion<CatalogItem> {
  final Value<String> id;
  final Value<String> hlc;
  final Value<bool> deleted;
  final Value<String> researchId;
  final Value<String?> propertyId;
  final Value<String> kind;
  final Value<String> title;
  final Value<String> url;
  final Value<String> source;
  final Value<String?> sourceId;
  final Value<String> address;
  final Value<String> postcode;
  final Value<int?> price;
  final Value<int?> beds;
  final Value<int?> baths;
  final Value<String> fields;
  final Value<String> body;
  final Value<String?> imageHash;
  final Value<String> notes;
  final Value<String> captured;
  final Value<int> rowid;
  const CatalogItemsCompanion({
    this.id = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.researchId = const Value.absent(),
    this.propertyId = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.address = const Value.absent(),
    this.postcode = const Value.absent(),
    this.price = const Value.absent(),
    this.beds = const Value.absent(),
    this.baths = const Value.absent(),
    this.fields = const Value.absent(),
    this.body = const Value.absent(),
    this.imageHash = const Value.absent(),
    this.notes = const Value.absent(),
    this.captured = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogItemsCompanion.insert({
    required String id,
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    required String researchId,
    this.propertyId = const Value.absent(),
    required String kind,
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.address = const Value.absent(),
    this.postcode = const Value.absent(),
    this.price = const Value.absent(),
    this.beds = const Value.absent(),
    this.baths = const Value.absent(),
    this.fields = const Value.absent(),
    this.body = const Value.absent(),
    this.imageHash = const Value.absent(),
    this.notes = const Value.absent(),
    required String captured,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       researchId = Value(researchId),
       kind = Value(kind),
       captured = Value(captured);
  static Insertable<CatalogItem> custom({
    Expression<String>? id,
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<String>? researchId,
    Expression<String>? propertyId,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<String>? url,
    Expression<String>? source,
    Expression<String>? sourceId,
    Expression<String>? address,
    Expression<String>? postcode,
    Expression<int>? price,
    Expression<int>? beds,
    Expression<int>? baths,
    Expression<String>? fields,
    Expression<String>? body,
    Expression<String>? imageHash,
    Expression<String>? notes,
    Expression<String>? captured,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (researchId != null) 'research_id': researchId,
      if (propertyId != null) 'property_id': propertyId,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (url != null) 'url': url,
      if (source != null) 'source': source,
      if (sourceId != null) 'source_id': sourceId,
      if (address != null) 'address': address,
      if (postcode != null) 'postcode': postcode,
      if (price != null) 'price': price,
      if (beds != null) 'beds': beds,
      if (baths != null) 'baths': baths,
      if (fields != null) 'fields': fields,
      if (body != null) 'body': body,
      if (imageHash != null) 'image_hash': imageHash,
      if (notes != null) 'notes': notes,
      if (captured != null) 'captured': captured,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? hlc,
    Value<bool>? deleted,
    Value<String>? researchId,
    Value<String?>? propertyId,
    Value<String>? kind,
    Value<String>? title,
    Value<String>? url,
    Value<String>? source,
    Value<String?>? sourceId,
    Value<String>? address,
    Value<String>? postcode,
    Value<int?>? price,
    Value<int?>? beds,
    Value<int?>? baths,
    Value<String>? fields,
    Value<String>? body,
    Value<String?>? imageHash,
    Value<String>? notes,
    Value<String>? captured,
    Value<int>? rowid,
  }) {
    return CatalogItemsCompanion(
      id: id ?? this.id,
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      researchId: researchId ?? this.researchId,
      propertyId: propertyId ?? this.propertyId,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      url: url ?? this.url,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      address: address ?? this.address,
      postcode: postcode ?? this.postcode,
      price: price ?? this.price,
      beds: beds ?? this.beds,
      baths: baths ?? this.baths,
      fields: fields ?? this.fields,
      body: body ?? this.body,
      imageHash: imageHash ?? this.imageHash,
      notes: notes ?? this.notes,
      captured: captured ?? this.captured,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (researchId.present) {
      map['research_id'] = Variable<String>(researchId.value);
    }
    if (propertyId.present) {
      map['property_id'] = Variable<String>(propertyId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (postcode.present) {
      map['postcode'] = Variable<String>(postcode.value);
    }
    if (price.present) {
      map['price'] = Variable<int>(price.value);
    }
    if (beds.present) {
      map['beds'] = Variable<int>(beds.value);
    }
    if (baths.present) {
      map['baths'] = Variable<int>(baths.value);
    }
    if (fields.present) {
      map['fields'] = Variable<String>(fields.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (imageHash.present) {
      map['image_hash'] = Variable<String>(imageHash.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (captured.present) {
      map['captured'] = Variable<String>(captured.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogItemsCompanion(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('researchId: $researchId, ')
          ..write('propertyId: $propertyId, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('source: $source, ')
          ..write('sourceId: $sourceId, ')
          ..write('address: $address, ')
          ..write('postcode: $postcode, ')
          ..write('price: $price, ')
          ..write('beds: $beds, ')
          ..write('baths: $baths, ')
          ..write('fields: $fields, ')
          ..write('body: $body, ')
          ..write('imageHash: $imageHash, ')
          ..write('notes: $notes, ')
          ..write('captured: $captured, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogImagesTable extends CatalogImages with TableInfo<$CatalogImagesTable, CatalogImage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogImagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<Uint8List> bytes = GeneratedColumn<Uint8List>(
    'bytes',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [itemId, bytes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'property_catalog_images';
  @override
  VerificationContext validateIntegrity(Insertable<CatalogImage> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta, itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(_bytesMeta, bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta));
    } else if (isInserting) {
      context.missing(_bytesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId};
  @override
  CatalogImage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogImage(
      itemId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      bytes: attachedDatabase.typeMapping.read(DriftSqlType.blob, data['${effectivePrefix}bytes'])!,
    );
  }

  @override
  $CatalogImagesTable createAlias(String alias) {
    return $CatalogImagesTable(attachedDatabase, alias);
  }
}

class CatalogImage extends DataClass implements Insertable<CatalogImage> {
  final String itemId;
  final Uint8List bytes;
  const CatalogImage({required this.itemId, required this.bytes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['bytes'] = Variable<Uint8List>(bytes);
    return map;
  }

  CatalogImagesCompanion toCompanion(bool nullToAbsent) {
    return CatalogImagesCompanion(itemId: Value(itemId), bytes: Value(bytes));
  }

  factory CatalogImage.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogImage(
      itemId: serializer.fromJson<String>(json['itemId']),
      bytes: serializer.fromJson<Uint8List>(json['bytes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'bytes': serializer.toJson<Uint8List>(bytes),
    };
  }

  CatalogImage copyWith({String? itemId, Uint8List? bytes}) =>
      CatalogImage(itemId: itemId ?? this.itemId, bytes: bytes ?? this.bytes);
  CatalogImage copyWithCompanion(CatalogImagesCompanion data) {
    return CatalogImage(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogImage(')
          ..write('itemId: $itemId, ')
          ..write('bytes: $bytes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(itemId, $driftBlobEquality.hash(bytes));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogImage &&
          other.itemId == this.itemId &&
          $driftBlobEquality.equals(other.bytes, this.bytes));
}

class CatalogImagesCompanion extends UpdateCompanion<CatalogImage> {
  final Value<String> itemId;
  final Value<Uint8List> bytes;
  final Value<int> rowid;
  const CatalogImagesCompanion({
    this.itemId = const Value.absent(),
    this.bytes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogImagesCompanion.insert({
    required String itemId,
    required Uint8List bytes,
    this.rowid = const Value.absent(),
  }) : itemId = Value(itemId),
       bytes = Value(bytes);
  static Insertable<CatalogImage> custom({
    Expression<String>? itemId,
    Expression<Uint8List>? bytes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (bytes != null) 'bytes': bytes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogImagesCompanion copyWith({Value<String>? itemId, Value<Uint8List>? bytes, Value<int>? rowid}) {
    return CatalogImagesCompanion(
      itemId: itemId ?? this.itemId,
      bytes: bytes ?? this.bytes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<Uint8List>(bytes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogImagesCompanion(')
          ..write('itemId: $itemId, ')
          ..write('bytes: $bytes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PrefsTable extends Prefs with TableInfo<$PrefsTable, Pref> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrefsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, hlc, deleted, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prefs';
  @override
  VerificationContext validateIntegrity(Insertable<Pref> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(_hlcMeta, hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta));
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta, deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Pref map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pref(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      hlc: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}hlc'])!,
      deleted: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      value: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $PrefsTable createAlias(String alias) {
    return $PrefsTable(attachedDatabase, alias);
  }
}

class Pref extends DataClass implements Insertable<Pref> {
  final String id;
  final String hlc;
  final bool deleted;
  final String value;
  const Pref({required this.id, required this.hlc, required this.deleted, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['hlc'] = Variable<String>(hlc);
    map['deleted'] = Variable<bool>(deleted);
    map['value'] = Variable<String>(value);
    return map;
  }

  PrefsCompanion toCompanion(bool nullToAbsent) {
    return PrefsCompanion(id: Value(id), hlc: Value(hlc), deleted: Value(deleted), value: Value(value));
  }

  factory Pref.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pref(
      id: serializer.fromJson<String>(json['id']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hlc': serializer.toJson<String>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'value': serializer.toJson<String>(value),
    };
  }

  Pref copyWith({String? id, String? hlc, bool? deleted, String? value}) => Pref(
    id: id ?? this.id,
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    value: value ?? this.value,
  );
  Pref copyWithCompanion(PrefsCompanion data) {
    return Pref(
      id: data.id.present ? data.id.value : this.id,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pref(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, hlc, deleted, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pref &&
          other.id == this.id &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.value == this.value);
}

class PrefsCompanion extends UpdateCompanion<Pref> {
  final Value<String> id;
  final Value<String> hlc;
  final Value<bool> deleted;
  final Value<String> value;
  final Value<int> rowid;
  const PrefsCompanion({
    this.id = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrefsCompanion.insert({
    required String id,
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    required String value,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       value = Value(value);
  static Insertable<Pref> custom({
    Expression<String>? id,
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrefsCompanion copyWith({
    Value<String>? id,
    Value<String>? hlc,
    Value<bool>? deleted,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return PrefsCompanion(
      id: id ?? this.id,
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrefsCompanion(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<String> rowId = GeneratedColumn<String>(
    'row_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [entity, rowId, seq];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(Insertable<OutboxItem> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity')) {
      context.handle(_entityMeta, entity.isAcceptableOrUnknown(data['entity']!, _entityMeta));
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('row_id')) {
      context.handle(_rowIdMeta, rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta));
    } else if (isInserting) {
      context.missing(_rowIdMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(_seqMeta, seq.isAcceptableOrUnknown(data['seq']!, _seqMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entity, rowId};
  @override
  OutboxItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxItem(
      entity: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}entity'])!,
      rowId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}row_id'])!,
      seq: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}seq']),
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }
}

class OutboxItem extends DataClass implements Insertable<OutboxItem> {
  final String entity;
  final String rowId;
  final int? seq;
  const OutboxItem({required this.entity, required this.rowId, this.seq});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity'] = Variable<String>(entity);
    map['row_id'] = Variable<String>(rowId);
    if (!nullToAbsent || seq != null) {
      map['seq'] = Variable<int>(seq);
    }
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      entity: Value(entity),
      rowId: Value(rowId),
      seq: seq == null && nullToAbsent ? const Value.absent() : Value(seq),
    );
  }

  factory OutboxItem.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxItem(
      entity: serializer.fromJson<String>(json['entity']),
      rowId: serializer.fromJson<String>(json['rowId']),
      seq: serializer.fromJson<int?>(json['seq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entity': serializer.toJson<String>(entity),
      'rowId': serializer.toJson<String>(rowId),
      'seq': serializer.toJson<int?>(seq),
    };
  }

  OutboxItem copyWith({String? entity, String? rowId, Value<int?> seq = const Value.absent()}) => OutboxItem(
    entity: entity ?? this.entity,
    rowId: rowId ?? this.rowId,
    seq: seq.present ? seq.value : this.seq,
  );
  OutboxItem copyWithCompanion(OutboxCompanion data) {
    return OutboxItem(
      entity: data.entity.present ? data.entity.value : this.entity,
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      seq: data.seq.present ? data.seq.value : this.seq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxItem(')
          ..write('entity: $entity, ')
          ..write('rowId: $rowId, ')
          ..write('seq: $seq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entity, rowId, seq);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxItem &&
          other.entity == this.entity &&
          other.rowId == this.rowId &&
          other.seq == this.seq);
}

class OutboxCompanion extends UpdateCompanion<OutboxItem> {
  final Value<String> entity;
  final Value<String> rowId;
  final Value<int?> seq;
  final Value<int> rowid;
  const OutboxCompanion({
    this.entity = const Value.absent(),
    this.rowId = const Value.absent(),
    this.seq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxCompanion.insert({
    required String entity,
    required String rowId,
    this.seq = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : entity = Value(entity),
       rowId = Value(rowId);
  static Insertable<OutboxItem> custom({
    Expression<String>? entity,
    Expression<String>? rowId,
    Expression<int>? seq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entity != null) 'entity': entity,
      if (rowId != null) 'row_id': rowId,
      if (seq != null) 'seq': seq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxCompanion copyWith({
    Value<String>? entity,
    Value<String>? rowId,
    Value<int?>? seq,
    Value<int>? rowid,
  }) {
    return OutboxCompanion(
      entity: entity ?? this.entity,
      rowId: rowId ?? this.rowId,
      seq: seq ?? this.seq,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (rowId.present) {
      map['row_id'] = Variable<String>(rowId.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('entity: $entity, ')
          ..write('rowId: $rowId, ')
          ..write('seq: $seq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorsTable extends SyncCursors with TableInfo<$SyncCursorsTable, SyncCursor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deviceIdMeta = const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [deviceId, seq];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursors';
  @override
  VerificationContext validateIntegrity(Insertable<SyncCursor> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta, deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(_seqMeta, seq.isAcceptableOrUnknown(data['seq']!, _seqMeta));
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceId};
  @override
  SyncCursor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursor(
      deviceId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      seq: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}seq'])!,
    );
  }

  @override
  $SyncCursorsTable createAlias(String alias) {
    return $SyncCursorsTable(attachedDatabase, alias);
  }
}

class SyncCursor extends DataClass implements Insertable<SyncCursor> {
  final String deviceId;
  final int seq;
  const SyncCursor({required this.deviceId, required this.seq});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_id'] = Variable<String>(deviceId);
    map['seq'] = Variable<int>(seq);
    return map;
  }

  SyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsCompanion(deviceId: Value(deviceId), seq: Value(seq));
  }

  factory SyncCursor.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursor(
      deviceId: serializer.fromJson<String>(json['deviceId']),
      seq: serializer.fromJson<int>(json['seq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deviceId': serializer.toJson<String>(deviceId),
      'seq': serializer.toJson<int>(seq),
    };
  }

  SyncCursor copyWith({String? deviceId, int? seq}) =>
      SyncCursor(deviceId: deviceId ?? this.deviceId, seq: seq ?? this.seq);
  SyncCursor copyWithCompanion(SyncCursorsCompanion data) {
    return SyncCursor(
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      seq: data.seq.present ? data.seq.value : this.seq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursor(')
          ..write('deviceId: $deviceId, ')
          ..write('seq: $seq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(deviceId, seq);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursor && other.deviceId == this.deviceId && other.seq == this.seq);
}

class SyncCursorsCompanion extends UpdateCompanion<SyncCursor> {
  final Value<String> deviceId;
  final Value<int> seq;
  final Value<int> rowid;
  const SyncCursorsCompanion({
    this.deviceId = const Value.absent(),
    this.seq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursorsCompanion.insert({required String deviceId, required int seq, this.rowid = const Value.absent()})
    : deviceId = Value(deviceId),
      seq = Value(seq);
  static Insertable<SyncCursor> custom({
    Expression<String>? deviceId,
    Expression<int>? seq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceId != null) 'device_id': deviceId,
      if (seq != null) 'seq': seq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursorsCompanion copyWith({Value<String>? deviceId, Value<int>? seq, Value<int>? rowid}) {
    return SyncCursorsCompanion(
      deviceId: deviceId ?? this.deviceId,
      seq: seq ?? this.seq,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsCompanion(')
          ..write('deviceId: $deviceId, ')
          ..write('seq: $seq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSettingsTable extends LocalSettings with TableInfo<$LocalSettingsTable, LocalSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_settings';
  @override
  VerificationContext validateIntegrity(Insertable<LocalSetting> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  LocalSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSetting(
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $LocalSettingsTable createAlias(String alias) {
    return $LocalSettingsTable(attachedDatabase, alias);
  }
}

class LocalSetting extends DataClass implements Insertable<LocalSetting> {
  final String key;
  final String value;
  const LocalSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  LocalSettingsCompanion toCompanion(bool nullToAbsent) {
    return LocalSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory LocalSetting.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  LocalSetting copyWith({String? key, String? value}) =>
      LocalSetting(key: key ?? this.key, value: value ?? this.value);
  LocalSetting copyWithCompanion(LocalSettingsCompanion data) {
    return LocalSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is LocalSetting && other.key == this.key && other.value == this.value);
}

class LocalSettingsCompanion extends UpdateCompanion<LocalSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const LocalSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<LocalSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSettingsCompanion copyWith({Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return LocalSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PropertiesTable properties = $PropertiesTable(this);
  late final $ContactsTable contacts = $ContactsTable(this);
  late final $InteractionsTable interactions = $InteractionsTable(this);
  late final $ViewingsTable viewings = $ViewingsTable(this);
  late final $SearchesTable searches = $SearchesTable(this);
  late final $AppraisalsTable appraisals = $AppraisalsTable(this);
  late final $TenanciesTable tenancies = $TenanciesTable(this);
  late final $RentPaymentsTable rentPayments = $RentPaymentsTable(this);
  late final $ComplianceItemsTable complianceItems = $ComplianceItemsTable(this);
  late final $AreasTable areas = $AreasTable(this);
  late final $ResearchesTable researches = $ResearchesTable(this);
  late final $CatalogItemsTable catalogItems = $CatalogItemsTable(this);
  late final $CatalogImagesTable catalogImages = $CatalogImagesTable(this);
  late final $PrefsTable prefs = $PrefsTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $SyncCursorsTable syncCursors = $SyncCursorsTable(this);
  late final $LocalSettingsTable localSettings = $LocalSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    properties,
    contacts,
    interactions,
    viewings,
    searches,
    appraisals,
    tenancies,
    rentPayments,
    complianceItems,
    areas,
    researches,
    catalogItems,
    catalogImages,
    prefs,
    outbox,
    syncCursors,
    localSettings,
  ];
}

typedef $$PropertiesTableCreateCompanionBuilder = PropertiesCompanion Function({
  required String id,
  Value<String> hlc,
  Value<bool> deleted,
  required String address,
  Value<String> postcode,
  Value<double?> lat,
  Value<double?> lon,
  required String kind,
  Value<String> stage,
  Value<int?> price,
  Value<int?> beds,
  Value<int?> baths,
  Value<String> style,
  Value<String> furnished,
  Value<String?> availableFrom,
  Value<String> source,
  Value<String?> sourceId,
  Value<String> url,
  Value<String?> imageUrl,
  Value<String> listingStatus,
  Value<String?> agentId,
  Value<int> rating,
  Value<String> notes,
  required String added,
  Value<String> meta,
  Value<int> rowid,
});
typedef $$PropertiesTableUpdateCompanionBuilder = PropertiesCompanion Function({
  Value<String> id,
  Value<String> hlc,
  Value<bool> deleted,
  Value<String> address,
  Value<String> postcode,
  Value<double?> lat,
  Value<double?> lon,
  Value<String> kind,
  Value<String> stage,
  Value<int?> price,
  Value<int?> beds,
  Value<int?> baths,
  Value<String> style,
  Value<String> furnished,
  Value<String?> availableFrom,
  Value<String> source,
  Value<String?> sourceId,
  Value<String> url,
  Value<String?> imageUrl,
  Value<String> listingStatus,
  Value<String?> agentId,
  Value<int> rating,
  Value<String> notes,
  Value<String> added,
  Value<String> meta,
  Value<int> rowid,
});

class $$PropertiesTableFilterComposer extends Composer<_$AppDatabase, $PropertiesTable> {
  $$PropertiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get postcode =>
      $composableBuilder(column: $table.postcode, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get price =>
      $composableBuilder(column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get beds =>
      $composableBuilder(column: $table.beds, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get baths =>
      $composableBuilder(column: $table.baths, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get style =>
      $composableBuilder(column: $table.style, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get furnished =>
      $composableBuilder(column: $table.furnished, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get availableFrom =>
      $composableBuilder(column: $table.availableFrom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get listingStatus =>
      $composableBuilder(column: $table.listingStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get agentId =>
      $composableBuilder(column: $table.agentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get added =>
      $composableBuilder(column: $table.added, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get meta =>
      $composableBuilder(column: $table.meta, builder: (column) => ColumnFilters(column));
}

class $$PropertiesTableOrderingComposer extends Composer<_$AppDatabase, $PropertiesTable> {
  $$PropertiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get postcode =>
      $composableBuilder(column: $table.postcode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get price =>
      $composableBuilder(column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get beds =>
      $composableBuilder(column: $table.beds, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get baths =>
      $composableBuilder(column: $table.baths, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get style =>
      $composableBuilder(column: $table.style, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get furnished =>
      $composableBuilder(column: $table.furnished, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get availableFrom =>
      $composableBuilder(column: $table.availableFrom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get listingStatus =>
      $composableBuilder(column: $table.listingStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get agentId =>
      $composableBuilder(column: $table.agentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get added =>
      $composableBuilder(column: $table.added, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get meta =>
      $composableBuilder(column: $table.meta, builder: (column) => ColumnOrderings(column));
}

class $$PropertiesTableAnnotationComposer extends Composer<_$AppDatabase, $PropertiesTable> {
  $$PropertiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hlc => $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get postcode =>
      $composableBuilder(column: $table.postcode, builder: (column) => column);

  GeneratedColumn<double> get lat => $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon => $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumn<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get stage => $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<int> get price => $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<int> get beds => $composableBuilder(column: $table.beds, builder: (column) => column);

  GeneratedColumn<int> get baths => $composableBuilder(column: $table.baths, builder: (column) => column);

  GeneratedColumn<String> get style => $composableBuilder(column: $table.style, builder: (column) => column);

  GeneratedColumn<String> get furnished =>
      $composableBuilder(column: $table.furnished, builder: (column) => column);

  GeneratedColumn<String> get availableFrom =>
      $composableBuilder(column: $table.availableFrom, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get url => $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get listingStatus =>
      $composableBuilder(column: $table.listingStatus, builder: (column) => column);

  GeneratedColumn<String> get agentId =>
      $composableBuilder(column: $table.agentId, builder: (column) => column);

  GeneratedColumn<int> get rating => $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get added => $composableBuilder(column: $table.added, builder: (column) => column);

  GeneratedColumn<String> get meta => $composableBuilder(column: $table.meta, builder: (column) => column);
}

class $$PropertiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PropertiesTable,
          Property,
          $$PropertiesTableFilterComposer,
          $$PropertiesTableOrderingComposer,
          $$PropertiesTableAnnotationComposer,
          $$PropertiesTableCreateCompanionBuilder,
          $$PropertiesTableUpdateCompanionBuilder,
          (Property, BaseReferences<_$AppDatabase, $PropertiesTable, Property>),
          Property,
          PrefetchHooks Function()
        > {
  $$PropertiesTableTableManager(_$AppDatabase db, $PropertiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$PropertiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$PropertiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$PropertiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> postcode = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lon = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> stage = const Value.absent(),
                Value<int?> price = const Value.absent(),
                Value<int?> beds = const Value.absent(),
                Value<int?> baths = const Value.absent(),
                Value<String> style = const Value.absent(),
                Value<String> furnished = const Value.absent(),
                Value<String?> availableFrom = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String> listingStatus = const Value.absent(),
                Value<String?> agentId = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> added = const Value.absent(),
                Value<String> meta = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PropertiesCompanion(
                id: id,
                hlc: hlc,
                deleted: deleted,
                address: address,
                postcode: postcode,
                lat: lat,
                lon: lon,
                kind: kind,
                stage: stage,
                price: price,
                beds: beds,
                baths: baths,
                style: style,
                furnished: furnished,
                availableFrom: availableFrom,
                source: source,
                sourceId: sourceId,
                url: url,
                imageUrl: imageUrl,
                listingStatus: listingStatus,
                agentId: agentId,
                rating: rating,
                notes: notes,
                added: added,
                meta: meta,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required String address,
                Value<String> postcode = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lon = const Value.absent(),
                required String kind,
                Value<String> stage = const Value.absent(),
                Value<int?> price = const Value.absent(),
                Value<int?> beds = const Value.absent(),
                Value<int?> baths = const Value.absent(),
                Value<String> style = const Value.absent(),
                Value<String> furnished = const Value.absent(),
                Value<String?> availableFrom = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String> listingStatus = const Value.absent(),
                Value<String?> agentId = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<String> notes = const Value.absent(),
                required String added,
                Value<String> meta = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PropertiesCompanion.insert(
                id: id,
                hlc: hlc,
                deleted: deleted,
                address: address,
                postcode: postcode,
                lat: lat,
                lon: lon,
                kind: kind,
                stage: stage,
                price: price,
                beds: beds,
                baths: baths,
                style: style,
                furnished: furnished,
                availableFrom: availableFrom,
                source: source,
                sourceId: sourceId,
                url: url,
                imageUrl: imageUrl,
                listingStatus: listingStatus,
                agentId: agentId,
                rating: rating,
                notes: notes,
                added: added,
                meta: meta,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PropertiesTable, Property>(table),
                  BaseReferences<_$AppDatabase, $PropertiesTable, Property>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PropertiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PropertiesTable,
      Property,
      $$PropertiesTableFilterComposer,
      $$PropertiesTableOrderingComposer,
      $$PropertiesTableAnnotationComposer,
      $$PropertiesTableCreateCompanionBuilder,
      $$PropertiesTableUpdateCompanionBuilder,
      (Property, BaseReferences<_$AppDatabase, $PropertiesTable, Property>),
      Property,
      PrefetchHooks Function()
    >;
typedef $$ContactsTableCreateCompanionBuilder = ContactsCompanion Function({
  required String id,
  Value<String> hlc,
  Value<bool> deleted,
  required String name,
  Value<String> role,
  Value<String> organisation,
  Value<String> phone,
  Value<String> email,
  Value<String> notes,
  Value<int> rowid,
});
typedef $$ContactsTableUpdateCompanionBuilder = ContactsCompanion Function({
  Value<String> id,
  Value<String> hlc,
  Value<bool> deleted,
  Value<String> name,
  Value<String> role,
  Value<String> organisation,
  Value<String> phone,
  Value<String> email,
  Value<String> notes,
  Value<int> rowid,
});

class $$ContactsTableFilterComposer extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get organisation =>
      $composableBuilder(column: $table.organisation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$ContactsTableOrderingComposer extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get organisation =>
      $composableBuilder(column: $table.organisation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$ContactsTableAnnotationComposer extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hlc => $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get role => $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get organisation =>
      $composableBuilder(column: $table.organisation, builder: (column) => column);

  GeneratedColumn<String> get phone => $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email => $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$ContactsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContactsTable,
          Contact,
          $$ContactsTableFilterComposer,
          $$ContactsTableOrderingComposer,
          $$ContactsTableAnnotationComposer,
          $$ContactsTableCreateCompanionBuilder,
          $$ContactsTableUpdateCompanionBuilder,
          (Contact, BaseReferences<_$AppDatabase, $ContactsTable, Contact>),
          Contact,
          PrefetchHooks Function()
        > {
  $$ContactsTableTableManager(_$AppDatabase db, $ContactsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> organisation = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContactsCompanion(
                id: id,
                hlc: hlc,
                deleted: deleted,
                name: name,
                role: role,
                organisation: organisation,
                phone: phone,
                email: email,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required String name,
                Value<String> role = const Value.absent(),
                Value<String> organisation = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContactsCompanion.insert(
                id: id,
                hlc: hlc,
                deleted: deleted,
                name: name,
                role: role,
                organisation: organisation,
                phone: phone,
                email: email,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ContactsTable, Contact>(table),
                  BaseReferences<_$AppDatabase, $ContactsTable, Contact>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContactsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContactsTable,
      Contact,
      $$ContactsTableFilterComposer,
      $$ContactsTableOrderingComposer,
      $$ContactsTableAnnotationComposer,
      $$ContactsTableCreateCompanionBuilder,
      $$ContactsTableUpdateCompanionBuilder,
      (Contact, BaseReferences<_$AppDatabase, $ContactsTable, Contact>),
      Contact,
      PrefetchHooks Function()
    >;
typedef $$InteractionsTableCreateCompanionBuilder = InteractionsCompanion Function({
  required String id,
  Value<String> hlc,
  Value<bool> deleted,
  Value<String?> propertyId,
  Value<String?> contactId,
  required String at,
  required String channel,
  Value<String> direction,
  Value<String> summary,
  Value<String?> followUp,
  Value<int> rowid,
});
typedef $$InteractionsTableUpdateCompanionBuilder = InteractionsCompanion Function({
  Value<String> id,
  Value<String> hlc,
  Value<bool> deleted,
  Value<String?> propertyId,
  Value<String?> contactId,
  Value<String> at,
  Value<String> channel,
  Value<String> direction,
  Value<String> summary,
  Value<String?> followUp,
  Value<int> rowid,
});

class $$InteractionsTableFilterComposer extends Composer<_$AppDatabase, $InteractionsTable> {
  $$InteractionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get propertyId =>
      $composableBuilder(column: $table.propertyId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contactId =>
      $composableBuilder(column: $table.contactId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get at =>
      $composableBuilder(column: $table.at, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get channel =>
      $composableBuilder(column: $table.channel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get followUp =>
      $composableBuilder(column: $table.followUp, builder: (column) => ColumnFilters(column));
}

class $$InteractionsTableOrderingComposer extends Composer<_$AppDatabase, $InteractionsTable> {
  $$InteractionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get propertyId =>
      $composableBuilder(column: $table.propertyId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contactId =>
      $composableBuilder(column: $table.contactId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get at =>
      $composableBuilder(column: $table.at, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get channel =>
      $composableBuilder(column: $table.channel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get followUp =>
      $composableBuilder(column: $table.followUp, builder: (column) => ColumnOrderings(column));
}

class $$InteractionsTableAnnotationComposer extends Composer<_$AppDatabase, $InteractionsTable> {
  $$InteractionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hlc => $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get propertyId =>
      $composableBuilder(column: $table.propertyId, builder: (column) => column);

  GeneratedColumn<String> get contactId =>
      $composableBuilder(column: $table.contactId, builder: (column) => column);

  GeneratedColumn<String> get at => $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get channel =>
      $composableBuilder(column: $table.channel, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get followUp =>
      $composableBuilder(column: $table.followUp, builder: (column) => column);
}

class $$InteractionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InteractionsTable,
          Interaction,
          $$InteractionsTableFilterComposer,
          $$InteractionsTableOrderingComposer,
          $$InteractionsTableAnnotationComposer,
          $$InteractionsTableCreateCompanionBuilder,
          $$InteractionsTableUpdateCompanionBuilder,
          (Interaction, BaseReferences<_$AppDatabase, $InteractionsTable, Interaction>),
          Interaction,
          PrefetchHooks Function()
        > {
  $$InteractionsTableTableManager(_$AppDatabase db, $InteractionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$InteractionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$InteractionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$InteractionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String?> propertyId = const Value.absent(),
                Value<String?> contactId = const Value.absent(),
                Value<String> at = const Value.absent(),
                Value<String> channel = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<String?> followUp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InteractionsCompanion(
                id: id,
                hlc: hlc,
                deleted: deleted,
                propertyId: propertyId,
                contactId: contactId,
                at: at,
                channel: channel,
                direction: direction,
                summary: summary,
                followUp: followUp,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String?> propertyId = const Value.absent(),
                Value<String?> contactId = const Value.absent(),
                required String at,
                required String channel,
                Value<String> direction = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<String?> followUp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InteractionsCompanion.insert(
                id: id,
                hlc: hlc,
                deleted: deleted,
                propertyId: propertyId,
                contactId: contactId,
                at: at,
                channel: channel,
                direction: direction,
                summary: summary,
                followUp: followUp,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InteractionsTable, Interaction>(table),
                  BaseReferences<_$AppDatabase, $InteractionsTable, Interaction>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InteractionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InteractionsTable,
      Interaction,
      $$InteractionsTableFilterComposer,
      $$InteractionsTableOrderingComposer,
      $$InteractionsTableAnnotationComposer,
      $$InteractionsTableCreateCompanionBuilder,
      $$InteractionsTableUpdateCompanionBuilder,
      (Interaction, BaseReferences<_$AppDatabase, $InteractionsTable, Interaction>),
      Interaction,
      PrefetchHooks Function()
    >;
typedef $$ViewingsTableCreateCompanionBuilder = ViewingsCompanion Function({
  required String id,
  Value<String> hlc,
  Value<bool> deleted,
  required String propertyId,
  required String at,
  Value<String> status,
  Value<int> rating,
  Value<String> notes,
  Value<int> rowid,
});
typedef $$ViewingsTableUpdateCompanionBuilder = ViewingsCompanion Function({
  Value<String> id,
  Value<String> hlc,
  Value<bool> deleted,
  Value<String> propertyId,
  Value<String> at,
  Value<String> status,
  Value<int> rating,
  Value<String> notes,
  Value<int> rowid,
});

class $$ViewingsTableFilterComposer extends Composer<_$AppDatabase, $ViewingsTable> {
  $$ViewingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get propertyId =>
      $composableBuilder(column: $table.propertyId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get at =>
      $composableBuilder(column: $table.at, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$ViewingsTableOrderingComposer extends Composer<_$AppDatabase, $ViewingsTable> {
  $$ViewingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get propertyId =>
      $composableBuilder(column: $table.propertyId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get at =>
      $composableBuilder(column: $table.at, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$ViewingsTableAnnotationComposer extends Composer<_$AppDatabase, $ViewingsTable> {
  $$ViewingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hlc => $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get propertyId =>
      $composableBuilder(column: $table.propertyId, builder: (column) => column);

  GeneratedColumn<String> get at => $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get rating => $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$ViewingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ViewingsTable,
          Viewing,
          $$ViewingsTableFilterComposer,
          $$ViewingsTableOrderingComposer,
          $$ViewingsTableAnnotationComposer,
          $$ViewingsTableCreateCompanionBuilder,
          $$ViewingsTableUpdateCompanionBuilder,
          (Viewing, BaseReferences<_$AppDatabase, $ViewingsTable, Viewing>),
          Viewing,
          PrefetchHooks Function()
        > {
  $$ViewingsTableTableManager(_$AppDatabase db, $ViewingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ViewingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ViewingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ViewingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> propertyId = const Value.absent(),
                Value<String> at = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ViewingsCompanion(
                id: id,
                hlc: hlc,
                deleted: deleted,
                propertyId: propertyId,
                at: at,
                status: status,
                rating: rating,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required String propertyId,
                required String at,
                Value<String> status = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ViewingsCompanion.insert(
                id: id,
                hlc: hlc,
                deleted: deleted,
                propertyId: propertyId,
                at: at,
                status: status,
                rating: rating,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ViewingsTable, Viewing>(table),
                  BaseReferences<_$AppDatabase, $ViewingsTable, Viewing>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ViewingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ViewingsTable,
      Viewing,
      $$ViewingsTableFilterComposer,
      $$ViewingsTableOrderingComposer,
      $$ViewingsTableAnnotationComposer,
      $$ViewingsTableCreateCompanionBuilder,
      $$ViewingsTableUpdateCompanionBuilder,
      (Viewing, BaseReferences<_$AppDatabase, $ViewingsTable, Viewing>),
      Viewing,
      PrefetchHooks Function()
    >;
typedef $$SearchesTableCreateCompanionBuilder = SearchesCompanion Function({
  required String id,
  Value<String> hlc,
  Value<bool> deleted,
  required String name,
  Value<String> source,
  required String path,
  Value<String> kind,
  Value<String> keywords,
  Value<int?> maxPrice,
  Value<int?> minBeds,
  Value<int?> maxBeds,
  Value<double?> centreLat,
  Value<double?> centreLon,
  Value<String> centreLabel,
  Value<double?> radiusKm,
  Value<bool> includeUnpriced,
  Value<bool> paused,
  Value<int> rowid,
});
typedef $$SearchesTableUpdateCompanionBuilder = SearchesCompanion Function({
  Value<String> id,
  Value<String> hlc,
  Value<bool> deleted,
  Value<String> name,
  Value<String> source,
  Value<String> path,
  Value<String> kind,
  Value<String> keywords,
  Value<int?> maxPrice,
  Value<int?> minBeds,
  Value<int?> maxBeds,
  Value<double?> centreLat,
  Value<double?> centreLon,
  Value<String> centreLabel,
  Value<double?> radiusKm,
  Value<bool> includeUnpriced,
  Value<bool> paused,
  Value<int> rowid,
});

class $$SearchesTableFilterComposer extends Composer<_$AppDatabase, $SearchesTable> {
  $$SearchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get keywords =>
      $composableBuilder(column: $table.keywords, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxPrice =>
      $composableBuilder(column: $table.maxPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get minBeds =>
      $composableBuilder(column: $table.minBeds, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxBeds =>
      $composableBuilder(column: $table.maxBeds, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get centreLat =>
      $composableBuilder(column: $table.centreLat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get centreLon =>
      $composableBuilder(column: $table.centreLon, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get centreLabel =>
      $composableBuilder(column: $table.centreLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get radiusKm =>
      $composableBuilder(column: $table.radiusKm, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get includeUnpriced =>
      $composableBuilder(column: $table.includeUnpriced, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get paused =>
      $composableBuilder(column: $table.paused, builder: (column) => ColumnFilters(column));
}

class $$SearchesTableOrderingComposer extends Composer<_$AppDatabase, $SearchesTable> {
  $$SearchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get keywords =>
      $composableBuilder(column: $table.keywords, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxPrice =>
      $composableBuilder(column: $table.maxPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get minBeds =>
      $composableBuilder(column: $table.minBeds, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxBeds =>
      $composableBuilder(column: $table.maxBeds, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get centreLat =>
      $composableBuilder(column: $table.centreLat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get centreLon =>
      $composableBuilder(column: $table.centreLon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get centreLabel =>
      $composableBuilder(column: $table.centreLabel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get radiusKm =>
      $composableBuilder(column: $table.radiusKm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get includeUnpriced =>
      $composableBuilder(column: $table.includeUnpriced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get paused =>
      $composableBuilder(column: $table.paused, builder: (column) => ColumnOrderings(column));
}

class $$SearchesTableAnnotationComposer extends Composer<_$AppDatabase, $SearchesTable> {
  $$SearchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hlc => $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get path => $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get keywords =>
      $composableBuilder(column: $table.keywords, builder: (column) => column);

  GeneratedColumn<int> get maxPrice =>
      $composableBuilder(column: $table.maxPrice, builder: (column) => column);

  GeneratedColumn<int> get minBeds => $composableBuilder(column: $table.minBeds, builder: (column) => column);

  GeneratedColumn<int> get maxBeds => $composableBuilder(column: $table.maxBeds, builder: (column) => column);

  GeneratedColumn<double> get centreLat =>
      $composableBuilder(column: $table.centreLat, builder: (column) => column);

  GeneratedColumn<double> get centreLon =>
      $composableBuilder(column: $table.centreLon, builder: (column) => column);

  GeneratedColumn<String> get centreLabel =>
      $composableBuilder(column: $table.centreLabel, builder: (column) => column);

  GeneratedColumn<double> get radiusKm =>
      $composableBuilder(column: $table.radiusKm, builder: (column) => column);

  GeneratedColumn<bool> get includeUnpriced =>
      $composableBuilder(column: $table.includeUnpriced, builder: (column) => column);

  GeneratedColumn<bool> get paused => $composableBuilder(column: $table.paused, builder: (column) => column);
}

class $$SearchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SearchesTable,
          Search,
          $$SearchesTableFilterComposer,
          $$SearchesTableOrderingComposer,
          $$SearchesTableAnnotationComposer,
          $$SearchesTableCreateCompanionBuilder,
          $$SearchesTableUpdateCompanionBuilder,
          (Search, BaseReferences<_$AppDatabase, $SearchesTable, Search>),
          Search,
          PrefetchHooks Function()
        > {
  $$SearchesTableTableManager(_$AppDatabase db, $SearchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SearchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SearchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SearchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> keywords = const Value.absent(),
                Value<int?> maxPrice = const Value.absent(),
                Value<int?> minBeds = const Value.absent(),
                Value<int?> maxBeds = const Value.absent(),
                Value<double?> centreLat = const Value.absent(),
                Value<double?> centreLon = const Value.absent(),
                Value<String> centreLabel = const Value.absent(),
                Value<double?> radiusKm = const Value.absent(),
                Value<bool> includeUnpriced = const Value.absent(),
                Value<bool> paused = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SearchesCompanion(
                id: id,
                hlc: hlc,
                deleted: deleted,
                name: name,
                source: source,
                path: path,
                kind: kind,
                keywords: keywords,
                maxPrice: maxPrice,
                minBeds: minBeds,
                maxBeds: maxBeds,
                centreLat: centreLat,
                centreLon: centreLon,
                centreLabel: centreLabel,
                radiusKm: radiusKm,
                includeUnpriced: includeUnpriced,
                paused: paused,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required String name,
                Value<String> source = const Value.absent(),
                required String path,
                Value<String> kind = const Value.absent(),
                Value<String> keywords = const Value.absent(),
                Value<int?> maxPrice = const Value.absent(),
                Value<int?> minBeds = const Value.absent(),
                Value<int?> maxBeds = const Value.absent(),
                Value<double?> centreLat = const Value.absent(),
                Value<double?> centreLon = const Value.absent(),
                Value<String> centreLabel = const Value.absent(),
                Value<double?> radiusKm = const Value.absent(),
                Value<bool> includeUnpriced = const Value.absent(),
                Value<bool> paused = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SearchesCompanion.insert(
                id: id,
                hlc: hlc,
                deleted: deleted,
                name: name,
                source: source,
                path: path,
                kind: kind,
                keywords: keywords,
                maxPrice: maxPrice,
                minBeds: minBeds,
                maxBeds: maxBeds,
                centreLat: centreLat,
                centreLon: centreLon,
                centreLabel: centreLabel,
                radiusKm: radiusKm,
                includeUnpriced: includeUnpriced,
                paused: paused,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SearchesTable, Search>(table),
                  BaseReferences<_$AppDatabase, $SearchesTable, Search>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SearchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SearchesTable,
      Search,
      $$SearchesTableFilterComposer,
      $$SearchesTableOrderingComposer,
      $$SearchesTableAnnotationComposer,
      $$SearchesTableCreateCompanionBuilder,
      $$SearchesTableUpdateCompanionBuilder,
      (Search, BaseReferences<_$AppDatabase, $SearchesTable, Search>),
      Search,
      PrefetchHooks Function()
    >;
typedef $$AppraisalsTableCreateCompanionBuilder = AppraisalsCompanion Function({
  required String id,
  Value<String> hlc,
  Value<bool> deleted,
  required String name,
  required String kind,
  Value<String?> propertyId,
  Value<String> inputs,
  Value<String> notes,
  required String updated,
  Value<int> rowid,
});
typedef $$AppraisalsTableUpdateCompanionBuilder = AppraisalsCompanion Function({
  Value<String> id,
  Value<String> hlc,
  Value<bool> deleted,
  Value<String> name,
  Value<String> kind,
  Value<String?> propertyId,
  Value<String> inputs,
  Value<String> notes,
  Value<String> updated,
  Value<int> rowid,
});

class $$AppraisalsTableFilterComposer extends Composer<_$AppDatabase, $AppraisalsTable> {
  $$AppraisalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get propertyId =>
      $composableBuilder(column: $table.propertyId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get inputs =>
      $composableBuilder(column: $table.inputs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updated =>
      $composableBuilder(column: $table.updated, builder: (column) => ColumnFilters(column));
}

class $$AppraisalsTableOrderingComposer extends Composer<_$AppDatabase, $AppraisalsTable> {
  $$AppraisalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get propertyId =>
      $composableBuilder(column: $table.propertyId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get inputs =>
      $composableBuilder(column: $table.inputs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updated =>
      $composableBuilder(column: $table.updated, builder: (column) => ColumnOrderings(column));
}

class $$AppraisalsTableAnnotationComposer extends Composer<_$AppDatabase, $AppraisalsTable> {
  $$AppraisalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hlc => $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get propertyId =>
      $composableBuilder(column: $table.propertyId, builder: (column) => column);

  GeneratedColumn<String> get inputs =>
      $composableBuilder(column: $table.inputs, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get updated =>
      $composableBuilder(column: $table.updated, builder: (column) => column);
}

class $$AppraisalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppraisalsTable,
          Appraisal,
          $$AppraisalsTableFilterComposer,
          $$AppraisalsTableOrderingComposer,
          $$AppraisalsTableAnnotationComposer,
          $$AppraisalsTableCreateCompanionBuilder,
          $$AppraisalsTableUpdateCompanionBuilder,
          (Appraisal, BaseReferences<_$AppDatabase, $AppraisalsTable, Appraisal>),
          Appraisal,
          PrefetchHooks Function()
        > {
  $$AppraisalsTableTableManager(_$AppDatabase db, $AppraisalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$AppraisalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$AppraisalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$AppraisalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> propertyId = const Value.absent(),
                Value<String> inputs = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> updated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppraisalsCompanion(
                id: id,
                hlc: hlc,
                deleted: deleted,
                name: name,
                kind: kind,
                propertyId: propertyId,
                inputs: inputs,
                notes: notes,
                updated: updated,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required String name,
                required String kind,
                Value<String?> propertyId = const Value.absent(),
                Value<String> inputs = const Value.absent(),
                Value<String> notes = const Value.absent(),
                required String updated,
                Value<int> rowid = const Value.absent(),
              }) => AppraisalsCompanion.insert(
                id: id,
                hlc: hlc,
                deleted: deleted,
                name: name,
                kind: kind,
                propertyId: propertyId,
                inputs: inputs,
                notes: notes,
                updated: updated,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppraisalsTable, Appraisal>(table),
                  BaseReferences<_$AppDatabase, $AppraisalsTable, Appraisal>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppraisalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppraisalsTable,
      Appraisal,
      $$AppraisalsTableFilterComposer,
      $$AppraisalsTableOrderingComposer,
      $$AppraisalsTableAnnotationComposer,
      $$AppraisalsTableCreateCompanionBuilder,
      $$AppraisalsTableUpdateCompanionBuilder,
      (Appraisal, BaseReferences<_$AppDatabase, $AppraisalsTable, Appraisal>),
      Appraisal,
      PrefetchHooks Function()
    >;
typedef $$TenanciesTableCreateCompanionBuilder = TenanciesCompanion Function({
  required String id,
  Value<String> hlc,
  Value<bool> deleted,
  required String propertyId,
  required String role,
  Value<String> otherParty,
  Value<String?> contactId,
  required String start,
  Value<String?> end,
  required int rent,
  Value<int> rentDay,
  Value<int> deposit,
  Value<String> depositScheme,
  Value<String> depositRef,
  Value<String> notes,
  Value<int> rowid,
});
typedef $$TenanciesTableUpdateCompanionBuilder = TenanciesCompanion Function({
  Value<String> id,
  Value<String> hlc,
  Value<bool> deleted,
  Value<String> propertyId,
  Value<String> role,
  Value<String> otherParty,
  Value<String?> contactId,
  Value<String> start,
  Value<String?> end,
  Value<int> rent,
  Value<int> rentDay,
  Value<int> deposit,
  Value<String> depositScheme,
  Value<String> depositRef,
  Value<String> notes,
  Value<int> rowid,
});

class $$TenanciesTableFilterComposer extends Composer<_$AppDatabase, $TenanciesTable> {
  $$TenanciesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get propertyId =>
      $composableBuilder(column: $table.propertyId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get otherParty =>
      $composableBuilder(column: $table.otherParty, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contactId =>
      $composableBuilder(column: $table.contactId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get start =>
      $composableBuilder(column: $table.start, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get end =>
      $composableBuilder(column: $table.end, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rent =>
      $composableBuilder(column: $table.rent, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rentDay =>
      $composableBuilder(column: $table.rentDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deposit =>
      $composableBuilder(column: $table.deposit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get depositScheme =>
      $composableBuilder(column: $table.depositScheme, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get depositRef =>
      $composableBuilder(column: $table.depositRef, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$TenanciesTableOrderingComposer extends Composer<_$AppDatabase, $TenanciesTable> {
  $$TenanciesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get propertyId =>
      $composableBuilder(column: $table.propertyId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get otherParty =>
      $composableBuilder(column: $table.otherParty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contactId =>
      $composableBuilder(column: $table.contactId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get start =>
      $composableBuilder(column: $table.start, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get end =>
      $composableBuilder(column: $table.end, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rent =>
      $composableBuilder(column: $table.rent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rentDay =>
      $composableBuilder(column: $table.rentDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deposit =>
      $composableBuilder(column: $table.deposit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get depositScheme =>
      $composableBuilder(column: $table.depositScheme, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get depositRef =>
      $composableBuilder(column: $table.depositRef, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$TenanciesTableAnnotationComposer extends Composer<_$AppDatabase, $TenanciesTable> {
  $$TenanciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hlc => $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get propertyId =>
      $composableBuilder(column: $table.propertyId, builder: (column) => column);

  GeneratedColumn<String> get role => $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get otherParty =>
      $composableBuilder(column: $table.otherParty, builder: (column) => column);

  GeneratedColumn<String> get contactId =>
      $composableBuilder(column: $table.contactId, builder: (column) => column);

  GeneratedColumn<String> get start => $composableBuilder(column: $table.start, builder: (column) => column);

  GeneratedColumn<String> get end => $composableBuilder(column: $table.end, builder: (column) => column);

  GeneratedColumn<int> get rent => $composableBuilder(column: $table.rent, builder: (column) => column);

  GeneratedColumn<int> get rentDay => $composableBuilder(column: $table.rentDay, builder: (column) => column);

  GeneratedColumn<int> get deposit => $composableBuilder(column: $table.deposit, builder: (column) => column);

  GeneratedColumn<String> get depositScheme =>
      $composableBuilder(column: $table.depositScheme, builder: (column) => column);

  GeneratedColumn<String> get depositRef =>
      $composableBuilder(column: $table.depositRef, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$TenanciesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TenanciesTable,
          Tenancy,
          $$TenanciesTableFilterComposer,
          $$TenanciesTableOrderingComposer,
          $$TenanciesTableAnnotationComposer,
          $$TenanciesTableCreateCompanionBuilder,
          $$TenanciesTableUpdateCompanionBuilder,
          (Tenancy, BaseReferences<_$AppDatabase, $TenanciesTable, Tenancy>),
          Tenancy,
          PrefetchHooks Function()
        > {
  $$TenanciesTableTableManager(_$AppDatabase db, $TenanciesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$TenanciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$TenanciesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$TenanciesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> propertyId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> otherParty = const Value.absent(),
                Value<String?> contactId = const Value.absent(),
                Value<String> start = const Value.absent(),
                Value<String?> end = const Value.absent(),
                Value<int> rent = const Value.absent(),
                Value<int> rentDay = const Value.absent(),
                Value<int> deposit = const Value.absent(),
                Value<String> depositScheme = const Value.absent(),
                Value<String> depositRef = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TenanciesCompanion(
                id: id,
                hlc: hlc,
                deleted: deleted,
                propertyId: propertyId,
                role: role,
                otherParty: otherParty,
                contactId: contactId,
                start: start,
                end: end,
                rent: rent,
                rentDay: rentDay,
                deposit: deposit,
                depositScheme: depositScheme,
                depositRef: depositRef,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required String propertyId,
                required String role,
                Value<String> otherParty = const Value.absent(),
                Value<String?> contactId = const Value.absent(),
                required String start,
                Value<String?> end = const Value.absent(),
                required int rent,
                Value<int> rentDay = const Value.absent(),
                Value<int> deposit = const Value.absent(),
                Value<String> depositScheme = const Value.absent(),
                Value<String> depositRef = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TenanciesCompanion.insert(
                id: id,
                hlc: hlc,
                deleted: deleted,
                propertyId: propertyId,
                role: role,
                otherParty: otherParty,
                contactId: contactId,
                start: start,
                end: end,
                rent: rent,
                rentDay: rentDay,
                deposit: deposit,
                depositScheme: depositScheme,
                depositRef: depositRef,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TenanciesTable, Tenancy>(table),
                  BaseReferences<_$AppDatabase, $TenanciesTable, Tenancy>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TenanciesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TenanciesTable,
      Tenancy,
      $$TenanciesTableFilterComposer,
      $$TenanciesTableOrderingComposer,
      $$TenanciesTableAnnotationComposer,
      $$TenanciesTableCreateCompanionBuilder,
      $$TenanciesTableUpdateCompanionBuilder,
      (Tenancy, BaseReferences<_$AppDatabase, $TenanciesTable, Tenancy>),
      Tenancy,
      PrefetchHooks Function()
    >;
typedef $$RentPaymentsTableCreateCompanionBuilder = RentPaymentsCompanion Function({
  required String id,
  Value<String> hlc,
  Value<bool> deleted,
  required String tenancyId,
  required String date,
  required int amount,
  Value<String> note,
  Value<int> rowid,
});
typedef $$RentPaymentsTableUpdateCompanionBuilder = RentPaymentsCompanion Function({
  Value<String> id,
  Value<String> hlc,
  Value<bool> deleted,
  Value<String> tenancyId,
  Value<String> date,
  Value<int> amount,
  Value<String> note,
  Value<int> rowid,
});

class $$RentPaymentsTableFilterComposer extends Composer<_$AppDatabase, $RentPaymentsTable> {
  $$RentPaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenancyId =>
      $composableBuilder(column: $table.tenancyId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnFilters(column));
}

class $$RentPaymentsTableOrderingComposer extends Composer<_$AppDatabase, $RentPaymentsTable> {
  $$RentPaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenancyId =>
      $composableBuilder(column: $table.tenancyId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnOrderings(column));
}

class $$RentPaymentsTableAnnotationComposer extends Composer<_$AppDatabase, $RentPaymentsTable> {
  $$RentPaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hlc => $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get tenancyId =>
      $composableBuilder(column: $table.tenancyId, builder: (column) => column);

  GeneratedColumn<String> get date => $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get amount => $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get note => $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$RentPaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RentPaymentsTable,
          RentPayment,
          $$RentPaymentsTableFilterComposer,
          $$RentPaymentsTableOrderingComposer,
          $$RentPaymentsTableAnnotationComposer,
          $$RentPaymentsTableCreateCompanionBuilder,
          $$RentPaymentsTableUpdateCompanionBuilder,
          (RentPayment, BaseReferences<_$AppDatabase, $RentPaymentsTable, RentPayment>),
          RentPayment,
          PrefetchHooks Function()
        > {
  $$RentPaymentsTableTableManager(_$AppDatabase db, $RentPaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$RentPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$RentPaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$RentPaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> tenancyId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RentPaymentsCompanion(
                id: id,
                hlc: hlc,
                deleted: deleted,
                tenancyId: tenancyId,
                date: date,
                amount: amount,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required String tenancyId,
                required String date,
                required int amount,
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RentPaymentsCompanion.insert(
                id: id,
                hlc: hlc,
                deleted: deleted,
                tenancyId: tenancyId,
                date: date,
                amount: amount,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RentPaymentsTable, RentPayment>(table),
                  BaseReferences<_$AppDatabase, $RentPaymentsTable, RentPayment>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RentPaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RentPaymentsTable,
      RentPayment,
      $$RentPaymentsTableFilterComposer,
      $$RentPaymentsTableOrderingComposer,
      $$RentPaymentsTableAnnotationComposer,
      $$RentPaymentsTableCreateCompanionBuilder,
      $$RentPaymentsTableUpdateCompanionBuilder,
      (RentPayment, BaseReferences<_$AppDatabase, $RentPaymentsTable, RentPayment>),
      RentPayment,
      PrefetchHooks Function()
    >;
typedef $$ComplianceItemsTableCreateCompanionBuilder = ComplianceItemsCompanion Function({
  required String id,
  Value<String> hlc,
  Value<bool> deleted,
  required String propertyId,
  required String kind,
  required String due,
  Value<String?> done,
  Value<String> notes,
  Value<int> rowid,
});
typedef $$ComplianceItemsTableUpdateCompanionBuilder = ComplianceItemsCompanion Function({
  Value<String> id,
  Value<String> hlc,
  Value<bool> deleted,
  Value<String> propertyId,
  Value<String> kind,
  Value<String> due,
  Value<String?> done,
  Value<String> notes,
  Value<int> rowid,
});

class $$ComplianceItemsTableFilterComposer extends Composer<_$AppDatabase, $ComplianceItemsTable> {
  $$ComplianceItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get propertyId =>
      $composableBuilder(column: $table.propertyId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get due =>
      $composableBuilder(column: $table.due, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get done =>
      $composableBuilder(column: $table.done, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$ComplianceItemsTableOrderingComposer extends Composer<_$AppDatabase, $ComplianceItemsTable> {
  $$ComplianceItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get propertyId =>
      $composableBuilder(column: $table.propertyId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get due =>
      $composableBuilder(column: $table.due, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get done =>
      $composableBuilder(column: $table.done, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$ComplianceItemsTableAnnotationComposer extends Composer<_$AppDatabase, $ComplianceItemsTable> {
  $$ComplianceItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hlc => $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get propertyId =>
      $composableBuilder(column: $table.propertyId, builder: (column) => column);

  GeneratedColumn<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get due => $composableBuilder(column: $table.due, builder: (column) => column);

  GeneratedColumn<String> get done => $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$ComplianceItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ComplianceItemsTable,
          ComplianceItem,
          $$ComplianceItemsTableFilterComposer,
          $$ComplianceItemsTableOrderingComposer,
          $$ComplianceItemsTableAnnotationComposer,
          $$ComplianceItemsTableCreateCompanionBuilder,
          $$ComplianceItemsTableUpdateCompanionBuilder,
          (ComplianceItem, BaseReferences<_$AppDatabase, $ComplianceItemsTable, ComplianceItem>),
          ComplianceItem,
          PrefetchHooks Function()
        > {
  $$ComplianceItemsTableTableManager(_$AppDatabase db, $ComplianceItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ComplianceItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ComplianceItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ComplianceItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> propertyId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> due = const Value.absent(),
                Value<String?> done = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ComplianceItemsCompanion(
                id: id,
                hlc: hlc,
                deleted: deleted,
                propertyId: propertyId,
                kind: kind,
                due: due,
                done: done,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required String propertyId,
                required String kind,
                required String due,
                Value<String?> done = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ComplianceItemsCompanion.insert(
                id: id,
                hlc: hlc,
                deleted: deleted,
                propertyId: propertyId,
                kind: kind,
                due: due,
                done: done,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ComplianceItemsTable, ComplianceItem>(table),
                  BaseReferences<_$AppDatabase, $ComplianceItemsTable, ComplianceItem>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ComplianceItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ComplianceItemsTable,
      ComplianceItem,
      $$ComplianceItemsTableFilterComposer,
      $$ComplianceItemsTableOrderingComposer,
      $$ComplianceItemsTableAnnotationComposer,
      $$ComplianceItemsTableCreateCompanionBuilder,
      $$ComplianceItemsTableUpdateCompanionBuilder,
      (ComplianceItem, BaseReferences<_$AppDatabase, $ComplianceItemsTable, ComplianceItem>),
      ComplianceItem,
      PrefetchHooks Function()
    >;
typedef $$AreasTableCreateCompanionBuilder = AreasCompanion Function({
  required String id,
  Value<String> hlc,
  Value<bool> deleted,
  required String postcode,
  Value<String> label,
  Value<String> report,
  required String fetched,
  Value<String> notes,
  Value<int> rowid,
});
typedef $$AreasTableUpdateCompanionBuilder = AreasCompanion Function({
  Value<String> id,
  Value<String> hlc,
  Value<bool> deleted,
  Value<String> postcode,
  Value<String> label,
  Value<String> report,
  Value<String> fetched,
  Value<String> notes,
  Value<int> rowid,
});

class $$AreasTableFilterComposer extends Composer<_$AppDatabase, $AreasTable> {
  $$AreasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get postcode =>
      $composableBuilder(column: $table.postcode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get report =>
      $composableBuilder(column: $table.report, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fetched =>
      $composableBuilder(column: $table.fetched, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$AreasTableOrderingComposer extends Composer<_$AppDatabase, $AreasTable> {
  $$AreasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get postcode =>
      $composableBuilder(column: $table.postcode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get report =>
      $composableBuilder(column: $table.report, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fetched =>
      $composableBuilder(column: $table.fetched, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$AreasTableAnnotationComposer extends Composer<_$AppDatabase, $AreasTable> {
  $$AreasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hlc => $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get postcode =>
      $composableBuilder(column: $table.postcode, builder: (column) => column);

  GeneratedColumn<String> get label => $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get report =>
      $composableBuilder(column: $table.report, builder: (column) => column);

  GeneratedColumn<String> get fetched =>
      $composableBuilder(column: $table.fetched, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$AreasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AreasTable,
          Area,
          $$AreasTableFilterComposer,
          $$AreasTableOrderingComposer,
          $$AreasTableAnnotationComposer,
          $$AreasTableCreateCompanionBuilder,
          $$AreasTableUpdateCompanionBuilder,
          (Area, BaseReferences<_$AppDatabase, $AreasTable, Area>),
          Area,
          PrefetchHooks Function()
        > {
  $$AreasTableTableManager(_$AppDatabase db, $AreasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$AreasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$AreasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$AreasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> postcode = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> report = const Value.absent(),
                Value<String> fetched = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AreasCompanion(
                id: id,
                hlc: hlc,
                deleted: deleted,
                postcode: postcode,
                label: label,
                report: report,
                fetched: fetched,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required String postcode,
                Value<String> label = const Value.absent(),
                Value<String> report = const Value.absent(),
                required String fetched,
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AreasCompanion.insert(
                id: id,
                hlc: hlc,
                deleted: deleted,
                postcode: postcode,
                label: label,
                report: report,
                fetched: fetched,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AreasTable, Area>(table),
                  BaseReferences<_$AppDatabase, $AreasTable, Area>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AreasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AreasTable,
      Area,
      $$AreasTableFilterComposer,
      $$AreasTableOrderingComposer,
      $$AreasTableAnnotationComposer,
      $$AreasTableCreateCompanionBuilder,
      $$AreasTableUpdateCompanionBuilder,
      (Area, BaseReferences<_$AppDatabase, $AreasTable, Area>),
      Area,
      PrefetchHooks Function()
    >;
typedef $$ResearchesTableCreateCompanionBuilder = ResearchesCompanion Function({
  required String id,
  Value<String> hlc,
  Value<bool> deleted,
  required String name,
  Value<String> kind,
  Value<String> criteria,
  Value<String> notes,
  Value<bool> archived,
  required String created,
  Value<int> rowid,
});
typedef $$ResearchesTableUpdateCompanionBuilder = ResearchesCompanion Function({
  Value<String> id,
  Value<String> hlc,
  Value<bool> deleted,
  Value<String> name,
  Value<String> kind,
  Value<String> criteria,
  Value<String> notes,
  Value<bool> archived,
  Value<String> created,
  Value<int> rowid,
});

class $$ResearchesTableFilterComposer extends Composer<_$AppDatabase, $ResearchesTable> {
  $$ResearchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get criteria =>
      $composableBuilder(column: $table.criteria, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get created =>
      $composableBuilder(column: $table.created, builder: (column) => ColumnFilters(column));
}

class $$ResearchesTableOrderingComposer extends Composer<_$AppDatabase, $ResearchesTable> {
  $$ResearchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get criteria =>
      $composableBuilder(column: $table.criteria, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get created =>
      $composableBuilder(column: $table.created, builder: (column) => ColumnOrderings(column));
}

class $$ResearchesTableAnnotationComposer extends Composer<_$AppDatabase, $ResearchesTable> {
  $$ResearchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hlc => $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get criteria =>
      $composableBuilder(column: $table.criteria, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<String> get created =>
      $composableBuilder(column: $table.created, builder: (column) => column);
}

class $$ResearchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResearchesTable,
          ResearchJob,
          $$ResearchesTableFilterComposer,
          $$ResearchesTableOrderingComposer,
          $$ResearchesTableAnnotationComposer,
          $$ResearchesTableCreateCompanionBuilder,
          $$ResearchesTableUpdateCompanionBuilder,
          (ResearchJob, BaseReferences<_$AppDatabase, $ResearchesTable, ResearchJob>),
          ResearchJob,
          PrefetchHooks Function()
        > {
  $$ResearchesTableTableManager(_$AppDatabase db, $ResearchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ResearchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ResearchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ResearchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> criteria = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<String> created = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResearchesCompanion(
                id: id,
                hlc: hlc,
                deleted: deleted,
                name: name,
                kind: kind,
                criteria: criteria,
                notes: notes,
                archived: archived,
                created: created,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required String name,
                Value<String> kind = const Value.absent(),
                Value<String> criteria = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                required String created,
                Value<int> rowid = const Value.absent(),
              }) => ResearchesCompanion.insert(
                id: id,
                hlc: hlc,
                deleted: deleted,
                name: name,
                kind: kind,
                criteria: criteria,
                notes: notes,
                archived: archived,
                created: created,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ResearchesTable, ResearchJob>(table),
                  BaseReferences<_$AppDatabase, $ResearchesTable, ResearchJob>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ResearchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResearchesTable,
      ResearchJob,
      $$ResearchesTableFilterComposer,
      $$ResearchesTableOrderingComposer,
      $$ResearchesTableAnnotationComposer,
      $$ResearchesTableCreateCompanionBuilder,
      $$ResearchesTableUpdateCompanionBuilder,
      (ResearchJob, BaseReferences<_$AppDatabase, $ResearchesTable, ResearchJob>),
      ResearchJob,
      PrefetchHooks Function()
    >;
typedef $$CatalogItemsTableCreateCompanionBuilder = CatalogItemsCompanion Function({
  required String id,
  Value<String> hlc,
  Value<bool> deleted,
  required String researchId,
  Value<String?> propertyId,
  required String kind,
  Value<String> title,
  Value<String> url,
  Value<String> source,
  Value<String?> sourceId,
  Value<String> address,
  Value<String> postcode,
  Value<int?> price,
  Value<int?> beds,
  Value<int?> baths,
  Value<String> fields,
  Value<String> body,
  Value<String?> imageHash,
  Value<String> notes,
  required String captured,
  Value<int> rowid,
});
typedef $$CatalogItemsTableUpdateCompanionBuilder = CatalogItemsCompanion Function({
  Value<String> id,
  Value<String> hlc,
  Value<bool> deleted,
  Value<String> researchId,
  Value<String?> propertyId,
  Value<String> kind,
  Value<String> title,
  Value<String> url,
  Value<String> source,
  Value<String?> sourceId,
  Value<String> address,
  Value<String> postcode,
  Value<int?> price,
  Value<int?> beds,
  Value<int?> baths,
  Value<String> fields,
  Value<String> body,
  Value<String?> imageHash,
  Value<String> notes,
  Value<String> captured,
  Value<int> rowid,
});

class $$CatalogItemsTableFilterComposer extends Composer<_$AppDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get researchId =>
      $composableBuilder(column: $table.researchId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get propertyId =>
      $composableBuilder(column: $table.propertyId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get postcode =>
      $composableBuilder(column: $table.postcode, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get price =>
      $composableBuilder(column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get beds =>
      $composableBuilder(column: $table.beds, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get baths =>
      $composableBuilder(column: $table.baths, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fields =>
      $composableBuilder(column: $table.fields, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageHash =>
      $composableBuilder(column: $table.imageHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get captured =>
      $composableBuilder(column: $table.captured, builder: (column) => ColumnFilters(column));
}

class $$CatalogItemsTableOrderingComposer extends Composer<_$AppDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get researchId =>
      $composableBuilder(column: $table.researchId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get propertyId =>
      $composableBuilder(column: $table.propertyId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get postcode =>
      $composableBuilder(column: $table.postcode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get price =>
      $composableBuilder(column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get beds =>
      $composableBuilder(column: $table.beds, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get baths =>
      $composableBuilder(column: $table.baths, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fields =>
      $composableBuilder(column: $table.fields, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageHash =>
      $composableBuilder(column: $table.imageHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get captured =>
      $composableBuilder(column: $table.captured, builder: (column) => ColumnOrderings(column));
}

class $$CatalogItemsTableAnnotationComposer extends Composer<_$AppDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hlc => $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get researchId =>
      $composableBuilder(column: $table.researchId, builder: (column) => column);

  GeneratedColumn<String> get propertyId =>
      $composableBuilder(column: $table.propertyId, builder: (column) => column);

  GeneratedColumn<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get url => $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get postcode =>
      $composableBuilder(column: $table.postcode, builder: (column) => column);

  GeneratedColumn<int> get price => $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<int> get beds => $composableBuilder(column: $table.beds, builder: (column) => column);

  GeneratedColumn<int> get baths => $composableBuilder(column: $table.baths, builder: (column) => column);

  GeneratedColumn<String> get fields =>
      $composableBuilder(column: $table.fields, builder: (column) => column);

  GeneratedColumn<String> get body => $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get imageHash =>
      $composableBuilder(column: $table.imageHash, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get captured =>
      $composableBuilder(column: $table.captured, builder: (column) => column);
}

class $$CatalogItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatalogItemsTable,
          CatalogItem,
          $$CatalogItemsTableFilterComposer,
          $$CatalogItemsTableOrderingComposer,
          $$CatalogItemsTableAnnotationComposer,
          $$CatalogItemsTableCreateCompanionBuilder,
          $$CatalogItemsTableUpdateCompanionBuilder,
          (CatalogItem, BaseReferences<_$AppDatabase, $CatalogItemsTable, CatalogItem>),
          CatalogItem,
          PrefetchHooks Function()
        > {
  $$CatalogItemsTableTableManager(_$AppDatabase db, $CatalogItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$CatalogItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$CatalogItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$CatalogItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> researchId = const Value.absent(),
                Value<String?> propertyId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> postcode = const Value.absent(),
                Value<int?> price = const Value.absent(),
                Value<int?> beds = const Value.absent(),
                Value<int?> baths = const Value.absent(),
                Value<String> fields = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> imageHash = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> captured = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogItemsCompanion(
                id: id,
                hlc: hlc,
                deleted: deleted,
                researchId: researchId,
                propertyId: propertyId,
                kind: kind,
                title: title,
                url: url,
                source: source,
                sourceId: sourceId,
                address: address,
                postcode: postcode,
                price: price,
                beds: beds,
                baths: baths,
                fields: fields,
                body: body,
                imageHash: imageHash,
                notes: notes,
                captured: captured,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required String researchId,
                Value<String?> propertyId = const Value.absent(),
                required String kind,
                Value<String> title = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> postcode = const Value.absent(),
                Value<int?> price = const Value.absent(),
                Value<int?> beds = const Value.absent(),
                Value<int?> baths = const Value.absent(),
                Value<String> fields = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> imageHash = const Value.absent(),
                Value<String> notes = const Value.absent(),
                required String captured,
                Value<int> rowid = const Value.absent(),
              }) => CatalogItemsCompanion.insert(
                id: id,
                hlc: hlc,
                deleted: deleted,
                researchId: researchId,
                propertyId: propertyId,
                kind: kind,
                title: title,
                url: url,
                source: source,
                sourceId: sourceId,
                address: address,
                postcode: postcode,
                price: price,
                beds: beds,
                baths: baths,
                fields: fields,
                body: body,
                imageHash: imageHash,
                notes: notes,
                captured: captured,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CatalogItemsTable, CatalogItem>(table),
                  BaseReferences<_$AppDatabase, $CatalogItemsTable, CatalogItem>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CatalogItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatalogItemsTable,
      CatalogItem,
      $$CatalogItemsTableFilterComposer,
      $$CatalogItemsTableOrderingComposer,
      $$CatalogItemsTableAnnotationComposer,
      $$CatalogItemsTableCreateCompanionBuilder,
      $$CatalogItemsTableUpdateCompanionBuilder,
      (CatalogItem, BaseReferences<_$AppDatabase, $CatalogItemsTable, CatalogItem>),
      CatalogItem,
      PrefetchHooks Function()
    >;
typedef $$CatalogImagesTableCreateCompanionBuilder = CatalogImagesCompanion Function({
  required String itemId,
  required Uint8List bytes,
  Value<int> rowid,
});
typedef $$CatalogImagesTableUpdateCompanionBuilder = CatalogImagesCompanion Function({
  Value<String> itemId,
  Value<Uint8List> bytes,
  Value<int> rowid,
});

class $$CatalogImagesTableFilterComposer extends Composer<_$AppDatabase, $CatalogImagesTable> {
  $$CatalogImagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => ColumnFilters(column));
}

class $$CatalogImagesTableOrderingComposer extends Composer<_$AppDatabase, $CatalogImagesTable> {
  $$CatalogImagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => ColumnOrderings(column));
}

class $$CatalogImagesTableAnnotationComposer extends Composer<_$AppDatabase, $CatalogImagesTable> {
  $$CatalogImagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<Uint8List> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);
}

class $$CatalogImagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatalogImagesTable,
          CatalogImage,
          $$CatalogImagesTableFilterComposer,
          $$CatalogImagesTableOrderingComposer,
          $$CatalogImagesTableAnnotationComposer,
          $$CatalogImagesTableCreateCompanionBuilder,
          $$CatalogImagesTableUpdateCompanionBuilder,
          (CatalogImage, BaseReferences<_$AppDatabase, $CatalogImagesTable, CatalogImage>),
          CatalogImage,
          PrefetchHooks Function()
        > {
  $$CatalogImagesTableTableManager(_$AppDatabase db, $CatalogImagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$CatalogImagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$CatalogImagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$CatalogImagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> itemId = const Value.absent(),
            Value<Uint8List> bytes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => CatalogImagesCompanion(itemId: itemId, bytes: bytes, rowid: rowid),
          createCompanionCallback: ({
            required String itemId,
            required Uint8List bytes,
            Value<int> rowid = const Value.absent(),
          }) => CatalogImagesCompanion.insert(itemId: itemId, bytes: bytes, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CatalogImagesTable, CatalogImage>(table),
                  BaseReferences<_$AppDatabase, $CatalogImagesTable, CatalogImage>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CatalogImagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatalogImagesTable,
      CatalogImage,
      $$CatalogImagesTableFilterComposer,
      $$CatalogImagesTableOrderingComposer,
      $$CatalogImagesTableAnnotationComposer,
      $$CatalogImagesTableCreateCompanionBuilder,
      $$CatalogImagesTableUpdateCompanionBuilder,
      (CatalogImage, BaseReferences<_$AppDatabase, $CatalogImagesTable, CatalogImage>),
      CatalogImage,
      PrefetchHooks Function()
    >;
typedef $$PrefsTableCreateCompanionBuilder = PrefsCompanion Function({
  required String id,
  Value<String> hlc,
  Value<bool> deleted,
  required String value,
  Value<int> rowid,
});
typedef $$PrefsTableUpdateCompanionBuilder = PrefsCompanion Function({
  Value<String> id,
  Value<String> hlc,
  Value<bool> deleted,
  Value<String> value,
  Value<int> rowid,
});

class $$PrefsTableFilterComposer extends Composer<_$AppDatabase, $PrefsTable> {
  $$PrefsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$PrefsTableOrderingComposer extends Composer<_$AppDatabase, $PrefsTable> {
  $$PrefsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$PrefsTableAnnotationComposer extends Composer<_$AppDatabase, $PrefsTable> {
  $$PrefsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hlc => $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get value => $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$PrefsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrefsTable,
          Pref,
          $$PrefsTableFilterComposer,
          $$PrefsTableOrderingComposer,
          $$PrefsTableAnnotationComposer,
          $$PrefsTableCreateCompanionBuilder,
          $$PrefsTableUpdateCompanionBuilder,
          (Pref, BaseReferences<_$AppDatabase, $PrefsTable, Pref>),
          Pref,
          PrefetchHooks Function()
        > {
  $$PrefsTableTableManager(_$AppDatabase db, $PrefsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$PrefsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$PrefsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$PrefsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> hlc = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => PrefsCompanion(id: id, hlc: hlc, deleted: deleted, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String id,
            Value<String> hlc = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => PrefsCompanion.insert(id: id, hlc: hlc, deleted: deleted, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PrefsTable, Pref>(table),
                  BaseReferences<_$AppDatabase, $PrefsTable, Pref>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PrefsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrefsTable,
      Pref,
      $$PrefsTableFilterComposer,
      $$PrefsTableOrderingComposer,
      $$PrefsTableAnnotationComposer,
      $$PrefsTableCreateCompanionBuilder,
      $$PrefsTableUpdateCompanionBuilder,
      (Pref, BaseReferences<_$AppDatabase, $PrefsTable, Pref>),
      Pref,
      PrefetchHooks Function()
    >;
typedef $$OutboxTableCreateCompanionBuilder = OutboxCompanion Function({
  required String entity,
  required String rowId,
  Value<int?> seq,
  Value<int> rowid,
});
typedef $$OutboxTableUpdateCompanionBuilder = OutboxCompanion Function({
  Value<String> entity,
  Value<String> rowId,
  Value<int?> seq,
  Value<int> rowid,
});

class $$OutboxTableFilterComposer extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => ColumnFilters(column));
}

class $$OutboxTableOrderingComposer extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => ColumnOrderings(column));
}

class $$OutboxTableAnnotationComposer extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get rowId => $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<int> get seq => $composableBuilder(column: $table.seq, builder: (column) => column);
}

class $$OutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxTable,
          OutboxItem,
          $$OutboxTableFilterComposer,
          $$OutboxTableOrderingComposer,
          $$OutboxTableAnnotationComposer,
          $$OutboxTableCreateCompanionBuilder,
          $$OutboxTableUpdateCompanionBuilder,
          (OutboxItem, BaseReferences<_$AppDatabase, $OutboxTable, OutboxItem>),
          OutboxItem,
          PrefetchHooks Function()
        > {
  $$OutboxTableTableManager(_$AppDatabase db, $OutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> entity = const Value.absent(),
            Value<String> rowId = const Value.absent(),
            Value<int?> seq = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => OutboxCompanion(entity: entity, rowId: rowId, seq: seq, rowid: rowid),
          createCompanionCallback: ({
            required String entity,
            required String rowId,
            Value<int?> seq = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => OutboxCompanion.insert(entity: entity, rowId: rowId, seq: seq, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutboxTable, OutboxItem>(table),
                  BaseReferences<_$AppDatabase, $OutboxTable, OutboxItem>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxTable,
      OutboxItem,
      $$OutboxTableFilterComposer,
      $$OutboxTableOrderingComposer,
      $$OutboxTableAnnotationComposer,
      $$OutboxTableCreateCompanionBuilder,
      $$OutboxTableUpdateCompanionBuilder,
      (OutboxItem, BaseReferences<_$AppDatabase, $OutboxTable, OutboxItem>),
      OutboxItem,
      PrefetchHooks Function()
    >;
typedef $$SyncCursorsTableCreateCompanionBuilder = SyncCursorsCompanion Function({
  required String deviceId,
  required int seq,
  Value<int> rowid,
});
typedef $$SyncCursorsTableUpdateCompanionBuilder = SyncCursorsCompanion Function({
  Value<String> deviceId,
  Value<int> seq,
  Value<int> rowid,
});

class $$SyncCursorsTableFilterComposer extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => ColumnFilters(column));
}

class $$SyncCursorsTableOrderingComposer extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => ColumnOrderings(column));
}

class $$SyncCursorsTableAnnotationComposer extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get seq => $composableBuilder(column: $table.seq, builder: (column) => column);
}

class $$SyncCursorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncCursorsTable,
          SyncCursor,
          $$SyncCursorsTableFilterComposer,
          $$SyncCursorsTableOrderingComposer,
          $$SyncCursorsTableAnnotationComposer,
          $$SyncCursorsTableCreateCompanionBuilder,
          $$SyncCursorsTableUpdateCompanionBuilder,
          (SyncCursor, BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>),
          SyncCursor,
          PrefetchHooks Function()
        > {
  $$SyncCursorsTableTableManager(_$AppDatabase db, $SyncCursorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SyncCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SyncCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SyncCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> deviceId = const Value.absent(),
            Value<int> seq = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SyncCursorsCompanion(deviceId: deviceId, seq: seq, rowid: rowid),
          createCompanionCallback: ({
            required String deviceId,
            required int seq,
            Value<int> rowid = const Value.absent(),
          }) => SyncCursorsCompanion.insert(deviceId: deviceId, seq: seq, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncCursorsTable, SyncCursor>(table),
                  BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncCursorsTable,
      SyncCursor,
      $$SyncCursorsTableFilterComposer,
      $$SyncCursorsTableOrderingComposer,
      $$SyncCursorsTableAnnotationComposer,
      $$SyncCursorsTableCreateCompanionBuilder,
      $$SyncCursorsTableUpdateCompanionBuilder,
      (SyncCursor, BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>),
      SyncCursor,
      PrefetchHooks Function()
    >;
typedef $$LocalSettingsTableCreateCompanionBuilder = LocalSettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$LocalSettingsTableUpdateCompanionBuilder = LocalSettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$LocalSettingsTableFilterComposer extends Composer<_$AppDatabase, $LocalSettingsTable> {
  $$LocalSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$LocalSettingsTableOrderingComposer extends Composer<_$AppDatabase, $LocalSettingsTable> {
  $$LocalSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$LocalSettingsTableAnnotationComposer extends Composer<_$AppDatabase, $LocalSettingsTable> {
  $$LocalSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key => $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value => $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$LocalSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSettingsTable,
          LocalSetting,
          $$LocalSettingsTableFilterComposer,
          $$LocalSettingsTableOrderingComposer,
          $$LocalSettingsTableAnnotationComposer,
          $$LocalSettingsTableCreateCompanionBuilder,
          $$LocalSettingsTableUpdateCompanionBuilder,
          (LocalSetting, BaseReferences<_$AppDatabase, $LocalSettingsTable, LocalSetting>),
          LocalSetting,
          PrefetchHooks Function()
        > {
  $$LocalSettingsTableTableManager(_$AppDatabase db, $LocalSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$LocalSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$LocalSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$LocalSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => LocalSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => LocalSettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalSettingsTable, LocalSetting>(table),
                  BaseReferences<_$AppDatabase, $LocalSettingsTable, LocalSetting>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSettingsTable,
      LocalSetting,
      $$LocalSettingsTableFilterComposer,
      $$LocalSettingsTableOrderingComposer,
      $$LocalSettingsTableAnnotationComposer,
      $$LocalSettingsTableCreateCompanionBuilder,
      $$LocalSettingsTableUpdateCompanionBuilder,
      (LocalSetting, BaseReferences<_$AppDatabase, $LocalSettingsTable, LocalSetting>),
      LocalSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PropertiesTableTableManager get properties => $$PropertiesTableTableManager(_db, _db.properties);
  $$ContactsTableTableManager get contacts => $$ContactsTableTableManager(_db, _db.contacts);
  $$InteractionsTableTableManager get interactions => $$InteractionsTableTableManager(_db, _db.interactions);
  $$ViewingsTableTableManager get viewings => $$ViewingsTableTableManager(_db, _db.viewings);
  $$SearchesTableTableManager get searches => $$SearchesTableTableManager(_db, _db.searches);
  $$AppraisalsTableTableManager get appraisals => $$AppraisalsTableTableManager(_db, _db.appraisals);
  $$TenanciesTableTableManager get tenancies => $$TenanciesTableTableManager(_db, _db.tenancies);
  $$RentPaymentsTableTableManager get rentPayments => $$RentPaymentsTableTableManager(_db, _db.rentPayments);
  $$ComplianceItemsTableTableManager get complianceItems =>
      $$ComplianceItemsTableTableManager(_db, _db.complianceItems);
  $$AreasTableTableManager get areas => $$AreasTableTableManager(_db, _db.areas);
  $$ResearchesTableTableManager get researches => $$ResearchesTableTableManager(_db, _db.researches);
  $$CatalogItemsTableTableManager get catalogItems => $$CatalogItemsTableTableManager(_db, _db.catalogItems);
  $$CatalogImagesTableTableManager get catalogImages =>
      $$CatalogImagesTableTableManager(_db, _db.catalogImages);
  $$PrefsTableTableManager get prefs => $$PrefsTableTableManager(_db, _db.prefs);
  $$OutboxTableTableManager get outbox => $$OutboxTableTableManager(_db, _db.outbox);
  $$SyncCursorsTableTableManager get syncCursors => $$SyncCursorsTableTableManager(_db, _db.syncCursors);
  $$LocalSettingsTableTableManager get localSettings =>
      $$LocalSettingsTableTableManager(_db, _db.localSettings);
}
