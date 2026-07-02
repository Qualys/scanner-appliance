# Scanner Capacity Calculator

Single-page HTML tool for estimating Qualys scanner pool sizing and scan duration based on workload, scanner specs, and parallelism settings.

## Quick start

No build step. Open `scanner-capacity-calculator.html` directly in a browser — no server needed.

```bash
# Or serve locally if preferred:
python3 -m http.server 8765
# then visit http://localhost:8765/scanner-capacity-calculator.html
```

## What it calculates

For a given **scan type** (VM / PC / WAS / MAP / PCI), **scanner type** (Virtual Internal / Perimeter / Physical 6120-B1 / 6120-A1), and workload (target IPs or scan jobs), the tool produces:

- **Scanner Capacity** — capacity units of one scanner derived from CPU MHz × memory × penalty factors.
- **Max Slices in Parallel / Scanner** — how many scan slices a single scanner can run concurrently (VM / PC / PCI only; hidden for MAP/WAS).
- **Total Slices** — slices needed to cover all target IPs at the chosen parallelism (P) (VM / PC / PCI only; hidden for MAP/WAS).
- **Parallelism Tradeoff Table** — four strategies (Fastest / Balanced / Economical / Minimal pool) showing the speed-vs-resource tradeoff for VM / PC / PCI scans. Each row shows scanners to provision, jobs to create, slices/burst, bursts, and estimated duration. Burst time: ~5–10 min for VM/PC, ~60–120 min for PCI. Jobs/scanner are capped by the **Concurrent Scans and Maps** limit, and a note appears when that limit is the bottleneck.
- **Scan Time Planner** — given a **Desired Scan Duration** (e.g. 10h overnight window, or 60 min for short batches), shows which scanner spec and count meets that window across standard specs **plus your own config**. The *Your Config* row shows the **real** estimated time with your *actual* pool (labelled “with your N scanners”), while preset rows show the time at the count each spec would need. The **Max Jobs** column reflects the effective per-scanner parallelism after the **Concurrent Scans and Maps** cap, so a larger spec stops helping once it hits that limit (a note explains this). When your current spec falls short, it spells out clear options: **add more scanners** at your current spec, **upgrade** to a larger spec, or **split the target list** into smaller scans. For Perimeter scanners, results are capped by your **External Scanners to Use** limit. Physical scanners show their fixed appliance capacity instead of vCPU/RAM.
- **MAP / WAS Est. Duration** — for MAP and WAS scans, a ballpark duration is shown directly on the result card: `ceil(jobs / scanners) × avg time/job` (~25 min/job for MAP, ~10 min/job for WAS), so no Scan Time Planner input is needed for a quick estimate.
- **Estimate guidance** — the planner shows how long *this scan alone* should take under typical Qualys-recommended conditions. If your actual time is significantly higher, consider: other parallel scans running, a mixed/undersized scanner pool, scan option profile settings (port range, authentication), or slow target network response.

## Key inputs

| Input | Description | Default |
|---|---|---|
| Scan Type | VM / PC / WAS / MAP / PCI | VM |
| Scanner Type | Virtual Internal / Perimeter / Physical (6120-B1 / 6120-A1) | Virtual Internal |
| Target IPs | Total IPs in scope (VM / PC / PCI) | — |
| Number of Scan Jobs | Total jobs for MAP or WAS scans | — |
| Parallel Host Scans (P) | Targets scanned per scanner per slice — *Option Profile setting* | 30 |
| Parallel ML Scaling | Multiplies parallelism ×3 when ON — *Option Profile setting* | OFF |
| Concurrent Scans and Maps | Max VM/PC/MAP jobs running simultaneously — also caps jobs/slices per scanner — *backoffice setting* | 100 |
| Concurrent WAS Scans | Max WAS jobs running simultaneously (WAS tab only) — *backoffice setting* | 10 |
| External Scanners to Use | Perimeter scanner pool cap — recommendations won't exceed this | 40 |
| Desired Scan Duration | Time window (hrs or min) — activates the Scan Time Planner | — |
| Scanner Pool Size | Current scanner count — activates spec comparison view | — |
| vScanner CPUs | vCPUs allocated (virtual scanners only) | 4 (Perimeter: 8) |
| vScanner Memory (GBs) | RAM allocated (virtual scanners only) | 8 GB (Perimeter: 16 GB) |
| Base CPU Speed (MHz) | Hypervisor CPU speed | 2600 MHz |
| Hyperthreading (HT) | Enable HT penalty in capacity formula | Off |

