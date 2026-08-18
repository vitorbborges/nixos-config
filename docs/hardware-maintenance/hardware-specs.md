# Hardware Identity & Full Specifications

## Identity

| Field | Value | Source |
|---|---|---|
| Manufacturer | ASUSTeK COMPUTER INC. | this machine (DMI) |
| Product name (DMI) | `Vivobook_ASUSLaptop K6604JI_K6604JI` | this machine |
| Board name | K6604JI | this machine |
| Marketing name | ASUS Vivobook Pro 16X OLED (K6604 series) | [ASUS](https://www.asus.com/laptops/for-creators/vivobook/vivobook-pro-16x-oled-k6604/) |
| Retail SKU match | K6604JI-ES96 (i9-13980HX / RTX 4070 / 1TB config) | [Amazon listing](https://www.amazon.com/ASUS-Vivobook-Pro-OLED-Laptop/dp/B0C48D8B7W), [SHI](https://www.shi.com/product/46239928/ASUS-Vivobook-Pro-16X-OLED-K6604JI-ES96) |
| BIOS version | K6604JI.300 | this machine |
| BIOS date | 2023-03-14 | this machine |
| Chassis type (SMBIOS) | 10 (Notebook) | this machine |
| Serial number | **TBD — fill in.** Run `! sudo dmidecode -s system-serial-number`, or check the sticker on the bottom panel. | — |

> `product_sku` came back empty from DMI on this unit — not unusual for consumer Vivobooks, ASUS doesn't always populate it.

## CPU

- Intel Core **i9-13980HX** (13th gen "Raptor Lake HX")
- 24 cores (8 P-cores + 16 E-cores) / 32 threads
- Up to 5.6GHz boost, 800MHz idle
- Known for running hot in thin chassis — see [`internal-maintenance.md`](internal-maintenance.md) and [`sources.md`](sources.md) for community threads about throttling around 95-100°C under sustained load on this CPU in ASUS chassis.

## GPU

- NVIDIA **GeForce RTX 4070 Max-Q / Mobile** (AD106M die), 8GB VRAM
- Intel UHD Graphics (Raptor Lake-S integrated) for Optimus/hybrid switching
- MUX switch present (can run pure dGPU or hybrid mode)
- Combined CPU+GPU thermal design point: 150W in Performance mode ([ASUS IceCool Pro](https://www.asus.com/us/content/how-does-the-asus-icecool-laptop-cooling-technology-work/))

## Memory

- 32GB DDR5 installed, 2× SO-DIMM slots, up to 64GB supported
- Exact part numbers/manufacturer not read yet (needs root). Run `! sudo dmidecode -t memory` and record here if you ever shop for a RAM upgrade.

## Storage

- **Samsung MZVL21T0HCLR-00B00**, ~954GB (1TB nominal), NVMe, OEM **PM9A1** variant
- Known issue class: some PM9A1 OEM firmware revisions (HPS2 and earlier) have a documented run-time-bad-blocks/SMART-error bug that can push the drive read-only; fixed in HPS3. Whether that applies to this ASUS-branded unit specifically is **unconfirmed** — check your firmware string once `nvme-cli`/`smartmontools` are installed (see [`software-diagnostics.md`](software-diagnostics.md)) before assuming anything is wrong.
- Single M.2 2280 slot (not dual) — no second drive can be added, only swapped.

## Display

- 16.0", 3200×2000 (3.2K), OLED, 16:10, 120Hz, 100% DCI-P3
- OLED-specific maintenance note: no backlight bleed to worry about, but OLED panels are more sensitive to pressure marks than LCD — extra reason to never press on the screen while cleaning (see [`cleaning-exterior.md`](cleaning-exterior.md)).

## Battery

- Part number **C41N2013** (cell config 4ICP5/63/133), 90Wh, 15.4V nominal, ~5675–5845mAh
- Sold under SKU `BATTGA503` at third-party ASUS parts resellers if you ever need a replacement (see [`tools-and-supplies.md`](tools-and-supplies.md))
- **Current health (2026-07-19): ~73% of design capacity (65.6Wh / 90.0Wh), 523 charge cycles.** This is meaningful degradation for the unit's age — see the charge-limiting recommendation in [`software-diagnostics.md`](software-diagnostics.md).
- ASUS's official position (per their support pages) is that the battery pack is not user-disassemblable — treat battery replacement as an authorized-service-center job, not a DIY teardown target, even under the "full depth" plan for the rest of this KB.

## Ports / connectivity

- Dual Thunderbolt 4
- SD card reader
- Intel Wi-Fi 6E AX210/AX1675 (2×2)

## Warranty

Check status directly with ASUS support using the serial number once retrieved — opening the chassis for cleaning/repaste is generally considered normal user maintenance by most manufacturers, but confirm your region's specific terms before doing anything to the battery or motherboard. ASUS's own docs (found during research) explicitly point to an authorized service center for disassembly beyond user-accessible panels; the guidance in this KB is community/technician-sourced, not manufacturer-sanctioned.
