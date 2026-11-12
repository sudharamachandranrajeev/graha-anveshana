import 'dart:async';
import 'dart:io';

import 'package:brahma_core/brahma_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/page_reader.dart';
import '../domain/sources.dart';
import 'common.dart';

/// Whether this build has an embedded web view. Linux has one (WPE WebKit)
/// when built with it; the portable release tarball is built without it
/// (packages/no_linux_webview) and cannot show sites at all.
bool get hasWebView =>
    !kIsWeb &&
    (Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isWindows ||
        Platform.isMacOS ||
        (Platform.isLinux && InAppWebViewPlatform.instance != null));

/// Called with the open page's HTML and its advert cards (cardsScript);
/// returns what to tell the user.
/// [at] is the address the page is at now.
typedef PageReader = Future<String> Function(String html, String cards, Uri at);

/// Opens [url] inside the app. Sites are never handed to the system
/// browser: a build with no web view says how to get one instead. [read]
/// adds a button that reads the page into the app; with [autoRead] it also
/// runs by itself each time a page finishes loading.
Future<void> openInApp(
  BuildContext context,
  Uri url, {
  String title = '',
  String readLabel = 'Add these homes to my results',
  PageReader? read,
  String? cardsScript,
  bool autoRead = false,
}) async {
  if (url.scheme != 'https' && url.scheme != 'http') {
    await openUri(context, url);
    return;
  }
  if (!hasWebView) {
    await showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('No in-app browser in this build'),
        content: Text(
          'This copy of Graha Anveshana was built without the in-app browser, so it cannot open '
          '${url.host} or read Zoopla and Facebook. Install WPE WebKit (Arch: pacman -S wpewebkit) and the Linux release with the in-app browser.',
        ),
        actions: [
          TextButton(
            onPressed: () => copyText(c, '$url', what: 'Link copied.'),
            child: const Text('Copy link'),
          ),
          FilledButton(onPressed: () => Navigator.of(c).pop(), child: const Text('OK')),
        ],
      ),
    );
    return;
  }
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BrowserPage(
        url: url,
        title: title,
        read: read,
        readLabel: readLabel,
        cardsScript: cardsScript,
        autoRead: autoRead,
      ),
    ),
  );
}

/// Loads a page in a hidden web view, as Search does for the sites that
/// turn plain HTTP apps away. Null where this build has no web view.
/// The hidden view shares the in-app browser's cookies, so a robot check
/// or sign-in the user passed there counts here too.
Future<({String html, String cards})> Function(Uri url)? hiddenPageLoader() =>
    hasWebView && InAppWebViewPlatform.instance != null && HeadlessInAppWebView.isClassSupported()
    ? loadHidden
    : null;

