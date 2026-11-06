import 'package:brahma_core/brahma_core.dart';
import 'package:flutter/material.dart';

import '../ui/contacts_page.dart';
import '../ui/hunt_page.dart';
import '../ui/invest_page.dart';
import '../ui/lettings_page.dart';
import '../ui/research_page.dart';
import '../ui/researches_page.dart';
import '../ui/searches_page.dart';
import 'settings_page.dart';

final propertyModule = AppModule(
  id: 'property',
  name: 'Property',
  destinations: [
    Destination(
      id: 'hunt',
      label: 'Hunt',
      icon: Icons.travel_explore_outlined,
      selectedIcon: Icons.travel_explore,
      primary: true,
      page: (_) => const HuntPage(),
    ),
    Destination(
      id: 'searches',
      label: 'Searches',
      icon: Icons.saved_search_outlined,
      selectedIcon: Icons.saved_search,
      primary: true,
      page: (_) => const SearchesPage(),
    ),
    Destination(
      id: 'invest',
      label: 'Invest',
      icon: Icons.calculate_outlined,
      selectedIcon: Icons.calculate,
      primary: true,
      page: (_) => const InvestPage(),
    ),
    Destination(
      id: 'researches',
      label: 'Researches',
      icon: Icons.collections_bookmark_outlined,
      selectedIcon: Icons.collections_bookmark,
      primary: true,
      page: (_) => const ResearchesPage(),
    ),
    Destination(
      id: 'research',
      label: 'Areas',
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights,
      primary: true,
      page: (_) => const ResearchPage(),
    ),
    Destination(
      id: 'lettings',
      label: 'Lettings',
      icon: Icons.assignment_outlined,
      selectedIcon: Icons.assignment,
      page: (_) => const LettingsPage(),
    ),
    Destination(
      id: 'contacts',
      label: 'Contacts',
      icon: Icons.contacts_outlined,
      selectedIcon: Icons.contacts,
      page: (_) => const ContactsPage(),
    ),
  ],
);

final modules = <AppModule>[propertyModule];

/// Settings is app-wide, so it comes after every module's screens.
final settingsDestination = Destination(
  id: 'settings',
  label: 'Settings',
  icon: Icons.settings_outlined,
  selectedIcon: Icons.settings,
  page: (_) => const SettingsPage(),
);

List<Destination> get allDestinations => [for (final m in modules) ...m.destinations, settingsDestination];
