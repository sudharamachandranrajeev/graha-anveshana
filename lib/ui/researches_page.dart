import 'dart:convert';

import 'package:brahma_core/brahma_core.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../app/recognition.dart';
import '../db/database.dart';
import '../domain/catalog.dart';
import '../domain/catalog_book.dart';
import '../domain/listing.dart';
import '../domain/pipeline.dart';
import '../domain/portals.dart';
import '../domain/research.dart';
import 'browser_page.dart';
import 'common.dart';
import 'look.dart';
import 'property_page.dart';

const researchKinds = {'rent': 'Renting', 'buy': 'Buying', 'invest': 'Investing', 'area': 'Area study'};

/// The research's criteria, read once per row.
ResearchCriteria criteriaOf(ResearchJob r) => ResearchCriteria.fromJson(r.criteria);

/// How well [i] fits [c], with the distance from the research's centre.
({double score, List<String> misses}) itemFit(ResearchCriteria c, CatalogItem i) {
  final f = fieldsOf(i);
  final lat = (f['lat'] as num?)?.toDouble(), lon = (f['lon'] as num?)?.toDouble();
  final fields = itemFields(i);
  return fit(
    c,
    monthlyOrPrice: fields.monthly,
    beds: i.beds,
    km: c.lat == null || lat == null ? null : distanceKm(c.lat!, c.lon!, lat, lon!),
    text: '${i.title} ${i.address} ${i.body} ${i.notes}',
  );
}

/// Pairs that look like the same home: within [items] and against the
/// rest of [all] (other researches). Pairs the user said differ are left out.
List<DuplicatePair> duplicatesFor(List<CatalogItem> items, List<CatalogItem> all) {
  final ids = {for (final i in items) i.id};
  final notSame = {
    for (final i in all)
      for (final o in ((fieldsOf(i)['notSame'] as List?) ?? const []).cast<String>()) ...{
        '${i.id}|$o',
        '$o|${i.id}',
      },
  };
  return [
    for (final p in findDuplicates([for (final i in all) keyOfItem(i)]))
      if ((ids.contains(p.keep.id) || ids.contains(p.drop.id)) &&
          !notSame.contains('${p.keep.id}|${p.drop.id}'))
        p,
  ];
}

/// The Hunt home this item matches that was let or sold, if any.
Property? seenBefore(CatalogItem i, List<Property> homes) {
  final key = keyOfItem(i);
  for (final p in homes) {
    if (p.id == i.propertyId) continue;
    if ((listingGone(p.listingStatus) || Stage.of(p.stage) == Stage.dropped) &&
        sameHome(key, keyOfProperty(p)) != null) {
      return p;
    }
  }
  return null;
}

