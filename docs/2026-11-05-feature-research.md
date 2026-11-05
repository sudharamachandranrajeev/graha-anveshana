# Graha Anveshana - feature research (2026-11-05)

Private, local-first UK property app for (a) renters/buyers and (b) small landlords/BTL investors.
Method: replica-entrepreneur. Collected public complaints and requests, weighted by rating, recency (last 24 months) and repetition. Every claim has a link. Nothing is invented. Themes with fewer than 3 independent sources are marked **thin**.

## 0. Read this first: limits of the evidence

- **Reddit was not reachable.** Reddit domains are blocked for the search tool and for fetching. No r/HousingUK, r/UKLandlords, r/UKPersonalFinance, r/FirstTimeBuyersUK, r/PropertyInvestingUK, r/Leeds or r/Doncaster thread was read. Every "n sources" count below excludes Reddit. Someone should read those threads by hand before locking the ranking.
- **Sources actually read:** Trustpilot pages (Rightmove, Zoopla, OnTheMarket, OpenRent, SpareRoom, Landlord Vision, Hammock, Property Hub), one App Store review page (Rightmove), MoneySavingExpert thread titles and search summaries, vendor and law-firm pages, gov.uk, ONS, council sites.
- **Trustpilot caveat:** The fetch tool summarises pages. Per-review star ratings were often not shown. I give a star rating only where the summary gave one. Trustpilot does not verify claims. Treat each review as one person's account.
- **Rightmove App Store reviews are mostly old.** Only two of the ten fetched fall in roughly the last 24 months (Nov 2024, Aug 2025). Older ones are listed as context and are not counted.
- **Not covered:** Goodlord, Coconut, Arthur Online, PropertyData and Property Tracker reviews were not collected. No claim about them is made.
- **Dates:** all gov.uk-sourced legal dates are from the Housing Hub landlord page (gov.uk campaign site) unless stated otherwise. Third-party law-firm dates are labelled as such.

## 1. Ranked candidate features

Scoring: evidence = number of independent sources I could cite (Trustpilot page = 1 source even if it holds several reviews; Reddit excluded). Difficulty is for an offline-first Flutter app using only free open data. Legal risk is ToS, data-protection or legal-advice risk.

Evidence links use the short keys in section 5.

