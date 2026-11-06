import 'package:brahma_core/brahma_core.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../db/database.dart';
import '../domain/book.dart';
import '../domain/contact_links.dart';
import '../domain/pipeline.dart';
import '../domain/portals.dart';
import '../domain/viewing_checklist.dart';
import 'advert_browser.dart';
import 'common.dart';
import 'look.dart';
import 'contacts_page.dart';
import 'hunt_page.dart';
import 'invest_page.dart';
import 'price_check_card.dart';
import 'research_page.dart';

const channelLabels = {
  'call': 'Call',
  'sms': 'Text',
  'whatsapp': 'WhatsApp',
  'email': 'E-mail',
  'visit': 'Visit',
  'note': 'Note',
};

const channelIcons = {
  'call': Icons.call_outlined,
  'sms': Icons.sms_outlined,
  'whatsapp': Icons.chat_outlined,
  'email': Icons.email_outlined,
  'visit': Icons.directions_walk,
  'note': Icons.sticky_note_2_outlined,
};

class PropertyPage extends ConsumerWidget {
  const PropertyPage(this.id, {super.key});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(propertiesProvider);
    final p = all.value?.where((p) => p.id == id).firstOrNull;
    if (p == null) {
      return Scaffold(
        appBar: AppBar(),
        body: all.isLoading
            ? const Center(child: CircularProgressIndicator())
            : const EmptyState(icon: Icons.home_outlined, title: 'This property was removed'),
      );
    }
    final kind = PropertyKind.of(p.kind);
    final contacts = ref.watch(contactsProvider).value ?? const <Contact>[];
    final agent = contacts.where((c) => c.id == p.agentId).firstOrNull;
    final home = ref.watch(homeProvider).value;
    final dist = distanceFromHome(home, p.lat, p.lon);
    final log = (ref.watch(interactionsProvider).value ?? const <Interaction>[])
        .where((i) => i.propertyId == id)
        .toList();
    final viewings = (ref.watch(viewingsProvider).value ?? const <Viewing>[])
        .where((v) => v.propertyId == id)
        .toList();
    final t = Theme.of(context).textTheme;

