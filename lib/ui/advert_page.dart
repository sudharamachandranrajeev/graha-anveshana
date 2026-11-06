import 'package:brahma_core/brahma_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/search_controller.dart';
import '../domain/advert.dart';
import '../domain/listing.dart';
import '../domain/property_search.dart';
import '../domain/search_request.dart';
import '../domain/sources.dart';
import 'browser_page.dart';
import 'common.dart';
import 'look.dart';
import 'search_page.dart';

/// A home from the search, shown in full inside the app: every photo, the
/// description, facts, floor plans and agent, read from the site's advert.
class AdvertPage extends ConsumerStatefulWidget {
  const AdvertPage(this.home, this.request, {super.key});
  final FoundHome home;
  final SearchRequest request;

  @override
  ConsumerState<AdvertPage> createState() => _AdvertPageState();
}

class _AdvertPageState extends ConsumerState<AdvertPage> {
  var _copy = 0;
  final _reads = <int, Future<AdvertDetails?>>{};

  FoundHome get h => widget.home;
  Listing get l => h.copies[_copy];

  Future<AdvertDetails?> get _details => _reads[_copy] ??= readAdvert(ref.read(searchHttpProvider), l);

  String get _site => SourceId.ofKey(l.source)?.label ?? l.source;

  void _openSite() => openInApp(context, Uri.parse(l.url), title: _site);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final q = widget.request;
    return PageScaffold(
      title: l.address.split(',').first,
      actions: [
        IconButton(tooltip: 'See it on $_site', icon: const Icon(Icons.language), onPressed: _openSite),
      ],
      body: FutureBuilder<AdvertDetails?>(
        future: _details,
        builder: (context, snap) {
          final d = snap.data;
          final photos = [...?d?.photos, if ((d?.photos ?? const []).isEmpty && h.image != null) h.image!];
          final facts = [
            if (h.beds != null) h.beds == 0 ? 'Studio' : '${h.beds} bed',
            if (l.baths != null) '${l.baths} bath',
            if (l.style.isNotEmpty) l.style,
            if (l.furnished.isNotEmpty) l.furnished,
          ].join(' · ');
          final phone = (d?.phone.isNotEmpty ?? false) ? d!.phone : l.agentPhone;
          final agent = (d?.agent.isNotEmpty ?? false) ? d!.agent : l.agent;
          return ListView(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 96 + MediaQuery.paddingOf(context).bottom),
            children: [
              Readable(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (photos.isNotEmpty) _Gallery(photos),
                    const SizedBox(height: 12),
                    Text(
                      h.price == null ? 'Price not shown' : '${gbp(h.price!)}${q.rent ? ' a month' : ''}',
                      style: t.headlineSmall,
                    ),
                    Text(l.address, style: t.titleMedium),
                    if (facts.isNotEmpty) Text(facts),
                    if (h.km != null)
                      Text('${miles(h.km!)} from ${ref.read(searchProvider).centre?.label ?? 'the centre'}'),
                    if (h.gone) ...[
                      const SizedBox(height: 4),
                      StatusLabel(Status.warning, q.rent ? 'Let agreed' : 'Sold or under offer'),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: () => saveToHunt(context, ref, h, rent: q.rent),
                          icon: const Icon(Icons.bookmark_add_outlined),
                          label: const Text('Add to Hunt'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => saveToResearch(context, ref, h, q),
                          icon: const Icon(Icons.collections_bookmark_outlined),
                          label: const Text('Add to a research'),
                        ),
                        if (phone.isNotEmpty)
                          OutlinedButton.icon(
                            onPressed: () =>
                                openUri(context, Uri(scheme: 'tel', path: phone.replaceAll(' ', ''))),
                            icon: const Icon(Icons.call_outlined),
                            label: Text('Call $phone'),
                          ),
                      ],
                    ),
                    if (h.copies.length > 1) ...[
                      const SizedBox(height: 16),
                      Text('On ${h.copies.length} sites', style: t.titleSmall),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (var i = 0; i < h.copies.length; i++)
                            ChoiceChip(
                              label: Text(
                                [
                                  SourceId.ofKey(h.copies[i].source)?.label ?? h.copies[i].source,
                                  if (h.copies[i].price != null) gbp(h.copies[i].price!),
                                ].join(' '),
                              ),
                              selected: i == _copy,
                              onSelected: (_) => setState(() => _copy = i),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (snap.connectionState != ConnectionState.done)
                      const Center(
                        child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()),
                      )
                    else if (snap.hasError || d == null)
                      _NotRead(site: _site, error: snap.error, text: l.description, onOpen: _openSite)
                    else ...[
                      if (d.features.isNotEmpty)
                        SectionCard(
                          title: 'Key features',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [for (final f in d.features) Text('• $f')],
                          ),
                        ),
                      if (d.facts.isNotEmpty)
                        SectionCard(
                          title: 'Details',
                          child: Column(
                            children: [for (final e in d.facts.entries) FigureRow(e.key, e.value)],
                          ),
                        ),
                      SectionCard(
                        title: 'Description',
                        child: SelectableText(d.description.isEmpty ? l.description : d.description),
                      ),
                      if (d.floorplans.isNotEmpty)
                        SectionCard(
                          title: 'Floor plans',
                          child: Column(
                            children: [
                              for (final f in d.floorplans)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Image.network(f, errorBuilder: (_, _, _) => const SizedBox()),
                                ),
                            ],
                          ),
                        ),
                    ],
                    if (agent.isNotEmpty)
                      SectionCard(
                        title: 'Agent',
                        child: Text([agent, if (phone.isNotEmpty) phone].join('\n')),
                      ),
                    Text(
                      'From $_site. Check the details with the agent before you commit.',
                      style: t.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The advert could not be read in the app: what the results page said, and
/// the site's own page inside the app.
class _NotRead extends StatelessWidget {
  const _NotRead({required this.site, required this.error, required this.text, required this.onOpen});
  final String site;
  final Object? error;
  final String text;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => SectionCard(
    title: 'Description',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (text.isNotEmpty) SelectableText(text),
        const SizedBox(height: 8),
        Text(
          error is SourceBlocked
              ? '$site asked to check you are not a robot, so the full advert is on its page.'
              : 'The full advert could not be read here${error == null ? '' : ' (${describeError(error!)})'}.',
        ),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          onPressed: onOpen,
          icon: const Icon(Icons.language),
          label: Text('See it on $site'),
        ),
      ],
    ),
  );
}

/// The advert's photos, one at a time.
class _Gallery extends StatefulWidget {
  const _Gallery(this.photos);
  final List<String> photos;

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  final _pages = PageController();
  var _at = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _go(int i) =>
      _pages.animateToPage(i, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);

  @override
  Widget build(BuildContext context) {
    final n = widget.photos.length;
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pages,
              itemCount: n,
              onPageChanged: (i) => setState(() => _at = i),
              itemBuilder: (_, i) => Image.network(
                widget.photos[i],
                fit: BoxFit.cover,
                semanticLabel: 'Photo ${i + 1} of $n',
                errorBuilder: (_, _, _) => ColoredBox(color: scheme.surfaceContainerHighest),
              ),
            ),
            if (n > 1) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton.filledTonal(
                  tooltip: 'Previous photo',
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _at == 0 ? null : () => _go(_at - 1),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton.filledTonal(
                  tooltip: 'Next photo',
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _at == n - 1 ? null : () => _go(_at + 1),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(padding: const EdgeInsets.all(8), child: Capsule('${_at + 1} / $n')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
