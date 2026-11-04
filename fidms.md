# FIDMS Repository Summary

## Overview

**fidms** is an R package that replaces a legacy Excel/VBA workflow called "Automated Polyarc". It processes chromatography data from Agilent GC-FID (Flame Ionization Detector) and GC-MSD (Mass Spectrometer Detector) instruments into client-facing analytical reports (Excel and PDF).

The package is designed for analyzing pyrolysis oils and other samples using a Polyarc reactor, which converts eluting carbon to methane before FID detection. This enables quantitation based on molar carbon content rather than compound-specific response factors.

**Status:** Development version (0.0.0.9000), locally maintained by Philip Bulsink.

---

## What This Repo Does

The package implements a linear data-processing pipeline:

1. **Parse** — Read three CSV files exported from Agilent instruments:
   - FIDpeaks.csv (FID detector peak table)
   - MSDpeaks.csv (MSD detector peak table)
   - MSDsearch.csv (MSD library search results)

2. **Align** — Match peaks between FID and MSD detectors by retention time using one of two engines:
   - `grid` (default): brute-force linear-shift search + greedy 1:1 matching
   - `gcalignr`: shift search + row-wise grouping (handles split/merged peaks better)

3. **Identify** — Merge the aligned peak tables and attach library names/scores from MSD search results

4. **Merge** — Combine nearby split peaks that represent the same compound

5. **Interpolate** — Estimate chemical formulas for unidentified peaks using a retention-index model fit at runtime

6. **Classify** — Assign peaks to chemical families (hydrocarbons, oxygenates, etc.) and flag solvents

7. **Quantify** — Apply calibration to calculate sample mass percentages:
   - External calibration (if calibration standards are in the sample)
   - Internal standard (relative response against a reference peak)
   - Polyarc response model: mass ∝ (FID area) × (molar mass / carbon count)

8. **Summarize** — Aggregate results by chemical family and element, compute recoveries and QC metrics

9. **Report** — Write Excel or PDF client reports (Total Compound table + Summary page)

---

## File Organization

### R/ (Source Code, 14 modules)

| File | Purpose | Key Exports |
|------|---------|------------|
| **parse.R** | CSV reader for Agilent peak tables & library searches | `.read_fid_peaks()`, `.read_msd_peaks()`, `.read_msd_search()` |
| **align.R** | FID/MSD retention-time alignment & peak matching | `.align_peaks()`, `.merge_close_peaks()`, `fidms_params()` |
| **align_gcalignr.R** | Alternative alignment engine using GCalignR package | `.align_peaks_gcalignr()` |
| **chemistry.R** | Formula parsing, molecular weight, retention-index model fitting | `.parse_formula()`, `.molecular_weight()`, `.fit_retention_index()` |
| **classify.R** | Chemical-family classification and solvent detection | `.classify_family()`, `.is_solvent()` |
| **hydrocarbon_type.R** | ASTM D2425 class-ion deconvolution from raw MS scan matrices | `.add_hydrocarbon_class()`, `.solve_hydrocarbon_class()`, `hydrocarbon_class_params()` |
| **interpolate.R** | Formula interpolation/extrapolation for unknown peaks | `.interpolate_unknowns()` |
| **calibrate.R** | Calibration-curve fitting and Polyarc quantitation | `calibrate()`, `.fit_calibration()` |
| **reference_peak.R** | Internal-standard reference peak suggestion & QC gates | `.suggest_reference_peak()`, `.reference_peak_ok()` |
| **pipeline.R** | End-to-end orchestration; Total Compound table construction | `process_sample()`, `prepare_peaks()`, `total_compound_table()` |
| **summarize.R** | Family/element/recovery summaries and sample metadata | `summarize_report()`, `sample_info()` |
| **report.R** | Excel and Quarto-PDF report writers | `write_excel_report()`, `write_pdf_report()` |
| **app.R** | Shiny web app launcher | `run_app()` |
| **fidms-package.R** | Dataset documentation (11 packaged data objects) | (11 data objects with roxygen docs) |

### data/ (11 Packaged Datasets)

All documented in `R/fidms-package.R`:

- **Lookups** (rebuilt by `data-raw/lookup_tables.R`):
  - `atomic_weights` — element atomic masses
  - `calibration_targets` — standard compound library
  - `calibration_points` — reference calibration concentrations
  - `chemical_family_terms` — family/subfamily classification rules
  - `solvent_names` — solvent name dictionary

- **Calibration** (runtime-refit, not shipped pre-computed):
  - `rical_reference_points` — RT/RI anchors for retention-index model

- **ASTM D2425/D2789** (class-ion deconvolution):
  - `sim_masses`, `class_response_matrix`, `parent_ion_factors` — hydrocarbon class standards
  - `sim_masses_oxygenate`, `oxygenate_response_matrix` — proposed oxygenate extension (placeholder; awaiting lab calibration)

### tests/testthat/ (Unit Tests)

- **test-parse.R**, **test-align.R**, **test-align-gcalignr.R** — CSV readers and alignment engines
- **test-chemistry.R** — formula parsing and RI model
- **test-classify.R** — chemical-family assignment
- **test-hydrocarbon-type.R** — class-ion deconvolution (largest test module)
- **test-calibrate.R** — curve fitting and quantitation
- **test-reference-peak.R** — internal-standard selection
- **test-pipeline.R** — end-to-end runs; regression on report table layout
- **fixtures/** — 10-peak sample excerpts (FIDpeaks.csv, MSDpeaks.csv, MSDsearch.csv) for reproducible testing

Coverage: tracked in `cobertura.xml` (at repo root, prior export).

### vignettes/ (User Documentation)

- **real_sample_workflow.Rmd** — "Processing a Real GC-MS/FID Sample":
  - End-to-end walkthrough of the example diesel sample
  - Code examples and screenshots of the Shiny app
  - Bundles **full** diesel peak-table CSVs (not test excerpts)
  - Built with knitr (outputs committed: `.html`, `.pdf`)
  - Images/ — app screenshots (01–06) + page 1 of generated PDF report (07)

### data-raw/ (Data Rebuild Scripts)

- **lookup_tables.R** — Rebuilds packaged lookup tables from `caltable.csv` and `rical.csv` (both local)
- **atomic_weights.R**, **hydrocarbon_type.R** — Source material for atomic weights and ASTM-transcribed class-ion matrices
- **capture_app_screenshots.R** — Dev-only; regenerates app screenshots using shinytest2 (needs local `diesel.D` directory)
- **render_pdf_page.R** — Dev-only; renders example PDF report page 1 via Quarto + LaTeX

### inst/ (Bundled App & Template)

- **app/app.R** — Shiny front-end (served via `run_app()`); **local-only by design** — no remote deployment targets, client data never uploaded
- **report/report.qmd** — Quarto template for PDF reports (rendered by `write_pdf_report()`)

### Local-only Files (Gitignored)

- **reference/** — ASTM standards (D2425-23, D2789-95, D8276 PDFs + screenshot tables), original `Automated Polyarc.xlsm`, sample CSV excerpts, and other reference material
- **diesel.D/** — Agilent raw-scan directory (diesel fuel sample) for class-ion module testing; required by vignette class-ion section and app screenshot generation
- **dev/** — Local development notes: `oxygenate-extension-design.md`, `oxygenate-extension-record.md`, scratch analysis scripts

---

## Dependencies

### Imports (Required)
- **chromConverter** — MS scan matrix I/O
- **dplyr** — data wrangling
- **GCalignR** — alternative peak-alignment algorithm (guarded by `engine = "gcalignr"`)
- **nnls** — non-negative least squares (class-ion solve)
- **openxlsx** — Excel I/O
- **rlang** — rlang::.data and error handling
- **stats**, **stringr**, **tibble**, **tidyr**, **utils** — base utilities

### Suggests (Optional, Feature-Gated)
- **shiny**, **bslib**, **DT** — local Shiny app
- **quarto**, **rmarkdown** — PDF report rendering
- **knitr** — vignette building
- **testthat** (≥ 3.0.0) — testing framework
- **withr** — temp-file management in tests

All optional features are guarded in code with `rlang::check_installed()` or `requireNamespace()`, so missing packages don't break the core pipeline.

---

## Public API

### Main Entry Points

- **`process_sample(fid_csv, msd_csv, search_csv, info, ...)`** — End-to-end pipeline orchestration; returns a processed sample object
- **`prepare_peaks(fid_csv, msd_csv, search_csv, ...)`** — Runs pipeline up to (but not including) quantitation; allows reference-peak review
- **`calibrate(prepared_sample, style, ...)`** — Apply calibration to quantify peak masses
- **`summarize_report(calibrated_sample)`** — Aggregate by family/element; compute recoveries and QC counts
- **`total_compound_table(summarized_sample)`** — Extract the main results table
- **`write_excel_report(result, ...)`** — Write 2-sheet Excel file (Total Compound + Summary)
- **`write_pdf_report(result, ...)`** — Render Quarto template to PDF (needs LaTeX)

### Configuration & Metadata

- **`sample_info(...)`** — Bundle sample metadata (ID, name, analyst, density, dilution, etc.)
- **`fidms_params(...)`** — Alignment and processing parameters (retention-time tolerance, peak-area thresholds, etc.)
- **`hydrocarbon_class_params(...)`** — ASTM D2425 class-ion deconvolution settings

### Utilities

- **`run_app()`** — Launch local Shiny front-end (no remote hosting)

All other functions are internal (dot-prefixed, `@keywords internal`); the public API is deliberately small.

---

## Key Design Decisions

### Calibration & Quantitation

The **Polyarc response model** quantifies without compound-specific response factors:

$$A_i = A_t \cdot \frac{F_i}{F_t} \cdot \frac{C_t}{C_i} \cdot \frac{M_i}{M_t}$$

where:
- $A_i$ = estimated compound mass
- $A_t$ = target peak area
- $F_i, F_t$ = FID areas (moles of C)
- $C_i, C_t$ = carbon count
- $M_i, M_t$ = molar mass

**Calibration styles:**
- `"slope"`, `"log"`, `"poly3"` — External calibration (requires target peaks in sample)
- `"internal"` — Relative response against an internal reference peak (fallback when no targets present)

Zero-response calibration levels are treated as **below-detection**, not as observed zeros, and excluded from curve fits. This matches analyst practice.

### Retention-Index Model

The RI polynomial (degree 6 by default, fit at runtime) is **not shipped pre-computed**; it is refit from packaged reference points (`rical_reference_points`) every run. Same for calibration coefficients/R² — both are runtime-refitted, not ported from the legacy workbook.

### Alignment Engines

Two engines, not expected to agree exactly:
- **`grid`** (default) — direct port of VBA `Lookup`/`Bump_Signal_Down`: linear-shift search + one-to-one greedy matching; fast and deterministic
- **`gcalignr`** — delegates to `GCalignR::align_chromatograms()`; row-wise grouping handles split/merged peaks more gracefully (use for large peak lists or multi-sample alignment)

The 10-peak test excerpt cannot determine which is "correct" because peak spacing leaves retention-time shift poorly constrained. Production default should be chosen after comparing both on a full real sample.

### Local-Only Shiny App

The app is intentionally **not configured for remote deployment** — client sample data must never be uploaded to any hosted service. Deployment is explicitly not a design goal.

---

## Data Flow Diagram

```
FIDpeaks.csv  ─────┐
                   ├──> parse ─────┐
MSDpeaks.csv  ─────┘               │
                                   ├──> align ──┐
MSDsearch.csv ─────────────────────┤            │
                                   ├──> identify/merge
                                   │
                    ┌──────────────┘
                    │
                    ├──> interpolate ──┐
                    │                  ├──> classify
                    │                  │
                    │      (optionally add class-ion
                    │       deconvolution if raw MS
                    │       scan data supplied)
                    │                  │
                    └──────────────────┤
                                       │
                         calibration ──┤──> quantify
                         targets       │
                                       ├──> summarize
                                       │
                                       ├──> total_compound_table
                                       │
                    ┌──────────────────┘
                    │
                    ├──> write_excel_report (.xlsx)
                    │
                    └──> write_pdf_report (.pdf, via Quarto+LaTeX)
```

---

## Standard Development Workflow

### 1. Understand the Code Path
- Read roxygen documentation in `R/*.R` (internal functions marked `@keywords internal`)
- Trace data flow through the linear pipeline or class-ion side path
- Identify affected modules

### 2. Make Changes
- Modify only relevant files in `R/`; don't create new `.R` files unless adding entirely new capability
- Keep internal helpers dot-prefixed with `@keywords internal`
- Use tidyverse verbs with explicit namespace; base R otherwise
- Use plain `stop("message", call. = FALSE)` for errors

### 3. Add Tests
- Create or update tests in `tests/testthat/test-{module}.R` (matching source file)
- Reuse 10-peak fixtures in `tests/testthat/fixtures/`; build synthetic tibbles for cases fixtures can't express
- Run `devtools::test()` to verify
- Ensure new exported functions have `@examples` blocks in roxygen

### 4. Update Documentation
- Regenerate man pages: `devtools::document()`
- If packaged data changes, rebuild via matching `data-raw/` script, then re-document
- Update README pipeline diagram or VBA mapping table if user-facing behavior changes
- If app UI or report layout changes, regenerate images with dev-only scripts, rebuild vignette

### 5. Verify Build
- Full check: `devtools::check()`
- Review test coverage for edited files (prior export: `cobertura.xml`)
- Ensure no regressions; all file references valid

### Testing Philosophy
- Test outputs and behavior, not just function existence
- Expect exact values (sheet names, column counts, sentinel strings, recovery sum to 100 ± tol)
- Fixtures are deliberately small; end-to-end tests run full pipeline on them with `style = "internal"` (excerpt has no calibration targets, exercising fallback branch)
- **Failing tests are valuable** — address them, don't suppress

---

## Known Limitations & Open Items

### Decided
✓ Degree-6 RI polynomial and calibration coefficients are **not** ported; refit at runtime  
✓ Zero-response calibration levels are below-detection (excluded from curve fit)  
✓ Local-only Shiny app by design (no remote deployment)

### Pending
- [ ] Choose production default alignment engine (`grid` vs `gcalignr`) after comparison on full real sample
- [ ] Verify PDF report pagination in LaTeX for 500+ peak samples
- [ ] Golden-file regression against macro output for full real sample (10-peak excerpts in repo are not complete runs)
- [ ] Calibration-report import and local persistence (deferred)

### Reference Material Limitation
ASTM standard PDFs in `reference/` (D2425-23, D2789-95, etc.) have complex multi-cell tables that `pdftotext -layout` extracts unreliably. Workaround: cross-reference plain `pdftotext` output with `-layout` version, or use `.png` screenshots of tables bundled in `reference/`. For future table re-verification/extension, prefer requesting direct page images rather than text extraction.

---

## Example Usage

### Via R Code

```r
library(fidms)

# Set up sample metadata
info <- sample_info(
  sample_id = "Diesel-1",
  sample_name = "Pyrolysis oil",
  project_code = "MD",
  analyst = c("analyst1", "analyst2"),
  density = 0.8519,
  methanol_wt_pct = 0,
  water_wt_pct = 0,
  dilution = 1
)

# Run end-to-end pipeline
result <- process_sample(
  "path/to/FIDpeaks.csv",
  "path/to/MSDpeaks.csv",
  "path/to/MSDsearch.csv",
  info = info,
  style = "slope"  # or "log", "poly3", "internal"
)

# Write reports
write_excel_report(result)  # → project_sampleid_GC-MS-FID.xlsx
write_pdf_report(result)    # → project_sampleid_GC-MS-FID.pdf (needs Quarto + LaTeX)
```

### Via Shiny App

```r
fidms::run_app()
```

Launches a local web interface for upload, review, and report generation. Client data stays local — the app is never deployed remotely.

---

## Contact & Maintenance

- **Author/Maintainer:** Philip Bulsink (pbulsink@example.com)
- **License:** MIT + file LICENSE
- **Repository:** Local development (git, not public)
- **Test Edition:** testthat 3

---

**Last Updated:** November 2026
