import 'dart:math' as math;

import 'package:brahma_core/brahma_core.dart';
import 'package:flutter/material.dart';

// The Anveshana look, shared by Graha and Vahana Anveshana (keep the two
// copies in step): an instrument panel. A charcoal canvas crossed by faint
// contour lines; hairline cards; one lime accent that marks the best or the
// chosen; big tabular figures with small spaced capitals above them.

const lime = Color(0xFFC8E64A);
const ink = Color(0xFF141517);

/// Inter, bundled. Standalone the app names it plainly; inside the Brahma
/// suite a package's fonts live under `packages/<name>/`, hence the fallback.
const _font = 'Inter';
const _fontInSuite = ['packages/anveshana/Inter'];

/// The colours the widgets below draw with, beyond the colour scheme.
class Tones {
  const Tones._({
    required this.top,
    required this.bottom,
    required this.line,
    required this.hairline,
    required this.muted,
    required this.track,
  });

  static const _dark = Tones._(
    top: Color(0xFF1B1C1F),
    bottom: Color(0xFF0E0F10),
    line: Color(0x12FFFFFF),
    hairline: Color(0x14FFFFFF),
    muted: Color(0xFF8E8F94),
    track: Color(0xFF3A3B3F),
  );
  static const _light = Tones._(
    top: Color(0xFFF1F1EC),
    bottom: Color(0xFFE6E6E0),
    line: Color(0x14000000),
    hairline: Color(0xFFDCDCD5),
    muted: Color(0xFF6B6C70),
    track: Color(0xFFD9D9D2),
  );

