---
name: cleaning-nixos-config
description: "Finds and removes dead modules, unused flake inputs, orphaned scripts, and stale cross-references in this NixOS config repo. Use when the user asks to clean up the config, remove packages or applications they no longer use, audit for dead code, or do a repo-wide sweep for leftovers from past work."
---

# Cleaning the NixOS Config

You are auditing `~/nixos-config` for dead weight: modules that configure packages the user no longer uses, flake inputs nothing references, orphaned files, and comments/docs that point at deleted modules. The user's standard for removal is evidence-based — a module is only dead if nothing live references it. When in doubt, ask; never delete on vibes.

## The procedure

Do these in order. Each deletion batch ends with a dual-host build check before moving to the next batch.

### 1. Trace the import graph

- `flake.nix` → `nixosConfigurations.desktop` imports `./modules/system` (recursive auto-import) and `home-manager.users.vitor` imports `./hosts/desktop/home.nix` → `./modules/user` (recursive auto-import). `oci-vps` imports `./hosts/oci-vps/default.nix` (manual list) and `./modules/server/default.nix` (selective list).
- Consequence: any `.nix` file in `modules/system/` or `modules/user/` is live for the desktop host even if no other file mentions it. The oci-vps host only sees files explicitly listed in its import lists — a module can be dead for the VPS while live for the desktop.
- List every module directory. For each, note which packages/services it configures.

### 2. Grep for live references

For each candidate package/module, grep the whole repo:

```bash
grep -rn "<module-name>\|<package-name>" --include="*.nix" --include="*.md" .
```

Evidence that a module is LIVE:
- package name in `home.packages` / `environment.systemPackages`
- keybind launching it in `modules/user/hyprland/generated.lua`
- desktop entry, MIME default (`modules/user/xdg/xdg.nix`), systemd unit/timer
- user said they use it

Evidence that it is DEAD:
- the only references are the module defining itself
- references only in comments and stale docs (comments rot too — they count as cleanup targets, not as evidence of life)

### 3. Categorize and confirm with the user

Report findings as a table: file(s), what it does, why suspected dead, and evidence. Mark which deletions you believe are safe vs. which need confirmation. This repo's history shows the user keeps intentional redundancy sometimes (e.g., an extra offline backup layer) — one layer of redundancy is not "dead", two mechanisms that do the same thing may be. Ask before deleting anything that could be intentional.

### 4. Delete in batches

- Delete the files, remove stale references (imports, comments, docs like `DISASTER_RECOVERY.md` / `TODO.md` / `AGENTS.md`), and `rmdir` emptied directories.
- `git add -A` after every batch — untracked files are invisible to the flake evaluator, and deleted-but-tracked files cause "not tracked by Git" errors.

### 5. Verify both hosts build

```bash
nix build .#nixosConfigurations.desktop.config.system.build.toplevel --no-link
nix build .#nixosConfigurations.oci-vps.config.system.build.toplevel --no-link
```

Both must exit 0 before the batch is done. VPS-only deletions still require the VPS build check, not just desktop.

### 6. Final orphan sweep

After all batches: grep for every deleted module/package name one more time (including comments and markdown). Fix or remove anything that still mentions them, then re-run the dual build.

## What is NOT dead (do not touch)

- Anything the user explicitly said to keep (they track this actively — re-confirm rather than assume).
- Runtime state files that herdr or other agents manage in-tree (they regenerate on rebuild).
- Files referenced as Nix sources (`./file` paths inside modules) — even "generated-looking" ones.

## Output format

End with a table: what was deleted, what was edited (with file paths), and the dual-build exit codes. Mention anything you flagged but did not delete because it needed user confirmation.

## References

- `references/cleanup-checklist.md` — the full checklist used in the 2026-08 cleanup, including the flake-input audit steps and the "replaceStrings derivation coercion" bug class that surfaces during module edits.