| # | Feature | Who wants it | Evidence (n) | Top complaint it fixes | Build difficulty | Legal / ToS risk |
|---|---|---|---|---|---|---|
| 1 | **Private by design: no ads, no lead selling, all data on device** | Everyone | 2 portals, 14 reviews [ZP-TP][OTM-TP] | "Bombarded with emails"; agents ring after a valuation request | Low (it is the architecture) | Low |
| 2 | **Saved-listing tracker from user-pasted links** with status (live / let / gone), last-checked date, manual price-change log | Renters, buyers | 4 [RM-TP][OTM-TP][MSE][RM-APP] | Stale, already-let or sold listings; lose place on refresh | Low | Low if the user pastes the link and the app stores only user-typed fields; no fetching of portal pages |
| 3 | **Enquiry / viewing CRM**: agent, date contacted, response time, "ghosted" flag, follow-up reminder | Renters, buyers | 3 [RM-TP][OTM-TP][MSE-gen] | Agents do not reply; two-week silence | Low | Low |
| 4 | **Sold-price and street history** (HM Land Registry Price Paid + UK HPI) | Buyers, investors | 3 [ZP-TP][RM-TP][RM-APP-old] **thin-ish** | Wrong "last sold" date; no price history | Medium (bundle a PPD slice for the target areas only; full file is large) | Low; OGL v3 needs attribution [LR-PPD] |
| 5 | **Valuation sanity check**: comparable sold prices by postcode/type with visible method and sample size | Buyers, sellers, investors | 2 portals, 8 reviews [ZP-TP][OTM-TP] | Estimates that ignore the recorded sale price or use a town 20 miles away | Medium | Low; show it as "comparables", not "valuation" |
| 6 | **Advert red-flag checker** (rent bidding wording, advance rent over one month, fee wording, price far from ONS/LHA benchmark, listing "back on market") | Renters | 3 [RM-TP][RM-TP-agent][GOV-HUB] | Fake price cuts, relisting after offer, fee opacity | Medium (rules from gov.uk; benchmark from ONS) | Low; label as guidance only |
| 7 | **Filters portals lack, applied to saved items**: pet-friendly, tenanted-sale, "offers over", viewed/hidden, lot size, notes | Renters, buyers | 3 [RM-APP][RM-TP][ZP-TP] | Cannot hide viewed homes; no pet filter; filters drop 332 results to 0 | Low (user-tagged fields) | Low |
| 8 | **Deep links to prefilled portal searches** (Rightmove, Zoopla, OTM, OpenRent, SpareRoom) | Renters, buyers | Derived; no complaint | Saves retyping criteria | Low | **Zoopla terms forbid deep links "other than the home page"** [ZP-TERMS]. Check each portal. Safer: links the user opens themselves, no framing |
| 9 | **Renters' Rights Act compliance timeline** (what applied 1 May 2026; what is pending) per tenancy | Landlords | 4 [GOV-HUB][OSB][PIN][NRLA] | Landlords unsure which rules apply | Low (static rules + dates) | Medium: legal-information risk, add "not legal advice" and update tag |
| 10 | **Section 13 rent-increase date calculator** (two months notice, once a year) | Landlords | 3 [GOV-HUB][TROW][BLACKACRE] | Contractual rent review clauses are void; wrong notice dates | Low | Medium: do not output the official form text until Form 4A is confirmed on gov.uk (only seen in commercial blogs) |
| 11 | **Compliance certificate tracker** (gas, EICR, EPC, smoke/CO, deposit, right to rent, info sheet) with local notifications | Landlords | 3 [HAM-TP][LV-SITE][LV-TP] | Missed expiry dates; pain at portfolio size | Low | Low |
| 12 | **Licensing checker** (is this postcode in a selective-licence ward or HMO Article 4 area?) | Landlords, investors | 4 councils [LEEDS-SL][ROTH-SL][DON-SL][WAK-A4] | £1,100 fee and up to £40,000 civil penalty if you miss it | Medium (needs curated postcode/polygon lists with source links and "verify with council") | Medium: wrong answer causes loss; show council map link and review date |
| 13 | **Rent ledger with bank CSV import and reconciliation** | Landlords | 3 [LV-TP][HAM-TP][ACCWEB] | Accounting and bank reconciliation hard | Medium (CSV mapping rules) | Low; no open-banking connection needed |
| 14 | **MTD-ready income/expense export** (quarterly summaries, CSV) | Landlords | 3 [HAM-SITE][LV-TP][ACCWEB] | Landlords still need separate MTD software | Medium; do not claim HMRC submission | Medium: HMRC software recognition is a regulatory step; export only |
| 15 | **Yield and BTL stress-test calculator** (rent from ONS by bedroom, price from PPD, mortgage rate, voids, EPC capex) | Investors | 1 direct [PH-TP]; indirect via marketing complaint | "Projections vs reality" (figures unrealistic, financing higher) | Low | Low; show assumptions |
| 16 | **EPC lookup and "cost to reach C" estimator** | Landlords, buyers | 4 [ELM][SIMMONS][INSIDE][EPC-DATA] | EPC C-equivalent required by 1 Oct 2030 (reported) | Medium (EPC data needs GOV.UK One Login for bulk CSV) | Low-Medium: address data; check guidance page |
| 17 | **LHA / Universal Credit affordability check** by BRMA, bundled CSV | Renters on benefits, landlords | 2 [LHA-CSV][RM-TP-benefit] **thin** | Benefit claimants refused; shortfall confusion | Low | Low |
| 18 | **Council choice-based lettings tracker** (Leeds Homes, Vico Homesearch, Doncaster HomeChoice): register status, bid log, reminders | Social-housing seekers | Derived from sources [LEEDS-CBL][WAK-CBL][DON-CBL] | Demand far above supply (799 bids on one home, older press) | Low (links + user log) | Low |
| 19 | **Area dossier**: flood risk (EA API), crime (data.police.uk), ONS price/rent, nearest amenities | Buyers, renters | 2 [ZP-TP flood][EA-DOC unverified] **thin** | Wrong flood data cost a sale (one Zoopla review) | Medium-High (caching, bundle limits; API 15 req/s [POL-API]) | Low; OGL |
| 20 | **Forwarded-alert importer**: parse portal alert emails the user already receives, local only | Renters, buyers | Derived | Stale lists; manual copy | Medium (parsers break) | Low: user's own mail; no scraping. Check each portal's alert-email terms |
| 21 | **All-in cost compare** (rent/price + council tax band + bills + fees + deposit cap) side by side | Renters, buyers | 2 [RM-APP][RM-TP] **thin** (requests for bills/zone filters) | No bills/zone comparison | Low | Low |
| 22 | **Tenant referencing prep checklist** (what agents check, affordability maths, guarantor) | Renters | 2 portals [RM-TP][OR-TP] **thin** | Rigid referencing, savings "shortfall", banking-app access demand | Low | Low |
| 23 | **Pet-request log** (date received, reason for refusal, response deadline) | Landlords | 1 [GOV-HUB] **thin** | New duty to respond to pet requests; timeframe not stated on the page | Low | Medium: timeframe unverified |
| 24 | **Encrypted document vault** (tenancy, certificates, photos) | Landlords | 0 direct; Property Hub/OpenRent privacy complaints indirect | Data sharing and bank access grievances | Low-Medium | Low |
| 25 | **Commute/travel filter** | Renters, buyers | 0 in collected sources | n/a | High (no free offline routing) | Low. Defer |

