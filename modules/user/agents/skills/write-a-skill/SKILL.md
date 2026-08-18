---
name: write-a-skill
description: "Use when the user wants to create, draft, rewrite, or improve a Claude Code skill (a SKILL.md file) — including 'write a skill for X,' 'turn this into a skill,' 'make a skill that does Y,' or 'fix/improve this skill.' Also use when the user asks how to structure a skill, why a skill isn't triggering, or how to write instructions an LLM will actually follow. Make sure to use this whenever the user mentions skill authoring, agent instructions, or prompt design for a reusable capability, even if they don't say the word 'skill.'"
---

# Write a Skill

This skill's method combines Anthropic's own `skill-creator` skill (structure, triggering, progressive disclosure) with prompt-engineering research on instruction-following, since skills are themselves prompts that another model — sometimes a much smaller one — has to execute correctly. Citations are inline so you know *why* a rule exists, not just that it exists.

## Step 1 — Scope it before drafting anything

Answer these, asking the user only for what you can't infer from context:

1. What should the skill enable, precisely?
2. When should it trigger — what phrases or situations?
3. What's the expected output format?
4. **Will this skill be executed by a small/cheap model, or the same capable model doing the authoring?** This changes the instruction style — see Step 3.

If the current conversation already contains the workflow to capture (the user said "turn this into a skill"), extract the answers from what already happened instead of re-asking.

## Step 2 — Anatomy and mechanics

```
skill-name/
├── SKILL.md (required: YAML frontmatter + Markdown body)
└── references/   optional — docs loaded only when the skill points to them
    scripts/       optional — executable code for deterministic sub-tasks
    assets/        optional — templates/files used in the output itself
```

**Progressive disclosure — three levels, in order of what's always in context:**
1. Frontmatter (`name` + `description`) — always loaded, so this is the only thing guaranteeing the skill triggers at all. Keep it to a couple of sentences.
2. The SKILL.md body — loaded whenever the skill triggers. **Keep this under ~500 lines.** If a sub-procedure is pushing you past that, move it to a `references/` file and point to it explicitly ("read `references/x.md` now, before doing Y") rather than inlining it.
3. Bundled resources — loaded only on demand, so they don't cost context until actually needed. Reference files over ~300 lines should carry their own table of contents.

**The description is the entire triggering mechanism** — nothing in the body helps if the skill never fires. Anthropic's own guidance: Claude tends to *under*-trigger skills, so write descriptions a bit "pushy" — state both what the skill does and the contexts that should invoke it, even contexts where the user won't use the skill's own name. Compare:
- Weak: "Helps with dashboards."
- Better: "Build a dashboard for internal data. Use this whenever the user mentions dashboards, data visualization, internal metrics, or wants to display company data — even if they don't say 'dashboard.'"

**Multi-domain skills** (the skill covers several frameworks/variants): keep SKILL.md as the shared workflow and selection logic, and split each variant into its own `references/<variant>.md` — the executing model only reads the one it needs.

**Principle of lack of surprise:** a skill's behavior must match what its description promises. Never author a skill designed to mislead, exfiltrate data, or exceed the access its description implies.

## Step 3 — Instruction-writing principles

**General, for any skill:**

- **Prefer imperative instructions** ("Do X") **and explain why in one clause** rather than stacking bare MUSTs — the reason is what lets the executing model generalize to cases you didn't enumerate.
- **Put the load-bearing constraints at the start and the end, not buried in the middle.** Models attend to the beginning and end of a context far more reliably than the middle — a controlled study found retrieval accuracy dropped sharply for information placed mid-context even when it was easy to find at either end (Liu et al., "Lost in the Middle," 2023). Restate your single most important non-negotiable right after the title, and again as the last line.
- **Keep the total instruction count low, and order them.** Compliance with *every* instruction in a prompt drops off roughly exponentially as the number of independent instructions grows (2025 work on multi-constraint prompting, sometimes called the "curse of instructions"). One ordered numbered procedure beats a flat pile of a dozen independent rules — group and sequence, then push anything non-essential to a reference file instead of adding it as instruction #13.
- **Use real structural delimiters** — Markdown headers, numbered steps, tables — not dense prose paragraphs carrying instructions. Claude is specifically tuned to attend to structure, and clear delimiters measurably reduce the model confusing instructions with content.
- **Draft, then reread with fresh eyes before showing the user.** The first draft is usually over-hedged or under-specified in ways that are obvious on a second pass and invisible on the first.