    return PageScaffold(
      title: p.address.split(',').first,
      actions: [
        if (p.url.isNotEmpty)
          IconButton(
            tooltip: 'Open the advert',
            icon: const Icon(Icons.open_in_new),
            // A portal advert opens in the app's browser, where Save brings
            // in its photos and details.
            onPressed: () => parsePortalLink(p.url) == null
                ? openUri(context, Uri.parse(p.url))
                : openPortal(context, Uri.parse(p.url)),
          ),
        IconButton(
          tooltip: 'Edit',
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => editProperty(context, ref, p: p),
        ),
        IconButton(
          tooltip: 'Remove',
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _remove(context, ref, p),
        ),
      ],
      children: [
        if (photosOf(p) case final photos when photos.isNotEmpty) PhotoGallery(photos),
        const SizedBox(height: 16),
        Eyebrow('${kind.label} · ${Stage.of(p.stage).label(kind)}'),
        const SizedBox(height: 4),
        Text(p.address, style: t.headlineSmall),
        const SizedBox(height: 12),
        FigureCard(
          eyebrow: kind == PropertyKind.rent ? 'Rent a month' : 'Price',
          value: p.price == null ? '–' : gbp(p.price!),
          caption: propertyFacts(p).isEmpty ? null : propertyFacts(p),
          detail: dist == null ? null : '${km(dist)} from ${home!.label.isEmpty ? 'home' : home.label}',
          accent: p.rating >= 4,
        ),
        Wrap(
          spacing: 16,
          runSpacing: 4,
          children: [
            if (p.availableFrom != null) Text('Available ${niceDate(p.availableFrom!)}'),
            if (p.listingStatus.isNotEmpty)
              StatusLabel(
                listingGone(p.listingStatus) ? Status.warning : Status.good,
                listingStatusLabel(p.listingStatus),
              ),
            Text('Added ${niceDate(p.added)}'),
          ],
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Stage',
          hint: 'hunt.stage',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in Stage.values)
                    ChoiceChip(
                      label: Text(s.label(kind)),
                      selected: Stage.of(p.stage) == s,
                      onSelected: (_) => ref.mutate((x) => x.book.setStage(p.id, s)),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Rating'),
                  for (var i = 1; i <= 5; i++)
                    IconButton(
                      tooltip: '$i of 5',
                      icon: Icon(i <= p.rating ? Icons.star : Icons.star_border, color: lime),
                      onPressed: () => ref.mutate(
                        (x) => x.book.save(x.db.properties, p.copyWith(rating: i == p.rating ? 0 : i), p.id),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        PriceCheckCard(p),
        _ContactCard(p, agent),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Viewings',
          trailing: Wrap(
            children: [
              TextButton.icon(
                onPressed: () => _checklist(context, ref, p, kind),
                icon: const Icon(Icons.checklist),
                label: const Text('Checklist'),
              ),
              TextButton.icon(
                onPressed: () => _bookViewing(context, ref, p),
                icon: const Icon(Icons.event_available_outlined),
                label: const Text('Book'),
              ),
            ],
          ),
          child: viewings.isEmpty
              ? const Text('None booked.')
              : Column(
                  children: [
                    for (final v in viewings)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(switch (v.status) {
                          'done' => Icons.check_circle_outline,
                          'cancelled' => Icons.cancel_outlined,
                          _ => Icons.event_outlined,
                        }),
                        title: Text(niceDateTime(v.at)),
                        subtitle: v.notes.isEmpty ? null : Text(v.notes),
                        trailing: PopupMenuButton<String>(
                          onSelected: (s) =>
                              ref.mutate((x) => x.book.save(x.db.viewings, v.copyWith(status: s), v.id)),
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'booked', child: Text('Booked')),
                            PopupMenuItem(value: 'done', child: Text('Done')),
                            PopupMenuItem(value: 'cancelled', child: Text('Cancelled')),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Contact log',
          trailing: TextButton.icon(
            onPressed: () => logInteraction(context, ref, propertyId: p.id, contactId: p.agentId),
            icon: const Icon(Icons.add_comment_outlined),
            label: const Text('Add'),
          ),
          child: log.isEmpty
              ? const Text('Nothing yet. Calls and messages started here are logged.')
              : Column(
                  children: [
                    for (final i in log)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(channelIcons[i.channel] ?? Icons.chat_bubble_outline),
                        title: Text(
                          '${channelLabels[i.channel] ?? i.channel}${i.direction == 'in' ? ' from them' : ''} · ${niceDateTime(i.at)}',
                        ),
                        subtitle: Text(
                          [
                            i.summary,
                            if (i.followUp != null) 'Follow up ${niceDate(i.followUp!)}',
                          ].where((s) => s.isNotEmpty).join('\n'),
                        ),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Notes',
          trailing: IconButton(
            tooltip: 'Edit notes',
            icon: const Icon(Icons.edit_note),
            onPressed: () => _editNotes(context, ref, p),
          ),
          child: Text(p.notes.isEmpty ? 'No notes.' : p.notes),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (p.postcode.isNotEmpty)
              OutlinedButton.icon(
                onPressed: () =>
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => ResearchPage(postcode: p.postcode))),
                icon: const Icon(Icons.map_outlined),
                label: const Text('Area report'),
              ),
            if (kind == PropertyKind.rent)
              OutlinedButton.icon(
                onPressed: () => checkAdvertWording(context, rent: p.price),
                icon: const Icon(Icons.rule),
                label: const Text('Check advert wording'),
              ),
            if (kind != PropertyKind.rent && p.price != null)
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        InvestPage(start: (kind: 'btl', inputs: {'price': p.price}), propertyId: p.id),
                  ),
                ),
                icon: const Icon(Icons.calculate_outlined),
                label: const Text('Appraise as a let'),
              ),
          ],
        ),
      ],
    );
  }

  /// Tick what was wrong at a viewing; the problems are added to the notes.
  Future<void> _checklist(BuildContext context, WidgetRef ref, Property p, PropertyKind kind) async {
    final items = viewingChecklist(kind);
    final found = <String>{};
    await showFormDialog(
      context,
      title: 'Viewing checklist',
      action: 'Add to notes',
      fields: (setState) => [
        const Text('Tick what you found wrong. Each line says what to look for.'),
        for (final i in items)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            value: found.contains(i.id),
            title: Text(i.label),
            subtitle: Text(i.ask),
            onChanged: (v) => setState(() => v! ? found.add(i.id) : found.remove(i.id)),
          ),
      ],
      onSave: () async {
        final note = viewingNote(today(), [
          for (final i in items)
            if (found.contains(i.id)) i,
        ]);
        await ref.mutate(
          (s) => s.book.save(
            s.db.properties,
            p.copyWith(notes: p.notes.isEmpty ? note : '${p.notes}\n$note'),
            p.id,
          ),
        );
        return null;
      },
    );
  }

  Future<void> _remove(BuildContext context, WidgetRef ref, Property p) async {
    if (!await confirm(
      context,
      title: 'Remove this property?',
      message: 'Its viewings, contact log, tenancies and checks go too.',
      action: 'Remove',
      destructive: true,
    )) {
      return;
    }
    if (!context.mounted) return;
    if (await guarded(context, () => ref.mutate((s) => s.book.removeProperty(p.id))) && context.mounted) {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _editNotes(BuildContext context, WidgetRef ref, Property p) {
    final notes = TextEditingController(text: p.notes);
    return showFormDialog(
      context,
      title: 'Notes',
      fields: (_) => [Field(notes, 'Notes', lines: 5, autofocus: true)],
      onSave: () async {
        await ref.mutate((s) => s.book.save(s.db.properties, p.copyWith(notes: notes.text.trim()), p.id));
        return null;
      },
    );
  }

  Future<void> _bookViewing(BuildContext context, WidgetRef ref, Property p) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 11, minute: 0));
    if (time == null || !context.mounted) return;
    final at =
        '${isoDate(date)}T${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    await guarded(context, () => ref.mutate((s) => s.book.bookViewing(p.id, at)));
  }
}

