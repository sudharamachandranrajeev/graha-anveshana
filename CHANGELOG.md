# Changelog

## 0.12.0

- Search filters: **Must have** (garage, driveway, any parking, garden, en suite, two bathrooms,
  ground floor or lift, pets allowed) and **Never show** (retirement, shared ownership, park and
  holiday homes, auctions, cash buyers only, house shares, student lets), read from each advert's
  words. Homes whose advert does not say stay, unless you choose to hide them. Rightmove also
  gets its own garden, parking and "don't show" filters.
- Draw an area on the Search map; homes outside it are left out.
- Travel time: "at most N minutes by car, bike or on foot" to one of your places, from the
  OpenStreetMap community router. On a home's page, tap Car, Bike or Walk for the time to each
  place. Only map points are sent.
- Leasehold homes for sale: service charge, ground rent and years left on the lease, a month's
  cost, what the advert leaves out, and a warning under 80 or 100 years.
- Area checks on a home's page: schools within a mile (OpenStreetMap, with Ofsted links), where
  the sun rises and sets through the year and which way the building's long sides face, Defra
  road and rail noise maps over the map, and links to the coal mining and radon maps.
- docs/2026-11-10-user-feature-requests.md and docs/2026-11-10-listing-sources-and-repos.md:
  what home-hunters ask for, and lawful ways to find more listings.

## 0.11.1

- Search: More sites links to SpareRoom, Leeds Homes and Doncaster HomeChoice (to rent),
  Share to Buy and the auction sites (to buy), and Home.co.uk. They open in your browser at the
  search's town where they can; Search does not read them, as their owners do not allow it.

## 0.11.0

- Simpler names: Hunt is now **Shortlist**, Researches are **Collections**, and the
  "Shortlisted" stage is **Liked**.
- New **Profile** page: your details and home point (moved from Settings), your places, site
  sign-ins (moved from Settings → Search sites) and the Trash.
- Your places: add work, family, a school. Every home in Search and on its page shows how far it
  is from each, with directions. Places now sync with your other devices; ones added in 0.10.1
  carry over.
- Throw a home out of Search (the bin on its card) and it never shows again, on any site, until
  you restore it from **Profile → Trash**. Undo right after, or empty the Trash.
- Signing in to Zoopla or Facebook does not get past their robot checks; pass one yourself with
  Open Zoopla.
- docs/2026-11-09-uk-property-sites.md: other UK property sites, and which allow being read.

## 0.10.1

- Zoopla (and other sites opened in the app): on one advert's own page, Add these homes adds
  that advert. Reading a page now says how many adverts it found, how many are new, and how many
  your filters left out. If it finds adverts it cannot read, More → Save this page saves the page
  to Downloads so the reading can be fixed.
- Zoopla shows a robot check to the hidden browser; tap Open Zoopla and pass it yourself.
- Every home's page (from Search and in Hunt) has a map, and shows how far the home is from a
  place you pick: your home point, the search's place, or any postcode, district or town (name it,
  e.g. "Work"). The distance is in a straight line, with a link to directions and travel time.
  The places are remembered, and the last one is used on the next home.

## 0.10.0

- Fixed: searching "furnished" showed unfurnished homes too. Words now match whole words only
  ("unfurnished" no longer counts as "furnished"), furnishing is a hard limit (a home that says
  the opposite is left out; one that does not say stays), and Rightmove and Zoopla are asked
  for the furnishing themselves.
- Connect Zoopla and Facebook Marketplace (Settings → Search sites): sign in on the site's own
  page inside the app, and Search reads them as you. Disconnect signs you out. After you pass a
  sign-in or robot check, a blocked site is searched again by itself.

- Search: sort the results by best match, price (either way), most bedrooms, nearest or
  available soonest. The order you pick is remembered.
- Search: a map of the results (OpenStreetMap), with the search's centre. Tap a pin to open the
  home. Homes the site gave no map point are placed by postcode; by district only, the pin is
  hollow.
- Search remembers: Carry on with the last search, Your usual (the place you search most), and
  Save search to keep one by name with its filters and order. Saved searches sync.
- Search learns what you like from the homes you keep in Hunt (price, bedrooms, district,
  features; homes you drop or rate low count against). Once you keep three, results put the
  homes most like them first ("For you") and mark the close ones. All on the device.
- Zoopla is read with the other sites, in a hidden in-app browser; no more opening it yourself.
  If it wants a robot check, Open Zoopla shows it, and its homes join your results by
  themselves as its pages load.
- New site: Facebook Marketplace (homes to rent and for sale), read the same way. Sign in through
  Open Facebook Marketplace when it asks.