Ranking logic: features 1-7 combine the strongest repeated complaints with low build effort and low legal risk. Features 9-14 are what small landlords repeat and what the law now forces. Features 15-24 are real but thinner or heavier. Feature 25 is last because I found no evidence for it.

## 2. Most hated in competitors

Counts are from the pages I fetched. Each Trustpilot page is one source.

| Complaint | Where | Evidence | Link |
|---|---|---|---|
| Stale / already-let / off-market listings | OnTheMarket: Oct 2026, 1 star, listed then shown off market. Rightmove search summary mentions a June 2026 review of a rental already taken. MSE threads on sold or let homes still advertised (older, anecdotal) | n=3 | [OTM-TP], [RM-TP], [MSE] |
| Agent / support not replying | Rightmove: no reply for two weeks (Sep 2026). OnTheMarket: "customer service is non existent" (Sep 2026, 1 star), "ignoring any follow ups" (Oct 2026, 1 star). Hammock: email wait of a week (Oct 2026, 2 stars) | n=3 | [RM-TP], [OTM-TP], [HAM-TP] |
| Selling your data / unwanted calls | Zoopla: six reviews, all 1 star (Aug-Nov 2026). OnTheMarket: "3-5 calls a day" (Sep 2026, 1 star) | n=2 portals, 9 reviews | [ZP-TP], [OTM-TP] |
| Wrong valuation or estimate | Zoopla: six reviews. OnTheMarket: two (Apr and Jun 2026, 1 star) | n=2 | [ZP-TP], [OTM-TP] |
| Wrong property data (type, address, county, last-sold date, flood risk) | Zoopla: five reviews. Rightmove: wrong property type, data attributed to HM Land Registry (Oct 2026) | n=2 | [ZP-TP], [RM-TP] |
| Fake price cuts, relisting after offer accepted | Review on an agent page that cites Rightmove (Jan and Apr 2026). One person's claim each, unverified | n=1 **thin** | [RM-TP-agent] |
| Rigid referencing and affordability checks | Rightmove: four reviews (Sep-Nov 2026): 20 days of problems, "shortfall" rule, guarantor demand. OpenRent: banking-app access demand (Sep 2026, 1 star) | n=2 | [RM-TP], [OR-TP] |
| Login / app / filter bugs | Zoopla: filters cut 332 results to 0; map jumps. OnTheMarket: Android filters gone (Jul 2026). Rightmove: login impossible (Oct 2026) | n=3 | [ZP-TP], [OTM-TP], [RM-TP] |
| Missing filters | Rightmove app: pet-friendly (Aug 2025), hide viewed homes and lot size (Nov 2024). Rightmove web: hide "offers over", filter out long-term tenants in sale listings (2026) | n=2 | [RM-APP], [RM-TP] |
| Fee opacity / price changes | OnTheMarket: promised cheaper rate not honoured (Aug 2026, 3 stars). Rightmove: monthly portal charges "too high" (from a search snippet; not on the fetched page) | n=2 **weak** | [OTM-TP], [RM-TP] |
| No human support, AI-only | OpenRent: "I couldn't talk to a human being" (Sep 2026, 1 star). Hammock: phone lines tell you to email | n=2 **thin** | [OR-TP], [HAM-TP] |
| Confusing landlord UX | OpenRent: "worst user experience EVER as a landlord" (Nov 2026, 2 stars); messages hard to find (Nov 2026, 2 stars) | n=1 portal | [OR-TP] |
| Sold-price / price-history gaps | MSE thread "sold prices not on rightmove" (old) and Zoopla wrong last-sold date (Sep 2026) | n=2 **thin** | [MSE], [ZP-TP] |
| Over-optimistic investment projections | Property Hub: 2-star review (Oct 2026): projections unrealistic, marketed as tenanted | n=1 **thin** | [PH-TP] |

