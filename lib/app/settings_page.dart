import 'package:brahma_core/brahma_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/book.dart';
import '../ui/common.dart';
import '../ui/search_page.dart';
import 'providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watch = ref.watch(watchProvider).value;
    return PageScaffold(
      title: 'Settings',
      children: [
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
                : 'Connected to ${Uri.parse(watch.url).host}. New listings are brought into the hunt when the app starts.',
          ),
        ),
        const SearchSitesCard(),
        const AppLockCard(),
        const HintsCard(),
        const SyncCard(),
        const SecurityCard(
          network:
              'Nothing leaves the device unless you search (the sites you search are read then, from this '
              'device), open a site in the app, sign in to sync, look up a postcode, add a link or use '
              'Brahma Watch.',
        ),
        const AboutCard(
          description: 'Property search, renting, buying, investment, development and lettings.',
        ),
      ],
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
