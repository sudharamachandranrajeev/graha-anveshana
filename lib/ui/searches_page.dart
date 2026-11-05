import 'package:brahma_core/brahma_core.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../db/database.dart';
import '../domain/watch_client.dart';
import 'common.dart';
import 'portals_card.dart';

WatchSearch _toWatch(Search s) => WatchSearch(
  id: s.id,
  name: s.name,
  path: s.path,
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
  s.path,
  if (s.maxPrice != null) 'up to ${gbp(s.maxPrice!)}',
  if (s.minBeds != null || s.maxBeds != null) '${s.minBeds ?? 0}–${s.maxBeds ?? '…'} beds',
  if (s.radiusKm != null && s.centreLat != null)
    'within ${km(s.radiusKm!)}${s.centreLabel.isEmpty ? '' : ' of ${s.centreLabel}'}',
].join(' · ');

class SearchesPage extends ConsumerWidget {
  const SearchesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watch = ref.watch(watchProvider).value;
    return PageScaffold(
      title: 'Searches',
      banner: 'page.searches',
      fab: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => editSearch(context, ref),
        icon: const Icon(Icons.saved_search),
        label: const Text('Add'),
      ),
      children: [
        const PortalsCard(),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Brahma Watch',
          hint: 'settings.watch',
          child: watch == null
              ? const Text(
                  'Not set up. Deploy Brahma Watch to your Cloudflare account (see the brahma repository), then '
                  'enter its address and token in Settings.',
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
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
                            leading: Icon(s.paused ? Icons.pause_circle_outline : Icons.manage_search),
                            title: Text(s.name),
                            subtitle: Text(_summary(s)),
                            onTap: () => editSearch(context, ref, s: s),
                            trailing: IconButton(
                              tooltip: 'Open on PropertyPal',
                              icon: const Icon(Icons.open_in_new),
                              onPressed: () =>
                                  openUri(context, Uri.parse('https://www.propertypal.com${s.path}')),
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
              path: Value(w.path),
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

/// Adds or edits a saved search. The centre comes from the home point.
Future<void> editSearch(BuildContext context, WidgetRef ref, {Search? s}) async {
  final home = await ref.read(homeProvider.future);
  if (!context.mounted) return;
  final name = TextEditingController(text: s?.name);
  final path = TextEditingController(text: s?.path ?? '/property-to-rent/');
  final maxPrice = TextEditingController(text: s?.maxPrice?.toString());
  final minBeds = TextEditingController(text: s?.minBeds?.toString());
  final maxBeds = TextEditingController(text: s?.maxBeds?.toString());
  final radius = TextEditingController(text: s?.radiusKm?.toString());
  var includeUnpriced = s?.includeUnpriced ?? true;
  var paused = s?.paused ?? false;
  await showFormDialog(
    context,
    title: s == null ? 'New search' : 'Edit search',
    fields: (setState) => [
      Field(name, 'Name', autofocus: s == null, hint: 'Rent near work'),
      Field(
        path,
        'PropertyPal search',
        helper: 'e.g. /property-to-rent/enniskillen or /property-for-sale/belfast/bt9',
      ),
      Field(maxPrice, 'Highest price', number: true, prefix: '£', helper: 'A month for lets'),
      Row(
        children: [
          Expanded(child: Field(minBeds, 'Beds from', number: true)),
          const SizedBox(width: 12),
          Expanded(child: Field(maxBeds, 'Beds up to', number: true)),
        ],
      ),
      Field(
        radius,
        'Within',
        number: true,
        suffix: 'km',
        helper: home == null
            ? 'Set a home point in Settings to limit the distance.'
            : 'Of ${home.label.isEmpty ? 'your home point' : home.label}',
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
    ],
    onSave: () async {
      final p = path.text.trim().toLowerCase();
      if (name.text.trim().isEmpty) return 'Enter a name.';
      if (!isSearchPath(p)) return 'The search should look like /property-to-rent/enniskillen.';
      final r = numberIn(radius)?.toDouble();
      final id = s?.id ?? newId();
      await ref.mutate(
        (x) => x.book.save(
          x.db.searches,
          SearchesCompanion(
            id: Value(id),
            name: Value(name.text.trim()),
            path: Value(p),
            maxPrice: Value(intIn(maxPrice)),
            minBeds: Value(intIn(minBeds)),
            maxBeds: Value(intIn(maxBeds)),
            centreLat: Value(r == null ? s?.centreLat : home?.lat ?? s?.centreLat),
            centreLon: Value(r == null ? s?.centreLon : home?.lon ?? s?.centreLon),
            centreLabel: Value(r == null ? s?.centreLabel ?? '' : home?.label ?? s?.centreLabel ?? ''),
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