/// [url]'s HTML and advert cards ([cardsScript]), once its list is drawn.
/// Sites draw their lists with script after the page loads, so this waits
/// until the cards stop changing, for up to [settle].
Future<({String html, String cards})> loadHidden(
  Uri url, {
  Duration timeout = const Duration(seconds: 30),
  Duration settle = const Duration(seconds: 10),
  int scrolls = 4,
}) async {
  final loaded = Completer<void>();
  final view = HeadlessInAppWebView(
    initialUrlRequest: URLRequest(url: WebUri.uri(url)),
    initialSettings: InAppWebViewSettings(javaScriptEnabled: true),
    initialSize: const Size(1280, 2400),
    onLoadStop: (_, _) {
      if (!loaded.isCompleted) loaded.complete();
    },
    onReceivedError: (_, request, error) {
      if ((request.isForMainFrame ?? true) && !loaded.isCompleted) {
        loaded.completeError(Exception(error.description));
      }
    },
  );
  try {
    await view.run();
    await loaded.future.timeout(timeout);
    final web = view.webViewController!;
    var cards = '[]';
    var last = -1;
    final until = DateTime.now().add(settle);
    while (DateTime.now().isBefore(until)) {
      cards = '${await web.evaluateJavascript(source: cardsScript) ?? '[]'}';
      final n = '"id":'.allMatches(cards).length;
      if (n > 0 && n == last) break;
      last = n;
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    // Sites with no next page add results as the list is scrolled: scroll
    // to the end a few times, while it still brings more.
    if (SourceId.ofUrl(url)?.scrollsForMore ?? false) {
      for (var i = 0; i < scrolls; i++) {
        await web.evaluateJavascript(source: 'window.scrollTo(0, document.body.scrollHeight)');
        final before = '"id":'.allMatches(cards).length;
        var after = before;
        for (var wait = 0; wait < 4 && after == before; wait++) {
          await Future<void>.delayed(const Duration(seconds: 1));
          cards = '${await web.evaluateJavascript(source: cardsScript) ?? '[]'}';
          after = '"id":'.allMatches(cards).length;
        }
        if (after == before) break;
      }
    }
    final html = '${await web.evaluateJavascript(source: 'document.documentElement.outerHTML') ?? ''}';
    return (html: html, cards: cards);
  } finally {
    await view.dispose();
  }
}

/// Whether the in-app browser holds a signed-in session for [s]: the
/// sign-in cookie is there. Null when the site has no known cookie or this
/// build has no web view.
Future<bool?> isSignedIn(SourceId s) async {
  final cookie = signInFor(s).cookie;
  if (!hasWebView || cookie == null) return null;
  final cookies = await CookieManager.instance().getCookies(url: WebUri('https://www.${s.host}/'));
  return cookies.any((c) => c.name == cookie);
}

/// Signs out of one site: its cookies in the in-app (and hidden) browser.
Future<void> signOutOf(SourceId s) async {
  if (!hasWebView) return;
  final url = WebUri('https://www.${s.host}/');
  await CookieManager.instance().deleteCookies(url: url, domain: '.${s.host}');
  await CookieManager.instance().deleteCookies(url: url);
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
    this.autoRead = false,
  });
  final bool autoRead;
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

  /// Reads the page into the app. [auto]: a page just loaded; a page with no
  /// adverts (a robot check, a sign-in) is passed over quietly.
  Future<void> _read({bool auto = false}) async {
    final web = _web;
    final read = widget.read;
    if (web == null || read == null) return;
    setState(() => _reading = true);
    try {
      final cards = widget.cardsScript == null
          ? '[]'
          : '${await web.evaluateJavascript(source: widget.cardsScript!) ?? '[]'}';
      if (auto && !cards.contains('"id":')) return;
      final html = '${await web.evaluateJavascript(source: 'document.documentElement.outerHTML') ?? ''}';
      final said = await read(html, cards, _at ?? widget.url);
      if (mounted) showMessage(context, said);
    } catch (e) {
      if (mounted && !auto) showError(context, e);
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  /// Saves the open page's HTML and the adverts the app found on it, in
  /// Downloads (else the app's documents folder), for the user to send in
  /// when a site's page is not read right. Cookies are not saved.
  Future<void> _save() async {
    final web = _web;
    if (web == null) return;
    try {
      final html = '${await web.evaluateJavascript(source: 'document.documentElement.outerHTML') ?? ''}';
      final cards = widget.cardsScript == null
          ? '[]'
          : '${await web.evaluateJavascript(source: widget.cardsScript!) ?? '[]'}';
      final dir =
          (Platform.isAndroid || Platform.isIOS ? null : await getDownloadsDirectory()) ??
          await getApplicationDocumentsDirectory();
      final stamp = DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-').substring(0, 19);
      final name = 'anveshana-${(_at ?? widget.url).host.replaceAll('www.', '')}-$stamp';
      final sep = Platform.pathSeparator;
      await File('${dir.path}$sep$name.html').writeAsString('<!-- ${_at ?? widget.url} -->\n$html');
      await File('${dir.path}$sep$name-adverts.json').writeAsString(cards);
      if (mounted) showMessage(context, 'Saved $name.html and $name-adverts.json in ${dir.path}.');
    } catch (e) {
      if (mounted) showError(context, e);
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
              _ => _save(),
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'copy', child: Text('Copy link')),
              if (widget.cardsScript != null)
                const PopupMenuItem(value: 'save', child: Text('Save this page (to fix reading it)')),
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
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          useShouldOverrideUrlLoading: true,
          supportMultipleWindows: true,
          javaScriptCanOpenWindowsAutomatically: true,
        ),
        onWebViewCreated: (c) => _web = c,
        onProgressChanged: (_, p) => setState(() => _progress = p / 100),
        onTitleChanged: (_, t) {
          if (t != null && t.isNotEmpty) setState(() => _title = t);
        },
        onUpdateVisitedHistory: (_, url, _) => setState(() => _at = url),
        onLoadStop: (_, _) async {
          if (!widget.autoRead || widget.read == null) return;
          // Results lists are drawn by script after the page loads.
          await Future<void>.delayed(const Duration(seconds: 2));
          if (mounted && !_reading) await _read(auto: true);
        },
        // Links and sign-in steps that ask for a new window open here, in
        // the same view, so nothing leaves the app.
        onCreateWindow: (c, action) async {
          final url = action.request.url;
          if (url != null) await c.loadUrl(urlRequest: URLRequest(url: url));
          return false;
        },
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
