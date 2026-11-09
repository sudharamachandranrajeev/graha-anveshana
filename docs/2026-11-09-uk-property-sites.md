# UK property sites beyond Rightmove, Zoopla, OnTheMarket, OpenRent, PropertyPal, Facebook Marketplace

Checked: 2026-11-09. Area: Leeds, Wakefield, Castleford, Pontefract, Normanton, Doncaster.
Method: web search plus a few light plain-HTTP reads (robots.txt, terms pages, one results page where public). No sign-in, no CAPTCHA or robot-check bypass, no personal data sent.

Legal note: this is research, not legal advice. Terms of use are contract terms; breaching them can lead to blocking or, for commercial scraping, claims (database right, breach of contract). A personal app on the user's own device that opens a search link in the browser carries essentially no risk. Automated reading carries more, and the risk is higher where the terms ban it.

Limits of this research: several sites sit behind Cloudflare or similar checks (PrimeLocation, Home.co.uk, Share to Buy terms, Zoopla group terms returned 403 or "Just a moment"). I did not try to get past those. Where I could not read the terms, they are marked "not found". Live listing counts were only obtained for SpareRoom; elsewhere coverage comes from search results and is flagged as unverified.

## Summary table

| Site | Type | Leeds-Doncaster coverage | API / alerts | ToS on automation | Recommendation |
|---|---|---|---|---|---|
| SpareRoom | Rooms, flatshares, some whole lets | Yes, verified: 798 results Leeds, 280 Doncaster, 140 Wakefield | No public API found; saved-search email alerts (account needed) | Terms page read: no explicit scraping clause found. Company stated in April 2026 that agents' automation tools breach its terms. robots.txt blocks many search URLs for Googlebot | Search link that opens the site. Do not read results automatically |
| Gumtree property | Rent, buy, rooms, private ads | Likely yes (national classifieds); count not verified | Saved-search email alerts; no public API | Clearly forbids: "use any robot spider, scraper or other automated means to access Gumtree and collect content for any purpose without our express written permission" | Search link only. Leave out any automated reading |
| PrimeLocation | Buy and rent (Zoopla group) | Yes (same feed pool as Zoopla); count not verified | Email alerts (account); no public API | Terms not found (403). Zoopla group terms reported by a third party to ban scraping; unconfirmed. robots.txt disallows /datafeed, /xmlfeed, /widgets | Search link only. Treat as same risk as Zoopla |
| Home.co.uk | Buy and rent aggregator, sold prices | Probably yes; count not verified (403) | Email alerts; no public API found | Terms not found (403). robots.txt: search engines and consumer AI search bots may read listings; no model training | Search link. Plain reading is borderline; ask before automating |
| Purplebricks | Buy (online agent, owned by Strike) | Some listings likely; not verified | Email alerts; no API | Terms not found | Search link only; low value (listings usually also on Rightmove/Zoopla) |
| Jitty | Buy and rent, AI search aggregator | Unclear; launched in southern England and London, northern coverage not confirmed | None found | T&Cs (July 2024 PDF at jitty.com/terms) could not be text-read here; robots.txt disallows /api, /terms, map and gallery paths but allows normal pages | Leave out for now; recheck coverage |
| Nestoria (UK) | Buy and rent aggregator | Unknown. nestoria.co.uk answers HTTP 401 (plain text) to plain requests on 2026-11-09, so it may be defunct or blocking bots. Wikipedia still says active (undated) | Historically a public API; current state unknown | Not found | Leave out. Do not rely on the old API |
| Leeds Homes (Leeds City Council choice-based lettings) | Social rent: council and housing association homes | Yes, Leeds only | Bids need a registered account; no public API or feed found | Not found | Search link only. Needs registration and bidding number |
| Doncaster HomeChoice (St Leger Homes) | Social rent: council, housing association, some private | Yes, Doncaster only | No API found; bidding needs registration | Not found | Search link only |
| Share to Buy | Shared ownership, new build and resale | Yes: pages for Leeds, Wakefield, Doncaster (cached results show listings) | Email alerts (account); no API found | Terms page not readable (403). robots.txt disallows /properties/ and /login/ | Search link (open Leeds/Wakefield/Doncaster location page). Do not read automatically |
| Allsop | Auction, residential and commercial | Has a "Property for Auction in Leeds" page | Catalogue email; no API found | Not found (terms URL returned no usable text) | Search link; low volume of residential in this area |
| Auction House (UK / online.auctionhouse.co.uk) | Auction | Regional branches; Yorkshire lots exist; not verified | Email alerts | Not found. robots.txt disallows /search-results | Search link only |
| BTG Eddisons Property Auctions | Auction | Yes: Doncaster and Leeds lots in 2026 catalogues | Catalogue alerts | Not found | Search link |
| EIG Property Auctions | Auction (online) | Yes: Yorkshire and Leeds lots, guide prices around 35k to 200k | Email alerts | Not found | Search link |
| Pugh Auctions | Auction | Not confirmed (nothing found for 2026) | Unknown | Not found | Leave out until coverage confirmed |
| William H. Brown (Pontefract office) | Local agent, sales plus auction lots | Yes (Pontefract, Wakefield) | Email alerts | Not found | Search link |
| Unipol (Leeds, Nottingham, Bradford) | Student lettings | Leeds yes; student only, not general | Site search; no API found | Not found (/legal/ page not readable here). robots.txt allows all | Search link, only if the user wants student lets |
| Moda Living (SOYO, Leeds) | Build to rent | Leeds city centre only | Enquiry forms; no API | Not found | Link to operator site; leave out of automation |
| PLATFORM_ (South Bank, Leeds) | Build to rent | Leeds | Registration of interest | Not found | Link only |
| Grainger (former Yorkshire Post site) | Build to rent | Leeds (scheme in development per press) | Registration of interest | Not found | Link only |
| Clarendon Quarter | Build to rent | Leeds | Enquiry forms | Not found | Link only |
| Local agents: Logic Lettings, Crown Estate Agents, Richard Kendall, Robson Estates, Move Maker, House Move Yorkshire | Local lettings and sales | Yes, towns in the corridor | Most use agent software feeds; agent sites may have email alerts | Not found per site | Prefer: these agents also list on Rightmove, Zoopla, OnTheMarket (already covered). Optional search links |

