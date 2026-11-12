import 'package:brahma_core/brahma_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../app/providers.dart';
import '../app/search_memory.dart';
import '../db/database.dart';
import '../domain/book.dart' show PrefKeys;
import '../domain/dashboard.dart';
import '../domain/pipeline.dart';
import 'common.dart';
import 'homes_map.dart';
import 'look.dart';
import 'property_page.dart';

/// "Your hunt so far": what the user has searched, saved, asked and seen,
/// worked out from the data on this device. Nothing is sent anywhere.
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key, this.today});

  /// Tests fix the date; null: now.
  final DateTime? today;

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  /// null: whichever of rent or buy has more homes.
  PropertyKind? _kind;

  /// A collection to look at alone; null: everything.
  String? _research;

  @override
  Widget build(BuildContext context) {
    final props = ref.watch(propertiesProvider);
    final log = ref.watch(interactionsProvider).value ?? const <Interaction>[];
    final views = ref.watch(viewingsProvider).value ?? const <Viewing>[];
    final contacts = ref.watch(contactsProvider).value ?? const <Contact>[];
    final researches = [
      for (final r in ref.watch(researchesProvider).value ?? const <ResearchJob>[])
        if (!r.archived) r,
    ];
    final items = ref.watch(catalogItemsProvider).value ?? const <CatalogItem>[];
    final history = ref.watch(searchHistoryProvider).value ?? const [];
    final saved = ref.watch(savedSearchesProvider).value ?? const [];
    final home = ref.watch(homeProvider).value;
    final places = ref.watch(profilePlacesProvider).value ?? const <NamedPoint>[];
    final goals = ref.watch(huntGoalsProvider).value ?? const <String, Object?>{};

    return PageScaffold(
      title: 'Dashboard',
      banner: 'page.dashboard',
      children: [
        AsyncView(
          props,
          builder: (all) {
            final rent = all.where((p) => p.kind == PropertyKind.rent.name).length;
            final buy = all.where((p) => p.kind == PropertyKind.buy.name).length;
            final kind = _kind ?? (buy > rent ? PropertyKind.buy : PropertyKind.rent);
            final research = researches.where((r) => r.id == _research).firstOrNull;
            final goal = goalIn(goals, kind);
            final lastBudget = history
                .where((q) => q.rent == (kind == PropertyKind.rent) && (q.maxPrice ?? 0) > 0)
                .firstOrNull
                ?.maxPrice;
            final s = summarise(
              kind: kind,
              properties: all,
              interactions: log,
              viewings: views,
              contacts: contacts,
              today: widget.today ?? DateTime.now(),
              only: research == null
                  ? null
                  : {
                      for (final i in items)
                        if (i.researchId == research.id && i.propertyId != null) i.propertyId!,
                    },
              budget: goal.budget ?? lastBudget,
              moveBy: goal.moveBy,
              places: [
                if (home != null)
                  (lat: home.lat, lon: home.lon, label: home.label.isEmpty ? 'Home' : home.label),
                ...places,
              ],
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _filters(context, kind, researches, research),
                const SizedBox(height: 12),
                _Plan(kind: kind, goal: goal, lastBudget: lastBudget, pace: s.pace, all: goals),
                if (s.isEmpty && history.isEmpty)
                  EmptyState(
                    icon: Icons.space_dashboard_outlined,
                    title: 'Your hunt shows here',
                    message:
                        'Search for homes ${kind == PropertyKind.rent ? 'to rent' : 'to buy'} and save the ones '
                        'you like. This page then shows how your hunt is going: what you have seen, asked about '
                        'and viewed, prices against your budget, and what to do next.',
                  )
                else
                  ..._body(
                    context,
                    s,
                    kind,
                    searches: history.length,
                    saved: saved.length,
                    home: home,
                    budgetSet: goal.budget != null,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _filters(
    BuildContext context,
    PropertyKind kind,
    List<ResearchJob> researches,
    ResearchJob? research,
  ) => Wrap(
    spacing: 12,
    runSpacing: 8,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      SegmentedButton<PropertyKind>(
        segments: const [
          ButtonSegment(value: PropertyKind.rent, label: Text('To rent')),
          ButtonSegment(value: PropertyKind.buy, label: Text('To buy')),
        ],
        selected: {kind},
        onSelectionChanged: (s) => setState(() => _kind = s.first),
      ),
      if (researches.isNotEmpty)
        DropdownButton<String?>(
          value: research?.id,
          hint: const Text('All homes'),
          items: [
            const DropdownMenuItem(value: null, child: Text('All homes')),
            for (final r in researches) DropdownMenuItem(value: r.id, child: Text(r.name)),
          ],
          onChanged: (v) => setState(() => _research = v),
        ),
    ],
  );

  List<Widget> _body(
    BuildContext context,
    HuntSummary s,
    PropertyKind kind, {
    required int searches,
    required int saved,
    required ({double lat, double lon, String label})? home,
    required bool budgetSet,
  }) {
    String? week(int n) => n == 0 ? null : '+$n new';
    final insights = s.insights;
    final p = s.prices;
    final maxBin = p == null ? 1 : p.bins.map((b) => b.count).fold(1, (a, b) => a > b ? a : b);
    final maxBeds = s.beds.map((b) => b.count).fold(1, (a, b) => a > b ? a : b);
    final maxDistrict = s.districts.map((d) => d.count).fold(1, (a, b) => a > b ? a : b);
    final first = s.funnel.first.count;
    final viewed = s.funnel[Stage.viewing.index].count;
    final rent = kind == PropertyKind.rent;
    String count(int n) => n == 0 ? 'none yet' : '$n';
    return [
      StatStrip([
        StatTile(
          'Searches',
          count(searches),
          detail: saved == 0 ? null : '$saved saved',
          explain:
              'Searches you ran on this device, and how many you saved to run again. '
              '"+N new" under a figure means this week.',
        ),
        StatTile(
          'Homes saved',
          count(s.homes.length),
          detail: week(s.addedThisWeek),
          explain: 'Homes ${rent ? 'to rent' : 'to buy'} in your Shortlist, at any stage.',
        ),
        StatTile(
          'Liked',
          count(s.liked.length),
          explain: 'Homes you marked Liked, or took further: asked about, viewed, applied or agreed.',
        ),
      ]),
      StatStrip([
        StatTile(
          'Enquiries',
          count(s.enquired.length),
          detail: week(s.enquiriesThisWeek),
          explain: 'Homes you asked an agent or landlord about: a message logged, or the stage says so.',
        ),
        StatTile(
          'Viewings',
          count(viewed),
          detail: week(s.viewingsThisWeek),
          explain: 'Homes with a viewing booked or done. Cancelled viewings do not count.',
        ),
        StatTile(
          'Days hunting',
          s.daysHunting == null ? 'none yet' : '${s.daysHunting}',
          explain: 'Days since you saved your first home ${rent ? 'to rent' : 'to buy'}.',
        ),
      ]),
      if (insights.isNotEmpty)
        SectionCard(
          title: 'What your hunt says',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final line in insights)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2, right: 8),
                        child: Icon(Icons.lightbulb_outline, size: 16),
                      ),
                      Expanded(child: Text(line)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      if (s.todo.isNotEmpty) ...[
        RowsHeading('To do next', trailing: Text('${s.todo.length}')),
        Card(
          child: Column(
            children: [
              for (final t in s.todo.take(8))
                ListTile(
                  dense: true,
                  leading: Icon(
                    t.urgent ? Icons.notification_important_outlined : Icons.check_box_outline_blank,
                    color: t.urgent ? StatusColors.serious : null,
                  ),
                  title: Text(t.text),
                  trailing: t.propertyId == null ? null : const Icon(Icons.chevron_right),
                  onTap: t.propertyId == null ? null : () => _open(context, t.propertyId!),
                ),
            ],
          ),
        ),
      ],
      RowsHeading('How far your homes got'),
      for (final f in s.funnel)
        if (f.count > 0 || f.stage.index <= Stage.viewing.index)
          ScoreRow(
            lead: f.stage.label(kind),
            leadWidth: 100,
            value: '${f.count}',
            bar: first == 0 ? 0 : f.count / first,
            best: f.stage == Stage.agreed && f.count > 0,
            detail: f.stage == Stage.fresh || first == 0
                ? null
                : '${(f.count / first * 100).round()}% of homes',
            onTap: f.homes.isEmpty ? null : () => _list(context, f.stage.label(kind), f.homes),
            explain:
                'No home has reached ${f.stage.label(kind)} yet. Each row counts homes that got this far.',
          ),
      if (s.dropped.isNotEmpty)
        ScoreRow(
          lead: Stage.dropped.label(kind),
          leadWidth: 100,
          value: '${s.dropped.length}',
          detail: 'Set aside; counted above for how far they got',
          onTap: () => _list(context, Stage.dropped.label(kind), s.dropped),
        ),
      SectionCard(
        title: 'The last 12 weeks',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _WeekBars('Homes saved', [for (final w in s.weeks) (w.start, w.added)]),
            _WeekBars('Enquiries', [for (final w in s.weeks) (w.start, w.enquiries)]),
            _WeekBars('Viewings', [for (final w in s.weeks) (w.start, w.viewings)]),
          ],
        ),
      ),
      if (p != null)
        SectionCard(
          title: kind == PropertyKind.rent ? 'Rents you have seen' : 'Prices you have seen',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FigureRow('Lowest', gbp(p.low)),
              FigureRow('Middle', gbp(p.median)),
              FigureRow('Highest', gbp(p.high)),
              if (p.likedMedian != null) FigureRow('Middle of the ones you like', gbp(p.likedMedian!)),
              if (p.budget != null)
                FigureRow(
                  budgetSet ? 'Your budget' : 'Your budget (last search)',
                  '${gbp(p.budget!)} · ${p.overBudget} over',
                ),
              if (p.bins.length > 1) ...[
                const SizedBox(height: 12),
                for (final b in p.bins)
                  _BinRow(
                    '${gbp(b.from)}–${gbp(b.to)}',
                    b.count,
                    share: b.count / maxBin,
                    budget: p.budget != null && b.from <= p.budget! && p.budget! <= b.to,
                  ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      if (s.beds.isNotEmpty) ...[
        RowsHeading('Bedrooms'),
        for (final b in s.beds)
          ScoreRow(
            lead: b.beds == 0 ? 'Studio' : '${b.beds} bed',
            value: '${b.count}',
            bar: b.count / maxBeds,
          ),
      ],
      if (s.districts.isNotEmpty || s.distances.isNotEmpty) ...[
        RowsHeading('Where'),
        for (final d in s.districts)
          ScoreRow(lead: d.district, value: '${d.count}', bar: d.count / maxDistrict),
        for (final d in s.distances)
          ScoreRow(
            lead: d.place,
            leadWidth: 120,
            detail: s.liked.isNotEmpty ? 'Liked homes, at the middle' : 'Your homes, at the middle',
            value: km(d.km),
          ),
        if (ref.watch(inlineMapsProvider))
          SizedBox(
            height: 280,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: HomesMap(
                  centre: home == null ? null : (lat: home.lat, lon: home.lon),
                  centreLabel: home?.label.isNotEmpty == true ? home!.label : 'Home',
                  homes: [
                    for (final h in s.liked.isNotEmpty ? s.liked : s.homes)
                      MapHome(
                        label: h.price == null ? h.address.split(',').first : gbp(h.price!),
                        lat: h.lat,
                        lon: h.lon,
                        postcode: h.postcode,
                        address: h.address,
                        onTap: () => _open(context, h.id),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
      if (s.agents.isNotEmpty) ...[
        RowsHeading('Agents and landlords'),
        for (final a in s.agents)
          ScoreRow(
            lead: a.name,
            leadWidth: 120,
            detail: [
              '${a.sent} sent',
              '${a.replies} ${a.replies == 1 ? 'reply' : 'replies'}',
              if (a.replyHours != null) 'replies in ${_hours(a.replyHours!)}',
              if (a.waiting > 0) '${a.waiting} waiting over a week',
            ].join(' · '),
            value: '${(a.replies / a.sent * 100).clamp(0, 100).round()}%',
          ),
      ],
      if (s.gone.isNotEmpty) ...[
        RowsHeading(kind == PropertyKind.rent ? 'Let before you got them' : 'Sold before you got them'),
        ScoreRow(
          lead: 'Gone',
          value: '${s.gone.length}',
          detail: '${s.goneBeforeEnquiry.length} before you asked about them',
          onTap: () => _list(context, 'Gone', s.gone),
        ),
      ],
      if (s.verdicts.isNotEmpty) ...[
        RowsHeading('After viewings'),
        for (final v in s.verdicts)
          ScoreRow(
            lead: v.verdict.label,
            leadWidth: 100,
            best: v.verdict == Impression.loved,
            detail: [
              v.home.address,
              if (v.notes.isNotEmpty) v.notes,
              'viewed ${niceDate(v.at.substring(0, 10))}',
            ].join(' · '),
            value: v.home.rating == 0 ? '' : '${v.home.rating}★',
            onTap: () => _open(context, v.home.id),
          ),
      ],
      if (!s.pulse.isEmpty) ...[
        RowsHeading('The market, from your searches'),
        if (s.pulse.cutThisWeek.isNotEmpty)
          ScoreRow(
            lead: 'Price cuts',
            value: '${s.pulse.cutThisWeek.length}',
            detail: 'homes you saved, in the last 7 days',
            onTap: () => _list(context, 'Price cuts this week', s.pulse.cutThisWeek),
          ),
        if (s.pulse.daysToGo != null)
          ScoreRow(
            lead: kind == PropertyKind.rent ? 'Time to let' : 'Time to sell',
            value: '${s.pulse.daysToGo} days',
            detail: 'at the middle, from first listed to last seen; ${s.pulse.goneFast} within two weeks',
            explain:
                'For homes you saved that went ${rent ? 'let' : 'sold'}: the days from when a site first listed '
                'them to the last time Search showed them. Half went faster, half slower.',
          ),
        if (s.pulse.mayBeGone.isNotEmpty)
          ScoreRow(
            lead: 'May be gone',
            value: '${s.pulse.mayBeGone.length}',
            detail: 'not seen in Search for two weeks',
            onTap: () => _list(context, 'May be gone', s.pulse.mayBeGone),
          ),
      ],
    ];
  }

  static String _hours(double h) => h < 1
      ? '${(h * 60).round()} min'
      : h < 48
      ? '${h.round()} h'
      : '${(h / 24).round()} days';

  void _open(BuildContext context, String id) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PropertyPage(id)));

  void _list(BuildContext context, String title, List<Property> homes) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(sheet).height * 0.7),
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text('$title · ${homes.length}', style: Theme.of(sheet).textTheme.titleMedium),
            ),
            for (final h in homes)
              ListTile(
                title: Text(h.address),
                subtitle: Text(propertyFacts(h)),
                trailing: Text(priceLabel(h)),
                onTap: () {
                  Navigator.pop(sheet);
                  _open(context, h.id);
                },
              ),
          ],
        ),
      ),
    ),
  );
}

/// The budget and the day to move by, set here for renting and buying
/// apart, with the days left.
class _Plan extends ConsumerWidget {
  const _Plan({
    required this.kind,
    required this.goal,
    required this.lastBudget,
    required this.pace,
    required this.all,
  });
  final PropertyKind kind;
  final HuntGoal goal;
  final int? lastBudget;
  final Pace? pace;
  final Map<String, Object?> all;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final left = pace?.daysLeft;
    return SectionCard(
      title: 'Your plan',
      trailing: TextButton.icon(
        onPressed: () => _edit(context, ref),
        icon: const Icon(Icons.edit_outlined),
        label: Text(goal.budget == null && goal.moveBy == null ? 'Set' : 'Change'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FigureRow(kind == PropertyKind.rent ? 'Most rent a month' : 'Most to pay', switch ((
            goal.budget,
            lastBudget,
          )) {
            (final b?, _) => gbp(b),
            (null, final b?) => 'not set (last search ${gbp(b)})',
            _ => 'not set',
          }),
          FigureRow(
            'Move by',
            goal.moveBy == null
                ? 'not set'
                : '${niceDate(goal.moveBy!)}${switch (left) {
                    null => '',
                    < 0 => ' (passed)',
                    0 => ' (today)',
                    1 => ' (1 day left)',
                    final n => ' ($n days left)',
                  }}',
          ),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final budget = TextEditingController(text: goal.budget?.toString() ?? '');
    var moveBy = goal.moveBy;
    await showFormDialog(
      context,
      title: 'Your plan ${kind == PropertyKind.rent ? 'to rent' : 'to buy'}',
      fields: (setState) => [
        Field(
          budget,
          kind == PropertyKind.rent ? 'Most rent a month' : 'Most to pay',
          prefix: '£',
          number: true,
          helper: 'Leave empty to use your last search\'s top price.',
        ),
        Row(
          children: [
            Expanded(child: Text(moveBy == null ? 'Move by: not set' : 'Move by: ${niceDate(moveBy!)}')),
            if (moveBy != null)
              IconButton(
                tooltip: 'Clear the date',
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() => moveBy = null),
              ),
            TextButton(
              onPressed: () async {
                final now = DateTime.now();
                final d = await showDatePicker(
                  context: context,
                  initialDate: moveBy == null ? now.add(const Duration(days: 30)) : DateTime.parse(moveBy!),
                  firstDate: now.subtract(const Duration(days: 365)),
                  lastDate: now.add(const Duration(days: 730)),
                );
                if (d != null) setState(() => moveBy = isoDate(d));
              },
              child: const Text('Pick a date'),
            ),
          ],
        ),
      ],
      onSave: () async {
        final b = intIn(budget);
        if (budget.text.trim().isNotEmpty && (b == null || b <= 0)) {
          return 'Give the budget as a number of pounds.';
        }
        await ref.mutate(
          (s) => s.book.setPref(PrefKeys.huntGoals, withGoal(all, kind, (budget: b, moveBy: moveBy))),
        );
        return null;
      },
    );
  }
}

