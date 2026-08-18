# Cleanup Checklist — nixos-config

The full procedure used in the 2026-08 cleanup. Run top to bottom; each batch ends with dual-host builds.

## 0. Scope

- Two hosts: `desktop` (auto-imports `modules/system/` + `modules/user/`) and `oci-vps` (manual import lists in `hosts/oci-vps/default.nix` + selective `modules/server/default.nix`).
- A module is dead only if NO live reference exists anywhere. Comments and docs referencing a module do not keep it alive — they become cleanup targets themselves.

## 1. Flake input audit

For each input in `flake.nix`:
1. `grep -rn "<input-name>" --include="*.nix" .` — must appear in at least one module (via `inputs.` threading) or in `outputs`.
2. If the only hits are `flake.nix` + `flake.lock`: unused input → remove the input block, the `outputs` destructure mention, then `nix flake update` (or `nix flake lock --update-input` cleanup) to prune `flake.lock`.

Real example: `llama-fs` was defined, passed into `outputs`, but never threaded via `specialArgs` → dead.

## 2. Per-module sweep

For every directory in `modules/user/` and `modules/system/`:
- List packages/services it configures.
- `grep -rn "<package>" --include="*.nix" --include="*.lua" --include="*.sh" .`
- Live evidence: `home.packages`, `environment.systemPackages`, keybind in `modules/user/hyprland/generated.lua`, desktop entry, MIME default in `xdg.nix`, systemd unit, or explicit user confirmation.
- Dead evidence: only self-references, or references only in comments/stale docs.

## 3. Cross-cutting reference sweep (after any deletion)

`grep -rn "<deleted-name>" .` across ALL files (including `.md`, comments):
- `hosts/oci-vps/*.nix` — import lists and firewall comments
- `DISASTER_RECOVERY.md` — recovery paths that name modules
- `TODO.md` — mark done items, remove stale ones
- `AGENTS.md` — principles and workflow commands that name modules
- `modules/server/default.nix` — selective import list
- WireGuard/firewall configs — comments naming services being removed

## 4. VPS-specific deletions

Deleting a VPS module requires:
1. Remove from `hosts/oci-vps/default.nix` import list.
2. Sweep firewall ports/comments (e.g., ActivityWatch's 5600 in `wireguard.nix`).
3. Delete auxiliary files (`*.py` scripts next to the module).
4. Build `oci-vps` — NOT the desktop build — to verify.

## 5. Empty-directory hygiene

`rmdir` emptied module directories. Git doesn't track directories, but leaving them invites confusion.

## 6. Final verification

- `nix build .#nixosConfigurations.desktop.config.system.build.toplevel --no-link` → exit 0
- `nix build .#nixosConfigurations.oci-vps.config.system.build.toplevel --no-link` → exit 0
- `git status --short` — review staged deletions; nothing unexpected (other agents may be committing concurrently — check `git log --oneline -3`).

## Known bug class during cleanup edits

When you edit modules while cleaning, `builtins.replaceStrings` requires string replacements: wrap derivations `"${drv}"`, `toString` paths. This fires lazily — the trace header may point at an unrelated module.