### Scanner type notes
- **Perimeter** — 8 vCPU / 16 GB RAM and above. External scanner pool cap applies.
- **Virtual Internal** — 40% virtual penalty applied, on top of 40% Hyperthreading/SMT penalty when HT is enabled.
- **Physical** — fixed hardware capacity; CPU/RAM inputs do not apply. Per the [Qualys physical scanner docs](https://docs.qualys.com/en/scanner/appliances/physical_scanner/overview.htm): **6120-B1 (NVXE) = 1245 units**, **6120-A1 (NVX) = 1040 units**.

### Default avg round times (used by Scan Time Planner)
| Scan type | Avg time |
|---|---|
| VM / PC | ~7.5 min/round |
| WAS | ~10 min/job |
| MAP | ~25 min/job |
| PCI | ~60 min/round |

## Key concepts

- **Slice** — sub-unit of a scan job covering up to P target IPs.
- **Job** — a configured scan in the Qualys portal (target list + scan profile). A job dispatches **one slice per scanner at a time**.
- **Round** — one parallel wave of slice execution across the entire scanner pool. `rounds = ceil(totalSlices / (scanners × maxSlicesPerScanner))`.
- **Jobs to Create** — the minimum number of jobs to create to achieve the row's stated duration. Splitting into more jobs lets each scanner run more slices in parallel. Capped by the **Concurrent Scans and Maps** limit. Keep in mind this is one of several levers — you may also need to adjust your **scanner pool size** or **scanner specs** (CPU / RAM) to meet your scan window.
- **Concurrent jobs cap** — since a scanner runs one slice per job, the *effective* max slices/scanner = `min(capacityMaxJobs, ConcurrentScansAndMaps)`. When the limit is below what the hardware could run, a bigger spec won't reduce time — only raising the limit or adding scanners helps. WAS uses the **Concurrent WAS Scans** limit instead.

## Export

Results can be exported as **CSV** or **Excel (.xlsx)** using the buttons in the results area. Exports include all inputs, tradeoff table, spec comparison, and Scan Time Planner data.

## Constants

All configuration constants live in the `K` object at the top of the `<script>` section in `scanner-capacity-calculator.html`.

| Name | Value | Notes |
|---|---|---|
| `VIRTUAL_PENALTY` | 0.6 | Applied to Virtual Internal scanners only (3/5) |
| `HT_PENALTY` | 0.6 | Applied when Hyperthreading is enabled (3/5) |
| `CPU_SPEED_MHZ` | 2600 | Default CPU speed (MHz); conservative estimate |
| `VM_SCAN_COST` | 2 | VM scan cost |
| `PC_SCAN_COST` | 4 | PC scan cost |
| `WAS_SCAN_COST` | 70 | WAS scan cost |
| `MAP_SCAN_COST` | 100 | MAP scan cost |
| `PHYS_NVXE_B1_CAP` | 1245 | Fixed capacity — Physical QGSA-6120-B1 (NVXE) |
| `PHYS_NVX_A1_CAP` | 1040 | Fixed capacity — Physical QGSA-6120-A1 (NVX) |
| `VIRTUAL_LOWEST_CAP` | 209 | Minimum viable virtual scanner capacity |
| `CAP_PER_SLICE_NO_ML` | 100 | Capacity per slice, ML Scaling OFF |
| `CAP_PER_SLICE_ML` | 300 | Capacity per slice, ML Scaling ON (×3) |
| `DEFAULT_PARALLEL_SLICES` | 1 | Default slices dispatched per scanner |

## Files

- `scanner-capacity-calculator.html` — the entire app (HTML + Tailwind CDN + vanilla JS, no build step).
- `product.png`, `qg_logo_iPhone.png` — branding assets.

## Caveats

Estimates are **ballpark**, based on **standard Qualys scan profile settings**, **recommended scanner sizing**, and **normal target network conditions** — assuming **this is the only scan running on the scanner**. A concurrent scan on the same scanner will reduce overall throughput. Actual duration also varies with: open ports, scan settings (port range, authenticated vs. non-authenticated), target network connectivity, and number of vulnerabilities to process. Default avg round times are conservative estimates — your environment may differ.