  static Tones of(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? _dark : _light;

  /// The canvas, top to bottom, and the contour lines drawn on it.
  final Color top, bottom, line;

  /// Card edges, secondary text and empty bar tracks.
  final Color hairline, muted, track;
}

ThemeData instrumentTheme(Brightness b) {
  final dark = b == Brightness.dark;
  final tones = dark ? Tones._dark : Tones._light;
  final base = buildTheme(b, seed: lime, accent: lime);
  final card = dark ? const Color(0xFF1F2023) : Colors.white;
  final raised = dark ? const Color(0xFF2A2B2F) : const Color(0xFFF3F3EF);
  final text = dark ? const Color(0xFFF2F2EF) : ink;
  final scheme = base.colorScheme.copyWith(
    // Lime reads on charcoal; on paper the actions turn ink and lime stays
    // a highlight.
    primary: dark ? lime : ink,
    onPrimary: dark ? ink : Colors.white,
    primaryContainer: dark ? const Color(0xFF3A4214) : const Color(0xFFE9F4C2),
    onPrimaryContainer: dark ? lime : ink,
    secondaryContainer: raised,
    onSecondaryContainer: text,
    tertiary: lime,
    onTertiary: ink,
    surface: dark ? const Color(0xFF17181A) : const Color(0xFFF7F7F3),
    onSurface: text,
    onSurfaceVariant: tones.muted,
    surfaceContainerLowest: card,
    surfaceContainerLow: card,
    surfaceContainer: card,
    surfaceContainerHigh: raised,
    surfaceContainerHighest: raised,
    outline: tones.muted,
    outlineVariant: tones.hairline,
  );
  final type = base.textTheme.apply(
    fontFamily: _font,
    fontFamilyFallback: _fontInSuite,
    bodyColor: text,
    displayColor: text,
  );
  TextStyle? tight(TextStyle? s, FontWeight w, double spacing) =>
      s?.copyWith(fontWeight: w, letterSpacing: spacing);
  final t = type.copyWith(
    displayLarge: tight(type.displayLarge, FontWeight.w800, -2.4),
    displayMedium: tight(type.displayMedium, FontWeight.w800, -2),
    displaySmall: tight(type.displaySmall, FontWeight.w800, -1.4),
    headlineLarge: tight(type.headlineLarge, FontWeight.w800, -1),
    headlineMedium: tight(type.headlineMedium, FontWeight.w800, -0.8),
    headlineSmall: tight(type.headlineSmall, FontWeight.w700, -0.6),
    titleLarge: tight(type.titleLarge, FontWeight.w700, -0.4),
    titleMedium: tight(type.titleMedium, FontWeight.w600, -0.1),
    titleSmall: tight(type.titleSmall, FontWeight.w600, 0),
    bodyLarge: type.bodyLarge?.copyWith(height: 1.45, letterSpacing: 0),
    bodyMedium: type.bodyMedium?.copyWith(height: 1.4, letterSpacing: 0),
    bodySmall: type.bodySmall?.copyWith(color: tones.muted, letterSpacing: 0),
    labelLarge: type.labelLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0),
  );
  final radius = BorderRadius.circular(18);
  final edge = BorderSide(color: tones.hairline);
  const stadium = StadiumBorder();
  final field = OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: edge);
  return base.copyWith(
    colorScheme: scheme,
    textTheme: t,
    primaryTextTheme: base.primaryTextTheme.apply(fontFamily: _font, fontFamilyFallback: _fontInSuite),
    // The canvas (see Backdrop) shows through every page.
    scaffoldBackgroundColor: Colors.transparent,
    canvasColor: scheme.surface,
    dividerTheme: DividerThemeData(color: tones.hairline, space: 24),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: text,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 68,
      titleSpacing: 20,
      titleTextStyle: t.headlineSmall?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.9,
      ),
    ),
    cardTheme: CardThemeData(
      color: card,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: radius, side: edge),
    ),
    listTileTheme: base.listTileTheme.copyWith(
      iconColor: tones.muted,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      subtitleTextStyle: t.bodySmall,
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: stadium,
      side: edge,
      backgroundColor: Colors.transparent,
      selectedColor: lime,
      secondarySelectedColor: lime,
      checkmarkColor: ink,
      labelStyle: t.labelMedium?.copyWith(
        fontWeight: FontWeight.w500,
        color: WidgetStateColor.resolveWith((s) => s.contains(WidgetState.selected) ? ink : text),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        shape: const WidgetStatePropertyAll(stadium),
        side: WidgetStatePropertyAll(edge),
        backgroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? lime : card,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? ink : text,
        ),
        iconColor: const WidgetStatePropertyAll(ink),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: stadium,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: t.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(shape: stadium, side: edge, foregroundColor: text),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(shape: stadium, foregroundColor: dark ? lime : ink),
    ),
    iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(foregroundColor: tones.muted)),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: lime,
      foregroundColor: ink,
      shape: stadium,
      elevation: 2,
      highlightElevation: 4,
      extendedTextStyle: t.labelLarge?.copyWith(fontSize: 15, color: ink),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      filled: true,
      fillColor: dark ? const Color(0xFF191A1C) : Colors.white,
      border: field,
      enabledBorder: field,
      focusedBorder: field.copyWith(borderSide: BorderSide(color: dark ? lime : ink, width: 1.4)),
      labelStyle: TextStyle(color: tones.muted),
      helperStyle: t.bodySmall,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: dark ? const Color(0xFF232427) : ink,
      surfaceTintColor: Colors.transparent,
      indicatorColor: lime,
      indicatorShape: stadium,
      elevation: 0,
      height: 64,
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(color: s.contains(WidgetState.selected) ? ink : Colors.white60),
      ),
      labelTextStyle: WidgetStatePropertyAll(
        t.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 1.2),
      ),
    ),
    // The rail echoes the reference's side dial: a lime dot for the screen
    // you are on, quiet spaced capitals for the rest.
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: Colors.transparent,
      indicatorColor: lime,
      indicatorShape: const CircleBorder(),
      selectedIconTheme: const IconThemeData(color: ink, size: 20),
      unselectedIconTheme: IconThemeData(color: tones.muted, size: 20),
      selectedLabelTextStyle: t.labelSmall?.copyWith(
        color: text,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
      unselectedLabelTextStyle: t.labelSmall?.copyWith(color: tones.muted, letterSpacing: 1.2),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: edge),
      titleTextStyle: t.headlineSmall,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: dark ? const Color(0xFF26272A) : Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: edge),
    ),
    snackBarTheme: base.snackBarTheme.copyWith(
      backgroundColor: dark ? const Color(0xFF2A2B2F) : ink,
      contentTextStyle: t.bodyMedium?.copyWith(color: Colors.white),
      actionTextColor: lime,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: dark ? lime : ink,
      linearTrackColor: tones.track,
    ),
    expansionTileTheme: ExpansionTileThemeData(
      shape: const Border(),
      collapsedShape: const Border(),
      iconColor: tones.muted,
      collapsedIconColor: tones.muted,
    ),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {for (final p in TargetPlatform.values) p: const _OnCanvas()},
    ),
  );
}

