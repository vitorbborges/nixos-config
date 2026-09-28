---
name: savings-plan
description: Manage the user's labeled savings system (retirement / emergency / purchase labels). Use whenever the user expresses wanting to buy something ("I want to buy…", "save for…", "wishlist", "new purchase"), wants to reprioritize savings goals, or reports money arriving (salary, benefits, bonus, "just got paid") — even if they never say "savings plan". Also use for questions about how much they can spend on a planned item.
---

# Savings Plan Skill

**HARD RULE: money never moves between buckets. Purchases never touch Retirement or Emergency. If a purchase would overflow the purchases pool, shrink other purchase labels — never the other buckets.** Restated at the end.

The user's savings system is three physical positions at Trade Republic:

| Bucket | Vehicle | Rule |
|--------|---------|------|
| Retirement | World equity ETF (VWCE) + all BRL holdings | Never touched until FIRE |
| Emergency | €STR money-market ETF (XEON) | Target = 6 × monthly living costs |
| Purchases | €STR money-market ETF, different ticker (DBX0AN) | Pool split among labeled goals |
| Living | TR cash | Card float only — no savings in cash |

**Read these two files at the start of every run — all numbers live there, never in this skill:**
- `~/Projects/Investments/knowledge/wallets.md` — current targets, the bucket split percentages (two phases: while emergency below target, after), investable flow components, lump-sum rules
- `~/Projects/Investments/knowledge/savings_labels.md` — the purchase label ledger (share = stars ÷ total stars of active labels)

Procedural facts:
- All buys happen via TR savings plans (€0 fee); sells cost €1
- Automated TR sync (pytr) is abandoned — the user reports TR numbers from the mobile app manually
- Use the amounts the user reports each time; never assume last month's numbers

## Mode 1 — New purchase idea

Trigger: user wants to buy something. Do not judge the idea; the grill decides.

1. Ask these 5 questions (numbered, one message):
   1. Target price in €?
   2. When do you want or need it (months)?
   3. Want level 1–10?
   4. Need (replacing something broken) or want (new)?
   5. Does it outrank any existing label?
2. Verdict: recommend creating a label only if it is a need or want ≥ 7. Otherwise recommend skipping or a lower priority, and stop.
3. If creating: ask stars (1–5 importance). Append the row to the Active Labels table in `savings_labels.md`:

`| {name} | €{target} | {stars} | {share}% | €0 | {today} |`

4. Recompute Share % for ALL active labels.
5. Tell the user this label's monthly € = share × the purchases pool (pool value from wallets.md split).

## Mode 2 — Payday allocation

Trigger: salary, benefits, bonus, or any money arrived.

1. Ask for: amount received this month (€) and TR app values (VWCE €, XEON €, DBX0AN €, cash €).
2. Compute the bucket split from wallets.md (while Emergency below target vs after).
3. Per label: label € = share % × purchases-pool amount.
4. Output ONE action list using this template, nothing else:

```
1. In TR app: XEON savings plan → set amount €{xeon} (edit plan, €0 fee)
2. In TR app: DBX0AN savings plan → set amount €{dbx0an}
3. (only after emergency target reached) VWCE savings plan → set amount €{vwce}
4. Labels this month: {label1} €{x}, {label2} €{y}
```

5. Update the TR table in `~/Projects/Investments/knowledge/holdings/index.md` and `Saved €` in `savings_labels.md`.

## Mode 3 — Maintenance

- "reprioritize" → ask which label changes stars → recompute all shares
- Label bought → mark ✅, move to Archived, recompute shares
- Label abandoned → ask "sure?" once → move to Archived
- Impulse buy overflowed the pool → shrink other active labels' saved-so-far proportionally; NEVER touch XEON or VWCE/BRL holdings
- Emergency target changes ONLY when actual living costs change (target = 6 × new monthly living costs); confirm the new living cost with the user before editing wallets.md

## Final check every run

Before finishing: confirm no bucket-crossing appeared anywhere in what you wrote, and that the emergency target was not edited without a real living-cost change.

**HARD RULE restated: money never moves between buckets. Purchases never touch Retirement or Emergency.**
