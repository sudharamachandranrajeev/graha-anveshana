import 'package:brahma_core/brahma_core.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../db/database.dart';
import '../domain/research.dart';
import '../domain/watch_client.dart';
import 'browser_page.dart';
import 'common.dart';

WatchSearch _toWatch(Search s) => WatchSearch(
  id: s.id,
  name: s.name,
  source: s.source,
  path: s.path,
  kind: s.kind,
  keywords: keywordList(s.keywords),
  maxPrice: s.maxPrice,
  minBeds: s.minBeds,
  maxBeds: s.maxBeds,
  centreLat: s.centreLat,
  centreLon: s.centreLon,
  centreLabel: s.centreLabel,
  radiusKm: s.radiusKm,
  includeUnpriced: s.includeUnpriced,
  paused: s.paused,
);

String _summary(Search s) => [
  if (s.source == 'email')
    switch (s.kind) {
      'rent' => 'Alert emails, to rent',
      'buy' => 'Alert emails, to buy',
      _ => 'Alert emails',
    }
  else
    s.path,
  if (s.maxPrice != null) 'up to ${gbp(s.maxPrice!)}',
  if (s.minBeds != null || s.maxBeds != null) '${s.minBeds ?? 0}–${s.maxBeds ?? '…'} beds',
  if (s.radiusKm != null && s.centreLat != null)
    'within ${km(s.radiusKm!)}${s.centreLabel.isEmpty ? '' : ' of ${s.centreLabel}'}',
  if (s.keywords.trim().isNotEmpty) s.keywords.trim(),
].join(' · ');

/// How portal alert emails reach Brahma Watch (England has no open feed).
Future<void> showAlertEmailHelp(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Searches from alert emails'),
    scrollable: true,
    content: const SizedBox(
      width: 520,
      child: Text(
        'Rightmove, Zoopla, OnTheMarket, OpenRent and SpareRoom do not let apps read their sites, but they '
        'email you new homes. Brahma Watch can read those emails and alert you only to the homes that '
        'fit an email search here: near a place or postcode, your price, bedrooms and words.\n\n'
        '1. On each site, save a search with instant email alerts.\n'
        '2. Set up the alert email address for Brahma Watch (see "Alert emails" in the Watch '
        'instructions in the brahma repository). It needs a domain on your Cloudflare account.\n'
        '3. In your mailbox, forward the sites\' alert emails to that address.\n'
        '4. Add an email search here and tap Send to Watch.\n\n'
        'The same home from two sites alerts once, and a price change alerts again. Let-agreed and sold '
        'changes do not come by email. Watch never opens the sites\' pages; tap an alert to open the '
        'advert yourself. Keep it for your own use.',
      ),
    ),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
  ),
);

