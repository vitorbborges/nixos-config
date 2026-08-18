# Price Sourcing — Gathering Maximum Available Price Information

Read this in full before quoting a price for any candidate. Follow it as a literal checklist, in order. Skip a step only where it says explicitly that it's optional.

## 0. Lock the exact identity first

Comparing prices across different SKUs, variants, or editions is invalid data, not just imprecise data. Before searching for a single price, pin down:
- Exact model number / SKU / edition (not just the product family or project name)
- Capacity/size/color/plan-tier variant, if the category has them
- Region/market version — a US-market SKU and an EU-market SKU of the "same" product are frequently different items with different prices and warranties
- New vs. refurbished/open-box/used — track as separate rows, never blend into one price
- For software/services: the exact pricing unit (per-seat, per-token, per-request, flat) — these don't compare directly until converted to a common unit

If the user named the item loosely, resolve it to the exact identity before continuing, and say what you resolved it to.

## 1. Set the search depth to the stakes

More search has a cost, and its payoff is bounded by how much price dispersion could plausibly exist for the item (Stigler, 1961 — the expected gain from one more price check scales with dispersion and with how much money is on the table). Use this to size the rest of this checklist:
- **Above ~$300 (or equivalent), or any recurring/metered cost**: run every numbered step below.
- **Roughly $50–300**: run steps 2, 3, 5; steps 4 and 6 are optional.
- **Below ~$50, or genuinely free/open-source with no paid tier**: run step 2 only, plus step 3 if a tracker exists. Stop there.

## 2. Current listed price — at least three source categories

Search and record price, availability, and any shipping/setup cost from each category that applies:
- **Manufacturer/official source** (official store, or official project site/repo for software)
- **Large general retailers**, or for services, the provider's own pricing page — match the user's region/currency; infer it from their language, stated currency, or location rather than defaulting to US sources
- **Multi-seller marketplaces** (Amazon marketplace, eBay) — list new and open-box/refurbished as separate rows; for software, list any reseller/bundle pricing separately too
- **Dedicated comparison aggregators** for the category/region (Google Shopping; regional aggregators such as Idealo, PriceRunner, PriceSpy, Trovaprezzi where applicable) — these surface sellers a plain search misses

## 3. Historical price — is "the price" actually a good price?

A current price with no history attached is unverifiable. Where a price-history tool exists (e.g. CamelCamelCamel or Keepa for Amazon listings, covering most major regional Amazon marketplaces), fetch it and note:
- All-time low and typical range
- Whether the current price sits at, above, or below the historical average
- Any obvious pattern (e.g. reliably discounted on a cycle)

If no tracker exists, check the Wayback Machine for archived snapshots of the listing as a fallback. If neither is available, say explicitly that no historical data was obtainable — don't imply a verification that didn't happen.

## 4. Sales-calendar awareness

Check whether a known sales event for the category/region is imminent (Black Friday/Cyber Monday, Prime Day or equivalent, back-to-school, a category-specific annual cycle). If one falls within a few weeks, say so explicitly and let the user weigh waiting against buying now — that call is theirs, not yours to make silently.

## 5. Stack the discount layer on top of the best listed price

After finding the best verified listed price from step 2, check what stacks on top of it:
- Cashback portals (Rakuten, TopCashback, or the regional equivalent)
- Retailer/provider coupon codes (search "`<source>` coupon code `<month/year>`")
- Card-linked or membership offers, only if the user has already told you which card/membership they hold — don't assume one
- For software/services: free tiers, usage credits, annual-vs-monthly billing discounts, and open-weight/self-hosted alternatives to a paid tier

Report the stacked total, not just the sticker price, whenever a real stackable discount is found.

## 6. Cross-region or cross-provider check — only when the gap looks large

If the item is meaningfully cheaper via a different region or provider, flag it, but attach the real added cost before treating it as comparable: customs/duties, extra shipping, warranty that may not transfer, return-shipping if it fails — or for services, migration effort, data-portability limits, and any loss of features. Never present a cross-region/cross-provider price as directly comparable without this adjustment; that's the total-cost-of-ownership principle applied to geography or platform.

## 7. Record everything in one ledger

One row per (source × condition/tier) combination, not one row per source:

| Source | Condition/Tier | Price | Extra cost (shipping/setup) | Total landed cost | Available now | vs. historical low | Checked |
|---|---|---|---|---|---|---|---|

Sort by total landed cost. The lowest row that is actually available and from a source you'd trust is the number that goes into the main comparison table in `SKILL.md` — not the first price you found.
