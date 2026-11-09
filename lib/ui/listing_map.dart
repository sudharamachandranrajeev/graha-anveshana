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
    await rememberPlace(ref, p);
  }

  Future<void> _addPlace() async {
    final where = TextEditingController();
    final name = TextEditingController();
    await showFormDialog(
      context,
      title: 'Measure from another place',
      action: 'Measure',
      fields: (_) => [
        Field(where, 'Postcode, district or town', autofocus: true),
        Field(name, 'Name (optional, e.g. Work)'),
      ],
      onSave: () async {
        if (where.text.trim().isEmpty) return 'Enter a postcode, district or town.';
        final w = await Research(client: ref.read(searchHttpProvider)).whereIs(where.text.trim());
        if (w == null) return 'Could not find "${where.text.trim()}". Try a postcode.';
        final label = name.text.trim().isEmpty ? w.label : name.text.trim();
        await _pick((lat: w.lat, lon: w.lon, label: label));
        return null;
      },
    );
    // The dialog's closing animation still reads the fields, so the
    // controllers are left to the garbage collector.
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final saved = ref.watch(distancePlacesProvider).value ?? const <NamedPoint>[];
    final anchors = widget.anchors;
    final options = [
      ...anchors,
      ...saved.where((s) => !anchors.any((a) => a.label.toLowerCase() == s.label.toLowerCase())),
    ];
    final from = _picked ?? saved.firstOrNull ?? anchors.firstOrNull;
    final at = _at;
    final d = at == null || from == null ? null : distanceKm(from.lat, from.lon, at.lat, at.lon);
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
        Text('Distance from', style: t.titleSmall),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final p in options)
              InputChip(
                label: Text(p.label),
                selected: from != null && p.label == from.label,
                onSelected: (_) => _pick(p),
                onDeleted: anchors.contains(p)
                    ? null
                    : () async {
                        if (_picked?.label == p.label) setState(() => _picked = null);
                        await forgetPlace(ref, p);
                      },
                deleteButtonTooltipMessage: 'Forget ${p.label}',
              ),
            ActionChip(
              avatar: const Icon(Icons.add_location_alt_outlined, size: 18),
              label: const Text('Another place'),
              onPressed: _addPlace,
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (at == null)
          Text(
            _looking
                ? 'Finding this home on the map…'
                : 'This advert gives no postcode or map point, so its distance is not known.',
            style: t.bodySmall,
          )
        else if (from == null)
          Text('Pick a place, or add one, to see how far this home is from it.', style: t.bodySmall)
        else
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              Text(
                '${at.rough ? 'About ' : ''}${miles(d!)} (${km(d)}) from ${from.label} in a straight line'
                '${at.rough ? ', to the middle of $_place' : ''}.',
              ),
              TextButton.icon(
                onPressed: () => openUri(context, directionsUrl(from, (lat: at.lat, lon: at.lon))),
                icon: const Icon(Icons.directions_outlined, size: 18),
                label: const Text('Directions and travel time'),
              ),
            ],
          ),
      ],
    );
  }
}