class SearchesPage extends ConsumerWidget {
  const SearchesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watch = ref.watch(watchProvider).value;
    return PageScaffold(
      title: 'Saved searches',
      banner: 'page.searches',
      fab: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => editSearch(context, ref),
        icon: const Icon(Icons.saved_search),
        label: const Text('Add'),
      ),
      children: [
        SectionCard(
          title: 'Brahma Watch',
          hint: 'settings.watch',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (watch == null)
                const Text(
                  'Not set up. Deploy Brahma Watch to your Cloudflare account (see the brahma repository), '
                  'then enter its address and token in Settings.',
                )
              else ...[
                Hint(
                  'searches.send',
                  child: FilledButton.icon(
                    onPressed: () => _send(context, ref, watch),
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: const Text('Send to Watch'),
                  ),
                ),
                Hint(
                  'searches.fetch',
                  child: OutlinedButton.icon(
                    onPressed: () => _fetch(context, ref, watch),
                    icon: const Icon(Icons.cloud_download_outlined),
                    label: const Text('Copy from Watch'),
                  ),
                ),
                Hint(
                  'searches.run',
                  child: OutlinedButton.icon(
                    onPressed: () => _do(context, watch.runNow, 'Brahma Watch checked every search.'),
                    icon: const Icon(Icons.play_arrow_outlined),
                    label: const Text('Check now'),
                  ),
                ),
                Hint(
                  'searches.test',
                  child: OutlinedButton.icon(
                    onPressed: () => _do(context, watch.testPush, 'Test alert sent.'),
                    icon: const Icon(Icons.notifications_outlined),
                    label: const Text('Test alert'),
                  ),
                ),
              ],
              Hint(
                'searches.emails',
                child: TextButton.icon(
                  onPressed: () => showAlertEmailHelp(context),
                  icon: const Icon(Icons.mail_outline),
                  label: const Text('Alert emails (England)'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AsyncView(
          ref.watch(searchesProvider),
          builder: (searches) => searches.isEmpty
              ? const EmptyState(
                  icon: Icons.saved_search,
                  title: 'No saved searches',
                  message: 'Add one, or copy the searches Brahma Watch already runs.',
                )
              : Column(
                  children: [
                    for (final s in searches)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          child: ListTile(
                            leading: Icon(
                              s.paused
                                  ? Icons.pause_circle_outline
                                  : s.source == 'email'
                                  ? Icons.mark_email_unread_outlined
                                  : Icons.manage_search,
                            ),
                            title: Text(s.name),
                            subtitle: Text(_summary(s)),
                            onTap: () => editSearch(context, ref, s: s),
                            trailing: s.source == 'email'
                                ? null
                                : IconButton(
                                    tooltip: 'Open on PropertyPal',
                                    icon: const Icon(Icons.open_in_new),
                                    onPressed: () =>
                                        openInApp(context, Uri.parse('https://www.propertypal.com${s.path}')),
                                  ),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _do(BuildContext context, Future<void> Function() action, String done) async {
    if (await guarded(context, action) && context.mounted) showMessage(context, done);
  }

  Future<void> _send(BuildContext context, WidgetRef ref, WatchClient watch) async {
    final searches = await ref.read(searchesProvider.future);
    if (!context.mounted) return;
    if (searches.isEmpty &&
        !await confirm(
          context,
          title: 'Clear Brahma Watch?',
          message: 'There are no searches here, so Brahma Watch would stop checking anything.',
          action: 'Clear',
          destructive: true,
        )) {
      return;
    }
    if (!context.mounted) return;
    await _do(
      context,
      () => watch.putSearches(searches.map(_toWatch).toList()),
      'Brahma Watch now runs ${searches.length} searches.',
    );
  }

  Future<void> _fetch(BuildContext context, WidgetRef ref, WatchClient watch) async {
    var n = 0;
    final ok = await guarded(context, () async {
      final remote = await watch.searches();
      n = remote.length;
      await ref.mutate((s) async {
        for (final w in remote) {
          await s.book.save(
            s.db.searches,
            SearchesCompanion(
              id: Value(w.id),
              name: Value(w.name),
              source: Value(w.source),
              path: Value(w.path),
              kind: Value(w.kind),
              keywords: Value(w.keywords.join(', ')),
              maxPrice: Value(w.maxPrice),
              minBeds: Value(w.minBeds),
              maxBeds: Value(w.maxBeds),
              centreLat: Value(w.centreLat),
              centreLon: Value(w.centreLon),
              centreLabel: Value(w.centreLabel),
              radiusKm: Value(w.radiusKm),
              includeUnpriced: Value(w.includeUnpriced),
              paused: Value(w.paused),
              deleted: const Value(false),
            ),
            w.id,
          );
        }
      });
    });
    if (ok && context.mounted) showMessage(context, 'Copied $n searches from Brahma Watch.');
  }
}

/// Adds or edits a saved search. A PropertyPal search measures distance from
/// the home point; an email search from the place or postcode typed in.
Future<void> editSearch(
  BuildContext context,
  WidgetRef ref, {
  Search? s,
  Future<({double lat, double lon, String label})?> Function(String place)? whereIs,
}) async {
  final home = await ref.read(homeProvider.future);
  if (!context.mounted) return;
  final locate = whereIs ?? Research().whereIs;
  var source = s?.source ?? 'propertypal';
  var kind = s?.kind ?? 'rent';
  final name = TextEditingController(text: s?.name);
  final path = TextEditingController(text: s?.path.isNotEmpty == true ? s!.path : '/property-to-rent/');
  final near = TextEditingController(text: s?.source == 'email' ? s!.centreLabel : '');
  final words = TextEditingController(text: s?.keywords);
  final maxPrice = TextEditingController(text: s?.maxPrice?.toString());
  final minBeds = TextEditingController(text: s?.minBeds?.toString());
  final maxBeds = TextEditingController(text: s?.maxBeds?.toString());
  final radius = TextEditingController(text: s?.radiusKm?.toString());
  var includeUnpriced = s?.includeUnpriced ?? true;
  var paused = s?.paused ?? false;
  await showFormDialog(
    context,
    title: s == null ? 'New search' : 'Edit search',
    fields: (setState) {
      final email = source == 'email';
      return [
        Field(name, 'Name', autofocus: s == null, hint: email ? 'Flats in Headingley' : 'Rent near work'),
        Choice<String>(
          label: 'Watch',
          value: source,
          options: const {
            'propertypal': 'A PropertyPal search (Northern Ireland)',
            'email': 'Alert emails from Rightmove, Zoopla and others (England)',
          },
          onChanged: (v) => setState(() => source = v),
        ),
        if (email) ...[
          Choice<String>(
            label: 'Homes',
            value: kind,
            options: const {'rent': 'To rent', 'buy': 'To buy'},
            onChanged: (v) => setState(() => kind = v),
          ),
          Field(near, 'Near', hint: 'LS6, LS6 1AA or Pontefract', helper: 'A postcode or place name'),
        ] else
          Field(
            path,
            'PropertyPal search',
            helper: 'e.g. /property-to-rent/enniskillen or /property-for-sale/belfast/bt9',
          ),
        Field(
          radius,
          'Within',
          number: true,
          suffix: 'km',
          helper: email
              ? 'Of the place above'
              : home == null
              ? 'Set a home point in Settings to limit the distance.'
              : 'Of ${home.label.isEmpty ? 'your home point' : home.label}',
        ),
        Field(maxPrice, 'Highest price', number: true, prefix: '£', helper: 'A month for lets'),
        Row(
          children: [
            Expanded(child: Field(minBeds, 'Beds from', number: true)),
            const SizedBox(width: 12),
            Expanded(child: Field(maxBeds, 'Beds up to', number: true)),
          ],
        ),
        if (email)
          Field(
            words,
            'Words',
            hint: 'garden, parking, -retirement',
            helper: 'The advert must mention each one; a word starting with - hides adverts that mention it',
          ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Include adverts without a price'),
          value: includeUnpriced,
          onChanged: (v) => setState(() => includeUnpriced = v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Paused'),
          value: paused,
          onChanged: (v) => setState(() => paused = v),
        ),
        if (email)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => showAlertEmailHelp(context),
              icon: const Icon(Icons.help_outline),
              label: const Text('How alert emails reach Brahma Watch'),
            ),
          ),
        if (s != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () async {
                await ref.mutate((x) => x.book.remove(x.db.searches, s.id));
                if (context.mounted) Navigator.of(context).pop(false);
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete this search'),
            ),
          ),
      ];
    },
    onSave: () async {
      if (name.text.trim().isEmpty) return 'Enter a name.';
      final email = source == 'email';
      final p = email ? '' : path.text.trim().toLowerCase();
      if (!email && !isSearchPath(p)) return 'The search should look like /property-to-rent/enniskillen.';
      final r = numberIn(radius)?.toDouble();
      ({double lat, double lon, String label})? centre;
      if (email) {
        final place = near.text.trim();
        if (place.isEmpty) {
          if (r != null) return 'Enter a place or postcode to measure the distance from.';
        } else if (s?.source == 'email' && place == s!.centreLabel && s.centreLat != null) {
          centre = (lat: s.centreLat!, lon: s.centreLon!, label: s.centreLabel);
        } else {
          centre = await locate(place);
          if (centre == null) return 'Could not find "$place". Try a postcode such as LS6 or LS6 1AA.';
          // Keep what was typed: it reads better than "LS61AA" and stays matchable on edit.
          centre = (lat: centre.lat, lon: centre.lon, label: place);
        }
      } else if (r != null) {
        centre = home == null
            ? (s?.centreLat == null ? null : (lat: s!.centreLat!, lon: s.centreLon!, label: s.centreLabel))
            : (lat: home.lat, lon: home.lon, label: home.label);
      } else if (s?.centreLat != null) {
        centre = (lat: s!.centreLat!, lon: s.centreLon!, label: s.centreLabel);
      }
      final id = s?.id ?? newId();
      await ref.mutate(
        (x) => x.book.save(
          x.db.searches,
          SearchesCompanion(
            id: Value(id),
            name: Value(name.text.trim()),
            source: Value(source),
            path: Value(p),
            kind: Value(email ? kind : ''),
            keywords: Value(email ? keywordList(words.text).join(', ') : ''),
            maxPrice: Value(intIn(maxPrice)),
            minBeds: Value(intIn(minBeds)),
            maxBeds: Value(intIn(maxBeds)),
            centreLat: Value(centre?.lat),
            centreLon: Value(centre?.lon),
            centreLabel: Value(centre?.label ?? ''),
            radiusKm: Value(r),
            includeUnpriced: Value(includeUnpriced),
            paused: Value(paused),
          ),
          id,
        ),
      );
      return null;
    },
  );
}
