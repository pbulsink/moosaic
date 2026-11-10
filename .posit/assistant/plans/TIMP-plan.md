# TIMP fallback deconvolution for moosaic

## Decisions
- Trigger: window has >=1 component with no library hit above min match factor, OR poor ALS fit (lack of fit above threshold).
- Dependency: TIMP in Suggests, guarded by `requireNamespace()`.
- Output: TIMP components replace the ALS components in the triggering window, then are re-searched.

## Basis (from massspec_ex.R)
TIMP's `mod_type = "mass"` fits a spectrotemporal model: each component has a parametric chromatographic peak shape (`peakpar`) and a spectrum estimated by variable projection (`nnls = TRUE`, `algorithm = "nls.lm"`). Data goes through `readData()`/`preProcess()` (time range, m/z range). `weightpar` downweights regions. The van Stokkum 2009 paper was not read here; verify details against it during the spike.

Key difference from MCR-ALS: concentration profiles are parametric (shaped peaks), which regularises heavily overlapped peaks. Spectra remain free and non-negative.

## Phase 0: feasibility spike (dev/, not in package)
1. Install TIMP; note dependencies and R 4.5 compatibility.
2. Take 3-5 windows from `tests/testthat/fixtures/real_windows/` where ALS components got no match, plus a synthetic window from `make_synthetic_run()` with known truth.
3. Build a TIMP data object from a moosaic window matrix (scans x m/z) directly (inspect `preProcess`/dataset classes); fallback: write a temp file and use `readData()`.
4. Fit `initModel(mod_type = "mass")` with peak starting values from `detect_fid_peaks()` apexes/widths and the ALS rank.
5. Compare to ALS: spectral cosine to truth (synthetic), library match factor (real), runtime.
6. Go/no-go: TIMP improves match or truth recovery on a meaningful share of windows at acceptable runtime. Log in `dev/challenges.md`.

## Phase 1: package integration (only if go)
Follow AGENTS.md conventions: one function per file, TDD, mirrored tests.

| File | Role |
|------|------|
| `R/needs_fallback.R` | `.needs_fallback()`: flag windows with unmatched components or high lack-of-fit |
| `R/to_timp_input.R` | `.to_timp_input()`: window matrix to TIMP dataset |
| `R/build_timp_model.R` | `.build_timp_model()`: peakpar starts from FID peaks/ALS profiles; rank from `estimate_rank()` |
| `R/fit_window_timp.R` | `fit_window_timp()`: fit and return the same structure as `fit_window()` |
| `R/from_timp_output.R` | `.from_timp_output()`: convert to moosaic structures, mirroring `from_als_output()` |
| `R/retry_unmatched.R` | `retry_unmatched()` [export]: for flagged windows run TIMP, rebuild components via `.build_components()`, re-run `identify_components()`, keep TIMP result only if it improves matches or lack-of-fit |

- Options (`aaa-options.R`, `SPEC.md` options table): `timp_fallback` (default FALSE), `timp_lof_threshold`, `timp_max_iter`, `timp_max_windows`.
- `process_sample()` gets an optional step after `identify_components()`; skipped with a message if TIMP is absent.
- Record provenance per component (`method = "timp"` or `"als"`), shown in `components_to_tibble()` and reports.
- Replace-only-if-better guard so the fallback never degrades results.
- Add `TIMP` to DESCRIPTION Suggests; add a decision entry in `SPEC.md` section 19.
- Use `.moosaic_*` wrappers with classes such as `timp-unavailable`, `timp-nonconvergence`; wrap the TIMP fit in `tryCatch` so failures keep the ALS result. Suppress TIMP PDF/plot output (`output`, `makeps`, `summaryplot*`) and write to tempdir.

## Testing
- Unit: each helper on hand-built inputs; `skip_if_not_installed("TIMP")`.
- Stage: synthetic overlapped window where ALS fails and TIMP recovers truth (cosine threshold).
- Challenge: real window fixtures; log outcomes.
- Integration: `process_sample()` with `timp_fallback = TRUE` on the phenols fixture with mocked search.
- Keep 100% per-file coverage; mock `fit_window_timp()` in `retry_unmatched()` tests.

## Risks / open items
- TIMP's mass model uses its own object classes and peak shapes; check suitability for tailing GC peaks.
- Parametric shapes may fail on shoulders or very asymmetric peaks.
- Runtime with many m/z channels; use `drop_empty_mz()` and bounded rank.
- May need `weightpar` to downweight air/bleed ions.
- Rank misestimates hurt both methods; consider trying rank +/- 1.
- TIMP maintenance/CRAN archival risk is why it stays optional.
