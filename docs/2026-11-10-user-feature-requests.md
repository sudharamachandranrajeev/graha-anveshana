# What UK home-hunters like, ask for and hate in property apps (2026-11-10)

Builds on [2026-11-05-feature-research.md](2026-11-05-feature-research.md) and
[2026-11-09-uk-property-sites.md](2026-11-09-uk-property-sites.md). Those found the stale-listing,
agent-silence, data-selling and valuation complaints, and the portal terms. This file does not repeat
them. It looks for features users ask for that the app does not have yet.

## 0. Limits of the evidence

- **Reddit is still blocked** for the search and fetch tools. Two Reddit items were read another way:
  one r/HousingUK post through a third-party snapshot site, and an r/HousingUK "useful websites" list
  that a Mumsnet user copied. Upvotes are given only where the snapshot showed them.
- **The best single source is a Mumsnet thread**, "What extra filters would you like Rightmove to
  offer?" (10 June 2026, 118 replies). I read the first two pages (about 50 replies). Counts below are
  posters on those pages only, not the whole thread.
- **Chrome Web Store pages** sit behind a Google consent wall. Extension user counts and ratings come
  from search-result summaries, not the store page. They are marked "unverified".
- **App Store review pages** show mostly 2019-2025 reviews. Each is one person's view.
- **Hacker News** had almost nothing: one 2026 comment on Rightmove's print view. GitHub
  house-hunting tools have very few stars (0 to 19, except one 282-star scraper). Treat both as weak
  signals of what builders think users want.
- **Vendor claims** (alert speed, usage numbers) are marked as the vendor's own claims.
- **Abroad:** I found feature lists for Zillow, Redfin, realestate.com.au, Domain and Funda, but very
  little user text. Only one 2026 editorial round-up of US app reviews (Unstar) gave themes and
  quotes. It is an editorial summary, not raw reviews.

## 1. Already in the app (checked in README, CHANGELOG and `lib/`)

Not proposed again: plain-words search with "-word" exclusions (`-retirement` is the hint in
`searches_page.dart`), sort, map, saved searches, "For you", Shortlist stages, Collections (these
already keep a price history per item in `fields`), Areas (prices, crime, flood, links), rent
fairness, advert wording check, compare with council tax and bills, viewing checklist, contact log
with a four-day no-reply flag, distances (straight line) to your places, a "Directions and travel
time" link-out on the map, Trash, Watch alerts for new homes and price drops, let/sold notices, sync,
app lock, More sites links (SpareRoom, social housing, Share to Buy, auctions).

## 2. Ranked candidate features (not in the app yet)

Evidence: **strong** = several independent sources, including user text from 2023-2026; **medium** =
two or three sources, or strong signal from builders and portals but little user text; **thin** = one
source or vendor claims only. Effort is for this Flutter app with its current Watch worker: S = days,
M = one to two weeks, L = more.