class ResearchesPage extends ConsumerWidget {
  const ResearchesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(catalogItemsProvider).value ?? const <CatalogItem>[];
    return PageScaffold(
      title: 'Researches',
      banner: 'page.researches',
      fab: FloatingActionButton.extended(
        heroTag: null,
        tooltip: hintText(ref, 'researches.new'),
        onPressed: () => editResearch(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New research'),
      ),
      children: [
        AsyncView(
          ref.watch(researchesProvider),
          builder: (researches) {
            if (researches.isEmpty) {
              return const EmptyState(
                icon: Icons.collections_bookmark_outlined,
                title: 'No researches yet',
                message:
                    'Start one for each hunt or study, such as "Rental near work, January" or "Buy-to-let in '
                    'Leeds". Each keeps its own catalog.',
              );
            }
            final open = researches.where((r) => !r.archived).toList();
            final archived = researches.where((r) => r.archived).toList();
            Widget card(ResearchJob r) {
              final mine = items.where((i) => i.researchId == r.id).toList();
              final dupes = duplicatesFor(mine, items).length;
              return Card(
                child: ListTile(
                  title: Text(r.name),
                  subtitle: Text(
                    [
                      researchKinds[r.kind] ?? r.kind,
                      '${mine.length} ${mine.length == 1 ? 'item' : 'items'}',
                      if (dupes > 0) '$dupes possible ${dupes == 1 ? 'duplicate' : 'duplicates'}',
                    ].join(' · '),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      Navigator.of(context)
                          .push(MaterialPageRoute<void>(builder: (_) => ResearchDetailPage(r.id))),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final r in open) card(r),
                if (archived.isNotEmpty) ...[
                  const RowsHeading('Archived'),
                  for (final r in archived) card(r),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

String hintText(WidgetRef ref, String id) => ref.read(hintTextsProvider)[id] ?? '';

/// Starts a research, or edits one.
Future<void> editResearch(BuildContext context, WidgetRef ref, {ResearchJob? r}) async {
  final c = r == null ? const ResearchCriteria() : criteriaOf(r);
  final name = TextEditingController(text: r?.name);
  final place = TextEditingController(text: c.place);
  final radius = TextEditingController(text: c.radiusKm?.toString());
  final maxPrice = TextEditingController(text: c.maxPrice?.toString());
  final minBeds = TextEditingController(text: c.minBeds?.toString());
  final words = TextEditingController(text: c.words);
  final notes = TextEditingController(text: r?.notes);
  var kind = r?.kind ?? 'rent';
  String? createdId;
  final ok = await showFormDialog(
    context,
    title: r == null ? 'New research' : 'Edit research',
    action: r == null ? 'Start' : 'Save',
    fields: (setState) => [
      Field(name, 'Name', hint: 'Rental near work, January', autofocus: r == null),
      Choice<String>(
        label: 'For',
        value: kind,
        options: researchKinds,
        onChanged: (v) => setState(() => kind = v),
      ),
      Field(place, 'Centre (postcode or place)', hint: 'BT1 1AA or Pontefract'),
      Field(radius, 'Within', number: true, suffix: 'km'),
      Field(maxPrice, kind == 'rent' ? 'Most rent a month' : 'Most price', number: true, prefix: '£'),
      Field(minBeds, 'Fewest bedrooms', number: true),
      Field(
        words,
        'Words',
        hint: 'parking garden -damp',
        helper: 'Words it should mention; -word for ones it must not.',
      ),
      Field(notes, 'Notes', lines: 2),
    ],
    onSave: () async {
      if (name.text.trim().isEmpty) return 'Give it a name.';
      double? lat = c.lat, lon = c.lon;
      if (place.text.trim() != c.place || (place.text.trim().isNotEmpty && lat == null)) {
        lat = lon = null;
        if (place.text.trim().isNotEmpty) {
          final p = await Research().whereIs(place.text.trim());
          if (p == null) return 'No UK postcode or place called "${place.text.trim()}".';
          lat = p.lat;
          lon = p.lon;
        }
      }
      final criteria = ResearchCriteria(
        place: place.text.trim(),
        lat: lat,
        lon: lon,
        radiusKm: numberIn(radius)?.toDouble(),
        maxPrice: intIn(maxPrice),
        minBeds: intIn(minBeds),
        words: words.text.trim(),
      );
      await ref.mutate((s) async {
        if (r == null) {
          createdId = await s.book.createResearch(
            name.text.trim(),
            kind: kind,
            criteria: criteria,
            notes: notes.text,
          );
        } else {
          await s.book.saveResearch(
            r.copyWith(name: name.text.trim(), kind: kind, criteria: criteria.toJson(), notes: notes.text),
          );
        }
      });
      return null;
    },
  );
  if (ok && createdId != null && context.mounted) {
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ResearchDetailPage(createdId!)));
  }
}

class ResearchDetailPage extends ConsumerWidget {
  const ResearchDetailPage(this.id, {super.key});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final researches = ref.watch(researchesProvider).value ?? const <ResearchJob>[];
    final r = researches.where((r) => r.id == id).firstOrNull;
    if (r == null) return const Scaffold(body: SizedBox.shrink());
    final all = ref.watch(catalogItemsProvider).value ?? const <CatalogItem>[];
    final homes = ref.watch(propertiesProvider).value ?? const <Property>[];
    final c = criteriaOf(r);
    final items = all.where((i) => i.researchId == id).toList();
    final scored = [for (final i in items) (item: i, fit: itemFit(c, i))]
      ..sort((a, b) {
        final s = b.fit.score.compareTo(a.fit.score);
        return s != 0 ? s : b.item.captured.compareTo(a.item.captured);
      });
    final dupes = duplicatesFor(items, all);
    return PageScaffold(
      title: r.name,
      actions: [
        IconButton(
          tooltip: hintText(ref, 'researches.duplicates'),
          onPressed: () => showDuplicates(context, ref, r),
          icon: Badge(
            isLabelVisible: dupes.isNotEmpty,
            label: Text('${dupes.length}'),
            child: const Icon(Icons.difference_outlined),
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (v) async {
            switch (v) {
              case 'edit':
                await editResearch(context, ref, r: r);
              case 'merge':
                await mergeResearchInto(context, ref, r);
              case 'archive':
                await ref.mutate((s) => s.book.saveResearch(r.copyWith(archived: !r.archived)));
              case 'delete':
                if (await confirm(
                      context,
                      'Delete "${r.name}"?',
                      'Its catalog of ${items.length} items goes too. Homes added to Hunt stay.',
                    ) &&
                    context.mounted) {
                  Navigator.of(context).pop();
                  await ref.mutate((s) => s.book.removeResearch(r.id));
                }
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'merge', child: Text('Merge another research into this')),
            PopupMenuItem(value: 'archive', child: Text(r.archived ? 'Bring back' : 'Archive')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ],
      fab: FloatingActionButton.extended(
        heroTag: null,
        tooltip: hintText(ref, 'researches.add'),
        onPressed: () => addToResearch(context, ref, r),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Capsule(researchKinds[r.kind] ?? r.kind),
            if (c.place.isNotEmpty)
              Capsule(
                c.radiusKm == null ? c.place : '${km(c.radiusKm!)} of ${c.place}',
                icon: Icons.place_outlined,
              ),
            if (c.maxPrice != null) Capsule('up to ${gbp(c.maxPrice!)}'),
            if (c.minBeds != null) Capsule('${c.minBeds}+ beds'),
            if (c.words.isNotEmpty) Capsule(c.words, icon: Icons.short_text),
          ],
        ),
        if (r.notes.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: Text(r.notes)),
        if (dupes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.difference_outlined),
                title: Text('${dupes.length} possible ${dupes.length == 1 ? 'duplicate' : 'duplicates'}'),
                subtitle: const Text('The same home captured more than once. Check and merge.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showDuplicates(context, ref, r),
              ),
            ),
          ),
        RowsHeading('Catalog', trailing: Text('${items.length}')),
        if (items.isEmpty)
          const EmptyState(
            icon: Icons.add_photo_alternate_outlined,
            title: 'Nothing captured yet',
            message:
                'Add a link, a screenshot, a photo of a sign, a PDF brochure or pasted text. The details are '
                'read on this device.',
          ),
        for (final s in scored)
          _ItemCard(item: s.item, fit: s.fit, showFit: !c.isEmpty, seen: seenBefore(s.item, homes)),
      ],
    );
  }
}

class _ItemCard extends ConsumerWidget {
  const _ItemCard({required this.item, required this.fit, required this.showFit, this.seen});
  final CatalogItem item;
  final ({double score, List<String> misses}) fit;
  final bool showFit;
  final Property? seen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = itemFields(item);
    final title = [
      item.title,
      item.address,
    ].firstWhere((t) => t.isNotEmpty, orElse: () => 'Untitled ${item.kind}');
    final tones = Tones.of(context);
    return Card(
      child: InkWell(
        onTap: () =>
            Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => CatalogItemPage(item.id))),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Thumb(item.id, kind: item.kind),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      [
                        if (f.price != null) '${gbp(f.price!)}${f.period.isEmpty ? '' : ' ${f.period}'}',
                        if (f.beds != null) f.beds == 0 ? 'studio' : '${f.beds} bed',
                        if (item.postcode.isNotEmpty && !title.contains(item.postcode)) item.postcode,
                        if (f.councilTaxBand.isNotEmpty) 'band ${f.councilTaxBand}',
                        if (f.epc.isNotEmpty) 'EPC ${f.epc}',
                        if (item.source.isNotEmpty) item.source,
                      ].join(' · '),
                    ),
                    if (showFit && fit.misses.isNotEmpty)
                      Text(fit.misses.join(', '), style: TextStyle(color: tones.muted)),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (item.propertyId != null) const Capsule('In Hunt', icon: Icons.travel_explore),
                        if (listingGone(f.status)) Capsule(listingStatusLabel(f.status)),
                        if (seen != null) const Capsule('Seen before', icon: Icons.history),
                      ],
                    ),
                  ],
                ),
              ),
              if (showFit)
                Tooltip(
                  message: hintText(ref, 'researches.fit'),
                  child: Text(
                    '${(fit.score * 100).round()}%',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumb extends ConsumerWidget {
  const _Thumb(this.itemId, {required this.kind, this.size = 56});
  final String itemId, kind;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) => FutureBuilder(
    future: ref.read(sessionProvider).book.image(itemId),
    builder: (context, snap) => ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: size,
        height: size,
        child: snap.data == null
            ? ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(switch (kind) {
                  'photo' => Icons.image_outlined,
                  'document' => Icons.description_outlined,
                  'link' || 'page' => Icons.link,
                  _ => Icons.sticky_note_2_outlined,
                }),
              )
            : Image.memory(snap.data!, fit: BoxFit.cover, gaplessPlayback: true),
      ),
    ),
  );
}

