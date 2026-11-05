# Graha Anveshana - continuous search research (2026-11-05)

Goal: keep watching for homes to rent and buy in Leeds, Pontefract, Castleford, Doncaster, Wakefield and nearby. Alert on new homes, price drops and let/sold changes. Stay within the law and each site's terms.

This builds on `docs/2026-11-05-feature-research.md`. That file already covers portal scraping bans and the open data the app uses. Nothing there is repeated here except where a new clause was read.

## 1. Read this first: evidence limits

- **Reddit is still blocked.** Fetching `reddit.com` failed ("unable to fetch"). No Reddit thread was read. All counts exclude Reddit.
- **Google Play pages did not render** (the fetch returned only a truncation note). The Zoopla UK App Store page returned 404. Only the Rightmove UK App Store page was read.
- **Several official pages could not be read directly:** Zoopla developer portal (title only), Zoopla help centre (403), Rightmove price-reduction FAQ (login redirect), Nestoria (401), Street developer docs (title only), LandlordZONE Hutch article (403). Where I rely on a search-engine summary of such a page, I say "(search summary)".
- **Trustpilot:** the fetch tool shows only the first page of recent reviews and often hides star ratings. I give stars only where shown.
- **No real alert email was read.** I did not sign up for anything, so I have not seen a Rightmove, Zoopla, OnTheMarket, OpenRent or SpareRoom alert email. Field lists for alert emails are **not verified**.
- **Not researched (time):** Sprift, Searchland, Nimbus, Hometrack, Homeflow data products, Auction House UK, SDL feeds, PrimeLocation terms, Home.co.uk terms. They are marked "not verified" below. No claim is made about them.
- **Vendor claims:** speed claims by Rental Radar, Hutch, Dwellio and Jitty are the companies' own. None is independently tested.

## 2. What Brahma Watch can and cannot take

I read `watch.ts`, `propertypal.ts`, `notify.ts`, `index.ts` and `wrangler.toml`.

- A `Watch` has `source: "propertypal"`, a search `path`, price, beds, centre and radius. `diff()` emits `new`, `price` and `status` events. The first run only records, so a new watch does not flood the phone. Events go to ntfy and to a KV `events` list (last 500) that the app reads over the HTTP API.
- The cron is `*/10 * * * *` (144 runs a day).
- **KV write budget is the tight limit.** The Workers Free plan allows **1,000 KV writes a day** [CF-KV]. `runWatches` writes `status:<id>` every run for every watch. That is 144 writes per watch per day before any `seen:` or `events` writes. Six watches use about 864 writes. Leeds plus four towns, rent and buy, is ten watches: over budget. Fix before adding sources: write `status` only when it changes, or keep one combined status key.
- Other Free plan limits: 10 ms CPU per request, 100,000 requests a day, 5 cron triggers per account, 50 subrequests per invocation, 128 MB memory [CF-LIMITS].
- England has no PropertyPal equivalent whose terms allow this kind of polling. The portal-pull design does not transfer. An **email-in** design does (section 4).

## 3. Sources table

Verdict key: **OK** = terms allow it or it is the user's own data. **Ask** = only with written permission or a paid licence. **No** = terms forbid automated use. **NV** = not verified.

