import 'package:brahma_core/brahma_core.dart';

/// Graha Anveshana's guided tour. It is offered once, can be skipped at any
/// step, and runs again from Settings > Hints and help > Take the tour.
const anveshanaTour = <TourStep>[
  TourStep(
    title: 'Welcome to Graha Anveshana',
    body:
        'It finds homes to rent or buy across the property sites and keeps your whole hunt in one place. '
        'This tour takes a minute. Skip it at any step.',
  ),
  TourStep(
    title: 'Search in your own words',
    body:
        'Type what you want, e.g. "2 bed to rent in Leeds under £900 within 3 miles with parking". The app '
        'reads Rightmove, OnTheMarket, OpenRent and PropertyPal for you and shows every home that answers, '
        'in one list.',
    screen: 'search',
    target: 'search.bar',
  ),
  TourStep(
    title: 'Rent or buy',
    body: 'Used when your words do not say. "For sale" or "to rent" in the search wins.',
    screen: 'search',
    target: 'search.kind',
  ),
  TourStep(
    title: 'After you search',
    body:
        'Your words become filters you can tap to change or remove. Each site shows how many adverts it '
        'gave. The same home on two sites shows once. Tap a home to see every photo, the description and '
        'the agent, here in the app, and save it to Shortlist or a collection.',
    screen: 'search',
  ),
  TourStep(
    title: 'Shortlist',
    body: 'Homes you are considering, from first sight to keys: enquiries, viewings, offers.',
    target: 'nav.hunt',
  ),
  TourStep(
    title: 'Collections',
    body: 'Keep each hunt or study apart, capture homes from screenshots, photos and brochures, and merge duplicates.',
    target: 'nav.researches',
  ),
  TourStep(
    title: 'Areas and Invest',
    body: 'Area reports for any UK postcode, and buy-to-let, buying and development sums.',
    target: 'nav.research',
  ),
  TourStep(
    title: 'Settings',
    body:
        'Your details for enquiries, the home point distances are measured from, which sites Search reads, '
        'and sync. Take this tour again under Hints and help.',
    target: 'nav.settings',
  ),
];