| # | Feature | What users say (1 line) | Evidence | Example links | Effort | ToS / privacy / security flag |
|---|---|---|---|---|---|---|
| 1 | **Floor area and £ per sq ft / m² on every home, plus a minimum-size filter.** Read the size from the floor plan text or the advert; fall back to the EPC register's floor area; show "size unknown" honestly | "Square footage! Ridiculous that it isn't included"; some "4/5 bedroom houses are only the same size as our current 3 bed" | **Strong**: 5 posters across 2 pages of the 118-reply Mumsnet thread (Jun 2026); MSE "any websites allow filtering by internal area"; Overclockers "home search by size"; Mumsnet tools thread recommends EPC for floor area and Housemetric for £/m²; many extensions (SquareCalc, PropertyData) and Rightmove's own area £/m² tool exist | [MN-FILTERS], [MN-FILTERS-2], [MSE-AREA], [OCUK-SIZE], [MN-TOOLS], [SQCALC], [RM-PSQM] | M | EPC API needs a registered account and API key: a stored credential. Keep it in the Watch worker or the OS keystore, never in sync. EPC docs say address data may need a Royal Mail licence. Agents sometimes inflate floor plan sizes (PropertyData), so label the source |
| 2 | **Price history, days on market and "relisted" flag on every Search card and Shortlist home.** Record first seen, each price change and status change the app itself sees; show "reduced 3 times, 94 days"; flag a home that comes back as "new" | Property Log (Rightmove price history) called "absolutely invaluable"; complaints when it went behind a paywall; "relisted a house as 'new' after 1 day off-market ... app should flag it" | **Strong**: Property Log ~100k users and 3.4 stars (unverified, from search summary); at least 4 rival extensions (Property Tracker, Property Price History, PaTMa, Area360) say they fill this gap; Zoopla's own "property timeline" is a praised feature; hidden price history is 7% of US app complaints (Unstar) | [MN-HIDE], [MN-TOOLS], [PLOG-SEARCH], [AREA360], [ZP-TIMELINE], [UNSTAR], [RD-RELIST] | S-M (Collections already store a history; Watch already sees drops) | Build history only from what this app saw. Do not import crowd-sourced data from Property Log and similar (their data, and one scanner flagged Property Log as "could be malicious", unverified) |
| 3 | **Real travel time, not straight-line distance, to each of your places, and a "within 30 min" filter.** Car, cycle and walk first; bus and train later. Allow more than one place at once | "within xx mins drive of a location"; "proximity to stations"; Zoopla and rivals "only allow you to search for commute times to one address" | **Medium**: 3 Mumsnet posters (Jun 2026); 5 indie GitHub tools build exactly this (HouseSpotter, HomeHunt, distributed-commuting, rightmove-filtering, house-prices); Rightmove, Zoopla, Share to Buy, Foxtons all bought commute search; commute ranked first (33%) in one Santander-linked survey | [MN-FILTERS], [MN-FILTERS-2], [GH-HOUSESPOTTER], [GH-MW], [RM-COMMUTE], [TT-CASES], [SURVEY-COMMUTE] | M (car/walk/cycle); L (public transport) | Routing services (OpenRouteService, TravelTime) need an API key: a credential. Sending home and "work"/"family" coordinates to a third party leaks where the user lives and works. Prefer a self-hosted router in the Watch worker or on-device; never send names of places |
| 4 | **Draw your own search area on the map and save it** | Rightmove calls Draw-a-Search one of its "most-loved" tools; a user complained when the app lost it ("no way to draw a search area"); Redfin's draw tool is called the best in its category "when working" | **Medium-strong**: Rightmove's own pages (over 1 million drawn areas, older figure); unitQ Rightmove user feedback (Feb 2025); Unstar Redfin praise; Rightmove saved drawn areas need a login and are not on its app (a gap) | [RM-DRAW], [RM-DRAW-HELP], [UNITQ-SUM], [UNSTAR] | M | None. Keep the polygon on device; Watch needs it to filter results |
| 5 | **Proper tick-box "must have" and "never show" filters, detected from the advert text, with an "unknown" state.** Garage, driveway, parking spaces, garden size, garden facing, bathrooms, en suite, floor plan present, floor level; never show retirement, shared ownership, park/holiday homes, auction, cash buyers only | "Absolute filter for garage - no garage, don't show it to me"; "Filter out houses with no floor plans!"; "half the retirement properties aren't filtered out"; "I would like the house type filters to work" | **Strong**: about 25 distinct filter wishes from about 40 posters on 2 pages (Mumsnet, Jun 2026); App Store (Rightmove 2023: "filter results on loads of different options"; Zoopla 2024: terraced homes in a detached search) | [MN-FILTERS], [MN-FILTERS-2], [RM-APPSTORE], [ZP-APPSTORE] | S-M (the word exclusion exists; this adds named filters and better detection) | None |
| 6 | **Leasehold true cost for buyers**: service charge, ground rent and years left on the lease, folded into the monthly figure, with a "missing from the advert" warning | Listings often leave these out; council tax band is a hard limit for some ("It ought to be Band B at most") | **Medium**: HomeOwners Alliance review of 150 leasehold listings: 62% gave service charge, 49% ground rent, 78% lease length (year not confirmed); gov.uk material-information consultation (2025) says about 10% of listings lack basics such as cost and tenure; Rightmove added these fields | [HOA-LEASE], [GOV-MATINFO], [RM-MATINFO], [MN-FILTERS-2] | S | Show as information, not legal advice. Short leases (under about 80 years) need a solicitor; say so |
| 7 | **Share a Shortlist or Collection with a partner or housemates**, each rating and commenting, with "you both liked" shown first | Rightmove built Shared Lists because users "requested it often"; its CTO says most movers live with at least one other person | **Medium**: Rightmove launch (Nov 2025); several small tools for couples and sharers (Land a House, Homeseek, TwoKeys, Crowdhaus; Wahi in Canada shows homes both partners like) | [PIE-SHARED], [LANDAHOUSE], [HOMESEEK], [COUPLES-SEARCH] | M-L | Shared data includes notes, contact logs and the user's details. Keep it end-to-end encrypted in Brahma sync; invite links must expire; let the owner choose what is shared (never Profile places or enquiry template by default) |
| 8 | **More area checks on a home**: nearby schools with Ofsted outcome, road and rail noise, broadband and mobile signal, sun and garden direction, coal mining and radon | The r/HousingUK "useful websites" list and a Mumsnet tools thread both list noise, sun, schools, broadband and flood; posters ask for garden direction and "proximity to an A road or motorway" | **Medium**: copied r/HousingUK list (date unknown); Mumsnet tools thread (Nov 2023, 41 replies); 3 Mumsnet posters on garden aspect and roads (Jun 2026); surveys: 84% of parents put catchment first (parents only), broadband ranked above schools in an older Rightmove survey | [MN-TOOLS], [MN-TOOLS-2], [MN-FILTERS], [MN-FILTERS-2], [SURVEY-SCHOOL], [SURVEY-BB] | M (each data set S-M) | Schools (GIAS, Ofsted MI) are OGL v3 with attribution. Ofsted moved to report cards from Nov 2025, so do not show old one-word grades as current. Catchment areas are not open data: say "nearby", never "in catchment". Ofcom coverage API needs a key. Check noise-map and coal/radon licences before bundling |
| 9 | **"Suspect stale" badge and a report button**: under offer or sold STC for over six months, listed for months with no change, back on the market after "let agreed"; tap to report it to the site | Stale and wrongly listed homes are the top complaint everywhere; "you can't even report these false or inaccurate listings on the app"; "a button to flag inaccuracies" | **Strong** for the problem (also in the 11-05 doc); stale listings are 23% of US app complaints (Unstar); Rightmove's own rule removes SSTC/under offer after 6 months; r/HousingUK post (14 points) about a house relisted after exchange | [UNSTAR], [RM-6MONTH], [NEG-SSTC], [RD-RELIST], [ZP-APPSTORE], [RM-APPSTORE] | S | Reporting must open the site's own report page for the user to send. Do not auto-submit |
| 10 | **Viewing day planner**: put booked viewings in the phone calendar (.ics), warn on clashes, order a day's viewings into a route | Australian portals build an "inspection planner" into the shortlist; Land a House adds clash warnings; Redfin is praised for easy viewing booking | **Thin-medium**: feature exists in realestate.com.au, Domain, Allhomes, but I found no user praise text; Capterra Redfin reviewers praise scheduling | [REA-PLANNER], [DOMAIN-PLANNER], [ALLHOMES-PLANNER], [LANDAHOUSE], [CAPTERRA-RF] | S-M | Calendar permission on the phone. Keep the agent's phone number out of shared calendars |
| 11 | **Offer helper for buyers**: comparable sold £/sq ft nearby, days on market and reductions, giving a reasoned offer range | "Is this a divorce, bankruptcy or ... probate so I can get a good deal"; price history is used to judge how keen a seller is | **Thin-medium**: 1 Mumsnet poster; indirect from item 2 demand; Zoopla tells agents to cut prices on slow listings | [MN-FILTERS-2], [ZP-AGENT-REPORT], [PLOG-SEARCH] | M (after items 1 and 2) | Label "comparables, not a valuation" (11-05 doc rule). Not financial advice |
| 12 | **Faster rental alerts** (minutes, not hours) for the busiest searches | Vendors say portal emails arrive hours late; good flats can let within hours | **Thin**: vendor claims only (Dwellio "every 35 seconds"; Rental Radar "up to 12 hours before" portal emails, 20 Trustpilot reviews, mostly 2023); one London flat let in 40 minutes (press) | [DWELLIO], [RR-TP], [PIE-40MIN] | S (Watch schedule) | **High ToS risk.** More frequent automated reads of Rightmove, OnTheMarket, Zoopla, SpareRoom break their terms and invite blocking. Only consider for sites that allow it; otherwise keep the current pace |
| 13 | **Agent and landlord track record from your own log**: per agent, how often they replied, average reply time, homes "ghosted"; link to Marks Out Of Tenancy | London renters rated "investigate bad landlords and agents" 9.3 out of 10 in importance | **Thin**: one London renters survey (older), Generation Rent page | [LDN-RENTERS], [MOOT] | S (the contact log exists) | Keep private. Sharing ratings of named agents risks defamation claims; do not publish them |
| 14 | **Photo viewer polish**: landscape full screen, jump back to the first photo, floor plan as its own tab | "you have to go all the way back through every photo"; landscape photos were a top request to Zoopla | **Thin**: 2-3 App Store reviews, 2019-2024 | [RM-APPSTORE], [ZP-APPSTORE] | S | None |

