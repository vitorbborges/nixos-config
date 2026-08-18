---
name: product-purchase-research
description: "Use when the user wants to research a product or tool before acquiring it — comparing alternatives, checking whether a price is good, or deciding what to get. Triggers on 'should I buy,' 'compare X vs Y,' 'what's the best,' 'help me find,' 'is this a good price,' 'which one should I get,' or naming a product/service category and asking for a recommendation — including free/open-source tools, where 'price' means total cost of adoption, not just a sticker price. Do not use this for pricing the user's own product or service."
---

# Product Purchase Research

**Non-negotiable, read before doing anything else:** every price you state must be verified via step 4 (which points to `references/price-sourcing.md`) — never state a price from memory or a single unverified listing. Every run of this skill ends in the exact output block in step 8. These two rules override anything else in this file if they ever conflict.

You are helping the user decide what to acquire, as the buyer — not pricing something the user sells (see the description above). Treat every step below as a concrete, ordered action. Do them in order; don't skip ahead by guessing what a later step wants.

## The procedure

1. **Pin the target.** Write down: budget ceiling, must-have features (hard cutoffs — anything failing one of these is eliminated, no exceptions), nice-to-haves (used only to break ties among survivors), how the thing will actually be used, and how long it needs to last. Use what the user already told you as-is — don't re-ask for it. If something load-bearing is missing, ask one short question; don't interrogate.

2. **Find candidates.** Search retailer/project listings, independent expert reviews for the category, and community discussion ("best `<category>` reddit", relevant forums) to build a wide raw pool. This step is about coverage, not judgment — don't filter yet.

3. **Eliminate on hard constraints.** Drop any candidate that fails even one must-have from step 1. A candidate that's disqualified gets no partial credit for being good elsewhere. Filter before you compare — people who filter first and score second reach better decisions faster than people who try to score everything at once (Payne, Bettman & Johnson, 1993).

4. **Verify price for every survivor.** Open and follow `references/price-sourcing.md` in full for each remaining candidate before writing down a single price. Do not compare, rank, or quote a price you haven't run through that procedure.

5. **Cut to 3–6 finalists.** If more than six candidates survive step 3, go back and tighten step 3's cutoffs — don't just present a longer list. Showing more options produces *worse* decisions, not better ones: in a controlled retail experiment, a 24-option display converted at roughly a tenth the rate of the same product shown with 6 options (Iyengar & Lepper, 2000).

6. **Score the finalists.** Fill in the table from step 8 — one row per finalist, one column per criterion from step 1, plus the verified price from step 4.

7. **Sanity-check reviews and ratings before trusting them.** Weight independent professional reviews, and a large sample of real user reviews (the 3-star ones are usually the most informative), over any raw average score. A high average built on few ratings is weak evidence: one field experiment found that a single artificial early positive rating inflated a post's final average by roughly 25% through herding (Muchnik, Aral & Taylor, *Science*, 2013), and organized markets for fake reviews are documented and active (He, Hollenbeck & Proserpio, 2022). A burst of near-identical five-star reviews, or (for open-source projects) a star-count growth rate wildly out of line with comparable well-known projects, is a red flag — investigate it, don't repeat it as a selling point.

8. **Output exactly this block, every time:**

   ```
   | Finalist | <criterion 1> | <criterion 2> | ... | Verified price |
   |---|---|---|---|---|

   Recommendation: <name> — <the one or two reasons it wins>
   Red flags found: <fabricated discount / suspicious rating pattern / decoy tier / none>
   Where to get it, and timing: <source(s), and whether now is a good time or worth waiting>
   ```

## Two more checks — apply only when they're relevant

**Total cost of ownership.** For anything with ongoing costs (electronics, appliances, vehicles, subscriptions, metered APIs): add consumables, maintenance, hosting/usage costs, and expected depreciation to the sticker price before ranking. The cheaper-to-acquire option is sometimes the more expensive one to run.

**Extended warranties / protection plans.** Default to recommending against them — they typically carry negative expected value (premiums of roughly 10–50% of item price against sub-5% failure rates in the covered window, with 50–70% margins for the seller). Recommend one only when the item is unusually fragile, expensive to repair relative to its price, or the specific model has documented reliability problems — and say explicitly which of those applies.

---
**Reminder, because this matters twice as much as anything in the middle of this file:** you are not done until (a) every stated price came from `references/price-sourcing.md`, and (b) your final message contains the step 8 output block in full — table, recommendation, red flags, and where/when to buy.
