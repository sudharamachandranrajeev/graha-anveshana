import 'dart:io';

import 'package:brahma_core/brahma_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'common.dart';

/// Whether this build has an embedded web view. Linux has one (WPE WebKit)
/// when built with it; the portable release tarball is built without it
/// (packages/no_linux_webview) and opens pages in the system browser.
bool get hasWebView =>
    !kIsWeb &&
    (Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isWindows ||
        Platform.isMacOS ||
        (Platform.isLinux && InAppWebViewPlatform.instance != null));

/// Called with the open page's HTML and its advert cards (cardsScript);
/// returns what to tell the user.
typedef PageReader = Future<String> Function(String html, String cards);

/// Opens [url] inside the app, or in the system browser where this build
/// has no web view. [read] adds a button that reads the page into the app.
Future<void> openInApp(
  BuildContext context,
  Uri url, {
  String title = '',
  String readLabel = 'Add these homes to my results',
  PageReader? read,
  String? cardsScript,
}) async {
  if (!hasWebView || (url.scheme != 'https' && url.scheme != 'http')) {
    await openUri(context, url);
    return;
  }
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) =>
          BrowserPage(url: url, title: title, read: read, readLabel: readLabel, cardsScript: cardsScript),
    ),
  );
}

/// Signs out of every site opened in the app: its cookies and site data.
Future<void> signOutOfSites() async {
  if (!hasWebView) return;
  await CookieManager.instance().deleteAllCookies();
  await WebStorageManager.instance().deleteAllData();
}

/// A site's own page inside the app. The user signs in or passes a robot
/// check on the site's page themselves; the app keeps only the cookies, in
/// the web view's own store, as any browser does.
class BrowserPage extends StatefulWidget {
  const BrowserPage({
    super.key,
    required this.url,
    this.title = '',
    this.read,
    this.readLabel = 'Add these homes to my results',
    this.cardsScript,
  });
  final Uri url;
  final String title;
  final PageReader? read;
  final String readLabel;
  final String? cardsScript;

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  InAppWebViewController? _web;
  var _progress = 0.0;
  late var _title = widget.title.isEmpty ? widget.url.host : widget.title;
  Uri? _at;
  var _reading = false;

  Future<void> _read() async {
    final web = _web;
    final read = widget.read;
    if (web == null || read == null) return;
    setState(() => _reading = true);
    try {
      final html = '${await web.evaluateJavascript(source: 'document.documentElement.outerHTML') ?? ''}';
      final cards = widget.cardsScript == null
          ? '[]'
          : '${await web.evaluateJavascript(source: widget.cardsScript!) ?? '[]'}';
      final said = await read(html, cards);
      if (mounted) showMessage(context, said);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) async {
      if (didPop) return;
      // Back walks the site's own history first, as a browser does.
      if (await _web?.canGoBack() ?? false) {
        await _web!.goBack();
      } else if (context.mounted) {
        Navigator.of(context).pop();
      }
    },
    child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_title, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              (_at ?? widget.url).host,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(tooltip: 'Back', icon: const Icon(Icons.arrow_back), onPressed: () => _web?.goBack()),
          IconButton(
            tooltip: 'Forward',
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => _web?.goForward(),
          ),
          IconButton(tooltip: 'Reload', icon: const Icon(Icons.refresh), onPressed: () => _web?.reload()),
          PopupMenuButton<String>(
            tooltip: 'More',
            onSelected: (v) => switch (v) {
              'copy' => copyText(context, '${_at ?? widget.url}', what: 'Link copied.'),
              _ => openUri(context, _at ?? widget.url),
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'copy', child: Text('Copy link')),
              PopupMenuItem(value: 'out', child: Text('Open in your browser')),
            ],
          ),
        ],
        bottom: _progress < 1
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(value: _progress == 0 ? null : _progress, minHeight: 3),
              )
            : null,
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri.uri(widget.url)),
        initialSettings: InAppWebViewSettings(javaScriptEnabled: true, useShouldOverrideUrlLoading: true),
        onWebViewCreated: (c) => _web = c,
        onProgressChanged: (_, p) => setState(() => _progress = p / 100),
        onTitleChanged: (_, t) {
          if (t != null && t.isNotEmpty) setState(() => _title = t);
        },
        onUpdateVisitedHistory: (_, url, _) => setState(() => _at = url),
        shouldOverrideUrlLoading: (_, action) async {
          final url = action.request.url;
          // Phone numbers, e-mail and app links go to the device's own app.
          if (url != null && url.scheme != 'https' && url.scheme != 'http' && url.scheme != 'about') {
            if (mounted) await openUri(context, url);
            return NavigationActionPolicy.CANCEL;
          }
          return NavigationActionPolicy.ALLOW;
        },
      ),
      bottomNavigationBar: widget.read == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: FilledButton.icon(
                  onPressed: _reading ? null : _read,
                  icon: _reading
                      ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.playlist_add),
                  label: Text(widget.readLabel),
                ),
              ),
            ),
    ),
  );
}