/// One series by week: a label, the total and a bar per week, oldest first.
class _WeekBars extends StatelessWidget {
  const _WeekBars(this.label, this.weeks);
  final String label;
  final List<(DateTime, int)> weeks;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final tones = Tones.of(context);
    final top = weeks.map((w) => w.$2).fold(0, (a, b) => a > b ? a : b);
    final total = weeks.fold(0, (n, w) => n + w.$2);
    final day = DateFormat('d MMM');
    return Semantics(
      label: '$label: $total in the last 12 weeks, $top at most in one week',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Eyebrow(label)),
                Text('$total', style: t.titleSmall?.merge(tabular).copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 44,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final (i, (start, n)) in weeks.indexed)
                    Expanded(
                      child: Tooltip(
                        message: 'Week of ${day.format(start)}: $n',
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Container(
                            height: top == 0 ? 3 : 3 + 41 * n / top,
                            decoration: BoxDecoration(
                              color: n == 0 ? tones.track : (i == weeks.length - 1 ? lime : tones.muted),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(day.format(weeks.first.$1), style: t.labelSmall?.copyWith(color: tones.muted)),
                const Spacer(),
                Text('This week', style: t.labelSmall?.copyWith(color: tones.muted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A price band in the prices card: its range, a bar and how many homes.
/// The band holding the budget is marked.
class _BinRow extends StatelessWidget {
  const _BinRow(this.label, this.count, {required this.share, this.budget = false});
  final String label;
  final int count;
  final double share;
  final bool budget;

  @override
  Widget build(BuildContext context) {
    final tones = Tones.of(context);
    final ink = Theme.of(context).colorScheme.onSurface;
    return Semantics(
      label: '$label: $count${budget ? ', your budget' : ''}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            SizedBox(width: 120, child: Text(label, style: const TextStyle().merge(tabular))),
            Expanded(
              child: LayoutBuilder(
                builder: (context, box) => ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Stack(
                    children: [
                      Container(height: 10, color: tones.track),
                      Container(
                        height: 10,
                        width: box.maxWidth * share.clamp(0, 1),
                        color: budget ? lime : ink.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 72,
              child: Text(
                budget ? '$count · budget' : '$count',
                textAlign: TextAlign.right,
                style: const TextStyle().merge(tabular),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
