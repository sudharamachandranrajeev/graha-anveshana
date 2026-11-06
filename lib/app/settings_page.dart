import 'package:brahma_core/brahma_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/book.dart';
import '../domain/contact_links.dart';
import '../domain/research.dart';
import '../ui/common.dart';
import 'providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicant = ref.watch(applicantProvider).value ?? const Applicant();
    final home = ref.watch(homeProvider).value;
    final watch = ref.watch(watchProvider).value;
    return PageScaffold(
      title: 'Settings',
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
                ? 'Not set. Distances and search radii are measured from here.'
                : '${home.label.isEmpty ? 'Set' : home.label} (${home.lat.toStringAsFixed(4)}, ${home.lon.toStringAsFixed(4)})',
          ),
        ),
        SectionCard(
          title: 'Brahma Watch',
          hint: 'settings.watch',
          trailing: TextButton(
            onPressed: () => _editWatch(context, ref),
            child: Text(watch == null ? 'Set up' : 'Change'),
          ),
          child: Text(
            watch == null
                ? 'Not set up. Brahma Watch runs your searches on your own free Cloudflare account and alerts '
                      'your phone through ntfy. On a computer with Git and Node.js 24+:\n'
                      '1. git clone https://github.com/sudharamachandranrajeev/brahma.git, then cd brahma/watch '
                      'and npm install.\n'
                      '2. npx wrangler login (once; it opens the browser to allow your Cloudflare account).\n'
                      '3. npm run setup. It prints the Watch address, its token and an ntfy topic with a QR code.\n'
                      '4. On your phone install ntfy and subscribe to that topic (scan the code).\n'
                      '5. Here choose Set up and paste the address and token (also kept in '
                      '~/.config/brahma/watch.env on that computer).'
                : 'Connected to ${Uri.parse(watch.url).host}. New listings are brought into Homes when the app starts.',
          ),
        ),
        const AppLockCard(),
        const HintsCard(),
        const SyncCard(),
        const SecurityCard(
          network:
              'Nothing leaves the device unless you sign in to sync, look up a postcode, add a PropertyPal link '
              'or use Brahma Watch.',
        ),
        const AboutCard(
          description: 'Property search, renting, buying, investment, development and lettings.',
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

  Future<void> _editWatch(BuildContext context, WidgetRef ref) async {
    final book = ref.read(sessionProvider).book;
    final url = TextEditingController(text: await book.pref<String>(PrefKeys.watchUrl, ''));
    final token = TextEditingController(text: await book.pref<String>(PrefKeys.watchToken, ''));
    if (!context.mounted) return;
    await showFormDialog(
      context,
      title: 'Brahma Watch',
      fields: (_) => [
        Field(url, 'Address', hint: 'https://brahma-watch.<you>.workers.dev'),
        Field(
          token,
          'Token',
          helper: 'API_TOKEN in ~/.config/brahma/watch.env after setup. Synced end-to-end encrypted.',
        ),
      ],
      onSave: () async {
        final u = Uri.tryParse(url.text.trim());
        if (url.text.trim().isNotEmpty && (u == null || u.scheme != 'https' || u.host.isEmpty)) {
          return 'The address starts with https://';
        }
        await ref.mutate((s) async {
          await s.book.setPref(PrefKeys.watchUrl, url.text.trim());
          await s.book.setPref(PrefKeys.watchToken, token.text.trim());
        });
        return null;
      },
    );
  }
}