| Source | What it is | Leeds / Wakefield / Doncaster coverage | Cost | Auth | Rate limit | Terms verdict (quote, link) | Fit for Brahma Watch |
|---|---|---|---|---|---|---|---|
| **Portal alert emails the user already gets** (Rightmove, Zoopla, OTM, OpenRent, SpareRoom) | Saved-search emails sent to the user | Same as each portal (near full for agents' stock) | Free | User's own account | Zoopla AUP 3.2.1: "fifty (50) email alerts per user per day"; 3.2.2: "fifty (50) created property alerts per user at any one time" [ZP-TERMS] | **OK, with care.** No terms read mention alert emails. Rightmove 5.5.1 bars access to "the Platform ... other than by means of direct human interaction" [RM-TERMS]; parsing an email already received is not accessing the Platform, but "Platform" includes "any other innovation used or operated by Us to deliver Rightmove's services", so this is a grey area. Zoopla bars "text or data mining or web scraping in relation to our Site" and allows use "only for personal, non-commercial purposes" [ZP-TERMS]. OTM 2.2: "you must not copy, transmit, modify, republish, store (in whole or in part)" Site material [OTM-TERMS]. SpareRoom 3.3: "You will not create any integrations (software or otherwise) to the Platform without the express written consent" [SR-TERMS]. Keep it personal, never fetch the listing page automatically, never share | **Best fit.** Add an `email()` handler to the same Worker (section 4) |
| Rightmove Real Time Datafeed | Agents and their software push listings in | n/a (write only) | n/a | Rightmove certificate, Network and Branch ID [RM-RTDF] | n/a | **No read access.** Upload channel only | None |
| Rightmove Data Services | Licensed market data: "asking prices, number of price reductions ... time on market" (search summary) [RM-DATA] | National | Not published; scoped per client | Contract | NV | **Ask.** Negotiated licence. Listing-level alerts not verified | Poor (cost, aimed at lenders and investors) |
| Zoopla listings API | Old developer API | n/a | n/a | Approved key | n/a | **Closed.** Search summary of the developer portal: "the Zoopla listings API is no longer publicly available"; commercial users told to contact Zoopla [ZP-DEV]. Page itself did not render: confirm by hand | None |
| OnTheMarket, OpenRent, SpareRoom | Portals | Yes | n/a | n/a | n/a | **No public API found.** OTM 3.3 and 8.4 "You are not permitted to use automated programs for such purposes" [OTM-TERMS]; OpenRent 1.1.5 "You will not use software or any other means to harvest information from the website" [OR-TERMS]; SpareRoom 3.4(g) "use software or any other means to harvest information from the Platform" [SR-TERMS] | Emails only |
| Gumtree | Classifieds incl. rentals | Some | n/a | n/a | n/a | **No.** Terms effective 30 Oct 2025: "use any robot spider, scraper or other automated means to access Gumtree" is prohibited without express written permission [GT-TERMS] | None |
| PrimeLocation | Zoopla group portal | Yes | NV | NV | NV | **NV.** Terms not read | None until checked |
| Home.co.uk | Search engine over agent listings; agents can send "XML, JSON and BLM" feeds (search summary) [HOME-AG] | NV | NV | NV | NV | **NV.** No public read API found. A 2010s trade article reports an agent objecting to being indexed [HOME-NEG] | None |
| Nestoria | Older UK search engine with a documented API | NV | NV | NV | NV | **NV.** Site returned 401 to the fetch. Current status unknown | None |
| Movebubble | London rental app | n/a | n/a | n/a | n/a | **Dormant.** Site and app offline; trade press speculated it ceased trading (around 2022) [MB] | None |
| PropertyHeads | Portal; says it "does not scrape listings" and uses "third party data suppliers" (search summary) [PH] | NV | NV | NV | NV | **NV.** No public API found | None |
| Jitty | AI portal. Indexes "homes straight from estate agents' websites"; Pre-Market "gathers pre-market listings directly from estate agents' marketing emails" (search summary) [JIT-EAT][JIT-PRE] | Own June 2025 post says it falls behind Rightmove on coverage [JIT-BEST] | Free to users | n/a | n/a | **NV.** No public API found | None, but its email method mirrors section 4 |
| PropertyData API | Paid data API (prices, rents, "sourced-properties") | National | £30/month (2,000 credits) to £800/month (300,000); most calls 1 credit; trial capped at 500 credits [PD-PRICE] | API key | 12 per 30 s (2k plan) to 60 per 30 s (300k plan) [PD-PRICE] | **Ask / NV.** Terms and fair-use pages not read. Whether the API returns individual live listings is **not verified** [PD-DOCS] | Possible later; check terms and output first |
| Street (Street Group) Open API and Property Feed | Agency CRM APIs. Key requested "through the Street software under Account Settings" (search summary) [STREET] | Agents who use Street | NV | Agent's key | A third-party guide polls every 15 min (search summary) | **Ask.** For the agent's own data. Needs an agent to grant access | Only via an agent partnership |
| Sprift, Searchland, Nimbus, Hometrack, Homeflow data | Licensed data / agent platforms | NV | NV | NV | NV | **NV** | Unknown |
| Letting agents' own sites | Agents' websites (Property Hive, Homeflow, Street, etc.) | Varies | Free | None | Per robots.txt | **Mostly No.** Linley & Simpson (Leeds agent) robots.txt: `User-agent: *` `Disallow: /` [LS-ROBOTS]. Hunters robots.txt blocks search, map and filter URLs [HUN-ROBOTS]. No public RSS feed of listings verified for Property Hive or Homeflow sites [PHIVE][HFLOW] | None without written permission from the agent |
| Leeds Homes (council CBL) | Social housing lets | Leeds | Free | Registration and bidding number [LEEDS-REG][LFHA] | NV | **NV.** Terms not found. No feed found. Historic lets are open data on data.gov.uk / Data Mill North, updated quarterly [DATAMILL] | Reminders and history only |
| Vico Homesearch (Wakefield district, incl. Pontefract, Castleford) | Weekly adverts of Vico and other RSL homes | Wakefield district | Free | Membership needed to see council-nominee homes [WAK-CBL][VICO] | NV | **NV.** No feed found | Weekly reminder only |
| Doncaster HomeChoice (St Leger Homes) | Weekly CBL cycle | Doncaster | Free | Registration | NV | **NV.** No feed found. 2023 guide: adverts run Thursday 00:01 to Sunday 23:59 (search summary) [DON-GUIDE] | Weekly reminder (Thursday) |
| Pugh (now BTG Eddisons) and other auctions | Auction lots | Leeds, Wakefield, Bradford, South Yorkshire [PUGH] | Free to browse | NV | NV | **NV.** No RSS or feed found. Pugh site says "We're now part of BTG Eddisons" | Email alerts if offered (NV) |

**Bottom line:** in England the only free, automatic and arguably lawful listing stream is the alert email the user already receives. Every portal and the agents checked forbid automated reading. Licensed APIs exist but cost money and their listing-level output and terms are not verified.

## 4. Alert email route

### 4.1 What each portal sends

| Portal | Speed options | Notes | Source |
|---|---|---|---|
| Rightmove | Instantly, daily, every 3 days, every 7 days (search summary of help centre and a spokesperson quote) | "No more than 14 new/reduced properties can be included in the email body itself"; a randomised selection; total count and a link to the full results. Alerts fire on "added today" or "reduced today". A cut under 2% does not go out in alerts (search summary). A lettings home counts as new only after a marketing break of 2 weeks or more (search summary). In 2015 Rightmove said first enquiries came "as quickly as 8 minutes" after a rental was added | [RM-ALERT-FAQ][PIE-RM][RM-RELIST][RM-INSTANT] |
| Zoopla | Frequency is set per saved search; exact options **NV** (help page 403) | Max 50 alert emails a day and 50 alerts per user | [ZP-HELP][ZP-TERMS] |
| OnTheMarket | Instant alerts exist ("2.3 billion instant property alerts" in 2023, OTM's own claim); other options NV | Leads with "New & exclusive" homes | [OTM-EXP] |
| OpenRent | **NV** | Uses SMS heavily for alerts (Twilio case study) | [OR-TWILIO] |
| SpareRoom | "daily summary emails each morning" plus "instant alerts" | Free ads under 7 days old can only be contacted by paid Early Bird users | [SR-ALERTS][SR-EARLY] |

**Fields in the emails: not verified.** Rightmove's FAQ confirms a count, a results link and up to 14 properties. Whether each item carries address, price, beds and image was not seen. Rightmove property URLs have the form `rightmove.co.uk/properties/<number>` (seen in search results). Zoopla, OTM, OpenRent and SpareRoom URL forms were not checked. Format stability: unknown. Rightmove changed its alert emails in 2023 so users "can't just click on the property" (Trustpilot, Jul 2023) [RM-TP-ALERT]. Expect breakage and keep fixtures.

**What alerts do not give:** let agreed, sold STC or withdrawn changes. Rightmove alerts carry "new" and "reduced" only. An MSE poster says "removal of SOLD STC does not trigger an alert" (Feb 2023) [MSE-STC]. So the monitor cannot learn let/sold status from emails. See section 6.

### 4.2 Routes compared

| Route | Works how | Cost | Limits | Verdict |
|---|---|---|---|---|
| **Cloudflare Email Routing + Email Worker** | Mail to `homes@<domain>` runs an `email()` handler in the Watch Worker | Inbound email unlimited on Free and Paid; Email Workers billed as Workers; Paid plan $5/month minimum [CF-EMAIL-PRICE]. Needs a domain on Cloudflare (domain cost NV) | 25 MiB per message; 200 rules per domain; 200 destination addresses; Free plan handlers may fail with `EXCEEDED_CPU` [CF-EMAIL-LIM]; 10 ms CPU [CF-LIMITS] | **Recommended** |
| Gmail filter forwarding to that address | Filter on `from:` each portal, "Forward it" | Free | Gmail sends a verification link to the forwarding address first [GMAIL-FWD]. The Worker must pass that one message on (e.g. to ntfy) so the user can click it | **Use with the above** |
| Gmail API | App or Worker reads the mailbox | Free | `gmail.readonly` is a restricted scope (vendor guide) [UNIPILE]. A personal Cloud project left in "Testing" gets refresh tokens "expiring in 7 days" [G-OAUTH] | Poor: weekly re-login |
| IMAP from the app | App logs in to the mailbox | Free | Google moved IMAP to OAuth; app-password status for personal Gmail **NV** [G-LSA] | Poor; also only runs while the app runs |
| Android "share to app" | User shares an email or link into the app | Free | Manual; no background watch | **Fallback** for users without a domain, and for single listings |

### 4.3 Recommended design

1. Buy or reuse a domain on the user's Cloudflare account. Turn on Email Routing. Create one address, e.g. `homes@`, routed to the Watch Worker.
2. In Gmail, add a forwarding address and filters for each portal's alert sender. Rightmove alerts come from `autoresponder@rightmove.com` (search summary) [RM-ALERT-FAQ]. Others: NV; take them from the first real email.
3. Worker `email()` handler, kept under 10 ms CPU:
   - Check the sender against an allow-list. Drop anything else.
   - If it is a Gmail verification message, push it to ntfy and stop.
   - Extract listing links and the visible price, beds and address with small regexes per portal. Do not fetch any link.
   - Turn each item into the existing `Listing` shape with `source: "email:rightmove"` etc. Run `matches()` and `diff()` as today, so the user's beds, price and radius rules also apply to portal alerts (which users say ignore criteria, section 5).
   - If parsing fails, store the raw text (truncated) under one KV key and send an ntfy "parser broke" warning. Do not lose the alert.
4. App: pulls `events` as now. Adds cross-portal de-duplication (same postcode or street + beds + price within a small band) and a single timeline per home.
5. Set every portal alert to **instant**. Use daily only as a backstop.
6. Budget KV writes: one write per email batch, not per listing.

Limits to tell the user: email is only as fast as the portal sends it; Rightmove caps each email at 14 homes; cuts under 2% are not alerted by Rightmove; let/sold changes do not arrive; any portal can change its email format without notice.

## 5. Ranked features

Method: replica-entrepreneur. Public complaints and requests, weighted by recency (last 24 months = Nov 2024 onward) and repetition. Older items are listed as context and not counted. "n" = independent sources (each Trustpilot page, store page, forum thread or news piece counts once). Fewer than 3 = **thin**.

| # | Feature | Evidence (n, recent) | Top complaint (quoted, linked) | Build difficulty | Legal / terms risk |
|---|---|---|---|---|---|
| 1 | **Strict filters applied to every alert**: pets, parking, garden, bills included, hide tenanted sales, hide "offers over", saved defaults | 5: OTM-TP, RM-TP (2 reviews), RM-APP (Jul 2025), ZP-TP, RM-PRESS | "On Android I can no longer put filters for parking and garden" (OTM, 20 Jul 2026, 1 star) [OTM-TP]; "there should be a box to tick if you are not interested in tenant properties" (RM, 23 Sep 2026, 3 stars) [RM-TP]; "the results go from 332 to 0" (Zoopla, 14 Sep 2026, 1 star) [ZP-TP]; "Bills Included" in Rightmove's top-five renter search terms in June 2026 and June 2025 [RM-PRESS] | Low-Medium (needs fields parsed from emails; many emails will lack them, so tag by keyword and let the user confirm) | Low |
| 2 | **Stale / let / sold flag** on every saved or alerted home | 3 + prior file: OTM-TP, OR-TP, RM-TP | "it was listed as off the market" after enquiry (OTM, 23 Oct 2026, 1 star) [OTM-TP]; "The landlord told me the place had been rented." (OpenRent, 6 Nov 2026, 1 star) [OR-TP]; "when you click on the property, it has a long term tenant" (RM, 23 Sep 2026, 3 stars) [RM-TP] | Medium. No lawful automatic status feed for portals (section 4.1). Use: age since first seen, user taps "still live?" which opens the link for a human check, agent reply logged | Low if a human opens the page; **High** if the app fetches portal pages |
| 3 | **Quiet, precise alerts**: one de-duplicated push per home, no spam, criteria really enforced | 3: ZP-TP, RM-TP, OTM-TP | Zoopla alerts for detached homes sent "dozens of semis every day" (Jul 2026, search summary) [ZP-TP]; "Please stop emailing me. Everyday I get bombard by you." (RM, 24 Oct 2026) [RM-TP]; matching results often poor (OTM, 14 Jul 2026, 1 star) [OTM-TP] | Low (Brahma `matches()` + dedupe) | Low |
| 4 | **Scam red flags** on alerts (bank transfer before viewing, copied photos, price far below ONS/LHA, contact moved off-platform) | 4 media: THE-WEEK, WHICH, PIE-SCAM, GENRENT | Rental fraud losses rose "from £7.2 million to £14.5 million" 2021-2025 (Report Fraud, via The Week) [THE-WEEK]; OpenRent removed a fake advert only after the renter had paid (PIE) [PIE-SCAM]; Which? found scam SpareRoom ads [WHICH]; scammers copy real adverts and swap contact details [THE-WEEK] | Medium (rules, benchmark from existing ONS/LHA data) | Low; label as guidance |
| 5 | **Fast alerts** (minutes, not daily) | 1 user recent (SR-TP, Nov 2026) + 4 vendors built on it (Rental Radar, Hutch, Dwellio, OTM) **thin on user complaints** | SpareRoom "restarted the seven-day restriction preventing free members from contacting me" (4 Nov 2026) [SR-TP]; Rental Radar was built because "delayed alerts via RightMove and Zoopla" hurt its founders (vendor) [RR-TP]; older: Rightmove app user set "instant email alerts" and was let down (Nov 2021, not counted) [RM-APP] | Low (instant portal alerts + email Worker + ntfy) | Low (email route). Vendor speed claims imply portal polling, which the terms forbid |
| 6 | **Cross-portal duplicate merge** (same home, several agents or portals, sometimes two prices) | 2 MSE threads (dates NV) **thin** | Same house "listed three times in a row on Rightmove"; one house at two prices about £5k apart (search summary) [MSE-DUP][MSE-2P]. Older: Zoopla "another alert for same apartment" (Nov 2020, not counted) [ZP-TP-ALERT] | Medium (fuzzy match on address, beds, price, photos absent) | Low |
| 7 | **Price-drop alerts, including small cuts** | 1 rule + 2 undated/old forum posts **thin** | Rightmove alerts skip cuts under 2% (search summary) [RM-RELIST]; MSE: "recent price reductions are not showing" (date NV) [MSE-RED]; "removal of SOLD STC does not trigger an alert" (Feb 2023, not counted) [MSE-STC] | Low for saved homes when a later email shows a new price; cannot see cuts that portals never email | Low |
| 8 | **Map: radius and drawn area that also drives alerts** | 2 recent (ZP-TP x2 reviews, one page) **thin** | "Their mapping is hopeless." (Zoopla, 27 Oct 2026, 1 star); "The map jumps to another property" (21 Oct 2026, 1 star) [ZP-TP]. Older request: "wish I could set up an email alert by a drawn area on a map" (Zoopla, Feb 2020, not counted) [ZP-TP-ALERT] | Medium (polygon test in `matches()`; needs lat/lon, which emails may lack: geocode postcode via the app's existing postcode data) | Low |
| 9 | **Keyword search across alerts** (e.g. "garage", "no chain", "bills included") | 1 recent + Zoopla's own advice **thin** | Zoopla replied that users should "use the keyword filter" to fix alert noise (search summary) [ZP-TP]; older: Rightmove "search functionality is dire" (Apr 2023, not counted) [RM-APP] | Low | Low |
| 10 | **Natural-language / AI search** | 1 (Product Hunt, 3 reviews, all positive) **thin** | No complaint found. Praise: "much easier and intuitive to find homes with Jitty" (search summary) [JIT-PH] | High (LLM or on-device model) | Medium (privacy if text leaves the device) |
| 11 | **Commute-time search** | 0 complaints found | Offered by Foxtons, Chancellors and Jitty (via TravelTime) [FOXTONS][CHANC][JIT-TT]; no user asked for it in sources read | High (no free offline routing) | Low. Defer |
| 12 | **"New homes only" filter** | 0 found | n/a | Low | Low. Defer |

Ranking logic: 1 to 4 have three or more recent independent sources and are cheap on the existing design. 5 has strong market proof (four products sell it) but thin user evidence; it ranks high because the email route makes it nearly free. 6 to 12 are thin or have no evidence.

### Competitors that already monitor across portals

| Product | How it gets data | What users say |
|---|---|---|
| Jitty | Agent websites indexed by AI; agent marketing emails for Pre-Market; agents can share feeds (search summaries) [JIT-EAT][JIT-PRE][JIT-RAISE] | Product Hunt 5.0 from 3 reviews; praise for ease of use [JIT-PH]. Trustpilot page not found (404) |
| Rental Radar (Property Labs) | "portal monitoring"; claims alerts "up to 12 hours before" Zoopla or Rightmove emails (vendor) | Trustpilot 4.6, 20 reviews, nearly all from mid-2023; "we were first to get in contact before any other person" (Jun 2023) [RR-TP]. Only 1 review in the last 12 months |
| Hutch | Searches "all the major UK property portals"; claims some alerts beat the source site (vendor, undated article) [HUTCH] | No reviews found |
| Dwellio | Monitors "6 major UK property sites", "checks every 35 seconds", price-drop and back-on-market alerts (vendor, launched 2026) [DWELLIO] | "No reviews yet" on Product Hunt |
| PropertyHeads | Says no scraping; third-party data suppliers [PH] | NV |
| Home.co.uk | Indexes agent listings; accepts agent feeds [HOME-AG] | NV |
| Movebubble | Dormant [MB] | n/a |

None of these says how it squares portal polling with the portal terms quoted in section 3. Graha Anveshana should not copy their method.

## 6. Recommendation

Build in this order. Each step is lawful on the evidence above.

1. **Fix the KV write budget in Brahma Watch** (status writes only on change). Without this, ten Leeds-area watches break the Free plan.
2. **Email-in for portal alerts** (section 4.3). The user creates instant alerts on Rightmove, Zoopla, OTM, OpenRent and SpareRoom for: Leeds (LS) with radius; Wakefield district (WF, covers Pontefract WF8 and Castleford WF10); Doncaster (DN); rent and buy. Gmail forwards them. The Worker parses, applies the user's own rules, de-duplicates and pushes one ntfy message per home. Ship with test fixtures built from the user's own first emails (not verified today).
3. **Strict filters and quiet alerts on top** (features 1 and 3). The Worker's `matches()` becomes the real filter. Add keyword tags (pets, parking, garden, bills, tenanted, "offers over").
4. **Stale and status handling without fetching portals** (feature 2). Show "first seen N days ago". Add a "check now" button that opens the listing for the user. Log the agent's answer. Auto-dim homes older than a user-set age.
5. **Scam red flags** (feature 4) using the ONS and LHA data already in the app.
6. **Weekly council reminders**: Doncaster HomeChoice on Thursday; Vico Homesearch and Leeds Homes on their cycle (Leeds and Vico days NV). No automated reading of those sites.
7. **Ask for permission, in writing**, before any other automatic source: Leeds independent agents (some may share a feed or a Street/Property Hive export), PropertyData (read its terms and test whether its API returns individual live listings), Rightmove Data Services. Do not poll agent sites: the one Leeds agent checked blocks all robots.

Do not: scrape or poll any portal, follow alert links automatically, frame portal pages, or share parsed alerts with anyone else.

## 7. Source keys

- [CF-KV] https://developers.cloudflare.com/kv/platform/pricing/
- [CF-LIMITS] https://developers.cloudflare.com/workers/platform/limits/
- [CF-EMAIL-LIM] https://developers.cloudflare.com/email-routing/limits/
- [CF-EMAIL-PRICE] https://developers.cloudflare.com/email-service/platform/pricing/ (search summary)
- [GMAIL-FWD] https://support.google.com/mail/answer/10957?hl=en-GB
- [G-OAUTH] https://developers.google.com/identity/protocols/oauth2
- [G-LSA] https://knowledge.workspace.google.com/admin/sync/transition-from-less-secure-apps-to-oauth (search summary)
- [UNIPILE] https://www.unipile.com/gmail-api-scopes-guide/ (vendor guide, search summary)
- [RM-TERMS] https://www.rightmove.co.uk/c/terms-of-use/
- [RM-RTDF] https://media.rightmove.co.uk/ps/pdf/guides/adf/Rightmove_Real_Time_Datafeed_Specification.pdf (from prior file)
- [RM-DATA] https://www.rightmove.co.uk/property-data/ (search summary)
- [RM-ALERT-FAQ] https://customerfaq.rightmove.co.uk/support/solutions/articles/7000098933-how-the-property-alerts-work and https://faq.rightmove.co.uk/support/solutions/articles/7000048758-how-to-register-for-property-alerts (second via search summary)
- [RM-RELIST] https://customerfaq.rightmove.co.uk/support/solutions/articles/7000055339-i-want-one-of-my-properties-to-go-back-out-in-the-property-alerts (search summary)
- [RM-INSTANT] https://www.rightmove.co.uk/news/articles/property-news/if-youre-looking-to-rent-get-in-first-with-instant-alerts (2015, search summary)
- [PIE-RM] https://propertyindustryeye.com/rightmove-denies-editing-property-alerts-to-detriment-of-agents/ (search summary)
- [RM-PRESS] https://www.rightmove.co.uk/press-centre/?p=5157 (search summary)
- [RM-TP] https://www.trustpilot.com/review/rightmove.co.uk
- [RM-TP-ALERT] https://www.trustpilot.com/review/rightmove.co.uk?search=alert
- [RM-APP] https://apps.apple.com/gb/app/rightmove-property-search/id323822803?see-all=reviews
- [ZP-TERMS] https://www.zoopla.co.uk/terms/
- [ZP-DEV] https://developers.zoopla.co.uk (page did not render; search summary)
- [ZP-HELP] https://help.zoopla.co.uk/hc/en-gb/articles/360005969458 (403; search summary)
- [ZP-TP] https://www.trustpilot.com/review/zoopla.co.uk
- [ZP-TP-ALERT] https://www.trustpilot.com/review/zoopla.co.uk?search=alert
- [OTM-TERMS] https://www.onthemarket.com/terms/
- [OTM-TP] https://www.trustpilot.com/review/www.onthemarket.com
- [OTM-EXP] https://expert.onthemarket.com/brand-exposure/ (search summary)
- [OR-TERMS] https://www.openrent.co.uk/terms
- [OR-TP] https://www.trustpilot.com/review/openrent.co.uk
- [OR-TWILIO] https://customers.twilio.com/en-us/openrent (search summary)
- [SR-TERMS] https://www.spareroom.co.uk/content/default/terms-uk
- [SR-TP] https://www.trustpilot.com/review/spareroom.co.uk
- [SR-ALERTS] https://www.spareroom.co.uk/content/info-faq/why-email-alerts/
- [SR-EARLY] https://www.spareroom.co.uk/content/info-advice/early-bird-explained/ (search summary)
- [GT-TERMS] https://www.gumtree.com/termsofuse
- [HOME-AG] https://home.co.uk/agents/join (search summary)
- [HOME-NEG] https://negotiator-magazine.co.uk/article/home.co.uk-under-fire-in-property-scraping-spat-704 (search summary)
- [MB] https://propertyindustryeye.com/has-rental-platform-movebubble-ceased-trading/ and https://thenegotiator.co.uk/news/proptech-problems-has-movebubble-shut-up-shop-for-good/ (search summary)
- [PH] https://propertyindustryeye.com/propertyheads-raises-funds-and-acquires-ourproperty/ (search summary)
- [JIT-EAT] https://www.estateagenttoday.co.uk/breaking-news/2024/04/google-backed-ai-property-search-app-launches-in-london (search summary)
- [JIT-PRE] https://jitty.com/post/get-ahead-of-the-game-jittys-new-pre-market-feature-gives-buyers-early-access-to-homes (search summary)
- [JIT-RAISE] https://jitty.com/post/weve-raised-3-8m-to-build-the-future-home-buying (search summary)
- [JIT-BEST] https://jitty.com/post/the-best-uk-property-portals (search summary)
- [JIT-PH] https://www.producthunt.com/products/jitty/reviews?page=2 (search summary)
- [JIT-TT] https://traveltime.com/case-study/jitty-property-search-traveltime-h3 (title only)
- [PD-PRICE] https://propertydata.co.uk/api/pricing
- [PD-DOCS] https://propertydata.co.uk/api/documentation
- [STREET] https://developers.street.co.uk/ (title only) and https://webdadi.atlassian.net/wiki/x/BQAXQQ (search summary)
- [LS-ROBOTS] https://www.linleyandsimpson.co.uk/robots.txt
- [HUN-ROBOTS] https://www.hunters.com/robots.txt
- [PHIVE] https://www.10ninety.co.uk/blog/9/property-hive-wordpress-plugin/ (search summary; no RSS found)
- [HFLOW] https://get.homeflow.co.uk/websites (search summary; no RSS found)
- [LEEDS-REG] https://www.leeds.gov.uk/housing/finding-a-home/apply-to-a-housing-association (search summary)
- [LFHA] https://www.lfha.co.uk/?p=115 (search summary)
- [DATAMILL] https://datamillnorth.org/dataset/leeds-city-council-property-lets
- [WAK-CBL] https://www.wakefield.gov.uk/housing/finding-a-new-home/what-is-choice-based-lettings (search summary)
- [VICO] https://www.vicohomes.co.uk/media/mcdbxgdg/homesearch_membership_guide_-vh0072_120526.pdf (search summary)
- [DON-GUIDE] https://tenantportal.stlegerhomes.co.uk/siteassets/images/FINAL%20Allocation%20Policy%20Guide%20June%202023.pdf (search summary)
- [PUGH] https://www.pugh-auctions.com/contact/property-auctions-leeds (search summary)
- [MSE-STC] https://forums.moneysavingexpert.com/discussion/6423288/how-to-trigger-alerts-on-rightmove-after-removing-sold-stc
- [MSE-RED] https://forums.moneysavingexpert.com/discussion/3874821/problem-on-rightmove-website (search summary)
- [MSE-DUP] https://forums.moneysavingexpert.com/discussion/6042011/multi-estate-agent-your-experiences/p2 (search summary)
- [MSE-2P] https://forums.moneysavingexpert.com/discussion/6534698/one-house-two-prices (search summary)
- [THE-WEEK] https://theweek.com/personal-finance/how-to-spot-a-rental-scam (search summary)
- [WHICH] https://www.which.co.uk/news/article/renters-targeted-by-scammers-on-spareroom-and-facebook-acdHR0k5kVGt (search summary)
- [PIE-SCAM] https://propertyindustryeye.com/?p=129878 (search summary)
- [GENRENT] https://www.generationrent.org/?p=9851 (search summary)
- [RR-TP] https://uk.trustpilot.com/review/propertylabs.co.uk
- [HUTCH] https://www.landlordzone.co.uk/news/ai-alerts-give-renters-a-head-start-in-property-search (403; search summary)
- [DWELLIO] https://www.producthunt.com/products/dwellio-2/reviews
- [FOXTONS] https://foxtons.co.uk/discover/2020/07/the-price-travel-trade-off-achieving-the-perfect-balance-between-affordability-and-commute-times (search summary)
- [CHANC] https://www.chancellors.co.uk/news/news/new-feature-search-by-travel-time (search summary)

## 8. Open items

1. Forward one real alert email from each portal into a fixture folder; write parsers from those, not from guesses.
2. Read by hand: Zoopla developer portal, Zoopla alert-frequency help, Rightmove price-reduction FAQ, PropertyData terms and `/sourced-properties` docs, PrimeLocation and Home.co.uk terms, Leeds Homes and Vico site terms.
3. Reddit (r/HousingUK, r/Leeds, r/Doncaster) for alert speed, duplicates and scams. Still blocked here.
4. Check whether personal Gmail still allows IMAP app passwords.
5. Confirm the cost of a domain on Cloudflare.