/// Asks how to add, then captures into [r]'s catalog.
Future<void> addToResearch(BuildContext context, WidgetRef ref, ResearchJob r) async {
  final how = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('A link'),
            subtitle: const Text(
              'PropertyPal adverts are read; other sites keep the link and you add details',
            ),
            onTap: () => Navigator.pop(context, 'link'),
          ),
          ListTile(
            leading: const Icon(Icons.add_photo_alternate_outlined),
            title: const Text('Screenshots, photos or PDFs'),
            subtitle: const Text('Read with OCR on this device; pick several at once'),
            onTap: () => Navigator.pop(context, 'file'),
          ),
          ListTile(
            leading: const Icon(Icons.content_paste),
            title: const Text('Pasted text'),
            subtitle: const Text('An advert, an alert email or an agent\'s message'),
            onTap: () => Navigator.pop(context, 'text'),
          ),
          ListTile(
            leading: const Icon(Icons.sticky_note_2_outlined),
            title: const Text('A note'),
            onTap: () => Navigator.pop(context, 'note'),
          ),
        ],
      ),
    ),
  );
  if (!context.mounted || how == null) return;
  switch (how) {
    case 'link':
      await _addLink(context, ref, r);
    case 'file':
      await _addFiles(context, ref, r);
    case 'text':
      await _addText(context, ref, r, note: false);
    case 'note':
      await _addText(context, ref, r, note: true);
  }
}

