/// Graha Anveshana's hints, by id, on top of the shared ones (coreHints). Tooltips
/// use the short ones; page banners (ids starting `page.`) explain a whole
/// screen once.
const anveshanaHints = <String, String>{
  // Navigation
  'nav.dashboard': 'Your hunt so far: what you have seen, asked about and viewed, and what to do next.',
  'nav.hunt': 'Homes you are looking at to rent or buy, from first sight to keys.',
  'nav.contacts': 'Agents, landlords, tenants, brokers, solicitors and trades.',
  'nav.search': 'Find homes to rent or buy across the property sites, in your own words.',
  'nav.invest': 'Buy-to-let, buying a home and development appraisals.',
  'nav.lettings': 'Tenancies, rent and landlord safety checks.',
  'nav.researches':
      'Your researches: one per hunt or study, each with its own catalog of homes and documents.',
  'nav.research': 'Area reports for any UK postcode, purchase tax and where to look further.',
  'nav.settings': 'Your details for enquiries, your home point, Brahma Watch, sync and security.',
  // Hunt
  'hunt.add':
      'Paste an advert link (PropertyPal, Rightmove, Zoopla, OnTheMarket, OpenRent), or type a property in.',
  'hunt.compare':
      'Liked homes side by side: price, cash needed to move in, size, distance and more. To compare '
      'chosen homes, New ones too, tap the checklist button and pick them.',
  'hunt.distance': 'As the crow flies from the home point in Settings.',
  'hunt.enquiry': 'A first message: is it free, what next, when to view. Your details come from Settings.',
  'hunt.stage': 'Where this property is in your hunt. Calls and messages move it on by themselves.',
  'hunt.stale':
      'No search has shown this home for two weeks or more, though its advert was not marked let or sold. '
      'It may have gone: check with the agent.',
  'hunt.gone': 'The advert says it is let or sold.',
  // Search
  'search.saved': 'Searches Brahma Watch checks for you, and the alerts it sends.',
  // Saved searches
  'searches.send': 'Replace the searches Brahma Watch runs with these.',
  'searches.fetch': 'Copy the searches Brahma Watch runs into Graha Anveshana.',
  'searches.run': 'Ask Brahma Watch to check every search now.',
  'searches.test': 'Send a test alert to your phone.',
  'searches.emails': 'England: watch Rightmove, Zoopla and other alert emails through Brahma Watch.',
  'searches.path':
      'The part of a PropertyPal search address after the site name, e.g. /property-to-rent/enniskillen.',
  // Invest
  'invest.save': 'Keep these figures to come back to.',
  'invest.icr': 'Lenders want rent to cover the interest at a stress rate by this much (often 125%).',
  'invest.residual': 'The most you could pay for the land and still make the target profit.',
  // Lettings
  'lettings.balance': 'Rent due so far minus rent recorded. Positive is owed.',
  'lettings.checks': 'Safety certificates and other duties with the date each is next due.',
  // Research
  'research.save': 'Keep this report to compare areas later.',
  'research.tax': 'Stamp Duty (England, NI), LBTT (Scotland) or LTT (Wales) for a price.',
  // Collections
  'researches.new':
      'Start a collection: a name, what it is for, and what fits (area, price, bedrooms, words).',
  'researches.add':
      'Add to the catalog from a link, a screenshot, a photo, a PDF brochure, pasted text or an alert email. '
      'Details are read on this device.',
  'researches.ocr':
      'Screenshots and photos are read with OCR on this device (Tesseract, or ML Kit on Android).',
  'researches.ai': 'Read with AI: sends only this item\'s text to the AI chosen in Settings, Ask AI.',
  'researches.duplicates': 'Find the same home captured twice (same advert, address, photo, or postcode, beds and price) and merge them.',
  'researches.merge': 'Merge another collection into this one, then check the joined catalog for duplicates.',
  'researches.hunt': 'Add this item to Shortlist to enquire, view and track it.',
  'researches.fit': 'How well an item fits the collection: price, bedrooms, distance and words.',
  'researches.seen': 'Seen before: you saved this home earlier and it was let or sold then.',
  // Settings
  'settings.applicant': 'Goes into enquiries you send. Stays on your devices.',
  'settings.home': 'Where distances are measured from, e.g. home or work.',
  'profile.places': 'Places every home is measured from: work, family, a school. Synced with your devices.',
  'profile.signins': 'Your own sign-ins to Zoopla and Facebook, kept by the in-app browser on this device.',
  'profile.trash': 'Homes you threw out of Search. They never show again until you restore them.',
  'settings.sites':
      'The sites the Search tab reads when you search. Each is read only then, from this device, one '
      'page at a time.',
  'settings.watch':
      'Your own Brahma Watch Worker on Cloudflare, which checks searches and alerts your phone.',
  // Page banners
  'page.dashboard':
      'Your hunt so far, worked out from what is on this device: homes saved and how far they got, '
      'prices against your budget, where they are, how agents reply, and what to do next. Tap a row to '
      'see its homes. Nothing here is sent anywhere.',
  'page.hunt':
      'Every home you are considering, from first sight to keys. Add one from Search or a link, then '
      'move it on: new, liked, enquired, viewing, applied, agreed. Calls and messages move it on '
      'by themselves; drop the ones that are not for you.',
  'page.contacts': 'Agents, landlords, tenants and trades in one place. Add them here or from a home.',
  'page.searches':
      'Searches Brahma Watch checks for you: PropertyPal searches, and in England the alert emails from '
      'Rightmove, Zoopla and others. Send them to the Watch, then new homes arrive '
      'as phone alerts and under Shortlist. Settings > Brahma Watch connects it first.',
  'page.invest':
      'Work out buy-to-let returns, what buying a home costs, or what land is worth to develop. Save the '
      'figures to compare later.',
  'page.lettings':
      'Tenancies for homes you let out or rent: rent due and paid, and safety checks with the date each '
      'is next due.',
  'page.researches':
      'Keep each hunt or study apart. Capture homes from any site, screenshots, photos and brochures; the '
      'app reads the details, scores how well each fits and finds duplicates to merge.',
  'page.research':
      'Type a UK postcode for prices, crime and links about the area, or work out purchase tax. Save '
      'reports to compare areas.',
};
