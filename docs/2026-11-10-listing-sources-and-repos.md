# More listings, earlier: lawful sources and reusable GitHub projects (2026-11-10)

Builds on [2026-11-05-feature-research.md](2026-11-05-feature-research.md),
[2026-11-09-uk-property-sites.md](2026-11-09-uk-property-sites.md) and
[2026-11-10-user-feature-requests.md](2026-11-10-user-feature-requests.md). Those already cover portal
terms (Rightmove, Zoopla, OnTheMarket, OpenRent, SpareRoom, Gumtree), SpareRoom, Share to Buy,
auctions, build to rent, Home.co.uk, Jitty and Nestoria. This file does not repeat them. It does not
research travel time, draw-a-search, must-have filters, leasehold cost or area checks; it only lists
code that could help build them.

Test area: Leeds to Doncaster (Leeds, Wakefield, Castleford, Pontefract, Doncaster).

## 0. Limits of the evidence

- **Method:** web search plus light reading of single pages (terms, robots.txt, docs, GitHub repo
  pages). No sign-in, no scraping, no API tokens, no cloning, nothing run.
- **Reddit is still blocked** for the tools. Hacker News had nothing useful from 2022-2026 on getting UK
  listings (searched "rightmove", "rightmove alerts", "uk property listings api").
- **User evidence is thin.** The best user text is one Mumsnet thread (March 2024, 36 replies). Most
  other sources are vendor pages, portal marketing or developer docs. Each is marked.
- **Several pages could not be read:** Zoopla's developer portal (certificate error), two agent-software
  help pages (403 or empty), Leeds Homes robots.txt (404). Where I could not read a page, the claim is
  marked "search summary" or "not confirmed".
- **GitHub dates:** "last updated" comes from GitHub search result pages. It is the last push or
  update, which is close to, but not always, the last commit. Repo pages often did not show a commit
  date; that is marked "not shown". Some dates showed no year; they are copied as shown. Stars are as
  shown on 2026-11-10.
- **Licence of this app:** the README says "No licence has been chosen yet; all rights reserved". As
  asked, compatibility below assumes the app becomes open source on GitHub.
- Not legal advice.

## A. Listing sources, ranked

Verdict key: **allowed** = the source's own terms or licence permit this use, or the data is the
user's own mail; **ask permission** = no terms found or terms silent, so ask the owner first;
**forbidden** = the terms ban it, or the only route is closed. Effort for this app: S = days, M = one
to two weeks, L = more.

