import 'package:brahma_core/brahma_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/modules.dart';
import 'app/providers.dart';
import 'app/security_checks.dart';
import 'app/session.dart';
import 'domain/pipeline.dart';
import 'ui/hints.dart';
import 'ui/look.dart';

/// Graha Anveshana as the Brahma suite app hosts it.
final anveshanaSuite = SuiteApp(
  identity: anveshanaIdentity,
  tagline: 'Property: renting, buying and lettings',
  icon: Icons.home_work_outlined,
  open: AppSession.open,
  overrides: (s) => [sessionProvider.overrideWithValue(s as AppSession)],
  hints: anveshanaHints,
  theme: (_, b) => anveshanaTheme(b),
  builder: (context, child) => Backdrop(child: child ?? const SizedBox.shrink()),
  home: (onHome) => AppShell(destinations: allDestinations, onHome: onHome, floating: true),
  onStart: fetchWatch,
  summary: (_) => const _Summary(),
  securityChecks: anveshanaChecks,
);

class _Summary extends ConsumerWidget {
  const _Summary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = today();
    final properties = ref.watch(propertiesProvider).value ?? const [];
    final viewings = ref.watch(viewingsProvider).value ?? const [];
    final checks = ref.watch(complianceProvider).value ?? const [];
    final hunting = properties.where(
      (p) => PropertyKind.of(p.kind) != PropertyKind.owned && Stage.of(p.stage).active,
    );
    final booked = viewings.where((v) => v.status == 'booked' && v.at.substring(0, 10).compareTo(now) >= 0);
    final due = checks.where((c) => c.done == null && c.due.compareTo(addDays(now, 30)) <= 0);
    return SummaryFigures([
      ('${hunting.length}', 'in the hunt'),
      ('${booked.length}', 'viewings booked'),
      ('${due.length}', 'checks due in 30 days'),
    ], next: properties.isEmpty ? 'Paste a listing link on Shortlist to start.' : null);
  }
}