/// The agent or landlord, with buttons that call or message and log it.
class _ContactCard extends ConsumerWidget {
  const _ContactCard(this.p, this.contact);
  final Property p;
  final Contact? contact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = contact;
    final rental = PropertyKind.of(p.kind) == PropertyKind.rent;
    return SectionCard(
      title: c == null
          ? 'Agent or landlord'
          : c.organisation.isNotEmpty && c.organisation != c.name
          ? '${c.name}, ${c.organisation}'
          : c.name,
      trailing: TextButton(
        onPressed: () => _pick(context, ref),
        child: Text(c == null ? 'Choose' : 'Change'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (c == null)
            const Text('No contact yet.')
          else ...[
            if (c.phone.isNotEmpty) Text(c.phone, style: tabular),
            if (c.email.isNotEmpty) Text(c.email),
            const SizedBox(height: 8),
            ContactButtons(c, propertyId: p.id),
          ],
          if (rental) ...[
            const SizedBox(height: 8),
            Hint(
              'hunt.enquiry',
              child: FilledButton.tonalIcon(
                onPressed: () => _enquiry(context, ref, c),
                icon: const Icon(Icons.forward_to_inbox_outlined),
                label: const Text('Write an enquiry'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final contacts = ref.read(contactsProvider).value ?? const <Contact>[];
    final picked = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Agent or landlord'),
        children: [
          for (final c in contacts)
            SimpleDialogOption(onPressed: () => Navigator.pop(context, c.id), child: Text(c.name)),
          SimpleDialogOption(onPressed: () => Navigator.pop(context, ''), child: const Text('New contact…')),
        ],
      ),
    );
    if (picked == null || !context.mounted) return;
    final id = picked.isEmpty ? await editContact(context, ref) : picked;
    if (id != null) {
      await ref.mutate((s) => s.book.save(s.db.properties, p.copyWith(agentId: Value(id)), p.id));
    }
  }

  Future<void> _enquiry(BuildContext context, WidgetRef ref, Contact? c) async {
    final applicant = await ref.read(applicantProvider.future);
    if (!context.mounted) return;
    final greeting = c == null
        ? ''
        : (c.role == 'agent' && c.organisation.isNotEmpty ? c.organisation : c.name);
    final text = rentalEnquiry(applicant, address: p.address, agent: greeting);
    final subject = 'Enquiry: ${p.address}';
    Future<void> sent(String channel, Uri uri) async {
      if (await openUri(context, uri)) {
        await ref.mutate(
          (s) => s.book.log(
            propertyId: p.id,
            contactId: c?.id,
            channel: channel,
            summary: 'Sent the enquiry',
            at: nowLocal(),
          ),
        );
        if (context.mounted) Navigator.of(context).pop();
      }
    }

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enquiry'),
        scrollable: true,
        content: SizedBox(
          width: 520,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (applicant.name.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: StatusLabel(Status.info, 'Add your details in Settings to sign it.'),
                ),
              SelectableText(text),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => copyText(context, text, what: 'Enquiry copied.'),
            child: const Text('Copy'),
          ),
          if (c != null && c.email.isNotEmpty)
            TextButton(
              onPressed: () => sent('email', mailUri(c.email, subject: subject, body: text)),
              child: const Text('E-mail'),
            ),
          if (c != null && c.phone.isNotEmpty) ...[
            TextButton(
              onPressed: () => sent('sms', smsUri(c.phone, body: text)),
              child: const Text('Text'),
            ),
            TextButton(
              onPressed: () => sent('whatsapp', whatsAppUri(c.phone, text: text)),
              child: const Text('WhatsApp'),
            ),
          ],
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}

/// Logs a call, message, visit or note, with an optional follow-up date.
Future<void> logInteraction(BuildContext context, WidgetRef ref, {String? propertyId, String? contactId}) {
  final summary = TextEditingController();
  var channel = 'note', direction = 'in';
  String? followUp;
  return showFormDialog(
    context,
    title: 'Add to the log',
    fields: (setState) => [
      Choice(
        label: 'What',
        value: channel,
        options: channelLabels,
        onChanged: (v) => setState(() => channel = v),
      ),
      if (channel != 'note')
        Choice(
          label: 'Who started it',
          value: direction,
          options: const {'in': 'They did', 'out': 'I did'},
          onChanged: (v) => setState(() => direction = v),
        ),
      Field(summary, 'What was said', lines: 3, autofocus: true),
      CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Follow up'),
        value: followUp != null,
        onChanged: (v) => setState(() => followUp = v! ? addDays(today(), 2) : null),
      ),
      if (followUp != null)
        DateField(value: followUp!, label: 'Follow up on', onChanged: (d) => setState(() => followUp = d)),
    ],
    onSave: () async {
      await ref.mutate(
        (s) => s.book.log(
          propertyId: propertyId,
          contactId: contactId,
          channel: channel,
          direction: channel == 'note' ? 'out' : direction,
          summary: summary.text.trim(),
          followUp: followUp,
          at: nowLocal(),
        ),
      );
      return null;
    },
  );
}

/// An advert's photos, swiped through one at a time.
class PhotoGallery extends StatefulWidget {
  const PhotoGallery(this.photos, {super.key});
  final List<String> photos;

  @override
  State<PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  final pages = PageController();
  var shown = 0;

  @override
  void dispose() {
    pages.dispose();
    super.dispose();
  }

  void _go(int i) =>
      pages.animateToPage(i, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);

  @override
  Widget build(BuildContext context) {
    final n = widget.photos.length;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Semantics(
              label: 'Photo ${shown + 1} of $n',
              child: PageView.builder(
                controller: pages,
                itemCount: n,
                onPageChanged: (i) => setState(() => shown = i),
                itemBuilder: (_, i) => Image.network(
                  widget.photos[i],
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Center(child: Icon(Icons.broken_image_outlined)),
                ),
              ),
            ),
            if (n > 1) ...[
              Positioned(
                right: 8,
                bottom: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Text('${shown + 1} / $n', style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ),
              // Arrows for a mouse, where swiping is awkward.
              if (shown > 0)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton.filledTonal(
                    tooltip: 'Previous photo',
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => _go(shown - 1),
                  ),
                ),
              if (shown < n - 1)
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton.filledTonal(
                    tooltip: 'Next photo',
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => _go(shown + 1),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