/// Looks the postcode up so distances can be measured; offline is fine.
Future<Map<String, Object?>> _placeOf(String postcode) async {
  if (postcode.isEmpty) return const {};
  try {
    final p = await Research().whereIs(postcode);
    return p == null ? const {} : {'lat': p.lat, 'lon': p.lon};
  } on Object {
    return const {};
  }
}

Future<void> _saved(BuildContext context, WidgetRef ref, List<String> ids) async {
  if (!context.mounted || ids.isEmpty) return;
  final all = await ref.read(catalogItemsProvider.future);
  final dupes = duplicatesFor(all.where((i) => ids.contains(i.id)).toList(), all);
  if (!context.mounted) return;
  showMessage(
    context,
    [
      ids.length == 1 ? 'Added to the catalog' : 'Added ${ids.length} items',
      if (dupes.isNotEmpty) '${dupes.length} may be duplicates; tap the duplicates button to check',
    ].join('. '),
  );
}

Future<String> _add(
  WidgetRef ref,
  ResearchJob r, {
  required String kind,
  required ItemFields fields,
  String title = '',
  String url = '',
  String source = '',
  String? sourceId,
  String body = '',
  Uint8List? image,
  String? imageHash,
  String notes = '',
}) async {
  final place = await _placeOf(fields.postcode);
  return ref.mutate((s) async {
    final id = await s.book.addItem(
      r.id,
      kind: kind,
      title: title,
      url: url,
      source: source,
      sourceId: sourceId,
      fields: fields,
      body: body,
      image: image,
      imageHash: imageHash,
      notes: notes,
    );
    if (place.isNotEmpty) {
      final item = await (s.db.select(s.db.catalogItems)..where((i) => i.id.equals(id))).getSingle();
      await s.book.save(
        s.db.catalogItems,
        item.copyWith(fields: jsonEncode({...fieldsOf(item), ...place})),
        id,
      );
    }
    return id;
  });
}

