# Changelog

## Unreleased

- Hunt is now **Homes** and Research is now **Areas**, with new icons. Homes is the list of homes
  you are considering; Areas tells you about a place (any UK postcode) and works out purchase tax.
  Each page's tip says which is which, and a home's **Area report** opens Areas for its postcode.
- Every photo of an advert, not just the first: swipe through them on the home's page. PropertyPal
  adverts and Brahma Watch alerts bring them all (needs the latest Brahma Watch for alerts).
- Android: Rightmove, Zoopla, OnTheMarket, OpenRent and Facebook Marketplace open inside the app.
  On an advert, **Save to Homes** brings in its photos, price, bedrooms and address; saving it again
  refreshes the home. **Open the advert** on a saved home opens it here too, so older homes can
  pick up their photos.
- Android: share an advert link to Anveshana from a portal's app or your browser.
- Searches: Zoopla and Facebook Marketplace join the portal searches.

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