What users praise (so we do not break it): OpenRent cost saving against agents, SpareRoom support staff, Landlord Vision support staff and dashboard, Hammock ease of setup and bank-feed MTD [OR-TP][SR-TP][LV-TP][HAM-TP].

Scores seen (Trustpilot, Nov 2026): Rightmove 3.2 (1,875 reviews), Zoopla 1.2 (3,681), OnTheMarket 2.4 (407), OpenRent 4.4 (8,744), SpareRoom 4.5 (21,162; one fetch gave 4.7), Landlord Vision 4.8 (368), Hammock 4.5 (104), Property Hub 4.6 (443).

## 3. Legitimate sources of live listings (England)

**Short answer:** no major portal gives a free public read API for listings. Scraping is forbidden by Rightmove, Zoopla, OnTheMarket and OpenRent as far as I could confirm. Do not build a scraper.

### 3.1 What the terms say

| Portal | Clause (quoted) | Link |
|---|---|---|
| Rightmove | 5.2: "scrape, hack, reverse engineer, compromise or impair the Platform;" and "use bots, crawlers, scrapers or other automated programs or means to access or collect data". 5.5.1: "extract or seek to extract information from the Platform, other than by means of direct human interaction". Footer: "Rightmove prohibits the scraping of its content." | [RM-TERMS], [RM-HOME] |
| Zoopla | "You shall not conduct, facilitate, authorise or permit any text or data mining or web scraping". Also: "Any "robot", "bot", "spider", "scraper" or other automated device, program, tool". Also: "Our Site must not be framed on any other website, application or platform" and "nor may you create a link to any part of our Site other than the home page, without prior agreement." | [ZP-TERMS] |
| OnTheMarket | 3.3: crawlers barred except the home page, unless they identify themselves and are "fully compliant with the Robots Exclusion Protocol". 8.4: "You are not permitted to use automated programs for such purposes." 2.2: no reproducing, storing or framing "(in whole or in part)" without written consent. | [OTM-TERMS] |
| OpenRent | 1.1: "You will not use software or any other means to harvest information from the website." | [OR-TERMS] |
| SpareRoom | Not verified. The terms page text was not captured. Assume restrictive. | [SR-HOME] |

Treat the Zoopla deep-link clause literally: a link to a search results page is a "link to any part of our Site". Ask for permission or leave Zoopla out of the link builder.

### 3.2 Official APIs

- **Rightmove:** the Real Time Datafeed is for authorised feed providers (agents and software vendors). It needs a Rightmove-issued certificate, Network ID and Branch ID [RM-RTDF]. It uploads listings. It does not serve public search. A third-party review says there is no public API for reading listings, sold prices or valuations; this is secondary, so confirm with Rightmove [RM-RTDF].
- **Zoopla, OnTheMarket, OpenRent, SpareRoom:** I found no public listings API. The terms I read mention none. Unverified beyond that; ask each company if you want a data agreement.
- A commercial data licence from Rightmove "Data Services" exists as a page link only [RM-HOME]; terms not seen.

### 3.3 Lawful alternatives

1. **Council choice-based lettings** (social housing, not market rent):
   - Leeds: Leeds Homes, about 4,000 lets a year with up to 1,000 housing-association nominations [LEEDS-CBL]. Past lets are also published as open data on [DATAMILL] (historic, not live).
   - Wakefield district (includes Pontefract, Castleford): Vico Homesearch. Membership needed to see council-nominee properties [WAK-CBL].
   - Doncaster: Doncaster HomeChoice via St Leger Homes. Local connection to Doncaster is needed; documents within 28 days or the application is not registered [DON-CBL].
   - App role: register-status tracker, bid log, reminders, links out. No scraping of their sites; check each site's terms before any automated read.
