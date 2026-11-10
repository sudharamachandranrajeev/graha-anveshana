import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/search_controller.dart';
import '../domain/area_checks.dart';
import '../domain/search_request.dart';
import 'common.dart';

/// Checks on the area around a home: schools nearby, which way it faces
/// and where the sun is, and the coal mining and radon maps. Nothing is
/// sent anywhere until the user taps a check; then only the map point.
class AreaChecksCard extends ConsumerStatefulWidget {
  const AreaChecksCard({super.key, required this.at, this.rough = false});
  final LatLon at;

  /// Only the postcode district is known: the point is its middle.
  final bool rough;

  @override
  ConsumerState<AreaChecksCard> createState() => _AreaChecksCardState();
}

class _AreaChecksCardState extends ConsumerState<AreaChecksCard> {
  List<NearSchool>? _schools;
  String _schoolsNote = '';
  var _schoolsBusy = false;

  /// What the building outline says; null: not asked yet.
  String? _facing;
  var _facingBusy = false;

  Future<void> _findSchools() async {
    setState(() {
      _schoolsBusy = true;
      _schoolsNote = '';
    });
    try {
      final got = await ref.read(areaChecksProvider).schools(widget.at);
      if (mounted) setState(() => _schools = got);
    } on AreaUnavailable catch (e) {
      if (mounted) setState(() => _schoolsNote = '$e');
    } finally {
      if (mounted) setState(() => _schoolsBusy = false);
    }
  }

  Future<void> _findFacing() async {
    setState(() => _facingBusy = true);
    String text;
    try {
      final outline = await ref.read(areaChecksProvider).building(widget.at);
      final f = outline == null ? null : facing(outline);
      text = outline == null
          ? 'OpenStreetMap has no building outline at this point.'
          : f == null
          ? 'The building outline is about square, so which way it faces is not clear.'
          : 'Its long sides face ${compass(f.$1)} (${sunFor(f.$1)}) and '
                '${compass(f.$2)} (${sunFor(f.$2)}). Check which side the garden is on.';
    } on AreaUnavailable catch (e) {
      text = '$e';
    }
    if (mounted) {
      setState(() {
        _facing = text;
        _facingBusy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final schools = _schools;
    return Card(
      margin: const EdgeInsets.only(top: 8),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: const Icon(Icons.travel_explore_outlined),
        title: const Text('Area checks'),
        subtitle: const Text('Schools, sun, coal mining, radon'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Schools nearby', style: t.titleSmall),
          if (schools == null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _schoolsBusy ? null : _findSchools,
                icon: _schoolsBusy
                    ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.school_outlined, size: 18),
                label: const Text('Find schools within a mile'),
              ),
            )
          else if (schools.isEmpty)
            Text('OpenStreetMap has no schools mapped within a mile.', style: t.bodySmall)
          else
            for (final s in schools.take(10))
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.school_outlined),
                title: Text(s.name),
                subtitle: Text([if (s.kind.isNotEmpty) s.kind, miles(s.km)].join(' · ')),
                trailing: IconButton(
                  tooltip: 'Ofsted report for ${s.name}',
                  icon: const Icon(Icons.open_in_new),
                  onPressed: () => openUri(context, ofstedSearch(s.name)),
                ),
              ),
          if (_schoolsNote.isNotEmpty) Text(_schoolsNote, style: t.bodySmall),
          Text(
            'Nearby schools from OpenStreetMap, in a straight line'
            '${widget.rough ? ' from the middle of the postcode district' : ''}. '
            'Being near a school does not put a home in its catchment: ask the council.',
            style: t.bodySmall,
          ),
          const Divider(height: 24),
          Text('Sun and garden direction', style: t.titleSmall),
          for (final d in sunDays(widget.at.lat))
            Text(
              '${d.day}: the sun rises in the ${compass(d.rise)} and sets in the ${compass(d.set)}; '
              'at noon it is in the south, ${d.noonHeight.round()}° up.',
            ),
          if (widget.rough)
            Text('Which way the home faces needs its exact map point.', style: t.bodySmall)
          else if (_facing == null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _facingBusy ? null : _findFacing,
                icon: _facingBusy
                    ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.explore_outlined, size: 18),
                label: const Text('Which way does it face?'),
              ),
            )
          else ...[
            const SizedBox(height: 4),
            Text(_facing!),
            Text(
              'From the OpenStreetMap building outline at the advert\'s map point, which can be a few '
              'doors out. Trees and nearby buildings also shade a garden.',
              style: t.bodySmall,
            ),
          ],
          const Divider(height: 24),
          Text('Ground', style: t.titleSmall),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.landscape_outlined),
            title: const Text('Coal mining map'),
            subtitle: const Text(
              'Mining Remediation Authority (formerly the Coal Authority). In a coal mining area, '
              'your solicitor orders a mining report.',
            ),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => openUri(context, coalMapUrl),
          ),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.warning_amber_outlined),
            title: const Text('Radon map'),
            subtitle: const Text(
              'UKHSA. Radon is a natural gas from the ground; the map shows areas where homes are more '
              'likely to have high levels. A report for one address is paid.',
            ),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => openUri(context, radonMapUrl),
          ),
        ],
      ),
    );
  }
}