Future<void> _addLink(BuildContext context, WidgetRef ref, ResearchJob r) async {
  final link = TextEditingController();
  final ids = <String>[];
  await showFormDialog(
    context,
    title: 'Add a link',
    action: 'Add',
    fields: (_) => [
      Field(link, 'Link', hint: 'https://…', autofocus: true),
      const Text(
        'PropertyPal adverts and searches are read for you. Other sites do not allow apps to read their pages, '
        'so the link is kept and you can add a screenshot or the details.',
      ),
    ],
    onSave: () async {
      final text = link.text.trim();
      final uri = Uri.tryParse(text);
      if (uri == null || !uri.hasScheme || uri.host.isEmpty) return 'That is not a web link.';
      if (uri.host.endsWith('propertypal.com')) {
        final List<Listing> listings;
        try {
          listings = await fetchPropertyPal(text);
        } on FormatException catch (e) {
          return e.message;
        }
        for (final l in listings) {
          ids.add(
            await _add(
              ref,
              r,
              kind: 'link',
              title: l.address,
              url: l.url,
              source: 'propertypal',
              sourceId: l.sourceId,
              fields: ItemFields.fromListing(l),
              body: l.description,
            ),
          );
        }
        return null;
      }
      final portal = parsePortalLink(text);
      ids.add(
        await _add(
          ref,
          r,
          kind: 'link',
          title: portal?.address ?? '',
          url: portal?.url.toString() ?? text,
          source: portal?.portal.name ?? uri.host.replaceFirst('www.', ''),
          sourceId: portal?.id,
          fields: ItemFields(address: portal?.address ?? ''),
        ),
      );
      return null;
    },
  );
  if (!context.mounted) return;
  await _saved(context, ref, ids);
  if (ids.length == 1 && context.mounted) {
    final item = (await ref.read(catalogItemsProvider.future)).where((i) => i.id == ids.single).firstOrNull;
    if (item != null && item.price == null && context.mounted) {
      await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => CatalogItemPage(item.id)));
    }
  }
}

Future<void> _addFiles(BuildContext context, WidgetRef ref, ResearchJob r) async {
  final picked = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: captureExtensions,
    dialogTitle: 'Screenshots, photos or PDFs to add',
  );
  final paths = [for (final f in picked) ?f.path];
  if (paths.isEmpty || !context.mounted) return;
  final ids = <String>[];
  final failed = <String>[];
  await showBusy(context, 'Reading ${paths.length == 1 ? 'the file' : '${paths.length} files'}…', () async {
    for (final path in paths) {
      try {
        final cap = await recogniseFile(path);
        ids.add(
          await _add(
            ref,
            r,
            kind: cap.kind,
            title: cap.title,
            fields: cap.fields,
            body: cap.text,
            image: cap.image,
            imageHash: cap.imageHash,
          ),
        );
      } on RecognitionException catch (e) {
        failed.add(e.message);
      }
    }
  });
  if (!context.mounted) return;
  if (failed.isNotEmpty) {
    showMessage(context, failed.first);
    return;
  }
  await _saved(context, ref, ids);
}

Future<void> _addText(BuildContext context, WidgetRef ref, ResearchJob r, {required bool note}) async {
  final pasted = note ? null : await Clipboard.getData(Clipboard.kTextPlain);
  if (!context.mounted) return;
  final text = TextEditingController(text: note ? '' : pasted?.text ?? '');
  final title = TextEditingController();
  final ids = <String>[];
  await showFormDialog(
    context,
    title: note ? 'Add a note' : 'Add pasted text',
    action: 'Add',
    fields: (_) => [
      Field(title, 'Title', hint: note ? 'Spoke to the agent' : 'Optional', autofocus: note),
      Field(text, note ? 'Note' : 'Text', lines: 6),
    ],
    onSave: () async {
      if (text.text.trim().isEmpty) return note ? 'Write the note.' : 'Paste the text.';
      final raw = text.text.contains('<html') ? textOfHtml(text.text) : text.text;
      ids.add(
        await _add(
          ref,
          r,
          kind: note ? 'note' : 'document',
          title: title.text.trim(),
          fields: readFields(raw),
          body: note ? '' : raw,
          notes: note ? raw : '',
        ),
      );
      return null;
    },
  );
  if (context.mounted) await _saved(context, ref, ids);
}

/// Runs [work] behind a small "working" dialog.
Future<void> showBusy(BuildContext context, String what, Future<void> Function() work) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 16),
          Expanded(child: Text(what)),
        ],
      ),
    ),
  );
  try {
    await work();
  } finally {
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
  }
}

Future<bool> confirm(BuildContext context, String title, String message, {String action = 'Delete'}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(action)),
        ],
      ),
    ) ??
    false;

/// Picks another research and merges it into [into].
Future<void> mergeResearchInto(BuildContext context, WidgetRef ref, ResearchJob into) async {
  final others = (await ref.read(researchesProvider.future)).where((r) => r.id != into.id).toList();
  if (!context.mounted) return;
  if (others.isEmpty) {
    showMessage(context, 'There is no other research to merge.');
    return;
  }
  final from = await showDialog<ResearchJob>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text('Merge into "${into.name}"'),
      children: [
        for (final o in others)
          SimpleDialogOption(onPressed: () => Navigator.pop(context, o), child: Text(o.name)),
      ],
    ),
  );
  if (from == null || !context.mounted) return;
  if (!await confirm(
        context,
        'Merge "${from.name}"?',
        'Its catalog moves into "${into.name}" and "${from.name}" is removed. Duplicates are shown for you to merge.',
        action: 'Merge',
      ) ||
      !context.mounted) {
    return;
  }
  await ref.mutate((s) => s.book.mergeResearches(into.id, from.id));
  if (context.mounted) await showDuplicates(context, ref, into);
}

