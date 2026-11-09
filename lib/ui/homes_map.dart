import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../domain/listing.dart';
import '../domain/research.dart';
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
  });
  final List<MapHome> homes;

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
    final points = [
      for (final p in pins) p.at,
      if (c != null) LatLng(c.lat, c.lon),
      if (from != null) LatLng(from.lat, from.lon),
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
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'dev.brahma.anveshana',
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
