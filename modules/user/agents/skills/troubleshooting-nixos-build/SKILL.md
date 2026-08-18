---
name: troubleshooting-nixos-build
description: "Diagnoses nixos-rebuild evaluation and build failures in this flake-based NixOS config. Use when a build fails, nix eval reports an error, a module change breaks the flake, or files suddenly become invisible to the evaluator."
---

# Troubleshooting NixOS Builds

You are debugging a flake-based NixOS config with home-manager as a NixOS module and recursive auto-imports (`modules/user/default.nix`, `modules/system/default.nix`). Most failures fall into a small set of known classes — classify before guessing.

## Step 1 — reproduce with the sudo-free build

```bash
nix build .#nixosConfigurations.desktop.config.system.build.toplevel --no-link
```

Add `--show-trace` to get the real error origin. Read the FULL trace — this is the critical step.

## Known error classes (check these before anything else)

### A. Lazy-evaluation misdirection

The trace header names one module while the true error is elsewhere. Example from real history: error surfaced under `fonts.fontconfig.configFile.fonts.settings` but the actual bug was a `builtins.replaceStrings` call in an unrelated module being lazily evaluated. Rule: read the entire trace to the last "while evaluating" frame, and look for the first mention of YOUR changed code.

### B. `replaceStrings` type errors ("expected a string but found a set")

`builtins.replaceStrings [ "@x@" ] [ value ] text` requires `value` to be a string. Derivations and paths are NOT coerced (unlike `${...}` interpolation which is). Fix: `[ "${drv}" ]` or `[ (toString path) ]`.

### C. "Path ... is not tracked by Git"

A module references a file via `./path` or `builtins.readFile ./path` but the file isn't `git add`ed. Nix flakes only see git-tracked files — untracked files are invisible even with a dirty tree. Fix: `git add` the file. Also fires for deleted-but-tracked files during cleanup batches.

### D. Option merge conflicts

Two modules define the same option at the same priority (e.g., a service's `style`/`text` field vs. a stylix target). Check whether one should use `lib.mkDefault`/`lib.mkAfter`/`lib.mkForce`, or whether the auto-target should be disabled with a documented `enable = false`.

### E. Auto-import surprises

Every `.nix` in `modules/user/` and `modules/system/` is imported automatically. A new file with a syntax error, wrong function args, or an undefined flake input breaks the build even if nothing imports it explicitly. New modules must declare `inputs` as a function argument if they use flake inputs (see AGENTS.md principle 5).

### F. Missing/wrong function arguments

Home-manager modules get `{ pkgs, config, lib, inputs, pkgs-stable, ... }` via `extraSpecialArgs`. A module referencing `pkgs-stable` or `inputs` without declaring them fails at eval. System modules get `{ inputs, username, kbLayout, pkgs-stable, theme, ... }` via `specialArgs`.

## Step 2 — fix one thing at a time

Apply a single fix, re-run the build, and only move on when it passes. If the error changes, you're progressing. If the same trace persists, your fix didn't touch the real cause (see class A).

## Step 3 — verify both hosts

A desktop-only fix must still pass the VPS build (shared `modules/user/` is partially imported there via `modules/server/default.nix`):

```bash
nix build .#nixosConfigurations.oci-vps.config.system.build.toplevel --no-link
```

## Step 4 — post-build checks

- Grep the built home-manager files for unsubstituted `@placeholder@` tokens.
- If the fix touched a script, run it by name to confirm runtime behavior.
- `git status` — confirm intended files only; other agents may be committing concurrently (check `git log --oneline -3` before assuming your change is unpushed).

## Output format

Report: the true error (class + one-line), the fix (file + diff), and dual-host build exit codes.