2. **User-pasted links and manual fields** (features 2, 3, 7). The user visits the portal. The app stores what the user types. This stays on the lawful side of "direct human interaction".
3. **User-owned email alerts** (feature 20). Parse alerts the user receives, on device only. Check each portal's alert terms; none were read.
4. **Prefilled search deep links** (feature 8). Safe only where terms allow. Zoopla's text says no.
5. **Open datasets for context, not listings:** Land Registry Price Paid (OGL v3, attribution needed) [LR-PPD]; ONS local price and rent pages [ONS-LEEDS]; EPC data (OGL v3 stated; bulk download needs a GOV.UK One Login) [EPC-DATA]; police API (15 requests per second average, burst 30) [POL-API]; LHA rates CSV [LHA-CSV]. Land Registry notes OGL does not cover third-party rights in address data, so keep PPD address use to display and matching [LR-PPD].
6. **RSS feeds:** not verified for any portal. Do not assume they exist.
7. **Letting agents' own sites and local landlord/community boards:** not researched here. Terms differ per site.

## 4. Local specifics

### 4.1 Prices and rents (ONS, latest seen)

ONS pages say local figures use small samples; use a year or more of trend. House prices are August 2026 (provisional); rents are September 2026 unless stated.

| Area (postcodes) | Avg price | Avg rent / month | 1 / 2 / 3 / 4+ bed rent | Link |
|---|---|---|---|---|
| Leeds (LS) | £246,000 (+2.4%); first-time buyers £215,000 | £1,148 (+4.5%) | not captured | [ONS-LEEDS] |
| Wakefield district (WF, incl. Pontefract WF8, Castleford WF10) | £199,000 (+2.9%); terraced £160,000 | £810 (+5.9%) | £579 / £730 / £874 / £1,224 | [ONS-WAKE] |
| Doncaster (DN) | £173,000 (+3.8%); terraced £135,000 | £699 (+5.2%) | £496 / £641 / £763 / £1,083 | [ONS-DON] |
| Rotherham (S60) | £191,000 (+0.7%) | £689 (+3.4%) | not captured | [ONS-ROTH] |
| Bradford (BD) | £185,000 (+2.1%) | £739 (+1.6%) | not captured | [ONS-BRAD] |
| North Yorkshire (covers Selby YO8 and Harrogate HG; no split) | £270,000 (+1.7%) | £852 (+2.3%) | not captured | [ONS-NYORKS] |
| Barnsley (S70) | £169,000 (Jan 2025) | £634 (Feb 2025); £460 / £572 / £685 / £1,006 | **stale: page last updated Mar 2025**; re-fetch before use | [ONS-BARN] |

Regional context: Yorkshire and The Humber rents rose 4.8% in the year to September 2026 [ONS-DON].

Pontefract and Castleford use Wakefield district figures; ONS does not split them in these pages. Postcode-level prices should come from PPD in-app.

### 4.2 Local Housing Allowance 2026-27 (monthly, UC LHA rates)

Source: gov.uk England rates CSV [LHA-CSV]. Values are monthly pounds. The sheet was read by the fetch tool; spot-check against the VOA lookup.

| BRMA | Shared (SAR) | 1 bed | 2 bed | 3 bed | 4 bed |
|---|---|---|---|---|---|
| Leeds | £347.62 | £675.00 | £775.00 | £850.00 | £1,200.00 |
| Wakefield | £326.98 | £500.00 | £595.00 | £725.00 | £885.00 |
| Doncaster | £304.17 | £425.00 | £500.00 | £550.00 | £725.00 |
| Barnsley | £316.33 | £415.00 | £450.00 | £550.00 | £775.00 |
| Rotherham | £351.33 | £430.00 | £500.00 | £550.00 | £817.50 |
| Harrogate | £421.33 | £595.00 | £735.86 | £875.00 | £1,275.00 |
| Bradford and South Dales | £326.33 | £450.00 | £525.00 | £635.00 | £750.00 |