| # | Source | What it adds | Freshness | Terms verdict | Effort | Links |
|---|---|---|---|---|---|---|
| 1 | **Local agents' own mailing lists and alerts, forwarded to Brahma Watch** (register with each Leeds-Doncaster agent; Watch parses their emails like portal alerts) | Homes **before** they reach portals, and a few that never do. Jitty built a "pre-market" feature on exactly this: it "gathers pre-market listings directly from estate agents' marketing emails" and says about 9% of homes sell before reaching portals (its own figure; 23% in London) | Mumsnet sellers: agents mail their lists "for 1-2 weeks before putting it on Rightmove"; buyers: "that day or two ahead". Other posters found agent emails added nothing over Rightmove. **Medium-thin** | **Allowed.** The user signs up and receives the mail. Each agent's privacy notice covers it. No automated reading of any site | S-M (a generic email parser; per-agent templates vary) | [JITTY-PREMKT], [MN-SKIP], [MN-SKIP-SUM] |
| 2 | **OnTheMarket alerts set to send at once** (via the existing alert-email route) | OnTheMarket "Only With Us" homes appear "24 hours or more before they're advertised on Rightmove or Zoopla". The agent sets the delay, "often 24 hours". Some are exclusive with no countdown | Minutes to hours after upload. OTM says these get twice the email leads in the first 24 hours (its own figure, Jan 2024-Jan 2025) | **Allowed** as the user's own email. I did not find OTM terms on reusing alert emails | S (check the Watch parser handles OTM alerts; tell the user to pick instant alerts) | [OTM-OWU], [OTM-LEAFLET] |
| 3 | **Rightmove alerts set to "instantly"** (existing route, a settings tip) | Rightmove says alerts can be "instantly, daily, every 3 days or every 7 days" and advises "instantly". An older trade article cited 90 minutes or less from upload to inbox | Minutes to hours. A relisted sale only alerts as new after a 14-week break | **Allowed** as user's own email | S (in-app tip and a check of the parser) | [RM-INSTANT], [RM-RELIST], [PIE-INSTANT] |
| 4 | **Weekly social-housing cycles as reminders** (Vico Homesearch for Wakefield district, Doncaster HomeChoice, Leeds Homes) | Council and housing-association homes not on portals. Vico adverts go live "on Wednesdays at 10.05 am" and close 9.55 am the next Wednesday. Doncaster HomeChoice: Wednesday about 17:00 to Sunday 23:59 (newer FAQ; a 2023 guide said Thursday 00:01). Leeds: cycle day not confirmed; new council homes are previewed on a council page about two weeks before advertising | Weekly | **Allowed** for links and reminders. Automated reading: **ask permission** (no terms or robots.txt found) | S (calendar-style reminder plus link; no reading) | [VICO-RENT], [WAK-CBL], [DON-FAQ], [DON-2023], [LEEDS-NEWBUILD] |
| 5 | **HM Land Registry Price Paid Data, linked-data API** | Not new listings. Shows what a listed or watched home finally **sold** for, so the app can close the loop on "sold STC" homes and price history. England and Wales | Monthly; data from 1995 | **Allowed.** Open Government Licence with an attribution statement; OGL "does not cover the use of third party rights" in address data | S-M (the app already uses PPD in area reports) | [LR-PPD], [LR-LD], [LR-OGL-NOTE] |
| 6 | **EPC register (new GOV.UK service)** | Floor area for a home (useful for the size filter) and, as a **weak** early signal, new certificates. The law says an EPC must be commissioned before a home is advertised to rent, but a certificate lasts ten years, so most re-lets reuse an old one. The old epc.opendatacommunities.org docs now redirect (301) to the new service | New lodgements daily to monthly (not stated on the page) | **Allowed.** "Open Government Licence v3.0, except where otherwise stated". API access needs a GOV.UK One Login account and a token (one open-source client uses a bearer token). Address licence caveats noted in the 11-10 doc | M | [EPC-NEW], [EPC-REDIRECT], [EPC-LAW], [GH-PROPSHARED] |
| 7 | **Agent websites' property sitemaps** (for example Linley & Simpson `properties.xml`; Reeds Rains sales and lettings sitemaps) | The agent's whole current stock in one file, sometimes before the portals (agents control portal delays; OTM priority uploads can hold portal copies back 24-72 hours, from a search summary only). Linley & Simpson's sitemap lists several hundred sale and rent pages across Yorkshire | Linley & Simpson entries all carried one timestamp (2026-11-06) when read on 2026-11-10, so the file may refresh in batches, not per listing | **Ask permission.** robots.txt allows general crawling of listing pages (Linley & Simpson blocks `/api/` and `/json/`; Reeds Rains sets a 1-second crawl delay and blocks GPTBot, Bytespider, Amazonbot, AhrefsBot from listing pages). No website terms page found for either. robots.txt is aimed at search engines, not permission for an app | M (one reader per agent website platform) | [LS-ROBOTS], [LS-SITEMAP], [LS-HOME], [RR-ROBOTS], [OTM-PRIORITY] |
| 8 | **Housing-association intermediate rent and rent to buy** | Below-market rents (about 80% of market) not always on CBL. Examples near Wakefield: Karbon Homes City Fields (rent to buy, shared ownership); Marsh Court key-worker intermediate rent at £700 pcm (date not shown) | Irregular | **Allowed** as links. Share to Buy (already linked) has an intermediate-rent section | S (add links) | [KARBON-CF], [STB-IR] |
| 9 | **PropertyData API** (paid) | A subset of portal listings matched to investor "sourcing" strategies, plus sold and rent data. It says: "If you need comprehensive listings data, you need to go to the portals directly" | "Real-time market snapshot" (its words); results may be kept 60 days | **Allowed** under its own licence, from £30 a month (2,000 credits). Photos are not licensed. Low value for finding a home to live in | S, plus cost | [PD-LICENCE], [PD-PRICING] |
| 10 | **Agent CRM feeds** (Reapit Foundations, Jupix, Street, Homeflow) | Clean, early data straight from an agent's system | Real time | **Ask permission** (from each agent and its software vendor). Reapit: approval needed, external apps must reach "at least £200.00 per month" in usage, and data may not be shared on. Jupix: per-agent client ID and passphrase; a third party says Jupix may charge. Street and Homeflow: API key per agency | L; not realistic for a personal app | [REAPIT-TERMS], [JUPIX-QLIK], [JUPIX-BOXPOD], [HOMEFLOW-GEM], [STREET-API] |
| 11 | **Portal partner APIs** (Zoopla, Rightmove, OnTheMarket, PropertyPal) | Would be ideal; none is open | n/a | **Forbidden / not available.** Zoopla's listings API is no longer public (search summary of its developer portal; the portal itself failed to load). Rightmove, OnTheMarket and PropertyPal feeds are for agents to **upload** listings, not to read them | n/a | [ZP-DEV], [ZP-API-TERMS], [RM-NOAPI], [OTM-FEEDS], [PP-API] |
| 12 | **Other aggregators** (Trovit, Mitula, Nestoria; all Lifull Connect) | Would add breadth | n/a | **Not available.** No UK publisher API found. A third party says Trovit Homes returns HTTP 401 to many IP ranges. Nestoria was unreachable on 2026-11-09 | n/a | [LIFULL], [TROVIT-401] |
| 13 | **Schema.org JSON-LD on agent pages** | Would make agent pages easy to read in a standard shape | n/a | Not verified. I found no evidence that UK agent website platforms (Starberry, Homeflow, Street) emit `RealEstateListing` markup. Treat as unknown | n/a | [SCHEMA-GUIDE] |
| 14 | **RSS feeds** | Would allow simple polling | n/a | None found for consumers. Rightmove's only RSS mention is an agent-facing feed from an account manager | n/a | [RM-RSS] |
| 15 | **Leeds council "bids and lettings" open data** | Not listings. Past bid counts per let, to show how competitive social homes are | Historic | Licence not checked | S | [LEEDS-BIDS] |