- Hunt: sort each stage by nearest, rating, price, bedrooms or newest added, and a map of your
  homes with your home point. A home's page shows it on a map.

## 0.9.1

- Windows: the app builds again with the in-app browser (0.9.0's Windows build failed).
- Search: a postcode district on its own ("LS6 2 bed", "flat Belfast BT9") searches that district.
- Search: a research made from a search keeps the search's centre for distances.
- Search: pages still arriving from an earlier search no longer mix into a new one.

## 0.9.0

- Search is the first tab. Type what you want in your own words ("2 bed to rent in Leeds under
  £900 within 3 miles with parking, no students") and the app reads Rightmove, OnTheMarket,
  OpenRent and PropertyPal for you, then shows every home that answers in one list: best match
  first, then nearest, then cheapest. More load as you scroll. The same home on two sites shows
  once, with both sites named. Your words become filters you can tap to change or remove.
- Open a home to see it in full inside the app: every photo, the description, key features,
  facts (deposit, furnishing, council tax...), floor plans and the agent, with Add to Hunt, Add
  to a research and Call.
- Zoopla, and any site that asks you to prove you are not a robot, open inside the app. Browse or
  pass the check yourself, then tap Add these homes to my results.
- Links to adverts and area sites open inside the app instead of your browser (Android, Windows,
  and Linux builds with WPE WebKit). Settings > Search sites switches each site on or off and
  signs you out of every site opened in the app.
- A guided tour on first launch. Skip it at any step; take it again from Settings > Hints and
  help > Take the tour.
- The old Searches tab is now Saved searches, behind the button at the top of Search. The
  portal links it had are gone: Search does the job inside the app.
- Place names in Northern Ireland are found on the map through OpenStreetMap.

## 0.8.2

- Updates install from inside the app. When a new version is out, the start-up banner's Update
  button (or Settings > About > Check for updates) downloads it, checks it against the release's
  checksums, and installs it: the Android installer opens, Windows runs the setup, and Linux
  swaps the new version in and offers a restart. Your data stays where it is. A download that
  does not match its checksum is thrown away, never installed.
- Linux: the app menu entry now describes Graha Anveshana instead of a finance app.

## 0.8.1

- Android: the app builds again. 0.8.0's Android package failed to build because of the on-device text reader.

## 0.8.0

- Researches: a new tab. Start a research for each hunt or study ("Rental near work, January",
  "Buy-to-let in Leeds"), with what fits: a centre and distance, the most price, the fewest
  bedrooms, and words an advert should or must not mention. Each research keeps its own catalog.
- Add to a catalog from a link (PropertyPal adverts and searches are read; other sites keep the
  link), screenshots, photos, PDF brochures, pasted text or alert emails, or a note. Pictures are
  read with OCR on the device (Tesseract on Linux and Windows, ML Kit on Android); PDFs give their
  text, and pages that are only pictures are OCR'd. Price, pcm or pw, bedrooms, bathrooms,
  postcode, address, council tax band, EPC rating, phone, agent, available date, furnished and
  "let agreed" or "sold STC" are read from the text.
- Read with AI (optional): fills in what OCR missed using the AI chosen in Settings, Ask AI. It
  sends only that item's text and asks first.
- Each item shows how well it fits the research, and why not.
- Duplicates: the same home captured twice (same advert or link, same address, same main photo,
  or the same postcode, bedrooms and a price within 5%) is found within a research and across
  researches. You merge it or mark it as not the same. Merging keeps every link, note and price
  seen, and the earliest capture date.
- Merge two researches into one.
- Seen before: an item that matches a Hunt home already let, sold or dropped says so.
- Add to Hunt from any catalog item.
- Help on every screen: the help button searches the app's own guide offline, opens the screen
  an answer is about, or passes the question on to Ask AI.
- The Research tab is now called Areas.
- Pictures stay on the device inside the encrypted database; their details sync.

## 0.7.0

- Searches: keep searching England continuously. An email search watches the alert emails
  Rightmove, Zoopla, OnTheMarket, OpenRent and SpareRoom send you, forwarded to your Brahma Watch:
  near a postcode, postcode district or place name ("LS6", "Pontefract"), within a distance, up to a
  price, by bedrooms, to rent or to buy, and words the advert must or must not mention. New homes
  and price changes arrive as phone alerts and under Hunt, once even when two sites send the same
  home. Needs the latest Brahma Watch (brahma repository, `watch/`) and a
  domain on your Cloudflare account; "Alert emails (England)" on the Searches page explains the
  setup.
- Alerted adverts keep their site and advert number, so a home you also pasted from Rightmove is
  not added twice.

## 0.6.0

- Lettings: import rent from your bank. Paste a statement downloaded as CSV; the app finds the lines
  for the rent or naming the tenant, skips ones already recorded, and records the ones you tick.
  Nothing leaves the device.
- Lettings: rent received by Making Tax Digital quarter (6 April to 5 July and so on), with a copy
  as CSV for your tax software or accountant. Income only; nothing is sent to HMRC.
- Hunt: find saved homes by words in the address, postcode or your notes ("pets", or "-damp" to
  hide), by fewest bedrooms and by the most you will pay.
- Council tax and bills a month on each home; Compare adds them to the rent as an all-in figure.
- Is it fair? shows the income tenant referencing usually asks for (30 times the rent, 36 for a
  guarantor), and the deposit line says six weeks when the rent is £50,000 a year or more.

## 0.5.0

Works for England now, not just Northern Ireland.

- Fixed: house prices were missing from every England area report (the price index answers a month
  with no data as a word, not a record).
- Searches: open Rightmove, OnTheMarket and OpenRent searches for any town or postcode. Zoopla is
  left out because its terms forbid links into its pages. The portals do not let apps read their
  adverts, so nothing is scraped.
- Add a home from a Rightmove, Zoopla, OnTheMarket or OpenRent link: the link is kept and you type
  the details. The same advert is never added twice.
- Is it fair? On a home's page: compare the rent with the ONS average and with housing benefit
  rates, or the price with recent sales on the street and the area average. Lets also show the most
  you can be asked to pay before moving in.
- Check advert wording: flags rent bidding, refusing benefits or children, banned fees, too much
  rent in advance, deposits over the legal limit, old-style tenancy wording and scam signs.
- Area reports: average rent, rent against price, housing benefit rates, selective licensing and
  small-HMO notes for Leeds, Wakefield, Doncaster and Rotherham, live flood alerts, and council
  lettings schemes. Saved areas compare rent and yield.
- Hunt: compare shortlisted homes side by side; enquiries with no reply for four days are flagged.
- Viewings: a checklist of what to look for; ticked problems join the notes.
- Lettings: Renters' Rights Act checks (information sheet, rental database, right to rent), rent
  rise dates, and a copyable rent record for your tax return.
- Tests pass on Windows again.

## 0.4.1

- Postcode lookups work again: any postcode with a space ("BT74 7BA") was sent double-encoded
  and came back "not a known postcode". Fixes the home point in Settings and Research.
- Phones get new navigation: a floating dock that scrolls through every screen (the "More"
  sheet is gone) and a side panel listing them all with what each is for. Swipe right on any
  page, or tap the dock's menu button, to open it; Back closes it.

## 0.4.0

A new look, after a dark instrument-panel reference: a charcoal canvas with faint contour lines,
hairline cards, one lime accent for the best or chosen, big tabular figures under small spaced
capitals, and a floating navigation bar. Light mode keeps the layout with ink actions. Inter is
bundled.

- Hunt leads with the homes in play; homes are ranked rows with the top-rated underlined.
- Invest leads with cash flow (or the mortgage, or the profit) and figure tiles.
- Lettings leads with rent outstanding; property and research pages get a headline figure.

## 0.3.0

Anveshana is now two apps. This one, Graha Anveshana, keeps the homes: hunt, searches, invest,
research and lettings. The cars (added in 0.2.0) moved to Vahana Anveshana. App ids, the data folder
and the encryption key are unchanged, so it upgrades in place; cars you saved in 0.2.0 stay in the
database but are no longer shown (add them again in Vahana Anveshana from their advert links).

## 0.2.0

Added the Cars module, since moved to Vahana Anveshana.

## 0.1.0

First release, for Linux, Windows and Android.

- Hunt: properties to rent or buy by stage, from PropertyPal links or typed in, with distance from
  a home point and adverts that go let or sold flagged.
- Contact agents and landlords by call, text, WhatsApp or e-mail, logged against the property;
  a first enquiry signed with your details; viewings and follow-ups.
- Saved searches sent to Brahma Watch (Cloudflare Worker) for phone alerts; its finds come into
  the hunt.
- Appraisals: buy-to-let, buying a home and development (residual land value), with SDLT, LBTT
  and LTT, Section 24 and April 2027 property income rates.
- Area research for any UK postcode: house price index, crime, sold prices and links per nation.
- Lettings: tenancies, rent and arrears, deposits and recurring landlord checks.
- Encrypted on the device; optional end-to-end encrypted sync on the shared Brahma account.
- Hints on every screen, which can be hidden and brought back in Settings.
