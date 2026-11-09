import 'package:brahma_core/brahma_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/book.dart';
import '../domain/contact_links.dart';
import '../domain/research.dart';
import '../domain/sources.dart';
import '../domain/trash.dart';
import '../ui/browser_page.dart';
import '../ui/common.dart';
import '../ui/listing_map.dart';
import '../ui/search_page.dart';
import 'providers.dart';
import 'search_memory.dart';

/// The user: their details for enquiries, their home point and places
/// (every home shows how far it is from each), their sign-ins to the sites
/// Search reads in the app, and the homes they threw out of Search.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicant = ref.watch(applicantProvider).value ?? const Applicant();
    final home = ref.watch(homeProvider).value;
    final places = ref.watch(profilePlacesProvider).value ?? const <NamedPoint>[];
    final trash = ref.watch(trashProvider).value ?? const <TrashedHome>[];
    return PageScaffold(
      title: 'Profile',
      children: [
        SectionCard(
          title: 'Your details',
          hint: 'settings.applicant',
          trailing: TextButton(
            onPressed: () => _editApplicant(context, ref, applicant),
            child: const Text('Edit'),
          ),
          child: Text(
            applicant.name.isEmpty
                ? 'Add your name, phone and household to sign enquiries.'
                : [
                    applicant.name,
                    applicant.phone,
                    applicant.household,
                  ].where((s) => s.isNotEmpty).join('\n'),
          ),
        ),
        SectionCard(
          title: 'Home point',
          hint: 'settings.home',
          trailing: TextButton(
            onPressed: () => _editHome(context, ref),
            child: Text(home == null ? 'Set' : 'Change'),
          ),
          child: Text(
            home == null
                ? 'Not set. Distances in Shortlist and search radii are measured from here.'
                : '${home.label.isEmpty ? 'Set' : home.label} (${home.lat.toStringAsFixed(4)}, ${home.lon.toStringAsFixed(4)})',
          ),
        ),
        SectionCard(
          title: 'Your places',
          hint: 'profile.places',
          trailing: TextButton(onPressed: () => askPlace(context, ref), child: const Text('Add')),
          child: places.isEmpty
              ? const Text(
                  'Add the places that matter: work, family, a school, the station. Every home in Search '
                  'and Shortlist shows how far it is from each.',
                )
              : Column(
                  children: [
                    for (final p in places)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.place_outlined),
                        title: Text(p.label),
                        subtitle: Text('${p.lat.toStringAsFixed(4)}, ${p.lon.toStringAsFixed(4)}'),
                        onTap: () => askPlace(context, ref, editing: p),
                        trailing: IconButton(
                          tooltip: 'Remove ${p.label}',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => removePlace(ref, p),
                        ),
                      ),
                  ],
                ),
        ),
        if (hasWebView)
          SectionCard(
            title: 'Site sign-ins',
            hint: 'profile.signins',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sign in to Zoopla or Facebook on their own pages inside the app, so Search reads them as '
                  'you. The app never sees your password. Signing in does not get past a site\'s robot '
                  'check: when one shows, pass it yourself in Open Zoopla (or Facebook) on Search.',
                ),
                for (final s in SourceId.values.where((s) => s.readInBrowser)) SiteConnectTile(s),
              ],
            ),
          ),
        SectionCard(
          title: 'Trash',
          hint: 'profile.trash',
          trailing: TextButton(
            onPressed: () =>
                Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const TrashPage())),
            child: const Text('Open'),
          ),
          child: Text(
            trash.isEmpty
                ? 'Homes you throw out of Search go here, and never show again unless you restore them.'
                : '${trash.length} ${trash.length == 1 ? 'home' : 'homes'} thrown out of Search.',
          ),
        ),
      ],
    );
  }

  Future<void> _editApplicant(BuildContext context, WidgetRef ref, Applicant a) {
    final name = TextEditingController(text: a.name);
    final phone = TextEditingController(text: a.phone);
    final email = TextEditingController(text: a.email);
    final household = TextEditingController(text: a.household);
    final work = TextEditingController(text: a.work);
    final moveIn = TextEditingController(text: a.moveIn);
    return showFormDialog(
      context,
      title: 'Your details',
      fields: (_) => [
        Field(name, 'Name'),
        Field(phone, 'Phone'),
        Field(email, 'E-mail'),
        Field(household, 'Household', lines: 2, hint: 'Two adults; no children, pets or smoking'),
        Field(
          work,
          'Work and references',
          lines: 2,
          hint: 'Job, employer; references and a guarantor available',
        ),
        Field(moveIn, 'Move in', hint: 'from January 2027', helper: 'Read as "Could a tenancy start …?"'),
      ],
      onSave: () async {
        await ref.mutate(
          (s) => s.book.setPref(
            PrefKeys.applicant,
            Applicant(
              name: name.text.trim(),
              phone: phone.text.trim(),
              email: email.text.trim(),
              household: household.text.trim(),
              work: work.text.trim(),
              moveIn: moveIn.text.trim(),
            ).toJson(),
          ),
        );
        return null;
      },
    );
  }

  /// The home point comes from a postcode, so no location permission is needed.
  Future<void> _editHome(BuildContext context, WidgetRef ref) {
    final postcode = TextEditingController();
    final label = TextEditingController(text: 'Home');
    return showFormDialog(
      context,
      title: 'Home point',
      fields: (_) => [
        Field(postcode, 'Postcode', autofocus: true),
        Field(label, 'Name', hint: 'Home, work…'),
        const Text('Only the postcode is sent, to postcodes.io, to find where it is.'),
      ],
      onSave: () async {
        if (postcode.text.trim().isEmpty) return 'Enter a postcode.';
        final place = await Research().place(postcode.text.trim());
        await ref.mutate((s) => s.book.setHome((lat: place.lat, lon: place.lon, label: label.text.trim())));
        return null;
      },
    );
  }
}

/// The homes thrown out of Search, newest first; restore any of them.
class TrashPage extends ConsumerWidget {
  const TrashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trash = ref.watch(trashProvider).value ?? const <TrashedHome>[];
    final t = Theme.of(context).textTheme;
    return PageScaffold(
      title: 'Trash',
      actions: [
        if (trash.isNotEmpty)
          TextButton(
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Empty the Trash?'),
                  content: Text('All ${trash.length} homes may show in Search again. This cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Empty')),
                  ],
                ),
              );
              if (ok ?? false) await emptyTrash(ref);
            },
            child: const Text('Empty'),
          ),
      ],
      children: [
        if (trash.isEmpty)
          const EmptyState(
            icon: Icons.delete_outline,
            title: 'The Trash is empty',
            message: 'Throw a home out of Search (the bin on its card) and it never shows again.',
          )
        else
          for (final h in trash)
            Card(
              child: ListTile(
                leading: const Icon(Icons.home_outlined),
                title: Text(h.address, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  [
                    if (h.price != null) gbp(h.price!),
                    if (h.beds != null) h.beds == 0 ? 'Studio' : '${h.beds} bed',
                    SourceId.ofKey(h.source)?.label ?? h.source,
                    'thrown out ${niceDate(h.at)}',
                  ].where((s) => s.isNotEmpty).join(' · '),
                  style: t.bodySmall,
                ),
                trailing: TextButton.icon(
                  onPressed: () async {
                    await restoreHome(ref, h);
                    if (context.mounted) showMessage(context, 'Restored: it shows in Search again.');
                  },
                  icon: const Icon(Icons.restore_from_trash_outlined),
                  label: const Text('Restore'),
                ),
              ),
            ),
      ],
    );
  }
}