Already ruled out in earlier docs and not repeated: Gumtree and SpareRoom automation (forbidden or
enforced), Zoopla deep links, PrimeLocation, Home.co.uk automation.

### Notes on the strongest options

- **Why agent emails beat everything else for "earlier".** Agents control when portals get a home.
  Some send it to their own list first (Mumsnet sellers, March 2024). OnTheMarket sells agents a 24-hour
  head start, and the Rightmove news page records agent software that held portal uploads back "up to
  three days". The user's inbox is the only lawful place that sees the agent's first move. Jitty, a
  funded portal, chose the same route (December 2024 post). [MN-SKIP], [OTM-OWU], [RM-DELAY],
  [JITTY-PREMKT]
- **What the evidence does not show.** No source measures how many Leeds-Doncaster homes go to agent
  lists first. Mumsnet posters are split. Treat the gain as "some homes, a day or two early".
- **Agents to start with** (seen in the 11-09 doc and here; check each one has an email alert or
  applicant register): Linley & Simpson, Manning Stainton, Reeds Rains, Richard Kendall, Logic Lettings,
  Crown Estate Agents, Robson Estates, Move Maker, House Move Yorkshire, Bridgfords, Whitegates,
  Martin & Co.
- **Privacy.** Registering gives the agent the user's details. The app should show this before linking
  out, and suggest a separate email address or alias for property mail.
- **Price Paid Data match.** The linked-data API needs no key. A third party notes a 500-row cap and a
  full postcode per query (unverified). Use it per watched home, not in bulk.

## B. Public GitHub projects