## Per-site notes

### SpareRoom
- URL: https://www.spareroom.co.uk
- Lists: rooms, flatshares, some whole properties to rent.
- Today: live results pages show 798 results for Leeds (https://www.spareroom.co.uk/flatshare/leeds), 280 Doncaster, 140 Wakefield (checked 2026-11-09, plain HTTP 200).
- API/alerts: no public API found. Saved searches with email alerts need an account.
- Terms: read https://www.spareroom.co.uk/content/default/terms-uk. I searched the text for scrape, spider, robot, crawl, automated, harvest and found no explicit automation clause. Do not read that as permission. SpareRoom told press in April 2026 that agents using automation tools breached its terms and suspended accounts ("a small group of users were using third-party software that put a huge strain on site infrastructure"; https://www.property118.com/?p=193845). robots.txt (https://www.spareroom.co.uk/robots.txt) disallows many search URLs for Googlebot (search.pl actions, sort options, detail pages).
- Recommendation: build a search URL and open it in the browser. Do not poll. Risk if automated: medium to high (active enforcement).

### Gumtree property
- URL: https://www.gumtree.com (property sections for rent and sale)
- Lists: private and agent ads, rooms, rent, buy.
- Today: not verified with a count.
- API/alerts: email alerts for saved searches (account). No public API found.
- Terms: https://www.gumtree.com/termsofuse says users must not "use any robot spider, scraper or other automated means to access Gumtree and collect content for any purpose without our express written permission". Clearly forbids.
- Recommendation: search link only. Scam risk is also high on classifieds, so keep the link-out model.

### PrimeLocation
- URL: https://www.primelocation.com
- Lists: buy and rent, same group as Zoopla.
- Today: not verified (403 to plain requests; I did not try to bypass).
- Alerts: account email alerts. No API; robots.txt disallows /datafeed, /xmlfeed, /widgets, /comparison-api/ (https://www.primelocation.com/robots.txt).
- Terms: not found (403). A third-party article reports the Zoopla terms ban "text or data mining and web scraping ... automated access by bots, spiders and scrapers" and that Zoopla's developer listings API closed publicly around 30 September 2026; I could not confirm either on Zoopla's own site.
- Recommendation: search link. Since it mostly duplicates Zoopla, low priority.

### Home.co.uk
- URL: https://www.home.co.uk
- Lists: buy, rent, sold prices; aggregator.
- Today: not verified (Cloudflare check on plain requests).
- Terms: not found. robots.txt (https://home.co.uk/robots.txt) says search engines may index the whole public site, consumer AI chat/search bots may read listings and searches, "Nothing may be used for model training". Not a statement about personal apps, but friendlier than most.
- Recommendation: search link; consider asking the site before automated reading.

### Purplebricks
- URL: https://www.purplebricks.co.uk
- Lists: homes for sale, online agent; sold to Strike for 1 pound in 2023 (https://thenegotiator.co.uk/news/breaking-purplebricks-sold-to-strike-for-just-1/). A January 2026 article says the brand continues under Strike.
- robots.txt (https://www.purplebricks.co.uk/robots.txt) is permissive (blocks brochures and blog paths only). Terms: not found.
- Recommendation: search link only; low value.

### Jitty
- URL: https://jitty.com
- Lists: AI-organised buy and rent search (rollout reported 2024 in southern England and London; Leeds coverage not confirmed).
- Terms: https://jitty.com/terms is a PDF "T&Cs July 2024"; I could not extract its text. robots.txt (https://jitty.com/robots.txt) disallows /api and /terms. A third-party Apify scraper exists but is not authorisation.
- Recommendation: leave out until Leeds coverage is shown.

### Nestoria
- URL: https://www.nestoria.co.uk
- Status: on 2026-11-09 the site returned HTTP 401 with a 13-byte plain-text body to plain requests, so I could not confirm it is running. Wikipedia lists it as active (undated); news results are from 2006 to 2014 (https://en.wikipedia.org/wiki/Nestoria). Treat as unconfirmed or gone.
- Recommendation: leave out.

### Leeds Homes (council choice-based lettings)
- URL: https://www.leedshomes.org.uk ; policy: https://www.leeds.gov.uk/housing/finding-a-home/lettings-policy
- Lists: council and housing association homes, new build council homes; applicants register and get a bidding number. Council statement: about 26,000 applicants on the register.
- Public listings page: https://www.leedshomes.org.uk/PropertySearch (page exists; I did not parse counts).
- API: none found. Open data: Leeds council publishes "property lets" statistics on data.gov.uk, not live adverts (https://www.data.gov.uk/dataset/f9024e3e-0e81-4d43-9b07-b54a07089e2a/leeds-city-council-property-lets1).
- Terms: not found.
- Recommendation: search link, plus a note that the user must register to bid. Eligibility applies.

### Doncaster HomeChoice (St Leger Homes of Doncaster)
- URL: https://www.stlegerhomes.co.uk/homechoice/ (St Leger Homes is still the council's housing provider as of 2026 per local news; https://www.doncasterfreepress.co.uk/news/politics/st-leger-homes-of-doncaster-32-new-housing-acquisitions-by-council-housing-provider-in-202526-says-exec-5450248)
- Lists: council, housing association and some private rented homes, by bidding. 7,658 on the register (to 1 Aug 2026).
- Terms and API: not found.
- Recommendation: search link.

### Share to Buy
- URL: https://www.sharetobuy.com ; locations: /locations/leeds, /locations/wakefield, /locations/doncaster
- Lists: shared ownership new builds and resales. Search results show shares from 10% to 75%, income cap 80,000 pounds outside London.
- Today: cached results show listings in all three areas (Flanshaw Field Drive Wakefield; Places for People schemes in Leeds and Doncaster); not verified live.
- Terms page (https://www.sharetobuy.com/terms) returned 403. robots.txt (https://www.sharetobuy.com/robots.txt) disallows /properties/ and /login/.
- Recommendation: open the location page in the browser. Do not read automatically given the robots rule.

### Auction sites
- Allsop: https://www.allsop.co.uk/auctions/property-for-auction-in-leeds/ ; robots.txt only lists a sitemap.
- Auction House: https://online.auctionhouse.co.uk/search?view=list ; robots.txt disallows /search-results.
- BTG Eddisons: https://www.btgeddisonspropertyauctions.com ; Doncaster and Leeds lots in 2026 catalogues.
- EIG: https://www.eigpropertyauctions.co.uk/search/property/yorkshire
- William H. Brown (Pontefract): lot at Leeds Road, auction 23 June 2026.
- Pugh: not confirmed.
- Terms: not found for any. Auction lots carry legal packs and buyer premiums, so the app should only show a link.
- Recommendation: one "Auctions" link group.

### Unipol
- URL: https://www.unipol.org.uk ("Student housing and advice in Leeds, Nottingham and Bradford"); property search at /PropertySearch-style pages. robots.txt allows everything. Terms not found.
- Recommendation: search link, student-only mode.

### Build to rent, Leeds
- Moda Living (SOYO, Quarry Hill), PLATFORM_ (South Bank, 451 apartments), Grainger (former Yorkshire Post site, 242 homes), Clarendon Quarter. Sources: https://www.yorkshirepost.co.uk/lifestyle/homes-and-gardens/this-is-where-515-apartments-will-be-built-in-leeds-city-centre-818875 and https://www.yorkshireeveningpost.co.uk/lifestyle/homes-and-gardens/south-bank-first-look-as-work-on-new-build-to-rent-apartment-scheme-gets-underway-in-leeds-4826807 . Press is dated; confirm which blocks are open. My searches did not confirm Get Living, Packaged Living, Fizzy or Sigma in Leeds.
- Terms: not found. These sell via their own websites and also list on Rightmove and Zoopla (already covered).
- Recommendation: curated links, not automation.

### New-build portals
- Share to Buy covers shared ownership. I did not research other new-build portals (for example developer sites or Rightmove New Homes) in depth. Rightmove new homes are already covered by the existing Rightmove source.

### Local Yorkshire agents
- Seen in search: Logic Lettings (Pontefract, covers Leeds/Wakefield/Doncaster/Castleford), Crown Estate Agents (Castleford, Pontefract), Richard Kendall (Wakefield, Pontefract), Robson Estates (Doncaster lettings), Move Maker (South Elmsall), House Move Yorkshire (Wakefield). Also Reeds Rains, Whitegates, Martin & Co, Bridgfords. Their stock normally also appears on Rightmove, Zoopla and OnTheMarket. Terms: not checked per agent.
- Recommendation: optional "local agents" links; not worth separate scraping.

## Top 5 to add next

1. SpareRoom, search link. Verified live: 798 Leeds rooms, 280 Doncaster, 140 Wakefield. Biggest source not already covered. Open in the browser only: SpareRoom actively enforces against automation (April 2026).
2. Leeds Homes plus Doncaster HomeChoice, as one "Social housing" link group. Different supply from private portals; the user can bid once registered. No automation needed or possible.
3. Share to Buy, location links for Leeds, Wakefield, Doncaster. Live shared ownership listings for all three; link-out avoids the robots.txt rule on /properties/.
4. Auctions bundle (Allsop Leeds, BTG Eddisons, EIG, Auction House). Lots in Doncaster, Leeds, Pontefract that never reach portals; link-out only.
5. Home.co.uk, search link. Aggregator across agents with the friendliest published robots stance; Nestoria (the older equivalent) is not confirmed running.

Honourable mention: Unipol if the user wants student lets; Gumtree for private ads (link only).

## Sites whose terms clearly forbid automated reading

- Gumtree: "use any robot spider, scraper or other automated means to access Gumtree and collect content for any purpose without our express written permission" (https://www.gumtree.com/termsofuse).
- SpareRoom: no clause found in the terms page I read, but the company states automation breaches its terms (April 2026, https://www.property118.com/?p=193845). Treat as forbidden in practice.
- Zoopla / PrimeLocation: reported by a third party only; not confirmed from the site itself.
