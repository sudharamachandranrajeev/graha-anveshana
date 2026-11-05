# Changelog

## Unreleased

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