"Compatible?" assumes the app becomes open source on GitHub. MIT, BSD and Apache-2.0: compatible.
LGPL: fine as a separate server, care if linked. GPL/AGPL: would force the app's licence. No licence
or not checked: do not copy code. Python and C++ projects cannot run inside the Flutter app; their
value is the method, or a separate helper. Brahma Watch runs on Cloudflare (JavaScript).

"Reference only" = it reads sites whose terms forbid automated reading. Learn from the structure; do
not reuse the site-reading code.

| Repo | Stars | Last updated | Licence | Language | Reuse value | Compatible? |
|---|---|---|---|---|---|---|
| **Listing de-duplication and address matching** | | | | | | |
| [moj-analytical-services/splink](https://github.com/moj-analytical-services/splink) | 2.6k | Splink 5 announced (blog dated 28 Sep 2026); commit date not shown | MIT | Python | Proven probabilistic record linkage (UK Ministry of Justice). Method for "same home on two sites": weights per field, term frequency for common street names | Yes (method; Python) |
| [moj-analytical-services/uk_address_matcher](https://github.com/moj-analytical-services/uk_address_matcher) | 82 | not shown (1,761 commits) | MIT | Python | Matches messy UK addresses to a reference list; no Ordnance Survey data needed. Useful to tie listings to EPC and Price Paid records | Yes (method; Python, DuckDB) |
| [dedupeio/dedupe](https://github.com/dedupeio/dedupe) | 4.5k | not shown | MIT | Python | Fuzzy matching and entity resolution with active learning | Yes (method) |
| [abracadabra50/open-properties](https://github.com/abracadabra50/open-properties) | 15 | Aug 11 (year not shown) | MIT | Python | Clear cross-portal merge rules: merge only on same ID or canonical URL; cross-site match on address, street tokens, postcode, beds, price; unclear cases go to `duplicate_candidates`. Snapshot diff ("yesterday vs today"). Its Rightmove/Zoopla readers are **reference only** | Yes for the rules |
| **Drawing a search area (flutter_map)** | | | | | | |
| [ibrierley/flutter_map_line_editor](https://github.com/ibrierley/flutter_map_line_editor) | 47 | pub.dev 8.0.0, published about 21 months ago | MIT | Dart | Create and edit polygons on flutter_map with draggable points. Listed in the flutter_map plugin list | Yes |
| [tdz4/flutter_map_polygon_editor](https://github.com/tdz4/flutter_map_polygon_editor) | 3 | Jul 11, 2025 | MIT | Dart | Polygon editor for flutter_map ^8.1.1: long-press to add, drag to move, drag a midpoint to insert; controller API. Very new, few users | Yes |
| [dartclub/turf_dart](https://github.com/dartclub/turf_dart) | 83 | not shown | MIT | Dart | `booleanPointInPolygon`, `simplify`, `area`, `polygonSmooth` are done (per its Progress.md). Filters homes inside a drawn area on device. No buffer or hull yet | Yes |
| [Wildhoney/Leaflet.FreeDraw](https://github.com/Wildhoney/Leaflet.FreeDraw) | 576 | May 8, 2025 | MIT | JavaScript | Freehand finger-drawn area to polygon: smooth, simplify (Clipper), concave hull, merge overlaps. Algorithm to port for a Rightmove-style "draw with your finger" | Yes (port) |
| [rorystephenson/flutter_map_supercluster](https://github.com/rorystephenson/flutter_map_supercluster) | 34 | not shown | BSD-3-Clause | Dart | Fast marker clustering for many homes on the map | Yes |
| [JaffaKetchup/flutter_map_tile_caching](https://github.com/JaffaKetchup/flutter_map_tile_caching) | not checked | not checked | GPL (per the flutter_map plugin list) | Dart | Offline map tiles | **Flag: GPL.** Use `flutter_map_cache` (josxha) instead if caching is needed; its licence was not checked |
| **Travel time and isochrones** (feature in progress; listed for reference only) | | | | | | |
| [valhalla/valhalla](https://github.com/valhalla/valhalla) | 6.4k | 3 hours ago (on 2026-11-10) | MIT | C++ | Routing, time-distance matrix and isochrones from OSM; public demo at valhalla1.openstreetmap.de | Yes (separate server) |
| [graphhopper/graphhopper](https://github.com/graphhopper/graphhopper) | 6.8k | 2 hours ago (on 2026-11-10) | Apache-2.0 | Java | Routing, `/isochrone`, and public transport from GTFS | Yes (separate server) |
| [Project-OSRM/osrm-backend](https://github.com/Project-OSRM/osrm-backend) | 8.2k | not shown | BSD-2-Clause | C++ | Fast car, cycle, walk routing and tables; no built-in isochrones (see archived [mapbox/osrm-isochrone](https://github.com/mapbox/osrm-isochrone), 131 stars, Jan 20, 2018) | Yes (separate server) |
| [opentripplanner/OpenTripPlanner](https://github.com/opentripplanner/OpenTripPlanner) | 2.8k | not shown | LGPL-3.0 (from `lgpl-3.0.txt`) | Java | Bus and train journey planning | Yes as a separate server; **flag LGPL** if embedded |
| [routingpy/routingpy](https://github.com/routingpy/routingpy) | 351 | Sep 1 (year not shown) | Apache-2.0 | Python | One client for OSRM, Valhalla, GraphHopper, openrouteservice, OTP2. Shows a clean common interface across engines | Yes (method) |
| [traffordDataLab/leaflet.reachability](https://github.com/traffordDataLab/leaflet.reachability) | 69 | Aug 13 (year not shown) | MIT | JavaScript | UI pattern for "reachable within N minutes" overlays (calls openrouteservice, needs a key) | Yes (UI idea) |
| **Open data clients (Price Paid, EPC, all-in-one)** | | | | | | |
| [paulieb89/property-shared](https://github.com/paulieb89/property-shared) | 18 | Sep 4 (year not shown) | MIT | Python | Land Registry comparables, EPC client (bearer token), block analyser for flats, yield sums. Its Rightmove and planning-portal readers are **reference only** | Yes for PPD/EPC parts |
| [dalepotter/uk_property_price_data](https://github.com/dalepotter/uk_property_price_data) | 18 | Oct 30, 2016 | not checked | none listed | Notes on loading Price Paid CSVs. Old | Unknown |
| [dhfwc18/epc-connector](https://github.com/dhfwc18/epc-connector) | 0 | 17 days ago | not checked | Python | Downloads and merges EPC data. Very new, no users | Unknown |
| [eco-watch/ecolookuptool](https://github.com/eco-watch/ecolookuptool) | 2 | Mar 1, 2023 | not checked | JavaScript | Front end for the old EPC API (now redirected) | Unknown; likely out of date |
| **Floor area from floor plans** | | | | | | |
| [VibeYolk/rightmove-property-details](https://github.com/VibeYolk/rightmove-property-details) | 0 | 4 days ago | not checked | JavaScript | Browser extension with optional local floor-plan OCR | Unknown; reads Rightmove pages: **reference only** |
| [Nedoko-maki/Rightmove-Webscraper](https://github.com/Nedoko-maki/Rightmove-Webscraper) | 0 | Mar 30, 2022 | not checked | Python | Tesseract OCR on Rightmove floor plans to get size | Unknown; **reference only** |
| **Alert bots and scrapers** (all **reference only**) | | | | | | |
| [toby-p/rightmove_webscraper.py](https://github.com/toby-p/rightmove_webscraper.py) | 282 | Dec 27, 2023 | MIT | Python | Best-known UK listing scraper. Its README says "the use of webscrapers is unauthorised by rightmove" and asks people not to use it | MIT, but **reference only** |
| [afspies/homehunt](https://github.com/afspies/homehunt) | 1 | Jul 19, 2025 | MIT | Python | Cross-portal dedup with a 24-hour window; TravelTime commute filter; Telegram alerts every 5 minutes. Uses Firecrawl and direct reads of Rightmove/Zoopla | MIT, **reference only** |
| [fcaponetto/RightMoveScraper](https://github.com/fcaponetto/RightMoveScraper) | 6 | Aug 29, 2024 | not checked | Python | New-listing alerts to Telegram | Unknown; **reference only** |
| [afiodorov/openrent](https://github.com/afiodorov/openrent) | 8 | Aug 25, 2018 | not checked | Python | Slack alerts for new OpenRent listings. OpenRent terms ban harvesting | Unknown; **reference only** |
| [AnthonyBloomer/zoopla](https://github.com/AnthonyBloomer/zoopla) | 89 | not shown | **none shown** | Python | Wrapper for the old Zoopla API, which is no longer public | **No** (no licence; dead API) |
| **Agent feed formats** (only if an agent agrees to share its feed) | | | | | | |
| [stilliard/blmreader](https://github.com/stilliard/blmreader) | 24 | May 8, 2020 | not checked | PHP | Reads Rightmove BLM files, the bulk format many agent systems export (OTM also accepts BLM v3.5.1) | Unknown |
| **Schools** | | | | | | |
| [aghatem/UK_School_checker](https://github.com/aghatem/UK_School_checker) | 2 | Jun 25, 2023 | not checked | Python | Nearby schools from a postcode with Ofsted grade and travel time. Ofsted moved to report cards in Nov 2025, so old grades are out of date | Unknown; thin |

What GitHub does **not** have: no maintained, licensed library for extracting floor area from UK floor
plans; no open parser for UK portal or agent alert emails; no maintained EPC client for the new GOV.UK
service. Those parts the app must write itself. The app already has on-device OCR, so floor area is a
text-pattern job (for example "Total area ... sq ft / sq m") on the OCR output.

## C. Top recommendations

1. **Agent emails into Brahma Watch.** Add a "Local agents" list (Leeds to Doncaster) with each
   agent's alert sign-up link, a privacy note, and a tip to use a separate address. Make Watch's email
   parser generic: pull links, price, beds, postcode from any agent email, then dedupe against portal
   homes. Lawful, and the only route with evidence of homes arriving earlier. Effort S-M.
2. **Tune the alert route already built.** Make sure OnTheMarket alerts parse (24-hour head start on
   "Only With Us" homes) and tell users to set Rightmove and OnTheMarket alerts to "instantly". Effort S.
3. **Social-housing week planner.** A weekly reminder for Vico (Wednesday 10:05) and Doncaster
   HomeChoice (Wednesday about 17:00 to Sunday 23:59), with links. Confirm the Leeds cycle on the Leeds
   Homes site before adding it. Effort S.
4. **Close the loop with Price Paid Data.** For a watched or shortlisted home that goes "sold STC",
   look it up monthly and show the sale price when it lands. Effort S-M.
5. **EPC for size, not for discovery.** Use the new EPC service for floor area (feeds the size filter);
   do not rely on EPC lodgements as a "new listing" signal. Store the token in the keystore or Watch.
   Effort M.
6. **Ask, then maybe read, agent sitemaps.** Email three or four big local agents (Linley & Simpson,
   Reeds Rains, Manning Stainton) asking whether a personal app may read their property sitemap once
   a day. Build a reader only for those who say yes. Effort M.
7. **Do not pursue:** Reapit/Jupix/Street/Homeflow feeds (cost and per-agent consent), PropertyData
   (paid, partial), Zoopla API (closed), Trovit/Mitula/Nestoria (no API, blocking), RSS (none).

For code: take the dedup rules from open-properties and the field-weighting idea from Splink; use
flutter_map_line_editor or flutter_map_polygon_editor with turf_dart for draw-a-search, and port
Leaflet.FreeDraw's smoothing for freehand drawing; Valhalla (MIT) or GraphHopper (Apache-2.0) for
self-hosted travel time. Avoid flutter_map_tile_caching (GPL) and any repo with no licence.

## Sources

Listing sources
- [JITTY-PREMKT] https://jitty.com/post/get-ahead-of-the-game-jittys-new-pre-market-feature-gives-buyers-early-access-to-homes (17 Dec 2024; East and North London only at launch)
- [MN-SKIP] https://www.mumsnet.com/talk/property/5036283-is-it-common-for-properties-to-skip-the-rightmove-stage (25 Mar 2024, 36 replies; reply dates not shown)
- [MN-SKIP-SUM] Mixed views (agent emails half a day to three days early; registering useless) from a search summary of https://www.mumsnet.com/talk/property/4703892-how-common-is-it-for-houses-to-sell-without-making-it-to-rightmove and https://forums.moneysavingexpert.com/discussion/5615300/how-do-people-buy-houses-before-they-hit-rightmove-etc (not opened; dates unknown)
- [OTM-OWU] https://onthemarket.com/only-with-us
- [OTM-LEAFLET] https://expert.onthemarket.com/vendor-leaflet-2026 (search summary; OTM's own figures)
- [OTM-PRIORITY] https://helpcentre.10ninety.co.uk/hc/en-gb/articles/360025387454--New-Exclusive-Listings-at-On-The-Market and https://webdadi.atlassian.net/wiki/spaces/PKB/pages/771096581 (both unreadable; 24/48/72-hour options from search summary only)
- [OTM-FEEDS] https://expert.onthemarket.com/help-centre/realtime-vs-blm/ (search summary)
- [RM-INSTANT] https://www.rightmove.co.uk/news/articles/property-news/if-youre-looking-to-rent-get-in-first-with-instant-alerts ; https://customerfaq.rightmove.co.uk/support/solutions/articles/7000098933-how-the-property-alerts-work (search summary)
- [RM-RELIST] https://customerfaq.rightmove.co.uk/support/solutions/articles/7000055339-i-want-one-of-my-properties-to-go-back-out-in-the-property-alerts (search summary)
- [PIE-INSTANT] https://propertyindustryeye.com/public-rushes-take-rightmoves-new-high-speed-service/ (older trade article; search summary)
- [RM-DELAY] A Rightmove news item quoted in a search summary for "Rightmove instant alerts delay" (agents' listings "delayed for up to three days"; some software built "a 48 hour delay switch" for OnTheMarket). Exact URL not confirmed and the item is undated; treat as thin
- [RM-RSS] https://propertyindustryeye.com/rightmove-gets-ready-to-shut-down-its-overnight-data-feed/ (search summary)
- [RM-NOAPI] https://providers.apievangelist.com/providers/rightmove/ and https://dev.to/devil_scrapes/rightmove-scraper-pull-uk-property-data-to-json-for-0002listing-5h1n (secondary sources)
- [ZP-DEV] https://developer.zoopla.co.uk/ (certificate error on fetch); https://providers.apievangelist.com/providers/zoopla/ (search summary: listings API "no longer publicly available")
- [ZP-API-TERMS] https://developer.zoopla.co.uk/API_terms_of_use (search summary)
- [PP-API] https://apidocs.propertypal.com/docs/introduction.md ; https://www.propertypal.com/faq/property-listingsproperty-listings/can-i-set-up-a-feed-to-upload-our-propertiescan-i-set-up-a-feed-to-upload-our-properties (search summary)
- [REAPIT-TERMS] https://foundations-documentation.reapit.cloud/developer-terms-and-conditions (read; version 1 Dec 2025)
- [JUPIX-QLIK] https://community.qlik.com/t5/Talend-Studio/XML-FEED-Web-service/td-p/2204998 (search summary)
- [JUPIX-BOXPOD] https://www.boxpodcommercialproperty.co.uk/integrations/jupix (search summary)
- [HOMEFLOW-GEM] https://developer.homeflow.co.uk/homeflow-api-gem (search summary)
- [STREET-API] https://developers.street.co.uk/ (page text not readable)
- [PD-LICENCE] https://propertydata.co.uk/api/documentation/licensing (read)
- [PD-PRICING] https://propertydata.co.uk/api/pricing (read)
- [LR-PPD] https://www.gov.uk/government/statistical-data-sets/price-paid-data-downloads
- [LR-LD] https://landregistry.data.gov.uk/ (search summary: monthly, SPARQL)
- [LR-OGL-NOTE] https://wired-gov.net/wg/news.nsf/print/October+2017+Price+Paid+Data+29112017155304 (third-party rights note)
- [EPC-NEW] https://get-energy-performance-data.communities.gov.uk/ (read)
- [EPC-REDIRECT] https://epc.opendatacommunities.org/docs/api (301 to the new service on 2026-11-10)
- [EPC-LAW] https://www.bristol.gov.uk/ntslat/letting-agency/energy-performance-and-efficiency ; https://www.landlordsguild.com/?p=46670 (search summary)
- [LS-ROBOTS] https://www.linleyandsimpson.co.uk/robots.txt (read)
- [LS-SITEMAP] https://www.linleyandsimpson.co.uk/properties.xml (read first 100,000 characters)
- [LS-HOME] https://www.linleyandsimpson.co.uk/ (footer: privacy policy, no terms of use found)
- [RR-ROBOTS] https://www.reedsrains.co.uk/robots.txt (read; terms page not found)
- [VICO-RENT] https://www.vicohomes.co.uk/find-a-home/homes-to-rent/ (read)
- [WAK-CBL] https://www.wakefield.gov.uk/housing/finding-a-new-home/what-is-choice-based-lettings (search summary)
- [DON-FAQ] https://www.stlegerhomes.co.uk/find-a-home/doncaster-homechoice/frequently-asked-questions/ (search summary)
- [DON-2023] https://tenantportal.stlegerhomes.co.uk/siteassets/images/FINAL%20Allocation%20Policy%20Guide%20June%202023.pdf (search summary)
- [LEEDS-NEWBUILD] https://yourvoice.leeds.gov.uk/kitchens-tarnside-mardale (search summary)
- [LEEDS-BIDS] https://www.data.gov.uk/dataset/6ae9e84d-5aee-43cb-8b17-8a2d2198ac4f/council-house-bids-and-lettings
- [KARBON-CF] https://karbonhomes.co.uk/find-a-home/new-homes/cityfields-wakefield (search summary; undated)
- [STB-IR] https://www.sharetobuy.com/guides-and-faqs/intermediate-rent/
- [LIFULL] https://lifull.com/en/ir/ar/annual-report-202309/business-overseas/ (search summary)
- [TROVIT-401] https://apify.com/rainminer/trovit-homes-scraper (third-party claim)
- [SCHEMA-GUIDE] https://hauteliving.com/realestate/insights/real-estate-listing-schema (general guide; no UK platform evidence)

GitHub and package pages (all read on 2026-11-10)
- Search pages: https://github.com/search?q=rightmove&type=repositories&s=stars&o=desc ; https://github.com/search?q=zoopla&type=repositories&s=stars&o=desc ; https://github.com/search?q=rightmove+telegram&type=repositories ; https://github.com/search?q=openrent&type=repositories ; https://github.com/search?q=isochrone&type=repositories ; https://github.com/search?q=routing+engine+openstreetmap&type=repositories ; https://github.com/search?q=%22price+paid%22+land+registry&type=repositories ; https://github.com/search?q=ofsted+schools&type=repositories ; https://github.com/search?q=energy+performance+certificate+uk&type=repositories&s=updated ; https://github.com/search?q=rightmove+floorplan&type=repositories ; https://github.com/search?q=floorplan+ocr&type=repositories ; https://github.com/search?q=flutter_map+polygon+editor&type=repositories ; https://github.com/topics/house-hunting
- flutter_map plugin list: https://docs.fleaflet.dev/plugins/list
- pub.dev: https://pub.dev/packages/flutter_map_line_editor ; https://pub.dev/packages/flutter_map_polygon_editor
- turf_dart progress: https://raw.githubusercontent.com/dartclub/turf_dart/main/Progress.md
- [GH-PROPSHARED] https://github.com/paulieb89/property-shared
- Repo pages linked in table B.