/// Pushed pages fade forwards like everywhere else in Brahma, each on its own
/// canvas so the page beneath never shows through the transparent scaffold.
class _OnCanvas extends PageTransitionsBuilder {
  const _OnCanvas();
  static const _inner = FadeForwardsPageTransitionsBuilder();

  @override
  Duration get transitionDuration => _inner.transitionDuration;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => _inner.buildTransitions(route, context, animation, secondaryAnimation, Backdrop(child: child));
}

/// The canvas behind every page: a dark wash crossed by faint contour lines.
class Backdrop extends StatelessWidget {
  const Backdrop({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tones = Tones.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [tones.top, tones.bottom],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(child: CustomPaint(painter: _Contours(tones.line))),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

/// Long, gently drifting lines like isobars on a chart.
class _Contours extends CustomPainter {
  const _Contours(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const lines = 9;
    for (var i = 0; i < lines; i++) {
      // Fixed per line, so the canvas never changes between frames.
      final a1 = 18.0 + 11 * ((i * 7) % 5);
      final a2 = 8.0 + 6 * ((i * 3) % 4);
      final f1 = 0.6 + 0.15 * (i % 3);
      final f2 = 1.7 + 0.2 * (i % 4);
      final p1 = i * 1.3, p2 = i * 2.1;
      final y0 = size.height * (i + 0.5) / lines;
      final path = Path();
      for (var x = -40.0; x <= size.width + 40; x += 8) {
        final u = x / math.max(size.width, 1);
        final y =
            y0 +
            a1 * math.sin(u * 2 * math.pi * f1 + p1) +
            a2 * math.sin(u * 2 * math.pi * f2 + p2) -
            (u - 0.5) * size.height * 0.18;
        x < -39 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_Contours old) => old.color != color;
}

/// Small spaced capitals over a heading or a figure: "LAKE LANIER · SEP 4–10".
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: Theme.of(context).textTheme.labelSmall
        ?.copyWith(color: color ?? Tones.of(context).muted, fontWeight: FontWeight.w600, letterSpacing: 1.8),
  );
}

/// The one figure a screen is about, large, with what it means beside it.
class FigureCard extends StatelessWidget {
  const FigureCard({
    super.key,
    this.eyebrow,
    required this.value,
    this.caption,
    this.detail,
    this.accent = false,
  });
  final String? eyebrow;
  final String value;

  /// Right-aligned beside the figure: what it is, then a muted detail.
  final String? caption, detail;

  /// Lime figure: the best of something.
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (eyebrow != null) ...[Eyebrow(eyebrow!), const SizedBox(height: 4)],
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        style: t.displayMedium
                            ?.merge(tabular)
                            .copyWith(
                              color: accent ? (dark ? lime : const Color(0xFF4F6300)) : null,
                              height: 1.05,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (caption != null || detail != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (caption != null) Text(caption!, textAlign: TextAlign.end, style: t.bodyMedium),
                          if (detail != null) Text(detail!, textAlign: TextAlign.end, style: t.bodySmall),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A row in a ranked list: a short lead, muted detail, the figure on the
/// right. [best] underlines it in lime; [bar] draws a relative track.
class ScoreRow extends StatelessWidget {
  const ScoreRow({
    super.key,
    required this.lead,
    this.detail,
    required this.value,
    this.best = false,
    this.bar,
    this.onTap,
    this.leadWidth = 88,
    this.below,
    this.explain,
  });
  final String lead;
  final String? detail;
  final String value;
  final bool best;

  /// 0 to 1: the share of the largest in the list.
  final double? bar;
  final VoidCallback? onTap;
  final double leadWidth;

  /// Shown under the row inside the same card (an opened row's details).
  final Widget? below;

  /// What the figure means, shown when the row is tapped and does nothing
  /// else.
  final String? explain;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final tones = Tones.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final row = Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          SizedBox(
            width: leadWidth,
            child: Text(lead, style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700), maxLines: 2),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (detail != null)
                  Text(detail!, style: t.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                if (bar != null)
                  Padding(
                    padding: EdgeInsets.only(top: detail == null ? 0 : 6),
                    child: _Track(bar!, best: best),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(value, style: t.titleLarge?.merge(tabular).copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: best
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: dark ? lime.withValues(alpha: 0.35) : tones.hairline),
              )
            : null,
        child: InkWell(
          onTap: onTap ?? (explain == null ? null : () => explainFigure(context, lead, explain!)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              row,
              if (below != null) Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 14), child: below),
              if (best)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(color: lime, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Track extends StatelessWidget {
  const _Track(this.share, {required this.best});
  final double share;
  final bool best;

  @override
  Widget build(BuildContext context) {
    final tones = Tones.of(context);
    final fill = best ? lime : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        height: 5,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: tones.track)),
            FractionallySizedBox(
              widthFactor: share.clamp(0, 1).toDouble(),
              child: ColoredBox(color: fill),
            ),
          ],
        ),
      ),
    );
  }
}

/// A short note on what a figure means, for a tapped tile or row.
Future<void> explainFigure(BuildContext context, String title, String text) => showDialog<void>(
  context: context,
  builder: (dialog) => AlertDialog(
    title: Text(title),
    content: Text(text),
    actions: [TextButton(onPressed: () => Navigator.pop(dialog), child: const Text('OK'))],
  ),
);

/// A small labelled figure: PRESSURE 1014.7.
class StatTile extends StatelessWidget {
  const StatTile(this.label, this.value, {super.key, this.detail, this.alert = false, this.explain});
  final String label, value;
  final String? detail;

  /// What the figure means, shown when the tile is tapped.
  final String? explain;

  /// Something needs doing: the figure turns the warning colour.
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: explain == null ? null : () => explainFigure(context, label, explain!),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Eyebrow(label),
                    if (explain != null) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.info_outline, size: 12, color: Tones.of(context).muted),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: t.titleLarge
                      ?.merge(tabular)
                      .copyWith(fontWeight: FontWeight.w800, color: alert ? StatusColors.serious : null),
                ),
              ),
              if (detail != null)
                Text(detail!, style: t.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stat tiles side by side, wrapping on narrow screens.
class StatStrip extends StatelessWidget {
  const StatStrip(this.tiles, {super.key});
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: LayoutBuilder(
      builder: (context, c) {
        // Up to three in a row on a phone, two by two for four.
        final fit = (c.maxWidth / 150).floor().clamp(1, tiles.length);
        final cols = tiles.length <= 3 && c.maxWidth >= 320 ? tiles.length : fit;
        final w = (c.maxWidth - 8 * (cols - 1)) / cols;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final tile in tiles) SizedBox(width: w, child: tile)],
        );
      },
    ),
  );
}

/// A quiet outlined label: "Candidate · 06:40".
class Capsule extends StatelessWidget {
  const Capsule(this.text, {super.key, this.icon});
  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final tones = Tones.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: ShapeDecoration(
        shape: StadiumBorder(side: BorderSide(color: tones.hairline)),
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: tones.muted), const SizedBox(width: 6)],
          Text(text, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: tones.muted)),
        ],
      ),
    );
  }
}

/// A heading for a run of rows: spaced capitals with an optional count.
class RowsHeading extends StatelessWidget {
  const RowsHeading(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
    child: Row(
      children: [
        Expanded(child: Eyebrow(text)),
        ?trailing,
      ],
    ),
  );
}