/// The likely duplicates for [r]'s catalog, to merge or mark as different.
Future<void> showDuplicates(BuildContext context, WidgetRef ref, ResearchJob r) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => _DuplicatesPage(r.id)));

class _DuplicatesPage extends ConsumerWidget {
  const _DuplicatesPage(this.researchId);
  final String researchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(catalogItemsProvider).value ?? const <CatalogItem>[];
    final researches = {
      for (final r in ref.watch(researchesProvider).value ?? const <ResearchJob>[]) r.id: r,
    };
    final byId = {for (final i in all) i.id: i};
    final pairs = duplicatesFor(all.where((i) => i.researchId == researchId).toList(), all);
    Widget side(CatalogItem i) {
      final f = itemFields(i);
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Thumb(i.id, kind: i.kind, size: 72),
            const SizedBox(height: 6),
            Text([i.title, i.address].firstWhere((t) => t.isNotEmpty, orElse: () => i.kind), maxLines: 2),
            Text(
              [
                if (f.price != null) gbp(f.price!),
                if (f.beds != null) '${f.beds} bed',
                if (i.postcode.isNotEmpty) i.postcode,
                if (i.source.isNotEmpty) i.source,
                i.captured.substring(0, 10),
                if (i.researchId != researchId) 'in ${researches[i.researchId]?.name ?? 'another research'}',
              ].join(' · '),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return PageScaffold(
      title: 'Possible duplicates',
      children: [
        if (pairs.isEmpty)
          const EmptyState(
            icon: Icons.check_circle_outline,
            title: 'No duplicates found',
            message: 'Nothing here looks like the same home twice.',
          ),
        for (final p in pairs)
          if (byId[p.keep.id] != null && byId[p.drop.id] != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Eyebrow(p.reason.label),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [side(byId[p.keep.id]!), const SizedBox(width: 12), side(byId[p.drop.id]!)],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8,
                      children: [
                        TextButton(
                          onPressed: () => ref.mutate((s) async {
                            final drop = byId[p.drop.id]!;
                            final f = fieldsOf(drop);
                            final notSame = {
                              ...((f['notSame'] as List?) ?? const []).cast<String>(),
                              p.keep.id,
                            };
                            await s.book.save(
                              s.db.catalogItems,
                              drop.copyWith(fields: jsonEncode({...f, 'notSame': notSame.toList()})),
                              drop.id,
                            );
                          }),
                          child: const Text('Not the same'),
                        ),
                        FilledButton(
                          // Merge into the one in this research, the earlier one when both are.
                          onPressed: () {
                            final keepHere = byId[p.keep.id]!.researchId == researchId;
                            final keep = keepHere ? p.keep.id : p.drop.id;
                            final drop = keepHere ? p.drop.id : p.keep.id;
                            ref.mutate((s) => s.book.mergeItems(keep, drop));
                          },
                          child: const Text('Merge'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

const _statuses = {
  '': '–',
  'toLet': 'To let',
  'letAgreed': 'Let agreed',
  'forSale': 'For sale',
  'saleAgreed': 'Sale agreed',
  'sold': 'Sold',
};

/// One catalog item: its picture, details (editable), links, prices seen,
/// the text they came from, and adding it to Hunt.
class CatalogItemPage extends ConsumerStatefulWidget {
  const CatalogItemPage(this.id, {super.key});
  final String id;

  @override
  ConsumerState<CatalogItemPage> createState() => _CatalogItemPageState();
}

class _CatalogItemPageState extends ConsumerState<CatalogItemPage> {
  final _c = <String, TextEditingController>{};
  String? _loadedHlc;
  var _period = '', _status = '', _furnished = '';

  TextEditingController _f(String k) => _c.putIfAbsent(k, TextEditingController.new);

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _load(CatalogItem i) {
    if (_loadedHlc == i.hlc) return;
    _loadedHlc = i.hlc;
    final f = itemFields(i);
    _f('title').text = i.title;
    _f('address').text = f.address;
    _f('postcode').text = f.postcode;
    _f('price').text = f.price?.toString() ?? '';
    _f('beds').text = f.beds?.toString() ?? '';
    _f('baths').text = f.baths?.toString() ?? '';
    _f('band').text = f.councilTaxBand;
    _f('epc').text = f.epc;
    _f('phone').text = f.phone;
    _f('agent').text = f.agent;
    _f('available').text = f.availableFrom;
    _f('notes').text = i.notes;
    _period = f.period;
    _status = _statuses.containsKey(f.status) ? f.status : '';
    _furnished = f.furnished;
  }

  ItemFields get _fields => ItemFields(
    address: _f('address').text.trim(),
    postcode: postcodeIn(_f('postcode').text) ?? _f('postcode').text.trim().toUpperCase(),
    price: intIn(_f('price')),
    period: _period,
    beds: intIn(_f('beds')),
    baths: intIn(_f('baths')),
    councilTaxBand: _f('band').text.trim().toUpperCase(),
    epc: _f('epc').text.trim().toUpperCase(),
    phone: _f('phone').text.trim(),
    agent: _f('agent').text.trim(),
    availableFrom: _f('available').text.trim(),
    status: _status,
    furnished: _furnished,
  );

  Future<void> _save(CatalogItem i) async {
    final f = _fields;
    final place = f.postcode != i.postcode ? await _placeOf(f.postcode) : const <String, Object?>{};
    await ref.mutate((s) async {
      await s.book.saveItem(i, f, title: _f('title').text.trim(), notes: _f('notes').text);
      if (place.isNotEmpty) {
        final now = await (s.db.select(s.db.catalogItems)..where((x) => x.id.equals(i.id))).getSingle();
        await s.book.save(
          s.db.catalogItems,
          now.copyWith(fields: jsonEncode({...fieldsOf(now), ...place})),
          i.id,
        );
      }
    });
    if (mounted) showMessage(context, 'Saved.');
  }

  Future<void> _readWithAi(CatalogItem i) async {
    final setup = ref.read(helpAiProvider).value ?? const HelpAiSetup();
    if (setup.via == HelpAi.chat) {
      showMessage(context, 'Choose an AI in Settings, Ask AI first (a chat website cannot fill in details).');
      return;
    }
    if (i.body.trim().isEmpty) {
      showMessage(context, 'This item has no text to read.');
      return;
    }
    final ok = await confirm(
      context,
      'Read with ${setup.via.label}?',
      'Only this item\'s text (${i.body.length} characters) is sent, to the AI you chose. Pictures and your '
          'other data are not.',
      action: 'Send',
    );
    if (!ok || !mounted) return;
    ItemFields? got;
    await guarded(context, () async {
      await showBusy(context, 'Asking ${setup.via.label}…', () async {
        final asker = await ref.read(helpAskerProvider)(setup);
        got = await aiFields(asker, i.body);
      });
    });
    if (got == null || !mounted) return;
    final merged = _fields.over(got!);
    setState(() {
      _f('address').text = merged.address;
      _f('postcode').text = merged.postcode;
      _f('price').text = merged.price?.toString() ?? '';
      _f('beds').text = merged.beds?.toString() ?? '';
      _f('baths').text = merged.baths?.toString() ?? '';
      _f('band').text = merged.councilTaxBand;
      _f('epc').text = merged.epc;
      _f('phone').text = merged.phone;
      _f('agent').text = merged.agent;
      _f('available').text = merged.availableFrom;
      _period = merged.period;
      _status = _statuses.containsKey(merged.status) ? merged.status : _status;
      _furnished = merged.furnished;
    });
    showMessage(context, 'Filled in what was missing. Check it, then Save.');
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(catalogItemsProvider).value ?? const <CatalogItem>[];
    final i = all.where((x) => x.id == widget.id).firstOrNull;
    if (i == null) return const Scaffold(body: SizedBox.shrink());
    _load(i);
    final research = (ref.watch(researchesProvider).value ?? const <ResearchJob>[])
        .where((r) => r.id == i.researchId)
        .firstOrNull;
    final homes = ref.watch(propertiesProvider).value ?? const <Property>[];
    final seen = seenBefore(i, homes);
    final prices = ((fieldsOf(i)['prices'] as List?) ?? const []).cast<Map>();
    return PageScaffold(
      title: i.title.isNotEmpty ? i.title : (i.address.isNotEmpty ? i.address : 'Catalog item'),
      actions: [
        IconButton(
          tooltip: hintText(ref, 'researches.ai'),
          onPressed: () => _readWithAi(i),
          icon: const Icon(Icons.auto_awesome_outlined),
        ),
        IconButton(
          tooltip: 'Delete',
          onPressed: () async {
            if (await confirm(context, 'Delete this item?', 'It is removed from "${research?.name}".') &&
                context.mounted) {
              Navigator.of(context).pop();
              await ref.mutate((s) => s.book.removeItem(i.id));
            }
          },
          icon: const Icon(Icons.delete_outline),
        ),
      ],
      children: [
        FutureBuilder(
          future: ref.read(sessionProvider).book.image(i.id),
          builder: (context, snap) => snap.data == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 360),
                      child: Image.memory(snap.data!, fit: BoxFit.contain),
                    ),
                  ),
                ),
        ),
        if (seen != null)
          Card(
            child: ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Seen before'),
              subtitle: Text(
                '${seen.address}: ${listingStatusLabel(seen.listingStatus)}${seen.added.isEmpty ? '' : ', saved ${seen.added}'}',
              ),
              onTap: () =>
                  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PropertyPage(seen.id))),
            ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (i.propertyId != null)
              FilledButton.tonalIcon(
                onPressed: () =>
                    Navigator.of(context)
                        .push(MaterialPageRoute<void>(builder: (_) => PropertyPage(i.propertyId!))),
                icon: const Icon(Icons.travel_explore),
                label: const Text('Open in Hunt'),
              )
            else
              FilledButton.tonalIcon(
                onPressed: () async {
                  await _save(i);
                  final now = (await ref.read(catalogItemsProvider.future)).firstWhere((x) => x.id == i.id);
                  final rental = research?.kind == 'rent' || _period.isNotEmpty;
                  await ref.mutate((s) => s.book.itemToHunt(now, rental: rental));
                  if (context.mounted) showMessage(context, 'Added to Hunt.');
                },
                icon: const Icon(Icons.add_home_outlined),
                label: const Text('Add to Hunt'),
              ),
            for (final link in linksOf(i))
              OutlinedButton.icon(
                onPressed: () => openInApp(context, Uri.parse(link)),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: Text(Uri.tryParse(link)?.host.replaceFirst('www.', '') ?? link),
              ),
          ],
        ),
        const RowsHeading('Details'),
        Field(_f('title'), 'Title'),
        Field(_f('address'), 'Address'),
        Field(_f('postcode'), 'Postcode'),
        Row(
          children: [
            Expanded(child: Field(_f('price'), 'Price', number: true, prefix: '£')),
            const SizedBox(width: 12),
            Expanded(
              child: Choice<String>(
                label: 'Per',
                value: _period,
                options: const {'pcm': 'month', 'pw': 'week', '': 'sale price'},
                onChanged: (v) => setState(() => _period = v),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(child: Field(_f('beds'), 'Bedrooms', number: true)),
            const SizedBox(width: 12),
            Expanded(child: Field(_f('baths'), 'Bathrooms', number: true)),
          ],
        ),
        Row(
          children: [
            Expanded(child: Field(_f('band'), 'Council tax band')),
            const SizedBox(width: 12),
            Expanded(child: Field(_f('epc'), 'EPC rating')),
          ],
        ),
        Choice<String>(
          label: 'Furnished',
          value: _furnished,
          options: const {
            '': '–',
            'furnished': 'Furnished',
            'part': 'Part furnished',
            'unfurnished': 'Unfurnished',
          },
          onChanged: (v) => setState(() => _furnished = v),
        ),
        Field(_f('available'), 'Available from'),
        Field(_f('agent'), 'Agent or landlord'),
        Field(_f('phone'), 'Phone'),
        Choice<String>(
          label: 'Advert says',
          value: _status,
          options: _statuses,
          onChanged: (v) => setState(() => _status = v),
        ),
        Field(_f('notes'), 'Notes', lines: 3),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(onPressed: () => _save(i), child: const Text('Save')),
        ),
        if (prices.length > 1) ...[
          const RowsHeading('Prices seen'),
          for (final p in prices) FigureRow('${p['at']}', gbp(p['price'] as num)),
        ],
        if (i.body.trim().isNotEmpty) ...[
          const RowsHeading('Text it was read from'),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text('${i.body.length} characters'),
            children: [SelectableText(i.body)],
          ),
        ],
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          child: Text(
            'Captured ${i.captured.replaceFirst('T', ' ').substring(0, 16)}${research == null ? '' : ' into ${research.name}'}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
