import 'dart:convert';
import 'dart:io' show Platform;

import 'package:brahma_core/brahma_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../app/providers.dart';
import '../domain/advert_page.dart';
import '../domain/portals.dart';
import 'common.dart';
import 'property_page.dart';

/// The in-app browser runs on Android only (webview_flutter has no Windows
/// or Linux build), so desktops keep opening the system browser.
bool get canBrowseInApp => !kIsWeb && Platform.isAndroid;

/// Opens a portal page: in the app's browser where it runs, so an advert can
/// be saved with its photos, otherwise in the system browser.
Future<void> openPortal(BuildContext context, Uri url) async {
  if (!canBrowseInApp) {
    await openUri(context, url);
    return;
  }
  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => AdvertBrowserPage(url)));
}

/// A portal's own site inside the app. The user browses it themselves; on an
/// advert, Save reads that one page into Homes (photos, price, beds,
/// address). Nothing is read until Save is tapped.
class AdvertBrowserPage extends ConsumerStatefulWidget {
  const AdvertBrowserPage(this.url, {super.key});
  final Uri url;

  @override
  ConsumerState<AdvertBrowserPage> createState() => _AdvertBrowserPageState();
}

class _AdvertBrowserPageState extends ConsumerState<AdvertBrowserPage> {
  late final WebViewController web;
  PortalAdvert? advert;
  var progress = 0;
  var saving = false;

  @override
  void initState() {
    super.initState();
    advert = parsePortalLink(widget.url.toString());
    web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          // Web pages only: no intent:, file: or app links from a portal page.
          onNavigationRequest: (r) {
            final scheme = Uri.tryParse(r.url)?.scheme;
            return scheme == 'https' || scheme == 'http'
                ? NavigationDecision.navigate
                : NavigationDecision.prevent;
          },
          onUrlChange: (c) {
            if (mounted && c.url != null) setState(() => advert = parsePortalLink(c.url!));
          },
          onProgress: (p) {
            if (mounted) setState(() => progress = p);
          },
        ),
      )
      ..loadRequest(widget.url);
  }

  Future<void> _save() async {
    final ad = advert;
    if (ad == null || saving) return;
    setState(() => saving = true);
    try {
      final raw = await web.runJavaScriptReturningResult('document.documentElement.outerHTML');
      // Android hands back the string JSON-encoded.
      final html = raw is String && raw.startsWith('"') ? jsonDecode(raw) as String : '$raw';
      final listing = listingFromAdvertPage(ad, html);
      final saved = await ref.mutate((s) => s.book.importListing(listing));
      if (!mounted) return;
      final photos = listing.images.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${saved.added ? 'Saved' : 'Updated'} ${listing.address}'
            '${photos == 0 ? '' : ' with $photos photo${photos == 1 ? '' : 's'}'}. Check the details.',
          ),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () =>
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => PropertyPage(saved.id))),
          ),
        ),
      );
    } on FormatException catch (e) {
      if (mounted) showMessage(context, e.message);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ad = advert;
    return PopScope(
      canPop: false,
      // Back goes back a page in the portal first.
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final nav = Navigator.of(context);
        if (await web.canGoBack()) {
          await web.goBack();
        } else {
          nav.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(ad?.portal.label ?? widget.url.host.replaceFirst('www.', '')),
          actions: [
            IconButton(
              tooltip: 'Open in your browser',
              icon: const Icon(Icons.open_in_new),
              onPressed: () async {
                final now = await web.currentUrl();
                if (context.mounted) await openUri(context, Uri.parse(now ?? '${widget.url}'));
              },
            ),
          ],
          bottom: progress < 100
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(2),
                  child: LinearProgressIndicator(value: progress / 100, minHeight: 2),
                )
              : null,
        ),
        body: WebViewWidget(controller: web),
        floatingActionButton: ad == null
            ? null
            : FloatingActionButton.extended(
                heroTag: null,
                onPressed: saving ? null : _save,
                icon: saving
                    ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.add_home_outlined),
                label: const Text('Save to Homes'),
              ),
      ),
    );
  }
}
