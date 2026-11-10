import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../domain/listing.dart';
import '../domain/research.dart';
import '../domain/search_request.dart';
import 'common.dart';

/// A home to pin: its own point, else the place to look up (a full
/// postcode, or a district for a rough pin).
class MapHome {
  MapHome({required this.label, this.lat, this.lon, String postcode = '', String address = '', this.onTap})
    : place = postcodeIn(postcode) ?? postcodeIn(address) ?? outcodeIn(postcode) ?? outcodeIn(address);

  /// What the pin shows: "£850" or "2 bed".
  final String label;
  final double? lat, lon;
  final String? place;
  final VoidCallback? onTap;
}

typedef Locate = Future<Map<String, ({double lat, double lon})>> Function(Iterable<String> places);

/// Whether pages show a map without being asked (a home's page). Widget
/// tests switch it off: they have no network for the map's tiles.
final inlineMapsProvider = Provider<bool>((ref) => true);

/// Homes on an OpenStreetMap map, with [centre] (the search's place or the
/// home point) marked. Homes without a point are placed by postcode
/// through postcodes.io; by district only, they get a hollow pin.
class HomesMap extends StatefulWidget {
  const HomesMap({
    super.key,
    required this.homes,
    this.centre,
    this.centreLabel = '',
    this.from,
    this.locate,
    this.shape = const [],
    this.onDraw,
    this.overlays = const [],
  });
  final List<MapHome> homes;

  /// An area the user drew, shown as a shaded polygon.
  final List<LatLon> shape;

  /// When set, the map offers "Draw an area": each tap adds a corner, and
  /// Done hands the corners back (an empty list clears the area).
  final ValueChanged<List<LatLon>>? onDraw;

  /// Extra map layers drawn over the tiles (e.g. a noise map).
  final List<Widget> overlays;

  /// A place the home is measured from: marked, with a straight line to the
  /// home (when there is one home).
  final ({double lat, double lon, String label})? from;
  final ({double lat, double lon})? centre;
  final String centreLabel;

  /// Looks places up; tests replace it.
  final Locate? locate;

  @override
  State<HomesMap> createState() => _HomesMapState();
}

class _HomesMapState extends State<HomesMap> {
  final _map = MapController();
  final _found = <String, ({double lat, double lon})>{};
  final _asked = <String>{};
  var _fitted = false;

  /// Corners placed so far while drawing; null when not drawing.
  List<LatLng>? _drawing;

  @override
  void initState() {
    super.initState();
    _lookUp();
  }

  @override
  void didUpdateWidget(HomesMap old) {
    super.didUpdateWidget(old);
    // A new place to measure from: fit the camera again to take it in.
    if (old.from != widget.from) _fitted = false;
    _lookUp();
  }

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  Future<void> _lookUp() async {
    final want = {
      for (final h in widget.homes)
        if (h.lat == null && h.place != null && !_asked.contains(h.place)) h.place!,
    };
    if (want.isEmpty) return;
    _asked.addAll(want);
    final got = await (widget.locate ?? Research().pointsFor)(want);
    if (mounted && got.isNotEmpty) setState(() => _found.addAll(got));
  }

  List<({LatLng at, MapHome home, bool rough})> get _pins => [
    for (final h in widget.homes)
      if (h.lat != null && h.lon != null)
        (at: LatLng(h.lat!, h.lon!), home: h, rough: false)
      else if (_found[h.place] case final p?)
        (at: LatLng(p.lat, p.lon), home: h, rough: postcodeIn(h.place!) == null),
  ];