Gaps and notes:
- **Selby has no BRMA row** in the fetched data. Which BRMA covers YO8 is **not verified**. The York row was shown instead (SAR £417.67, 1 bed £675, 2 bed £775, 3 bed £825, 4 bed £1,200) but I did not confirm Selby falls in it.
- Rows are named "Wakefield" (not "Wakefield and Castleford") and "Bradford and South Dales".
- A 2-bed LHA of £500 in Doncaster against a market 2-bed average of £641 (ONS) means a gap of about £141 a month. The same comparison for Wakefield is £595 against £730. Both are my arithmetic from the two sources above.
- The gov.uk landing page for 2026-27 LHA returned 404, so I could not confirm the freeze statement. One search result said councils describe rates as frozen; not verified.

### 4.3 Licensing and planning schemes

| Council | Scheme | Status | Link |
|---|---|---|---|
| Leeds | Selective licensing in parts of six wards: Armley; Beeston and Holbeck; Burmantofts and Richmond Hill; Hunslet and Riverside; Gipton and Harehills; Farnley and Wortley | Applications due 9 Feb 2026 for existing lets; new purchases within 14 days. Fee £1,100 online / £1,225 paper; revised two-part split from 26 Feb 2026. Penalty: unlimited fine or civil penalty up to £40,000. Designation period 9 Feb 2026 to 8 Feb 2031 per Kamma (secondary). Council has an interactive map and indicative street list | [LEEDS-SL] |
| Rotherham | Selective licensing in six areas (Town centre/Eastwood/Clifton/Boston Castle; Masbrough/Kimberworth; Thurcroft; Dinnington; Brinsworth; Parkgate) | In force 15 Feb 2026 for about 5 years; designation notice 14 Nov 2025. Early-application deadline 16 May 2026. A council page titled "1st May 2026 - April 2031" conflicts on the start date; check the council | [ROTH-SL] |
| Doncaster | Selective licensing, Hexthorpe only | Designation 1 Mar 2022; scheme page titled 2022-2027. Edlington ended 6 Feb 2023. Additional HMO licensing status not confirmed | [DON-SL] |
| Wakefield (covers Pontefract, Castleford) | No selective licensing found. Article 4 Direction for small HMOs (6 or fewer occupants) in specific areas, including Castleford Centre North and Castleford Smawthorne, plus four Wakefield city areas | Made 23 Oct 2024; due to take effect 24 Oct 2025, subject to confirmation (confirmation not seen). Pontefract not mentioned in any result. A council officer said selective licensing was unsuited to Wakefield (undated article) | [WAK-A4] |
| Barnsley | Unclear. A 2017 four-area proposal was put on hold after a legal challenge. A Barnsley Chronicle article (undated) describes accredited vs full licensing fees (£115 / £530 over five years). A council FOI response says no selective scheme was running at that time (undated) | **Not confirmed** | [BARN] |
| Bradford | Commercial sites claim additional HMO and selective licensing in inner-city wards; no official page found | **Unverified** | [BRAD] |
| Selby, Harrogate (North Yorkshire Council) | Not searched | Gap | n/a |

National note: since 23 Dec 2024 councils in England need no Secretary of State confirmation for selective licensing schemes of any size (from a gov.uk guide, via search result) [SL-GUIDE]. More areas can appear without notice. Build the licence checker so the user can add a council and a source link.

### 4.4 Renters' Rights Act and related law (England)

From the gov.uk Housing Hub landlord page [GOV-HUB]:

| Date | What |
|---|---|
| Royal Assent 27 Oct 2025 | Act passed [GOV-RRA] |
| In force 1 May 2026 | Section 21 abolished; possession needs a ground. Most tenancies become assured periodic; fixed terms banned. Rent increases once a year with at least two months notice. Rental bidding banned; adverts must state a specific rent. Advance rent capped at one month. No refusing renters for children or benefits. Tenants can give two months notice at any time |
| By 31 May 2026 | Existing tenancies: give the Renters' Rights Act Information Sheet (or a written record of terms if none) |
| 1 Jun - 30 Sep | Ground 4A student possession, with prior written notice before the tenancy starts |
| From 15 Dec 2026 | "Register your rental property" rollout by region, starting in the West Midlands. Landlord and each property must register. Yorkshire date not stated |
| Future, no date given | Ombudsman, Awaab's Law and Decent Homes Standard for the private rented sector |

