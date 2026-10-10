# Security-audit CLI tools for an on-demand NixOS pipeline

Research date: 2026-10-10. Scope: one-shot tools for a root-run `security-audit`
script on this repo's immutable, flake-based NixOS desktop. Selection criteria:
packaged in current nixpkgs, no dependency on an always-running daemon, useful
signal on an immutable store, runtime from seconds to a few minutes.

Existing baseline (already in `modules/system/security-audit/`): `lynis` 3.1.7,
`AIDE` 0.19.4 (watches `/etc`, `/boot`, `/root`), and built-in
`nix store verify --all`.

Every nixpkgs attribute name was verified with `nix eval nixpkgs#<attr>.name`
against the current nixpkgs (nixos-unstable) on the date above; versions shown
are those eval results. Legend: **root** = root needed/recommended, **net** =
network required, **time** = typical runtime.

## Comparison

| Tool | What it checks | nixpkgs attr (eval version) | root / net / time | NixOS caveats | Source |
|---|---|---|---|---|---|
| kernel-hardening-checker | Kconfig + boot cmdline + sysctls vs KSPP hardening recommendations | `kernel-hardening-checker` (0.6.17.1) | root recommended / no / <10 s | Autodetect works here (`/proc/config.gz` present; fallback `nixpkgs#linux.configfile`). Many KSPP `FAIL`s are deliberate NixOS trade-offs, not bugs. | [repo](https://github.com/a13xp0p0v/kernel-hardening-checker) |
| vulnix | CVE advisories for derivations in the closure, matched against NVD | `vulnix` (1.12.5) | no (needs store DB / nix-daemon) / yes (NVD sync, cached) / first sync minutes, scan seconds–minutes | Name/version matching is a coarse heuristic (documented upstream) → false positives; whitelist discipline needed. Point at the running closure, not all GC roots. | [repo](https://github.com/nix-community/vulnix) |
| spectre-meltdown-checker | CPU transient-execution vulnerabilities and current mitigation state | `spectre-meltdown-checker` (26.36.0602723) | yes (full MSR-level detail; degraded as non-root) / no / <30 s | Reports running kernel + boot cmdline; re-run after kernel/boot changes. Upstream exit codes are coarse. | [repo](https://github.com/speed47/spectre-meltdown-checker) |
| systemd-analyze security | Exposure/sandboxing score per systemd unit (capabilities, namespaces, filesystem access) | part of `systemd` (no extra install) | no (root to see all system units) / no / ~5–15 s | Measures sandboxing, not vulnerabilities; NixOS units are upstream defaults, so mediocre scores are normal and often only fixable via overrides. | [systemd-analyze(1)](https://www.freedesktop.org/software/systemd/man/latest/systemd-analyze.html) |
| fwupdmgr security | Host Security ID (HSI): firmware protections (BootGuard/ME, Secure Boot, IOMMU, TPM, SPI locks…) | `fwupd` (2.1.6); service already enabled in `modules/system/hardware-maintenance.nix` | no (polkit; daemon D-Bus-activated) / only for LVFS suffix checks / seconds | Daemon-backed (D-Bus activation), hardware-dependent; ratings describe vendor firmware and cannot be fixed in software. Manual check, not pipeline material. | [HSI spec](https://fwupd.github.io/libfwupdplugin/hsi.html) |
| sbctl | Secure Boot state, keys, and setup mode (UEFI only) | `sbctl` (0.18) | yes / no / seconds | Only meaningful when pursuing Secure Boot (e.g. lanzaboote), which this repo does not currently use; otherwise it just reports disabled. | [repo](https://github.com/Foxboron/sbctl) |
| unhide | Hidden processes and TCP/UDP ports via syscall vs `/proc` diffing | `unhide` (20240510) | yes / no / seconds | Targets kernel-level stealth rootkits; low expected hit rate on NixOS since store content is already hash-verified, but cheap. | [repo](https://github.com/YJesus/Unhide) |
| osquery | SQL queries over live system state; standalone `osqueryi`, no daemon | `osquery` (5.23.1) | some tables need admin / no / seconds per query | Value equals the query set you write (overlaps lynis); event/audit tables need extra services. | [osqueryi docs](https://osquery.readthedocs.io/en/stable/introduction/using-osqueryi/) |
| clamav | Malware signatures in files (`clamscan` one-shot) | `clamav` (1.5.4) | optional, yes for all files / yes (freshclam DB) / minutes–hours | Needs writable DB dir (`services.clamav` on NixOS); store binaries are hash-verified, so only `/home` is worth scanning; too slow for this pipeline. | [repo](https://github.com/Cisco-Talos/clamav) |
| fail2ban | Auth-log patterns → IP bans | `fail2ban` (1.1.1) | yes / no / continuous daemon | Long-running service, not one-shot; fits the VPS, not a desktop audit. | [site](https://www.fail2ban.org/) |
| openscap (`oscap`) | SCAP/XCCDF policy compliance from content datastreams | `openscap` (1.4.2); content: `scap-security-guide` (0.1.82) | sometimes / no / minutes+ | No NixOS-tailored SCAP content; shipped guide targets RHEL/Ubuntu → mostly inapplicable findings. | [repo](https://github.com/OpenSCAP/openscap) |
| checksec | ELF hardening flags (RELRO, PIE, NX, canary, fortify) | `checksec` (3.2.0) | no / no / ms per binary | Per-binary only, no system-wide mode; nixpkgs builds with hardening by default, so redundant. | [docs](https://slimm609.github.io/checksec/) |
| auditd | Kernel audit events per rules (`auditctl`/`ausearch`) | `audit` (4.2.1) | yes / no / continuous | Event daemon, not a scanner; one-shot value is `auditctl -l`; requires persistent service + log review. | [repo](https://github.com/linux-audit/audit-userspace) |
| lynis | Broad host hardening audit (baseline, already installed) | `lynis` (3.1.7) | yes (recommended) / no / 1–3 min | NixOS-unaware package-manager and `/etc` checks produce noise; still the broadest single host audit. | [site](https://cisofy.com/lynis/) |
| cve-bin-tool | CVEs in detected binaries | `cve-bin-tool` (3.4) | no / yes (NVD download) / long | Heavy dataset; binary detection is inferior to vulnix for Nix closures. | [repo](https://github.com/intel/cve-bin-tool) |
| ssh-audit | SSH server/client algorithm and policy audit | `ssh-audit` (3.9.0) | no / yes (connects to endpoint) / seconds | Needs a live SSH endpoint; sshd is not enabled on this desktop, so moot locally. | [repo](https://github.com/jtesta/ssh-audit) |
| tiger | Legacy host security audit scripts | **not in nixpkgs** | — | `nix eval nixpkgs#tiger` fails; upstream is Debian-oriented and effectively dormant. | [savannah](https://savannah.nongnu.org/projects/tiger/) |
| rkhunter | Rootkit detection | **not in nixpkgs** | — | `nix eval nixpkgs#rkhunter` fails. Use `unhide` if rootkit checks are wanted. | [sourceforge](https://sourceforge.net/projects/rkhunter/) |
| chkrootkit | Rootkit detection | **removed from nixpkgs** | — | Eval error: "removed as it is unmaintained and archived upstream and didn't even work on NixOS". | [upstream](https://www.chkrootkit.org/) |

## Recommended for the pipeline

1. **`kernel-hardening-checker`** — fastest high-signal local check (kernel Kconfig + cmdline + sysctl vs KSPP, no network); run as `sudo kernel-hardening-checker -a -m show_fail`.
2. **`vulnix`** — the only tool that reasons about Nix closures; `sudo vulnix /run/current-system` catches known-CVE package versions that `nix store verify` cannot (it checks hashes, not advisories).
3. **`spectre-meltdown-checker`** — verifies CPU vulnerability mitigations are actually active on this Intel laptop; seconds, no network, complements the kernel-config view.
4. **`systemd-analyze security`** — zero-install unit sandboxing/exposure report; shows service-level attack surface nothing else in the pipeline covers.

Free extras already available (run manually, not automated): `fwupdmgr security`
(fwupd service is already enabled) and `sbctl status` — both report hardware/firmware
state rather than OS hygiene.

## Not recommended (or manual-only) and why

- **fail2ban** — long-running daemon, not one-shot; belongs on the VPS ([site](https://www.fail2ban.org/)).
- **auditd** — continuous event logging, not a scanner ([repo](https://github.com/linux-audit/audit-userspace)).
- **clamav** — signature DB needs network and writable state; scans too slow, and store content is hash-verified ([repo](https://github.com/Cisco-Talos/clamav)).
- **openscap/oscap** — no NixOS SCAP content; shipped guide targets RHEL/Ubuntu ([repo](https://github.com/OpenSCAP/openscap)).
- **osquery** — standalone `osqueryi` works, but needs hand-written query sets; duplicates lynis for more effort ([docs](https://osquery.readthedocs.io/en/stable/introduction/using-osqueryi/)).
- **unhide** — low expected signal on an immutable, hash-verified store; add only if stealth-rootkit paranoia matters ([repo](https://github.com/YJesus/Unhide)).
- **checksec** — per-ELF flags, no system-wide mode; nixpkgs hardens by default ([docs](https://slimm609.github.io/checksec/)).
- **cve-bin-tool** — heavy NVD dataset, redundant with vulnix for Nix closures ([repo](https://github.com/intel/cve-bin-tool)).
- **ssh-audit** — needs a live SSH endpoint; sshd is not enabled here ([repo](https://github.com/jtesta/ssh-audit)).
- **sbctl** — only useful if Secure Boot adoption (lanzaboote) is planned ([repo](https://github.com/Foxboron/sbctl)).
- **fwupdmgr security** — good info but daemon-backed and hardware-oriented; manual check ([HSI spec](https://fwupd.github.io/libfwupdplugin/hsi.html)).
- **tiger, rkhunter, chkrootkit** — not installable from nixpkgs (verified via `nix eval`; chkrootkit was removed as unmaintained and nonfunctional on NixOS).
- **lynis** — already in the pipeline as the baseline broad audit ([site](https://cisofy.com/lynis/)).
