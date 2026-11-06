import 'package:brahma_core/brahma_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../domain/listing.dart';
import '../domain/portals.dart';
import 'advert_browser.dart';

/// Share to Anveshana (Android): a link shared from a portal's app or a
/// browser. A portal page opens in the app's browser, ready to save; a
/// PropertyPal advert is read straight in. MainActivity hands the text over.
class ShareInbox extends ConsumerStatefulWidget {
  const ShareInbox({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<ShareInbox> createState() => _ShareInboxState();
}

const _channel = MethodChannel('dev.brahma.anveshana/share');

class _ShareInboxState extends ConsumerState<ShareInbox> {
  @override
  void initState() {
    super.initState();
    if (!canBrowseInApp) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'shared' && call.arguments is String) await _open(call.arguments as String);
    });
    _channel.invokeMethod<String>('takeShared').then((text) {
      if (text != null) _open(text);
    }, onError: (_) {});
  }

  Future<void> _open(String text) async {
    if (!mounted) return;
    final url = sharedLink(text);
    if (url == null) {
      showMessage(context, 'Share an advert link to add it to Homes.');
    } else if (portalOf(url) != null) {
      await openPortal(context, url);
    } else if (RegExp(r'(^|\.)propertypal\.com$').hasMatch(url.host)) {
      await guarded(context, () async {
        final listings = await fetchPropertyPal('$url');
        await ref.mutate((s) async {
          for (final l in listings) {
            await s.book.importListing(l);
          }
        });
        if (mounted) showMessage(context, 'Added ${listings.length} from PropertyPal.');
      });
    } else {
      showMessage(context, 'Anveshana reads adverts from PropertyPal and the big portals, not ${url.host}.');
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// The first https link in shared text such as "Look at this home on
/// Rightmove! https://www.rightmove.co.uk/properties/123".
Uri? sharedLink(String text) {
  final m = RegExp(r'https://[^\s<>"]+').firstMatch(text);
  return m == null ? null : Uri.tryParse(m.group(0)!);
}

/// The portal [url] is on, or null.
Portal? portalOf(Uri url) {
  for (final p in Portal.values) {
    if (url.host == p.host || url.host.endsWith('.${p.host}')) return p;
  }
  return null;
}