Other points, all from secondary sources, marked as such:
- Law firms say a section 21 notice served before 1 May had to be followed by court proceedings started by 31 July 2026 [ALANB]; grounds for possession rose from 21 to 37 (reported by a landlord-advice site).
- PRS database fee reported as £65 per property per year by one law firm; another source says the fee will be confirmed nearer launch [OSBORNE]. Treat as unconfirmed.
- Disputes over rent increases: First-tier Tribunal now; a move to the Valuation Office was reported without a date [TROW].
- Awaab's Law Phase 1 began 27 Oct 2025 for social landlords only. The gov.uk page names no private-rented date [AWAAB].
- EPC: law-firm sources say the Warm Homes Plan (21 Jan 2026) sets an EPC C-equivalent minimum for private rentals by 1 Oct 2030, in England and Wales; the follow-up consultation response was not confirmed [SIMMONS][ELM]. Check gov.uk before shipping dates.
- Civil penalty up to £40,000 per property for offences from 1 May 2026 is stated on a Doncaster commercial guide [BELVOIR]; Leeds council says "up to £40,000" too [LEEDS-SL].
- Form 4A for rent increases is named only in commercial blogs [BLACKACRE]. Confirm on gov.uk.

Design rule: store every legal date with a source URL and a "last checked" stamp in app data. Ship updates via app releases, not live fetches.

## 5. Source keys

