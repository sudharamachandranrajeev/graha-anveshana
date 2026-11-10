import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../app/search_controller.dart';
import '../app/search_memory.dart';
import '../domain/listing.dart';
import '../domain/area_checks.dart';
import '../domain/research.dart';
import '../domain/search_request.dart';
import '../domain/travel.dart';
import 'area_checks_card.dart';
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

  /// The noise map drawn over the map; null: none.
  NoiseMap? _noise;

  /// The travel mode the user asked times for; null: not asked (nothing is
  /// sent to the router until then).
  TravelMode? _mode;
  Map<String, double?> _times = const {};
  String _timesNote = '';

  Future<void> _travel(TravelMode mode, List<NamedPoint> to) async {
    final at = _at;
    if (at == null || to.isEmpty) return;
    setState(() {
      _mode = mode;
      _timesNote = 'Asking the travel time service…';
    });
    try {
      final got = await ref
          .read(travelTimesProvider)
          .minutesToEach(mode, (lat: at.lat, lon: at.lon), [for (final p in to) (lat: p.lat, lon: p.lon)]);
      if (!mounted || _mode != mode) return;
      setState(() {
        _times = {for (final (i, p) in to.indexed) p.label: got[i]};
        _timesNote = '';
      });
    } on TravelUnavailable catch (e) {
      if (mounted) setState(() => _timesNote = '$e');
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
      final mins = _mode == null ? null : _times[p.label];
      final by = mins == null ? '' : ', ${minutesText(mins)} by ${_mode!.label.toLowerCase()}';
      return '${at.rough ? 'about ' : ''}${miles(d)} (${km(d)})$by';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (ref.watch(inlineMapsProvider) && (at != null || _place != null))
          RouteMap(
            home: MapHome(
              label: widget.label,
              lat: at?.lat,
              lon: at?.lon,
              postcode: widget.postcode,
              address: widget.address,
            ),
            at: at == null || at.rough ? null : (lat: at.lat, lon: at.lon),
            from: from,
            mode: _mode ?? TravelMode.car,
            noise: _noise,
          ),
        if (ref.watch(inlineMapsProvider) && at != null)
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final n in noiseMaps)
                FilterChip(
                  avatar: const Icon(Icons.volume_up_outlined, size: 18),
                  label: Text(n.label),
                  selected: _noise == n,
                  onSelected: (on) => setState(() => _noise = on ? n : null),
                ),
              if (_noise case final n?)
                Text(
                  'Defra noise map (England, ${n.year}), Open Government Licence. '
                  'Darker red: louder over day, evening and night.',
                  style: t.bodySmall,
                ),
            ],
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
            )
          else ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Travel time:', style: t.bodySmall),
                for (final m in TravelMode.values)
                  ChoiceChip(
                    avatar: Icon(travelIcon(m), size: 18),
                    label: Text(m.label),
                    selected: _mode == m,
                    onSelected: (_) => _travel(m, options),
                  ),
              ],
            ),
            Text(
              _timesNote.isNotEmpty
                  ? _timesNote
                  : 'Times by road or path from the OpenStreetMap community router, without traffic. '
                        'Only the map points are sent. Bus and train: use Directions.',
              style: t.bodySmall,
            ),
          ],
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _addPlace,
            icon: const Icon(Icons.add_location_alt_outlined, size: 18),
            label: const Text('Add a place'),
          ),
        ),
        if (at != null) AreaChecksCard(at: (lat: at.lat, lon: at.lon), rough: at.rough),
      ],
    );
  }
}

TileLayer _noiseLayer(NoiseMap n) => TileLayer(
  key: ValueKey(n.layer),
  userAgentPackageName: 'dev.brahma.anveshana',
  wmsOptions: WMSTileLayerOptions(baseUrl: n.url, layers: [n.layer], version: '1.3.0'),
);

/// One home on the map with the route to it from [from] by [mode], from the
/// OpenStreetMap community router (only the two map points are sent). Small
/// on a home's page, with Expand to open it full screen ([full]).
class RouteMap extends ConsumerStatefulWidget {
  const RouteMap({
    super.key,
    required this.home,
    this.at,
    this.from,
    this.mode = TravelMode.car,
    this.noise,
    this.full = false,
  });
  final MapHome home;

  /// The home's exact point; null: not known well enough for a route.
  final LatLon? at;
  final NamedPoint? from;
  final TravelMode mode;
  final NoiseMap? noise;
  final bool full;

  @override
  ConsumerState<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends ConsumerState<RouteMap> {
  late var _mode = widget.mode;
  TravelRoute? _route;
  String _note = '';

  /// The place, point and mode last asked for, so each is asked once.
  String? _asked;

  @override
  void didUpdateWidget(RouteMap old) {
    super.didUpdateWidget(old);
    if (old.mode != widget.mode) _mode = widget.mode;
  }

  Future<void> _ask() async {
    final from = widget.from, at = widget.at;
    final key = from == null || at == null
        ? null
        : '${from.lat},${from.lon}|${at.lat},${at.lon}|${_mode.name}';
    if (key == _asked) return;
    _asked = key;
    setState(() {
      _route = null;
      _note = key == null ? '' : 'Finding the route…';
    });
    if (key == null) return;
    String note;
    TravelRoute? got;
    try {
      got = await ref.read(travelTimesProvider).route(_mode, (lat: from!.lat, lon: from.lon), at!);
      note = got == null ? 'No route found by ${_mode.label.toLowerCase()}.' : '';
    } on TravelUnavailable catch (e) {
      note = '$e';
    }
    if (!mounted || key != _asked) return;
    setState(() {
      _route = got;
      _note = note;
    });
  }

  void _expand() => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => RouteMap(
        home: widget.home,
        at: widget.at,
        from: widget.from,
        mode: _mode,
        noise: widget.noise,
        full: true,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ask();
    });
    final t = Theme.of(context).textTheme;
    final from = widget.from, route = _route;
    final summary = route != null && from != null
        ? 'By ${_mode.label.toLowerCase()} from ${from.label}: ${minutesText(route.minutes)}, '
              '${miles(route.km)} by road or path (no traffic)'
        : _note;
    final map = HomesMap(
      homes: [widget.home],
      from: from,
      route: route?.line ?? const [],
      overlays: [if (widget.noise case final n?) _noiseLayer(n)],
      onExpand: widget.full ? null : _expand,
    );
    if (!widget.full) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 240,
            child: ClipRRect(borderRadius: BorderRadius.circular(16), child: map),
          ),
          if (summary.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(summary, style: t.bodySmall),
            ),
        ],
      );
    }
    final at = widget.at;
    return Scaffold(
      appBar: AppBar(
        title: Text(from == null ? widget.home.label : '${widget.home.label} from ${from.label}'),
      ),
      body: Column(
        children: [
          Expanded(child: map),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (from != null && at != null)
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        for (final m in TravelMode.values)
                          ChoiceChip(
                            avatar: Icon(travelIcon(m), size: 18),
                            label: Text(m.label),
                            selected: _mode == m,
                            onSelected: (_) => setState(() => _mode = m),
                          ),
                        OutlinedButton.icon(
                          onPressed: () => openUri(context, directionsUrl(from, at)),
                          icon: const Icon(Icons.directions_outlined, size: 18),
                          label: const Text('Directions (bus, train)'),
                        ),
                      ],
                    ),
                  if (summary.isNotEmpty) Text(summary),
                  if (from == null)
                    Text('Add a place in Profile to see the route to this home.', style: t.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
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
