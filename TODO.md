# NixOS Config TODO

## Neovim

- [x] **GitHub Copilot** — `blink-cmp-copilot` enabled; authenticated.

- [ ] **LSP cleanup** — archive `vitorbborges/nvim-config` repo on GitHub (manual).

---

## Development

- [ ] **Replace `conda` with `uv` + nix devshells** — conda conflicts with NixOS FHS; migrate envs to `uv venv`, then remove from `python.nix`.

---

## Deferred

- [ ] **`asusctl` keyboard RGB** — `services.asusd` already enabled; set profiles with `asusctl aura -m static -c RRGGBB`.

- [ ] **ActivityWatch** — verify `services.activitywatch` works on baremetal.

- [ ] **`hosts/` abstraction** — isolate per-machine specifics into `hosts/vivobook/` (hardware config, monitor layout, PRIME bus IDs).