- [RM-TP] https://www.trustpilot.com/review/rightmove.co.uk
- [RM-TP-agent] https://ca.trustpilot.com/review/letlaunch.co.uk (agent page found by search; the Rightmove-related claims there are one reviewer each)
- [RM-TP-benefit] Joan, Sep 2026, same Rightmove Trustpilot page
- [OTM-TP] https://www.trustpilot.com/review/www.onthemarket.com
- [ZP-TP] https://www.trustpilot.com/review/zoopla.co.uk
- [OR-TP] https://www.trustpilot.com/review/openrent.co.uk
- [SR-TP] https://www.trustpilot.com/review/spareroom.co.uk
- [LV-TP] https://www.trustpilot.com/review/landlordvision.co.uk
- [HAM-TP] https://www.trustpilot.com/review/usehammock.com
- [PH-TP] https://www.trustpilot.com/review/propertyhub.net
- [RM-APP] https://apps.apple.com/us/app/rightmove-property-search/id323822803?see-all=reviews&platform=iphone
- [RM-APP-old] same page, 2021-2022 reviews (outside 24 months)
- [MSE] https://forums.moneysavingexpert.com/discussion/6267214/sold-house-still-on-rightmove and https://forums.moneysavingexpert.com/discussion/6033022/rightmove-no-longer-on-the-market/p2 (titles and search summary only; threads not opened)
- [MSE-gen] same MSE search, no thread read for agent no-reply; weak
- [RM-TERMS] https://www.rightmove.co.uk/c/terms-of-use/
- [RM-HOME] https://www.rightmove.co.uk/this-site/website-terms-of-use.html
- [RM-RTDF] https://media.rightmove.co.uk/ps/pdf/guides/adf/Rightmove_Real_Time_Datafeed_Specification.pdf
- [ZP-TERMS] https://www.zoopla.co.uk/terms/
- [OTM-TERMS] https://www.onthemarket.com/terms/
- [OR-TERMS] https://www.openrent.co.uk/terms
- [SR-HOME] https://www.spareroom.co.uk/content/terms-and-conditions/
- [GOV-HUB] https://housinghub.campaign.gov.uk/renting-is-changing/
- [GOV-RRA] https://www.gov.uk/government/publications/guide-to-the-renters-rights-act
- [AWAAB] https://www.gov.uk/government/publications/awaabs-law-guidance-for-social-landlords
- [ALANB] https://www.alanboswell.com/news/what-is-a-section-21-notice
- [OSBORNE] https://www.osborneclarke.com/insights/renters-rights-act-phase-2-introduces-landlord-database-and-rent-dispute-reforms-england
- [TROW] https://www.trowers.com/insights/2025/july/rent-increases-under-the-renters-rights-bill
- [BLACKACRE] https://blackacresurveyors.com/blog/section-13-rent-increase-form-4a-guide/
- [PIN] https://www.pinsentmasons.com/out-law/guides/renters-rights-act-2025-guide-private-landlords-england
- [NRLA] https://www.nrla.org.uk/resources/renters-rights
- [SIMMONS] https://www.simmons-simmons.com/en/publications/cmkws6657001itp58cb0i2cse/the-warm-homes-plan-mees-for-privately-rented-homes-epc-c-by-2030
- [ELM] https://www.elmhurstenergy.co.uk/blog/2026/01/22/domestic-private-rented-properties-required-to-meet-epc-band-c-by-october-2030/
- [INSIDE] https://www.insidehousing.co.uk/news/private-landlords-required-to-meet-epc-c-by-2030-90396
- [HAM-SITE] https://www.usehammock.com/mtd-software-for-landlords/
- [LV-SITE] https://www.landlordvision.co.uk
- [ACCWEB] https://www.accountingweb.co.uk/node/221700
- [LHA-CSV] https://www.gov.uk/csv-preview/69d654a2e1430e837a86f64a/england-rates-2026-to-2027.csv
- [LEEDS-SL] https://www.leeds.gov.uk/housing/information-for-landlords/selective-licensing
- [ROTH-SL] https://www.rotherham.gov.uk/housing/selective-licensing-2026-2031
- [DON-SL] https://www.doncaster.gov.uk/services/business-investment/selective-licensing
- [WAK-A4] https://www.wakefield.gov.uk/planning/planning-applications-and-advice/help-with-a-planning-application/article-4-direction-for-smaller-houses-in-multiple-occupation
- [BARN] https://www.barnsleychronicle.com/article/private-landlords-warned-to-clean-up-their-act and https://www.barnsley.gov.uk/media/00sccdgu/foi5290-additional-and-selective-licencing.pdf
- [BRAD] https://rentercheck.vercel.app/councils/bradford (commercial, unverified)
- [BELVOIR] https://www.belvoir.co.uk/?p=46977
- [SL-GUIDE] https://gov.uk/government/publications/selective-licensing-in-the-private-rented-sector-a-guide-for-local-authorities/selective-licensing-in-the-private-rented-sector-a-guide-for-local-authorities
- [LEEDS-CBL] https://leeds.gov.uk/housing/finding-a-home/lettings-policy
- [DATAMILL] https://datamillnorth.org/dataset/leeds-city-council-property-lets
- [WAK-CBL] https://www.wakefield.gov.uk/housing/finding-a-new-home/what-is-choice-based-lettings
- [DON-CBL] https://stlegerhomes.co.uk/find-a-home/doncaster-homechoice/allocations
- [LR-PPD] https://www.gov.uk/government/statistical-data-sets/price-paid-data-downloads
- [EPC-DATA] https://get-energy-performance-data.communities.gov.uk/
- [POL-API] https://data.police.uk/docs/api-call-limits/
- [EA-DOC unverified] Environment Agency flood API: not fetched; check terms before build
- [ONS-LEEDS] https://www.ons.gov.uk/visualisations/housingpriceslocal/E08000035/
- [ONS-WAKE] https://www.ons.gov.uk/visualisations/housingpriceslocal/E08000036/
- [ONS-DON] https://www.ons.gov.uk/visualisations/housingpriceslocal/E08000017/
- [ONS-ROTH] https://www.ons.gov.uk/visualisations/housingpriceslocal/E08000018/
- [ONS-BRAD] https://www.ons.gov.uk/visualisations/housingpriceslocal/E08000032/
- [ONS-NYORKS] https://www.ons.gov.uk/visualisations/housingpriceslocal/E06000065/
- [ONS-BARN] https://www.ons.gov.uk/visualisations/housingpriceslocal/E08000016/

## 6. Open items

1. Read the Reddit and MSE threads by hand (blocked here). Re-rank after.
2. Collect Goodlord, Coconut, Arthur Online, PropertyData and Property Tracker reviews.
3. Confirm: Form 4A, PRS database fee and Yorkshire rollout date, Wakefield Article 4 confirmation, Selby BRMA, Barnsley and Bradford licensing, Selby and Harrogate licensing, postcodes.io licence (about page returned 404), Environment Agency and UK HPI terms, SpareRoom terms.
4. Re-fetch Barnsley ONS rent (the page seen was March 2025).