  void _fit(List<LatLng> points) {
    if (_fitted || points.isEmpty) return;
    _fitted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (points.length == 1) {
        _map.move(points.single, 14);
      } else {
        _map.fitCamera(
          CameraFit.coordinates(coordinates: points, padding: const EdgeInsets.all(48), maxZoom: 15),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pins = _pins;
    final c = widget.centre;
    final from = widget.from;
    final shape = [for (final p in widget.shape) LatLng(p.lat, p.lon)];
    final drawing = _drawing;
    final points = [
      for (final p in pins) p.at,
      if (c != null) LatLng(c.lat, c.lon),
      if (from != null) LatLng(from.lat, from.lon),
      ...shape,
    ];
    _fit(points);
    final missing = widget.homes.length - pins.length;
    return Stack(
      children: [
        FlutterMap(
          mapController: _map,
          options: MapOptions(
            initialCenter: points.firstOrNull ?? const LatLng(54.0, -2.5),
            initialZoom: points.isEmpty ? 5.5 : 13,
            onTap: drawing == null ? null : (_, at) => setState(() => drawing.add(at)),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'dev.brahma.anveshana',
            ),
            ...widget.overlays,
            if (drawing == null && shape.length >= 3)
              PolygonLayer(
                polygons: [
                  Polygon(
                    points: shape,
                    color: scheme.primary.withValues(alpha: 0.12),
                    borderColor: scheme.primary,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
            if (drawing != null && drawing.isNotEmpty)
              PolygonLayer(
                polygons: [
                  Polygon(
                    points: drawing,
                    color: scheme.tertiary.withValues(alpha: 0.15),
                    borderColor: scheme.tertiary,
                    borderStrokeWidth: 2,
                    pattern: StrokePattern.dashed(segments: const [8, 6]),
                  ),
                ],
              ),
            if (from != null && pins.length == 1)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [LatLng(from.lat, from.lon), pins.single.at],
                    color: scheme.secondary,
                    strokeWidth: 3,
                    pattern: StrokePattern.dashed(segments: const [8, 6]),
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                if (c != null)
                  Marker(
                    point: LatLng(c.lat, c.lon),
                    width: 36,
                    height: 36,
                    child: Tooltip(
                      message: widget.centreLabel.isEmpty ? 'The centre' : widget.centreLabel,
                      child: Icon(Icons.my_location, color: scheme.tertiary, size: 28),
                    ),
                  ),
                if (from != null)
                  Marker(
                    point: LatLng(from.lat, from.lon),
                    width: 36,
                    height: 36,
                    alignment: Alignment.topCenter,
                    child: Tooltip(
                      message: from.label,
                      child: Icon(Icons.place, color: scheme.secondary, size: 32),
                    ),
                  ),
                for (final p in pins)
                  Marker(
                    point: p.at,
                    width: 84,
                    height: 30,
                    child: _Pin(p.home, rough: p.rough),
                  ),
                for (final p in drawing ?? const <LatLng>[])
                  Marker(
                    point: p,
                    width: 14,
                    height: 14,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: scheme.tertiary,
                        shape: BoxShape.circle,
                        border: Border.all(color: scheme.onTertiary, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  onTap: () => openUri(context, Uri.parse('https://www.openstreetmap.org/copyright')),
                ),
              ],
            ),
          ],
        ),
        if (missing > 0)
          Positioned(
            left: 8,
            top: 8,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text(
                  missing == 1 ? '1 home has no place to pin' : '$missing homes have no place to pin',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
        if (widget.onDraw != null)
          Positioned(
            right: 8,
            top: 8,
            child: drawing == null
                ? Wrap(
                    spacing: 8,
                    children: [
                      if (shape.isNotEmpty)
                        FilledButton.tonalIcon(
                          onPressed: () => widget.onDraw!(const []),
                          icon: const Icon(Icons.layers_clear_outlined),
                          label: const Text('Clear area'),
                        ),
                      FilledButton.tonalIcon(
                        onPressed: () => setState(() => _drawing = []),
                        icon: const Icon(Icons.draw_outlined),
                        label: Text(shape.isEmpty ? 'Draw an area' : 'Draw again'),
                      ),
                    ],
                  )
                : Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            drawing.length < 3
                                ? 'Tap the map to put a corner (${drawing.length} of at least 3)'
                                : '${drawing.length} corners',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            children: [
                              TextButton(
                                onPressed: () => setState(() => _drawing = null),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: drawing.isEmpty ? null : () => setState(drawing.removeLast),
                                child: const Text('Undo'),
                              ),
                              FilledButton(
                                onPressed: drawing.length < 3
                                    ? null
                                    : () {
                                        final done = [
                                          for (final p in drawing) (lat: p.latitude, lon: p.longitude),
                                        ];
                                        setState(() => _drawing = null);
                                        widget.onDraw!(done);
                                      },
                                child: const Text('Done'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
      ],
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin(this.home, {required this.rough});
  final MapHome home;
  final bool rough;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: rough ? '${home.label}, somewhere in ${home.place}' : home.label,
      child: Material(
        color: rough ? scheme.surface : scheme.primary,
        shape: StadiumBorder(side: BorderSide(color: scheme.primary, width: 1.5)),
        elevation: 2,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: home.onTap,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                home.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: rough ? scheme.primary : scheme.onPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