**If the skill will run on a smaller/cheaper model (Step 1, question 4):**

- **Decompose the task yourself — don't rely on the model to reason its way there.** Chain-of-thought-style prompting ("think step by step") only reliably improves outcomes above a scale threshold researchers place around 100B+ parameters; below that threshold it can be neutral or even worse than direct instructions (Wei et al., 2022). If the skill needs multi-step reasoning, write out the steps explicitly and in order — do the decomposition in the skill text itself, the way you'd write a procedure for a competent but literal-minded junior, not a hint for a expert to elaborate on.
- **Don't lean on multiple examples to teach a pattern.** It's tempting to add three worked examples and let the model infer the rule — but the benefit of in-context examples for inferring a *pattern* grows with model size; smaller models lean more on their pretrained priors and show only marginal gains from extra examples (consistent across recent scaling studies, e.g. on the Qwen model family). Give **one** concrete, literal output template to fill in instead of several examples to generalize from — a template is a mold, not a pattern to induce, and molds transfer to small models far more reliably.
- **Keep the skill narrow and single-purpose.** Small models are already competitive with large ones on well-scoped, narrow tasks; the gap shows up on broad, ambiguous, generalist ones (Belcak et al., NVIDIA, "Small Language Models are the Future of Agentic AI," 2025). If a skill is trying to cover too much ground, that's a sign to split it, not to write more caveats into one file.

## Step 4 — Draft

Write the SKILL.md applying Steps 2 and 3. Default to no bundled resources; add `references/` only once the body would otherwise exceed roughly 400–500 lines or needs to branch by domain/variant.

## Step 5 — Self-check before showing the user

Reread the draft and confirm:
- [ ] The description alone (no body) would make Claude trigger this in the right conversations, including phrasings that don't use the skill's own vocabulary
- [ ] The single most important constraint appears in the first paragraph and again in the last
- [ ] Every instruction is either in one ordered sequence, or clearly marked as conditional/optional
- [ ] Nothing asks the executing model to run a script, hit an API, or read a file that doesn't actually exist in this environment
- [ ] If built for a smaller model: no step assumes an inferential leap; there's at most one template to fill, not several examples to generalize from

## Step 6 — Validate, lightly

Full benchmark harnesses (Anthropic's internal `skill-creator` runs paired with/without-skill evals through dedicated aggregation and viewer scripts) aren't available in this environment — don't reference scripts or tooling that isn't actually installed here. Instead:

1. Draft 2–3 realistic test prompts — the kind of thing the user would actually type — and confirm them with the user before running anything.
2. If the user wants rigor: launch two fresh subagents in parallel for the same prompt, one told to use the new skill, one with no skill, and compare outputs side by side.
3. Otherwise, just walk through a prompt manually with the skill in mind and sanity-check the output against Step 5's checklist.
4. Revise based on what breaks. Repeat once or twice, not indefinitely — this is a judgment call, not a fixed loop count.

## Step 7 — Save it in this repo

This is a NixOS system — files outside of `nixos-config` don't survive a rebuild. To make a skill persistent:

1. Write it to `modules/user/agents/skills/<skill-name>/SKILL.md` (plus any `references/`, `scripts/`, `assets/` alongside it).
2. That's it — `modules/user/agents/skills.nix` recursively materializes every skill under `modules/user/agents/skills/` to `~/.claude/skills/` on rebuild. No registration step, no import list.
3. `git add` the new files — untracked files are invisible to the flake evaluator even with a dirty tree.
4. Validate before asking the user to switch: `nix build .#nixosConfigurations.desktop.config.system.build.toplevel --no-link` catches evaluation errors without needing sudo.
5. Ask the user to run `sudo nixos-rebuild switch --flake ~/nixos-config#desktop` themselves — this session cannot run sudo interactively.