Ranking logic: items 1, 2 and 5 have the most user text and reuse what the app already reads. Items 3
and 4 are wanted and well proven by portals but need new map or routing work. Items 6 to 9 are cheap
wins for buyers. Items 10 to 14 are thinner or carry risk.

## 3. Most liked things about the top apps

- **Rightmove**: the biggest stock; Draw-a-Search ("one of our most-loved tools", by Rightmove's own
  account); sold prices for every street; notes and hide on adverts; new Shared Lists (Nov 2025);
  AI Keywords (rolled out Nov-Dec 2025). [RM-DRAW], [PIE-SHARED], [RM-AIKW]
- **Zoopla**: the property timeline (past listings and sales of a home), sold prices matched to old
  adverts with photos and floor plans. [ZP-TIMELINE], [MSE-SOLD]
- **OpenRent**: no agent fees, direct to landlord (Trustpilot 4.4, 8,744 reviews in the 11-05 doc).
- **SpareRoom**: helpful staff; "useful that you can message people before you give out any details"
  (Trustpilot 4.5-4.7, 21,176 reviews, Nov 2026). [SR-TP]
- **Jitty**: natural-language search; Jitty says 75% of its users search in plain words (its own
  figure); Product Hunt reviews call it "magical" (only 3 reviews). [JITTY-PH], [JITTY-500K]
