import 'dart:io';

import 'package:brahma_core/brahma_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../app/providers.dart';
import '../db/database.dart';
import '../domain/viewing_plan.dart';
import 'common.dart';
import 'property_page.dart';

/// Booked viewings from today, day by day in time order, with a warning
/// where two are too close to get between.
class ViewingPlanPage extends ConsumerWidget {
  const ViewingPlanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homes = ref.watch(propertiesProvider).value ?? const <Property>[];
    final views = ref.watch(viewingsProvider).value ?? const <Viewing>[];
    final days = planViewings(views, homes, today: today());
    final all = [for (final d in days) ...d.viewings];
    return PageScaffold(
      title: 'Viewings',
      actions: [
        if (all.isNotEmpty && canSaveIcs)
          IconButton(
            tooltip: 'Add them all to your calendar',
            icon: const Icon(Icons.edit_calendar_outlined),
            onPressed: () => saveIcs(context, all),
          ),
      ],
      children: [
        if (days.isEmpty)
          const EmptyState(
            icon: Icons.event_available_outlined,
            title: 'No viewings booked',
            message: 'Book a viewing on a home\'s page. Booked viewings show here day by day.',
          ),
        for (final d in days)
          SectionCard(
            title: niceDate(d.day),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final c in d.clashes)
                  Padding(padding: const EdgeInsets.only(bottom: 8), child: StatusLabel(Status.warning, c)),
                for (final b in d.viewings)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Text(b.viewing.at.substring(11, 16), style: tabular),
                    title: Text(b.home.address),
                    subtitle: b.viewing.notes.isEmpty ? null : Text(b.viewing.notes),
                    trailing: IconButton(
                      tooltip: 'Add to calendar',
                      icon: const Icon(Icons.event_outlined),
                      onPressed: () => addToCalendar(context, b),
                    ),
                    onTap: () =>
                        Navigator.of(context)
                            .push(MaterialPageRoute<void>(builder: (_) => PropertyPage(b.home.id))),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// A calendar file is saved where the user can open it: Downloads on a
/// computer. Phones use Google Calendar's page instead.
bool get canSaveIcs => !(Platform.isAndroid || Platform.isIOS);

/// Saves [items] as an .ics file in Downloads and opens it, so the
/// calendar app offers to add them.
Future<void> saveIcs(BuildContext context, List<BookedViewing> items) => guarded(context, () async {
  final dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
  final name = items.length == 1 ? 'viewing-${items.single.viewing.at.substring(0, 10)}' : 'viewings';
  final file = File('${dir.path}${Platform.pathSeparator}anveshana-$name.ics');
  await file.writeAsString(viewingsIcs(items, stamp: DateTime.now()));
  if (!context.mounted) return;
  showMessage(context, 'Saved ${file.path}. Open it to add to your calendar.');
  await openUri(context, Uri.file(file.path));
});

/// Offers the ways to put one viewing in a calendar.
Future<void> addToCalendar(BuildContext context, BookedViewing b) async {
  final how = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canSaveIcs)
            ListTile(
              leading: const Icon(Icons.file_download_outlined),
              title: const Text('Calendar file (.ics)'),
              subtitle: const Text('Saved in Downloads; opens in your calendar app'),
              onTap: () => Navigator.pop(sheet, 'ics'),
            ),
          ListTile(
            leading: const Icon(Icons.open_in_new),
            title: const Text('Google Calendar'),
            subtitle: const Text('Opens Google Calendar with the viewing filled in'),
            onTap: () => Navigator.pop(sheet, 'google'),
          ),
        ],
      ),
    ),
  );
  if (!context.mounted) return;
  switch (how) {
    case 'ics':
      await saveIcs(context, [b]);
    case 'google':
      await openUri(context, googleCalendarLink(b));
  }
}
