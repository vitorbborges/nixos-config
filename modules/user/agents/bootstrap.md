# Skill Activation Protocol

Your context includes an `available_skills` catalog. Skills are mandatory
workflows when they match the task — not reference material to skim.

## Before any task

1. Scan `available_skills`. If a skill's description matches the work you are
   about to do, load it with the skill tool and follow its workflow. Prefer a
   skill's workflow over improvising.
2. When a task moves into a new phase (implementation done -> review, feature
   complete -> cleanup), re-check the catalog for the phase's skill.
3. If no skill matches, work normally. Never force a skill onto a task.

## After compaction

Re-scan the catalog. A compacted context forgets which skill was loaded.

## Frequent triggers

| Situation | Skill |
|---|---|
| Any bug, failure, or unexpected behavior | systematic-debugging |
| Writing code test-first | tdd |
| A feature or task is complete | requesting-code-review |
| Large work spanning sessions | wayfinder |
| Long session needs to be handed off | handoff |
| NixOS build breaks | diagnosing-bugs or troubleshooting-nixos-build |
| Reviewing a diff for over-engineering | ponytail-review |