- **Price-history extensions** (Property Log, Property Tracker, PaTMa, Area360): every price change on
  a Rightmove advert. [PLOG-SEARCH]
- **Redfin**: draw-your-area, fresher listing status and faster alerts, easy viewing booking.
  **Trulia**: neighbourhood overlays (crime, commute). **Zillow**: many photos, 3D tours, mortgage
  sums. [UNSTAR], [CAPTERRA-RF]
- **realestate.com.au / Domain**: inspection planner tied to the shortlist. [REA-PLANNER],
  [DOMAIN-PLANNER]

## 4. Most hated things (avoid these)

| Hated | Evidence | Links |
|---|---|---|
| Stale listings: sold or let homes still shown, relisted as "new" | Top theme in 11-05 doc; 23% of US app complaints; r/HousingUK post; Henry Pryor calls SSTC listings "hugely annoying" | [UNSTAR], [NEG-SSTC], [RD-RELIST] |
| Agent spam and lead selling after one click | 18% of US complaints ("Saved one search ... got 14 agent calls in 3 days"); Zoopla 1-star reviews in 11-05 doc | [UNSTAR] |
| Wrong automatic valuations | 15% of US complaints; Zoopla "devalued my house by £88k" | [UNSTAR], [ZP-APPSTORE] |
| Paywalls on basics | Property Log prices "always blurred" unless you pay; SpareRoom's 7-day early-bird rule confuses users | [PLOG-SEARCH], [SR-TP] |
| Redesigns that remove features | "If it isn't broken, don't 'fix' it" (Rightmove, Jul 2025); "Where has the 'search here' button gone"; sold prices and draw search vanished after an update (Feb 2025) | [RM-APPSTORE], [UNITQ-SUM] |
| Filters that do not work | terraced homes in a detached search; retirement homes slip through keyword filters; US: "Set max price $600K ... feed showed $700K houses" | [ZP-APPSTORE], [MN-FILTERS-2], [UNSTAR] |
| Wrong map pins | 11% of US complaints ("the pin was on the highway") | [UNSTAR] |
| Being profiled | Zoopla user "cautious about how it's being used to create profiles" | [ZP-APPSTORE] |
| No way to report a false advert | Zoopla (2024), Rightmove (2021) App Store reviews | [ZP-APPSTORE], [RM-APPSTORE] |
| Basic features behind a login | Rightmove: saved drawn areas need My Rightmove and are not on the app | [RM-DRAW-HELP] |

Design rules that follow: never sell or share data; never remove a feature without a setting to keep
it; show "unknown" rather than guessing; keep every figure's source visible; no paywall on core
search.

## 5. Security and privacy flags in one place

1. **API keys** (EPC, routing, Ofcom): credentials. Store in the OS keystore or the user's own Watch
   worker. Never sync them in plain text and never ship a shared key inside the app.
