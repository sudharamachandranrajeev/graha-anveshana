import 'package:brahma_core/brahma_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../db/database.dart';
import '../domain/pipeline.dart';
import '../domain/travel.dart';
import 'browser_page.dart';

final _gbp = NumberFormat.currency(locale: 'en_GB', symbol: '£', decimalDigits: 0);

/// Whole pounds, e.g. £1,250.
String gbp(num v) => v.isFinite ? _gbp.format(v.round()) : '–';

/// A property's rent ("£650 pcm") or asking price.
String priceLabel(Property p) => switch (p.price) {
  null => 'Price not shown',
  final v => PropertyKind.of(p.kind) == PropertyKind.rent ? '${gbp(v)} pcm' : gbp(v),
};

/// "2 bed · Apartment · Furnished".
String propertyFacts(Property p) => [
  if (p.beds != null) p.beds == 0 ? 'Studio' : '${p.beds} bed',
  if (p.style.isNotEmpty) p.style,
  if (p.furnished.isNotEmpty) p.furnished,
].join(' · ');

String km(double v) => v < 10 ? '${v.toStringAsFixed(1)} km' : '${v.round()} km';

/// [km] kilometres as "1.2 mi".
String miles(double km) {
  final mi = km / 1.609344;
  return mi < 10 ? '${mi.toStringAsFixed(1)} mi' : '${mi.round()} mi';
}

/// "2026-10-24T11:00" as "24 Oct 2026, 11:00".
String niceDateTime(String at) =>
    at.length > 10 ? '${niceDate(at.substring(0, 10))}, ${at.substring(11, 16)}' : niceDate(at);

/// Now as local yyyy-MM-ddTHH:mm.
/// When a home is free: a date ("3 Jan 2027") or the advert's own words
/// ("now", "1st March"), which some sites give instead of a date.
String availableLabel(String from) {
  final d = RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(from) ? DateTime.tryParse(from.substring(0, 10)) : null;
  return d == null ? from : niceDate(from.substring(0, 10));
}

String nowLocal() => DateTime.now().toIso8601String().substring(0, 16);

/// Opens [uri]: web pages in the app's own browser ([openInApp]), never the
/// system one; phone numbers, e-mail, files and calendar entries in the
/// device's app for them.
Future<bool> openUri(BuildContext context, Uri uri) async {
  if (uri.scheme == 'https' || uri.scheme == 'http') {
    await openInApp(context, uri);
    return hasWebView;
  }
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication).catchError((_) => false);
  if (!ok && context.mounted) showMessage(context, 'Nothing on this device can open $uri.');
  return ok;
}

Future<void> copyText(BuildContext context, String text, {String what = 'Copied.'}) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) showMessage(context, what);
}

/// A plain text field with a label.
class Field extends StatelessWidget {
  const Field(
    this.controller,
    this.label, {
    super.key,
    this.number = false,
    this.lines = 1,
    this.hint,
    this.helper,
    this.prefix,
    this.suffix,
    this.autofocus = false,
  });
  final TextEditingController controller;
  final String label;
  final bool number;
  final int lines;
  final String? hint, helper, prefix, suffix;
  final bool autofocus;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      autofocus: autofocus,
      minLines: lines,
      maxLines: lines == 1 ? 1 : lines + 4,
      keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helper,
        helperMaxLines: 3,
        prefixText: prefix,
        suffixText: suffix,
      ),
    ),
  );
}

/// The number in a field, or null when empty or not a number.
num? numberIn(TextEditingController c) => num.tryParse(c.text.replaceAll(RegExp(r'[£,%\s]'), ''));
int? intIn(TextEditingController c) => numberIn(c)?.round();

/// A form in a dialog with Cancel and a save button; returns whether saved.
/// [onSave] returns an error message to show, or null when done.
Future<bool> showFormDialog(
  BuildContext context, {
  required String title,
  required List<Widget> Function(StateSetter setState) fields,
  required Future<String?> Function() onSave,
  String action = 'Save',
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) {
      String? error;
      var busy = false;
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(title),
          scrollable: true,
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...fields(setState),
                if (error != null) Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(
              onPressed: busy
                  ? null
                  : () async {
                      setState(() => busy = true);
                      String? e;
                      try {
                        e = await onSave();
                      } catch (x) {
                        e = describeError(x);
                      }
                      if (!context.mounted) return;
                      if (e == null) {
                        Navigator.pop(context, true);
                      } else {
                        setState(() {
                          error = e;
                          busy = false;
                        });
                      }
                    },
              child: Text(action),
            ),
          ],
        ),
      );
    },
  );
  return ok ?? false;
}

/// A labelled dropdown for small fixed choices.
class Choice<T> extends StatelessWidget {
  const Choice({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });
  final String label;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      isExpanded: true,
      items: [for (final e in options.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    ),
  );
}

/// Label on the left, figure on the right.
class FigureRow extends StatelessWidget {
  const FigureRow(this.label, this.value, {super.key, this.strong = false, this.status});
  final String label, value;
  final bool strong;
  final Status? status;

  @override
  Widget build(BuildContext context) {
    final style = strong ? const TextStyle(fontWeight: FontWeight.w600) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          if (status != null) ...[
            Icon(status!.icon, size: 18, color: status!.color),
            const SizedBox(width: 6),
          ],
          Text(value, style: (style ?? const TextStyle()).merge(tabular)),
        ],
      ),
    );
  }
}

enum Unit { pounds, percent, number }

/// A number field that keeps its own text while typing.
class NumberInput extends StatefulWidget {
  const NumberInput({
    super.key,
    required this.value,
    required this.label,
    required this.unit,
    required this.onChanged,
    this.helper,
  });
  final double value;
  final String label;
  final Unit unit;
  final String? helper;
  final ValueChanged<double> onChanged;

  @override
  State<NumberInput> createState() => _NumberInputState();
}

class _NumberInputState extends State<NumberInput> {
  late final c = TextEditingController(text: _show(widget.value));

  String _show(double v) {
    final x = widget.unit == Unit.percent ? v * 100 : v;
    return x == x.roundToDouble() ? x.round().toString() : double.parse(x.toStringAsFixed(4)).toString();
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: widget.label,
        helperText: widget.helper,
        prefixText: widget.unit == Unit.pounds ? '£' : null,
        suffixText: widget.unit == Unit.percent ? '%' : null,
      ),
      onChanged: (_) {
        final v = numberIn(c)?.toDouble();
        if (v != null) widget.onChanged(widget.unit == Unit.percent ? v / 100 : v);
      },
    ),
  );
}

IconData travelIcon(TravelMode m) => switch (m) {
  TravelMode.car => Icons.directions_car_outlined,
  TravelMode.bike => Icons.directions_bike_outlined,
  TravelMode.foot => Icons.directions_walk_outlined,
};
