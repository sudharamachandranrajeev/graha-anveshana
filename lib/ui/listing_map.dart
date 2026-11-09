import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../app/search_controller.dart';
import '../app/search_memory.dart';
import '../domain/listing.dart';
import '../domain/research.dart';
import 'common.dart';
import 'homes_map.dart';

/// The places a home page always offers to measure from: the user's home
/// point (Settings) and [centre], the search's place.
List<NamedPoint> anchorPlaces(WidgetRef ref, {NamedPoint? centre}) {
  final home = ref.watch(homeProvider).value;
  return [
    if (home != null) (lat: home.lat, lon: home.lon, label: home.label.isEmpty ? 'Home' : home.label),
    if (centre != null && centre.label != home?.label) centre,
  ];
}

/// A link that opens directions from [from] to [to] in Google Maps, which
/// gives the distance and time by road, public transport, bike or on foot.
Uri directionsUrl(NamedPoint from, ({double lat, double lon}) to) => Uri.https(
  'www.google.com',
  '/maps/dir/',
  {'api': '1', 'origin': '${from.lat},${from.lon}', 'destination': '${to.lat},${to.lon}'},
);

/// One home on a map, and how far it is from a place the user picks: their
/// home point, the search's centre, a place they measured from before, or
/// any postcode or town. The last place picked is used on the next home.
class ListingMap extends ConsumerStatefulWidget {
  const ListingMap({
    super.key,
    required this.label,
    this.lat,
    this.lon,
    this.postcode = '',
    this.address = '',
    this.anchors = const [],
  });

  /// What the home's pin shows ("£850").
  final String label;
  final double? lat, lon;
  final String postcode, address;

  /// Places always offered ([anchorPlaces]).
  final List<NamedPoint> anchors;

  @override
  ConsumerState<ListingMap> createState() => _ListingMapState();
}

class _ListingMapState extends ConsumerState<ListingMap> {
  /// The place picked on this page; null: the last one used.
  NamedPoint? _picked;

  /// Where the home is; [rough]: only its postcode district is known.
  ({double lat, double lon, bool rough})? _at;
  var _looking = false;

  late final _place = MapHome(label: widget.label, postcode: widget.postcode, address: widget.address).place;

  @override
  void initState() {
    super.initState();
    if (widget.lat != null && widget.lon != null) {
      _at = (lat: widget.lat!, lon: widget.lon!, rough: false);
    } else if (_place case final place?) {
      _looking = true;
      _lookUp(place);
    }
  }

  Future<void> _lookUp(String place) async {
    try {
      final got = await Research(client: ref.read(searchHttpProvider)).pointsFor({place});
      if (got[place] case final p? when mounted) {
        setState(() => _at = (lat: p.lat, lon: p.lon, rough: postcodeIn(place) == null));
      }
    } on Object {
      // No point: the page says so.
    } finally {
      if (mounted) setState(() => _looking = false);
    }
  }

  Future<void> _pick(NamedPoint p) async {
    setState(() => _picked = p);
    await pickPlace(ref, p);
  }

  /// Adds a place to the profile, and measures from it.
  Future<void> _addPlace() async {
    final p = await askPlace(context, ref);
    if (p != null && mounted) await _pick(p);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final places = ref.watch(profilePlacesProvider).value ?? const <NamedPoint>[];
    final last = ref.watch(lastPlaceProvider).value;
    final anchors = widget.anchors;
    final options = [
      ...anchors,
      ...places.where((s) => !anchors.any((a) => a.label.toLowerCase() == s.label.toLowerCase())),
    ];
    final from =
        _picked ??
        options.where((o) => o.label == last).firstOrNull ??
        places.firstOrNull ??
        anchors.firstOrNull;
    final at = _at;
    String far(NamedPoint p) {
      final d = distanceKm(p.lat, p.lon, at!.lat, at.lon);
      return '${at.rough ? 'about ' : ''}${miles(d)} (${km(d)})';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (ref.watch(inlineMapsProvider) && (at != null || _place != null))
          SizedBox(
            height: 240,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: HomesMap(
                homes: [
                  MapHome(
                    label: widget.label,
                    lat: at?.lat,
                    lon: at?.lon,
                    postcode: widget.postcode,
                    address: widget.address,
                  ),
                ],
                from: from,
              ),
            ),
          ),
        const SizedBox(height: 8),
        Text('Distance from your places', style: t.titleSmall),
        if (at == null)
          Text(
            _looking
                ? 'Finding this home on the map…'
                : 'This advert gives no postcode or map point, so its distance is not known.',
            style: t.bodySmall,
          )
        else ...[
          for (final p in options)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              selected: p.label == from?.label,
              selectedColor: scheme.primary,
              leading: Icon(p.label == from?.label ? Icons.place : Icons.place_outlined),
              title: Text('${p.label}: ${far(p)}'),
              subtitle: p.label == from?.label
                  ? Text(
                      'In a straight line${at.rough ? ', to the middle of $_place' : ''}; on the map.',
                      style: t.bodySmall,
                    )
                  : null,
              trailing: IconButton(
                tooltip: 'Directions and travel time from ${p.label}',
                icon: const Icon(Icons.directions_outlined),
                onPressed: () => openUri(context, directionsUrl(p, (lat: at.lat, lon: at.lon))),
              ),
              onTap: () => _pick(p),
            ),
          if (options.isEmpty)
            Text(
              'Add your places (work, family, a school) in Profile, or here, to see how far this home is.',
              style: t.bodySmall,
            ),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _addPlace,
            icon: const Icon(Icons.add_location_alt_outlined, size: 18),
            label: const Text('Add a place'),
          ),
        ),
      ],
    );
  }
}

/// Asks for a place (a postcode, district or town, with an optional name),
/// finds it and adds it to the profile's places. Null when cancelled.
Future<NamedPoint?> askPlace(BuildContext context, WidgetRef ref, {NamedPoint? editing}) async {
  final where = TextEditingController();
  final name = TextEditingController(text: editing?.label ?? '');
  NamedPoint? added;
  await showFormDialog(
    context,
    title: editing == null ? 'Add a place' : 'Change ${editing.label}',
    action: editing == null ? 'Add' : 'Save',
    fields: (_) => [
      Field(where, 'Postcode, district or town', autofocus: true),
      Field(name, 'Name (optional, e.g. Work)'),
      const Text('Only what you type here is sent, to postcodes.io, to find where it is.'),
    ],
    onSave: () async {
      if (where.text.trim().isEmpty) return 'Enter a postcode, district or town.';
      final w = await Research(client: ref.read(searchHttpProvider)).whereIs(where.text.trim());
      if (w == null) return 'Could not find "${where.text.trim()}". Try a postcode.';
      final label = name.text.trim().isEmpty ? w.label : name.text.trim();
      final p = (lat: w.lat, lon: w.lon, label: label);
      if (editing != null && editing.label != label) await removePlace(ref, editing);
      await addPlace(ref, p);
      added = p;
      return null;
    },
  );
  // The dialog's closing animation still reads the fields, so the
  // controllers are left to the garbage collector.
  return added;
}