2. **Travel time** sends coordinates of the home and the user's places to a routing service. That
   reveals home and work. Prefer self-hosted or on-device routing.
3. **Shared lists** expose notes, contact logs and personal details to others. Keep end-to-end
   encryption, expiring invites, and an explicit "what is shared" choice.
4. **Faster polling** of portals breaks their terms (see 11-05 and 11-09 docs). Do not raise the pace.
5. **Crowd price-history data** from browser extensions is not ours to use; one extension was flagged
   by a scanner (unverified). Build history only from what the app sees.
6. **Agent ratings**: keep private to avoid defamation.
7. **Schools**: do not claim catchment; Ofsted grades changed in Nov 2025.

## 6. Sources

- [MN-FILTERS] https://www.mumsnet.com/talk/_chat/5540747-what-extra-filters-would-you-like-rightmove-to-offer (10 Jun 2026, 118 replies; page 1 read)
- [MN-FILTERS-2] https://www.mumsnet.com/talk/_chat/5540747-what-extra-filters-would-you-like-rightmove-to-offer?page=2 (page 2 read)
- [MN-TOOLS] https://www.mumsnet.com/talk/property/4935470-tools-for-house-buyers (4 Nov 2023, 41 replies)
- [MN-TOOLS-2] https://www.mumsnet.com/talk/property/4935470-tools-for-house-buyers?page=2 (contains a copy of the r/HousingUK useful-websites list)
- [MN-HIDE] https://www.mumsnet.com/talk/property/4957448-rightmove-has-added-a-hide-ad-feature-bonus-feedback-if-its-overpriced-sold-fraudulent-etc (5 Dec 2023, 24 replies)
- [MSE-AREA] https://forums.moneysavingexpert.com/discussion/6168997/any-websites-allow-filtering-by-internal-area (title and search summary only)
- [MSE-SOLD] https://www.moneysavingexpert.com/mortgages/free-house-prices (MSE guide; search summary)
- [OCUK-SIZE] https://forums.overclockers.co.uk/threads/home-search-by-size.18629788 (older; search summary)
- [RD-RELIST] r/HousingUK "House went back on Rightmove week of completion", 14 points, 16 comments, via snapshot https://reddit.sentinel-team.org/posts/1rqatoy/snapshots/2026-03-11T03%3A16%3A34.475398Z (third-party mirror)
- [PLOG-SEARCH] https://chromewebstore.google.com/detail/property-log/jccihedpilhidcbkconacnalppdeecno (consent wall; figures from search summaries, unverified); https://alternativeto.net/software/property-log/about (freemium, $4/month); https://extensionauditor.com/scan/property-log-jccihedpilhidcbkconacnalppdeecno (403 on fetch; "could be malicious" flag from search summary, unverified)
- [AREA360] https://area360.uk/blog/13-rightmove-price-history (403 on fetch; search summary) and Show HN https://news.ycombinator.com/item?id=42823484 (2 points)
- [SQCALC] https://chromewebstore.google.com/detail/gdcgkgemddcjnljiojikojjaeamikdan (search summary)
- [RM-PSQM] https://thenegotiator.co.uk/news/online-tool-launched-today-is-first-to-provide-per-square-metre-house-prices/
- [ZP-TIMELINE] https://help.zoopla.co.uk/hc/en-gb/articles/360018069878 (search summary)
- [ZP-AGENT-REPORT] https://support.zoopla.co.uk/hc/en-gb/articles/360004485898 (search summary)
- [UNSTAR] https://unstar.app/blog/zillow-redfin-realtor-trulia-home-search-apps-ranked-2026 (24 Apr 2026; editorial summary of US app reviews)
- [UNITQ-SUM] https://unitq.com/unitq-scorecards/rightmove (score 40, Nov 2026; the Feb 2025 user quotes came from a search summary and were not on the fetched page)
- [RM-APPSTORE] https://apps.apple.com/gb/app/rightmove-property-search/id323822803?see-all=reviews (4.8, 179k ratings; reviews 2020-2025)
- [ZP-APPSTORE] https://apps.apple.com/gb/app/zoopla-property-search-uk/id380932800?see-all=reviews (4.7, 191k ratings; reviews 2019-2025)
- [RM-DRAW] https://www.rightmove.co.uk/news/articles/dream-properties/how-do-you-use-draw-a-search ; https://www.propertyreporter.co.uk/property/rightmove-launches-draw-a-search.html
- [RM-DRAW-HELP] https://faq.rightmove.co.uk/support/solutions/articles/7000048757-draw-a-search
- [RM-COMMUTE] https://www.rightmove.co.uk/news/?p=24534
- [TT-CASES] https://traveltime.com/case-study/rightmove-property-poi-search-traveltime ; https://traveltime.com/case-study/jitty-property-search-traveltime-h3 ; https://theintermediary.co.uk/?p=74969 (Share to Buy)
- [GH-HOUSESPOTTER] https://github.com/Gman0909/HouseSpotter (0 stars); https://github.com/afspies/homehunt ; https://github.com/harrychurchley/distributed-commuting
- [GH-MW] https://github.com/matthewweaver/house-prices (2018)
- [SURVEY-COMMUTE] https://mortgagesoup.co.uk/brits-pay-extra-to-be-close-to-work/
- [SURVEY-SCHOOL] https://www.propertyreporter.co.uk/property/school-catchment-areas-twice-as-popular-amongst-house-hunting-familes-than-low-crime-rate-areas.html (parents only)
- [SURVEY-BB] https://www.fierce-network.com/telecom/broadband-speed-becomes-key-factor-uk-home-purchases-says-rightmove (older Rightmove survey)
- [HOA-LEASE] https://landlordzone.co.uk/news/leasehold-property-listings-miss-out-vital-facts (search summary; year not confirmed)
- [GOV-MATINFO] https://www.gov.uk/government/consultations/material-information-in-property-listings/material-information-in-property-listings
- [RM-MATINFO] https://hub.rightmove.co.uk/rightmove-updates-for-material-information
- [RM-6MONTH] https://customerfaq.rightmove.co.uk/support/solutions/articles/7000089614-what-should-i-do-when-an-agent-has-marked-a-property-as-sold-stc-or-let-agreed-but-they-re-not-r
- [NEG-SSTC] https://thenegotiator.co.uk/news/agents-slammed-over-properties-kept-on-portals-for-sale-despite-being-sstc/
- [PIE-SHARED] https://propertyindustryeye.com/?p=157551 (19 Nov 2025)
- [LANDAHOUSE] https://addons.mozilla.org/firefox/addon/land-a-house/ (2 users, no reviews; feature list only)
- [HOMESEEK] https://www.producthunt.com/products/homeseek
- [COUPLES-SEARCH] https://lifestyle.kccrradio.com/story/209705/new-proptech-platform-twokeys-eliminates-the-group-chat-chaos-for-house-hunting-couples-and-roommates/ ; https://thenegotiator.co.uk/news/new-app-hoping-to-rival-rightmove-wins-200k-to-attract-more-agents/ ; https://realestatemagazine.ca/house-hunting-app-feature-for-couples-delivers-recommended-properties-favourite-listings-and-more/
- [REA-PLANNER] https://apps.apple.com/au/app/id404667893?l=en-au
- [DOMAIN-PLANNER] https://apps.apple.com/au/app/id319908646
- [ALLHOMES-PLANNER] https://help.allhomes.com.au/hc/en-us/articles/360053344694-Using-Allhomes-Inspection-Planner
- [CAPTERRA-RF] https://www.capterra.com/p/210572/Redfin/reviews/ (22 reviews, 4.6; search summary)
- [DWELLIO] https://www.producthunt.com/p/dwellio-2 (vendor claim)
- [RR-TP] https://www.trustpilot.com/review/propertylabs.co.uk (20 reviews, mostly 2023)
- [PIE-40MIN] https://propertyindustryeye.com/tiny-flat-lets-within-40-minutes-tenant-moves-within-two-hours/
- [LDN-RENTERS] https://london.gov.uk/media/43769/download (search summary; date not confirmed)
- [MOOT] https://nb.generationrent.org/rate_your_landlord_and_more_on_marks_out_of_tenancy
- [SR-TP] https://www.trustpilot.com/review/spareroom.co.uk (21,176 reviews, Nov 2026)
- [JITTY-PH] https://www.producthunt.com/products/jitty/reviews (3 reviews)
- [JITTY-500K] https://www.estateagenttoday.co.uk/breaking-news/2025/11/jitty-passes-half-a-million-property-searches/ (company figures)
- [RM-AIKW] https://hub.rightmove.co.uk/latest-ai-innovations/
- Data licences: EPC API docs https://epc.opendatacommunities.org/docs/api ; schools https://get-information-schools.service.gov.uk/ ; HN search https://hn.algolia.com/api/v1/search?query=rightmove
