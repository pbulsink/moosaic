# moosaic - Agent Guidelines

Automated data extraction, deconvolution, and spectral searching for GC-FID/MS data: FID-guided windowed MCR-ALS deconvolution, library search, RI/element-filtered identification, Polyarc quantification, and reporting.

- **Package:** `moosaic` v`0.0.0.9000`
- **Authors:** Philip Bulsink <philip.bulsink@nrcan-rncan.gc.ca> (aut, cre)
- **License:** GPL (>= 3)

## Package Overview

Automated data extraction, deconvolution, and spectral searching for GC-FID/MS data. The pipeline is: `read_experiment()` → `align_detectors()` → FID peak/window detection → per-window rank estimation → FID-derived constraints → MCR-ALS fit (`fit_window()`) → components → library search (mspepsearchr) → RI + element-penalty scoring → Polyarc quantification (`quantify()`) → reports (`summarize_report()`, `write_excel_report()`, `write_pdf_report()`). The one-call entry point is `process_sample()`.

`.posit/SPEC.md` is the authoritative design document (draft v2): conventions, per-stage file/function tables, testing strategy, options reference, and a decisions log. Read it before implementing or modifying any stage.

## Project Structure

### R/ (Source Code)
- `aaa-options.R` - default option values (single source of defaults)
- `aaa-quant_data.R` - lookup tables ported from fidms (atomic weights, calibration targets/points, family terms, solvents)
- `align_detectors.R` - align MS and FID retention times [export]
- `als_diagnostics.R` - fit diagnostics for an ALS solution
- `annotate_component.R` - annotate one component by library search [export]
- `apply_alignment.R` - apply a detector delay to MS retention times
- `apply_curve.R` - evaluate calibration curves
- `apply_filter.R` - symmetric-support FIR filter with edge padding
- `apportion_fid_area.R` - apportion raw FID area among fitted components
- `assign_target_rows.R` - governing calibration target for each peak
- `background_profile.R` - flat background profile
- `bin_mz.R` - nominal m/z bin index
- `build_components.R` - turn a window fit into components
- `build_constraints.R` - FID-derived initial concentration profiles [export]
- `build_formula.R` - build C/H/O formulas
- `build_ms_matrix.R` - dense scan-by-m/z matrix from MS data [export]
- `build_peak_table.R` - peak table from an identified result
- `build_s0.R` - initial spectra estimate from SVD
- `build_sparse_ms_matrix.R` - sparse (dgCMatrix) scan-by-m/z matrix
- `build_tic.R` - total ion chromatogram from raw MS data
- `carbon_count.R` - carbon atoms per formula
- `check_fid_baseline.R` - check the raw FID baseline
- `classify_family.R` - chemical family of each peak
- `component_to_query.R` - build a search query from a component
- `components_to_tibble.R` - components as a tibble [export]
- `compute_ri.R` - retention index from retention time (van den Dool & Kratz)
- `consensus_rank.R` - consensus of rank votes
- `correct_baseline.R` - subtract an estimated baseline
- `deconvolve_run.R` - deconvolve every FID window of a run [export]
- `derivative_signal.R` - Savitzky-Golay derivative of a signal
- `detect_fid_peaks.R` - detect peaks in an FID trace [export]
- `detect_fid_windows.R` - detect deconvolution windows from the FID [export]
- `drop_empty_mz.R` - remove m/z channels with no signal
- `element_counts.R` - tracked element counts for formulas
- `element_penalty.R` - penalty for unexpected elements in a formula
- `estimate_delay_gcalignr.R` - estimate detector delay with GCalignR
- `estimate_delay_xcorr.R` - estimate detector delay by cross-correlation
- `estimate_delay.R` - MS-to-FID delay dispatcher (engine choice)
- `estimate_noise.R` - robust noise estimate
- `estimate_rank.R` - number of components in a window [export]
- `extract_fid_window.R` - FID signal resampled onto a window's MS scans
- `extract_metadata.R` - extract metadata from raw data attributes
- `extract_ms_matrix.R` - MS data matrix for a window [export]
- `find_local_maxima.R` - find local maxima
- `find_peak_bounds.R` - find peak boundaries around an apex
- `find_shoulders.R` - find shoulders from a second derivative
- `fit_calibration.R` - fit external calibration curves
- `fit_window.R` - fit one window by MCR-ALS [export]
- `from_als_output.R` - convert an `ALS::als()` result to moosaic structures
- `gcms_fid_exp.R` - create a gcms_fid_exp object from raw data [export]
- `get_moosaic_option.R` - get a moosaic option by name (aborts if unknown)
- `has_shoulder.R` - test a peak for an unresolved shoulder
- `identify_components.R` - identify the components of a deconvolved run [export]
- `integrate_trapezoid.R` - trapezoidal integral
- `interpolate_unknowns.R` - estimate formulas for unidentified peaks
- `is_background_component.R` - detect column bleed, air, or flat baseline
- `is_gcms_fid_exp.R` - check if object is a gcms_fid_exp [export]
- `is_solvent.R` - flag solvent peaks
- `leading_singular_values.R` - leading singular values of a matrix
- `match_targets.R` - match peak names to calibration targets
- `merge_overlapping_peaks.R` - merge peaks into deconvolution windows
- `molecular_weight.R` - molecular weight from atom counts
- `moosaic_abort.R` - cli error wrapper (`.moosaic_abort()`)
- `moosaic_inform.R` - cli message wrapper (`.moosaic_inform()`)
- `moosaic_options.R` - get all moosaic options [export]
- `moosaic_warn.R` - cli warning wrapper (`.moosaic_warn()`)
- `moosaic-package.R` - package-level documentation stub (`NULL`)
- `new_component.R` - construct a component (S3 `moosaic_component`)
- `new_gcms_fid_exp.R` - internal constructor for gcms_fid_exp
- `normalize_columns.R` - scale matrix columns to a maximum of 1
- `parse_formula.R` - parse a molecular formula
- `parse_search_results.R` - stack search results into one tibble
- `parse_window.R` - normalise a window specification
- `peak_prominence.R` - topographic prominence of peaks
- `peaks_to_gcalignr.R` - convert detected peaks to GCalignR input
- `permute_columns.R` - permute matrix columns independently (parallel analysis)
- `polyarc_mass.R` - Polyarc mass relative to a reference peak
- `preprocess_fid_for_detection.R` - prepare a detection copy of the FID trace
- `print.gcms_fid_exp.R` - S3 print method [export]
- `process_sample.R` - full pipeline: raw files to quantified result [export]
- `process_window.R` - deconvolve one window [export]
- `quantify.R` - quantify identified components (Polyarc) [export]
- `rank_bic.R` - rank estimate by BIC
- `rank_fid.R` - rank estimate from the FID trace
- `rank_pa.R` - rank estimate by parallel analysis
- `rank_svd.R` - rank estimate from cumulative explained variance
- `read_experiment.R` - read a GC-FID/MS experiment from ChemStation files [export]
- `read_ri_calibration.R` - read an RI calibration file [export]
- `recovery_excluded.R` - names excluded from GC recovery
- `reference_peak_ok.R` - which peaks can act as the internal reference
- `report_path.R` - default report file name and path check (`.report_path()`, `.check_report_path()`)
- `require_quantified.R` - check that a result has been quantified
- `resample_fid_to_scans.R` - resample the FID onto the MS scan grid (boxcar mean)
- `reset_moosaic_options.R` - reset moosaic options to defaults [export]
- `ri_penalty.R` - retention index penalty
- `run_als.R` - run `ALS::als()` quietly, capturing the trace
- `run_mspepsearch.R` - library search via mspepsearchr (`.search_fn()`, `.run_mspepsearch()`, `.merge_search_batches()`)
- `running_min.R` - centred running minimum
- `sample_info.R` - sample metadata for quantification and reports [export]
- `score_candidates.R` - combine match factor and penalties into a final score
- `segment_fid_window.R` - split a FID window into contiguous per-component segments
- `set_moosaic_options.R` - set moosaic options (validated) [export]
- `sg_coefs.R` - Savitzky-Golay filter coefficients
- `smooth_signal.R` - Savitzky-Golay smoothing
- `specify_identification_penalties.R` - specify identification penalties [export]
- `specify_library.R` - specify library paths for spectral searching [export]
- `specify_ri_calibration.R` - specify RI calibration file [export]
- `specify_search_params.R` - specify search parameters [export]
- `standardize_fid.R` - standardize FID data to internal structure
- `standardize_ms.R` - standardize MS data to internal structure
- `subset_rt.R` - subset matrix rows to a retention-time window
- `suggest_reference_peak.R` - suggest the internal reference peak
- `summarize_report.R` - summarise a quantified result for reporting [export]
- `summary_notes.R` - report footnotes (`.summary_notes()`, `.element_note()`)
- `to_als_input.R` - build the argument list for `ALS::als()`
- `total_compound_table.R` - total compound table [export]
- `validate_gcms_fid_exp.R` - validate a gcms_fid_exp object
- `write_excel_report.R` - write the Excel report (openxlsx) [export]
- `write_msp.R` - write components to an MSP file [export]
- `write_pdf_report.R` - write the PDF report (quarto) [export]
- `zzz.R` - `.onLoad()` sets unset default options

### tests/testthat/ (Unit Tests)
Tests mirror source files 1:1 per project convention: `R/{name}.R` → `tests/testthat/test-{name}.R`. Every function file has a matching test file (except `R/aaa-*.R` and `R/moosaic-package.R`); do not create separate or renamed test files. The only extra test files are the `test-integration-*.R` files.

- `helper-synthetic.R` - `make_synthetic_run()`: known-truth synthetic `gcms_fid_exp` mirroring real sampling rates (FID 50 Hz, MS 0.27 s scans); ground truth in `$processing$synthetic_truth`
- `helper-als.R` - `als_fixture()`: low-rank ALS problem with C0/S0 starts
- `helper-rank.R`, `helper-components.R`, `helper-identify.R`, `helper-quant.R` - shared fixtures/mocks for rank estimation, component construction, identification (mocked search), and quantification tests
- `test-integration-synthetic.R` - full pipeline on a synthetic run with ground truth recovered
- `test-integration-real.R` - full `process_sample()` on the real phenols fixture run (skipped when fixtures absent)
- `fixtures/real_run/` - real ChemStation excerpt (`data.ms`, `FID1A.ch`)
- `fixtures/ri/ONSITE.CAL` - RI calibration format fixture
- `fixtures/real_windows/`, `fixtures/search/` - hand-picked windows and recorded search output
- `_snaps/` - testthat snapshot files

### Other
- `.posit/SPEC.md` - package specification (authoritative design doc; draft v2, decisions log in section 19)
- `inst/report/report.qmd` - Quarto template rendered by `write_pdf_report()`
- `dev/` - development notes and challenge register (Rbuildignored; currently empty: create `dev/challenges.md` when logging the first challenge)
- `vignettes/moosaic-params.Rmd` - parameter/options vignette
- `_pkgdown.yml`, `.github/workflows/` - pkgdown site (https://pbulsink.github.io/moosaic/), R-CMD-check, and test-coverage CI

## Architecture Summary

One function per file: exported functions are the public API (32 exports plus `.moosaic_default_options()` and the S3 print method); everything else is a dot-prefixed internal helper co-located with its module. Internal data flow follows the pipeline stages in `.posit/SPEC.md` section 17; raw FID intensities are never modified (detection works on processed copies), and MS spectra are normalised to max = 1 internally, scaled to max 999 for search/MSP output.

| File | Role | Key Functions |
|------|------|---------------|
| `aaa-options.R` | Single source of default option values | `.moosaic_default_options()` (exported) |
| `aaa-quant_data.R` | fidms lookup tables: atomic weights, calibration targets/points, family terms, solvents, tracked elements | data objects only |
| `align_detectors.R` | Align MS and FID retention times via a chosen engine | `align_detectors()` |
| `als_diagnostics.R` | Fit diagnostics for an ALS solution (lack of fit, R², convergence) | `.als_diagnostics()` |
| `annotate_component.R` | Annotate one component by library search with RI/element scoring | `annotate_component()` |
| `apply_alignment.R` | Apply a detector delay to MS retention times | `.apply_alignment()` |
| `apply_curve.R` | Evaluate calibration curves at measured responses | `.apply_curve()` |
| `apply_filter.R` | Symmetric-support FIR filter with edge padding | `.apply_filter()` |
| `apportion_fid_area.R` | Apportion raw FID area among fitted components by scan shares | `.apportion_fid_area()` |
| `assign_target_rows.R` | Governing calibration target for each peak | `.assign_target_rows()` |
| `background_profile.R` | Flat background profile for the ALS baseline column | `.background_profile()` |
| `bin_mz.R` | Compute nominal m/z bin index (round to integer) | `.bin_mz()` |
| `build_components.R` | Turn a window fit into component objects | `.build_components()` |
| `build_constraints.R` | Build FID-derived initial concentration profiles C0 | `build_constraints()` |
| `build_formula.R` | Build C/H/O formulas from element counts | `.build_formula()` |
| `build_ms_matrix.R` | Build a dense scan-by-m/z matrix from long MS data | `build_ms_matrix()` |
| `build_peak_table.R` | Peak table from an identified result with element columns | `.build_peak_table()` |
| `build_s0.R` | Initial spectra estimate S0 from SVD, non-negative max 1 | `.build_s0()` |
| `build_sparse_ms_matrix.R` | Build a sparse dgCMatrix scan-by-m/z matrix for the whole run | `.build_sparse_ms_matrix()` |
| `build_tic.R` | Build a total ion chromatogram from raw MS data (fallback/check) | `.build_tic()` |
| `carbon_count.R` | Carbon atoms per formula | `.carbon_count()` |
| `check_fid_baseline.R` | Verify the raw FID baseline is ~0 or linear; warn otherwise | `.check_fid_baseline()` |
| `classify_family.R` | Chemical family of each peak from name/formula terms | `.classify_family()` |
| `component_to_query.R` | Build a search query (mz/intst max 999, RI) from a component | `.component_to_query()` |
| `components_to_tibble.R` | Components as a tibble | `components_to_tibble()` |
| `compute_ri.R` | Retention index by piecewise linear interpolation of the RI ladder | `.compute_ri()` |
| `consensus_rank.R` | Consensus of rank votes with confidence | `.consensus_rank()` |
| `correct_baseline.R` | Subtract an estimated baseline (rolling minimum or fit) | `.correct_baseline()` |
| `deconvolve_run.R` | Deconvolve every FID window of a run into components | `deconvolve_run()` |
| `derivative_signal.R` | Savitzky-Golay derivative of a signal | `.derivative_signal()` |
| `detect_fid_peaks.R` | Detect peaks (apex, bounds, shoulder) in an FID trace | `detect_fid_peaks()` |
| `detect_fid_windows.R` | Merge detected peaks into deconvolution windows | `detect_fid_windows()` |
| `drop_empty_mz.R` | Remove m/z channels with no signal from a window matrix | `.drop_empty_mz()` |
| `element_counts.R` | Tracked element counts for formulas (fixed column order) | `.element_counts()` |
| `element_penalty.R` | Penalty for unexpected elements in a formula | `.element_penalty()` |
| `estimate_delay_gcalignr.R` | Estimate detector delay with GCalignR peak-list alignment | `.estimate_delay_gcalignr()` |
| `estimate_delay_xcorr.R` | Estimate detector delay by normalised cross-correlation | `.estimate_delay_xcorr()` |
| `estimate_delay.R` | Dispatch MS-to-FID delay estimation to a chosen engine | `.estimate_delay()` |
| `estimate_noise.R` | Robust noise estimate (MAD of differences) | `.estimate_noise()` |
| `estimate_rank.R` | Estimate the number of components in a window by consensus | `estimate_rank()` |
| `extract_fid_window.R` | FID signal resampled onto a window's MS scans (raw or detection copy) | `.extract_fid_window()` |
| `extract_metadata.R` | Extract metadata from raw data attributes into lists | `.extract_metadata()` |
| `extract_ms_matrix.R` | Extract the dense MS matrix for one window on aligned rt | `extract_ms_matrix()` |
| `find_local_maxima.R` | Find local maxima above a height threshold | `.find_local_maxima()` |
| `find_peak_bounds.R` | Find peak boundaries around an apex (valley/baseline stop) | `.find_peak_bounds()` |
| `find_shoulders.R` | Find shoulders from a second derivative | `.find_shoulders()` |
| `fit_calibration.R` | Fit external calibration curves per target group | `.fit_calibration()` |
| `fit_window.R` | Fit one window by MCR-ALS with FID constraints | `fit_window()` |
| `from_als_output.R` | Convert an `ALS::als()` result to moosaic structures | `.from_als_output()` |
| `gcms_fid_exp.R` | Create a validated gcms_fid_exp object from raw data | `gcms_fid_exp()` |
| `get_moosaic_option.R` | Read one option; abort with class on unknown name | `.get_moosaic_option()` |
| `has_shoulder.R` | Test a peak for an unresolved shoulder | `.has_shoulder()` |
| `identify_components.R` | Identify components of a deconvolved run (search + scoring) | `identify_components()` |
| `integrate_trapezoid.R` | Trapezoidal integral | `.integrate_trapezoid()` |
| `interpolate_unknowns.R` | Estimate formulas for unidentified peaks by interpolation | `.interpolate_unknowns()` |
| `is_background_component.R` | Flag column bleed, air ions, or flat baseline components | `.is_background_component()` |
| `is_gcms_fid_exp.R` | Type check for gcms_fid_exp objects | `is_gcms_fid_exp()` |
| `is_solvent.R` | Flag solvent peaks by name | `.is_solvent()` |
| `leading_singular_values.R` | Leading singular values of a matrix (rank methods) | `.leading_singular_values()` |
| `match_targets.R` | Match peak names to calibration targets incl. synonyms | `.match_targets()` |
| `merge_overlapping_peaks.R` | Merge overlapping peaks into deconvolution windows | `.merge_overlapping_peaks()` |
| `molecular_weight.R` | Molecular weight from atom counts (ported from fidms) | `.molecular_weight()` |
| `moosaic_abort.R` | cli error wrapper with `moosaic-error-{class}` classes | `.moosaic_abort()` |
| `moosaic_inform.R` | cli message wrapper with `moosaic-message-{class}` classes | `.moosaic_inform()` |
| `moosaic_options.R` | Get all current moosaic options | `moosaic_options()` |
| `moosaic_warn.R` | cli warning wrapper with `moosaic-warning-{class}` classes | `.moosaic_warn()` |
| `moosaic-package.R` | Package-level documentation stub (excluded from coverage) | — |
| `new_component.R` | Construct a component object (S3 `moosaic_component`) | `.new_component()` |
| `new_gcms_fid_exp.R` | Internal constructor for gcms_fid_exp objects | `.new_gcms_fid_exp()` |
| `normalize_columns.R` | Scale matrix columns to a maximum of 1 | `.normalize_columns()` |
| `parse_formula.R` | Parse a molecular formula into element counts (ported from fidms) | `.parse_formula()` |
| `parse_search_results.R` | Stack per-query search results into one tibble | `.parse_search_results()` |
| `parse_window.R` | Normalise a window specification to start/end rt | `.parse_window()` |
| `peak_prominence.R` | Topographic prominence of peaks (window merging) | `.peak_prominence()` |
| `peaks_to_gcalignr.R` | Convert detected peaks to GCalignR input data frames | `.peaks_to_gcalignr()` |
| `permute_columns.R` | Permute each column independently (parallel analysis nulls) | `.permute_columns()` |
| `polyarc_mass.R` | Polyarc mass of a component relative to the reference peak | `.polyarc_mass()` |
| `preprocess_fid_for_detection.R` | Prepare a detection copy of the FID trace (raw untouched) | `.preprocess_fid_for_detection()` |
| `print.gcms_fid_exp.R` | S3 print method for gcms_fid_exp objects | `print.gcms_fid_exp()` |
| `process_sample.R` | One-call pipeline: raw files to quantified, summarised result | `process_sample()` |
| `process_window.R` | Deconvolve one window (rank → constraints → ALS fit) | `process_window()` |
| `quantify.R` | Quantify identified components by the Polyarc method | `quantify()` |
| `rank_bic.R` | Rank estimate by BIC of rank-r reconstructions | `.rank_bic()` |
| `rank_fid.R` | Rank estimate from the FID trace peak count | `.rank_fid()` |
| `rank_pa.R` | Rank estimate by parallel analysis with column permutations | `.rank_pa()` |
| `rank_svd.R` | Rank estimate from cumulative explained variance of SVD | `.rank_svd()` |
| `read_experiment.R` | Read ChemStation `.ms`/`.ch` files via chromConverter into a gcms_fid_exp | `read_experiment()` |
| `read_ri_calibration.R` | Parse a whitespace-delimited RI calibration (`.CAL`) file | `read_ri_calibration()` |
| `recovery_excluded.R` | Names excluded from GC recovery calculations | `.recovery_excluded()` |
| `reference_peak_ok.R` | Which peaks can act as the internal reference peak | `.reference_peak_ok()` |
| `report_path.R` | Default report file name and path validation | `.report_path()`, `.check_report_path()` |
| `require_quantified.R` | Check that a result has been quantified before reporting | `.require_quantified()` |
| `resample_fid_to_scans.R` | Boxcar-mean resample of the FID onto the MS scan grid | `.resample_fid_to_scans()` |
| `reset_moosaic_options.R` | Reset all moosaic options to defaults | `reset_moosaic_options()` |
| `ri_penalty.R` | Retention index penalty with grace band | `.ri_penalty()` |
| `run_als.R` | Run `ALS::als()` quietly, capturing iteration trace into diagnostics | `.run_als()` |
| `run_mspepsearch.R` | Resolve and run the mspepsearchr search function; merge per-library batches | `.search_fn()`, `.run_mspepsearch()`, `.merge_search_batches()` |
| `running_min.R` | Centred running minimum (baseline estimation) | `.running_min()` |
| `sample_info.R` | Sample metadata object for quantification and reports | `sample_info()` |
| `score_candidates.R` | Combine match factor, RI penalty, element penalty into final score | `.score_candidates()` |
| `segment_fid_window.R` | Split a FID window into contiguous per-component segments | `.segment_fid_window()` |
| `set_moosaic_options.R` | Validate names and set options; return old values invisibly | `set_moosaic_options()` |
| `sg_coefs.R` | Savitzky-Golay filter coefficients for smoothing/derivative | `.sg_coefs()` |
| `smooth_signal.R` | Savitzky-Golay smoothing of a signal | `.smooth_signal()` |
| `specify_identification_penalties.R` | Configure RI grace, per-unit penalty, element penalties, allowed elements | `specify_identification_penalties()` |
| `specify_library.R` | Store NIST-format library paths (list) after existence checks | `specify_library()` |
| `specify_ri_calibration.R` | Store the RI calibration path after parse validation | `specify_ri_calibration()` |
| `specify_search_params.R` | Configure search function type, hits, threads, RI column type, min match factor | `specify_search_params()` |
| `standardize_fid.R` | Standardize raw FID data to the internal structure | `.standardize_fid()` |
| `standardize_ms.R` | Standardize raw MS data (MS1/TIC/BPC) to the internal structure | `.standardize_ms()` |
| `subset_rt.R` | Subset matrix rows to a retention-time window (inclusive) | `.subset_rt()` |
| `suggest_reference_peak.R` | Suggest the internal reference peak for quantification | `.suggest_reference_peak()` |
| `summarize_report.R` | Summarise a quantified result: families, elements, totals, notes | `summarize_report()` |
| `summary_notes.R` | Report footnotes (element and method notes) | `.summary_notes()`, `.element_note()` |
| `to_als_input.R` | Build the CList/PsiList/S/x/x2 argument list for `ALS::als()` | `.to_als_input()` |
| `total_compound_table.R` | Total compound table with areas, ratios, scores | `total_compound_table()` |
| `validate_gcms_fid_exp.R` | Validate gcms_fid_exp structure (rt order, lengths, types) | `.validate_gcms_fid_exp()` |
| `write_excel_report.R` | Write the multi-sheet Excel report via openxlsx | `write_excel_report()` |
| `write_msp.R` | Write components to an MSP file (intensities max 999) | `write_msp()` |
| `write_pdf_report.R` | Render the Quarto PDF report from `inst/report/report.qmd` | `write_pdf_report()` |
| `zzz.R` | `.onLoad()` sets only unset default options (.Rprofile wins) | — |

**Dependencies:**
- **Imports (DESCRIPTION):** ALS, chromConverter, cli, Matrix, tibble, rlang, stats
- **Suggested (optional features):** mspepsearchr (library search; `Remotes: andreysamokhin/mspepsearchr`, Windows native executable), quarto (PDF reports), openxlsx (Excel reports; guarded by `requireNamespace()`), GCalignR (`align_detectors()` gcalignr engine), knitr/rmarkdown (vignettes), testthat (>= 3.0.0), withr

## Standard Workflow

This section describes the typical development and testing workflow for this package. Agents should follow these steps when making changes:

### 1. Understand the Code Path
- Read `.posit/SPEC.md` first: it defines each stage's file/function table, data structures, options, and the decisions log (section 19).
- Read roxygen documentation in `R/*.R` to understand function purposes and signatures; every function (including internal) has full roxygen.
- Trace data flow through the pipeline stages (`process_sample()` is the reference order); identify which files are affected by the proposed change.

### 2. Make Changes
- One function per file: `R/{function_name}.R`; internal helpers are dot-prefixed and the file is named without the dot (e.g. `.estimate_delay()` → `R/estimate_delay.R`). Do not create new `.R` files unless adding a completely new capability that does not fit an existing module.
- Use `.moosaic_abort()`, `.moosaic_warn()`, `.moosaic_inform()` for all errors/warnings/messages (never bare `stop()`/`warning()`); pass `class = "{name}"` producing classes like `moosaic-error-{class}`, and name the calling function with `{.fn}` in messages.
- Validate parameters where they are used; propagate `call = rlang::caller_env()`.
- Follow existing style: `|>` pipes, `\()` lambdas, tibbles for tabular output, ASCII only. Format with `air format .` and keep code lintr-clean.
- Preserve full roxygen on every function you touch (`@param`, `@return` with structure, `@details`; `@examples` for exported; `@keywords internal` for helpers).

### 3. Add Tests (TDD)
- Tests are written **before** implementation and mirror source files: create or update `tests/testthat/test-{name}.R` matching `R/{name}.R`. Place new tests adjacent to existing tests for the same function.
- Test descriptions are plain behavioural sentences with no issue labels (e.g. `test_that(".bin_mz() rounds 39.9 to bin 40", ...)`).
- Use `withr::local_options()` around any test that changes moosaic options; use `make_synthetic_run()` from `helper-synthetic.R` for stage-level tests with known truth, and inline minimal inputs for unit tests.
- Follow the four-level gate: unit (per function) → stage (synthetic composition recovers ground truth) → challenge (real-data fixtures in `tests/testthat/fixtures/`, guarded by `skip_if_not(file.exists(...))`) → integration (`test-integration-*.R`). Log unexpected real-data behaviour in `dev/challenges.md`.
- Run tests with `devtools::test()` (or `testthat::test_local()`); testthat edition 3 is configured.
- Some functionality requires suggested packages: library search needs `mspepsearchr` (guarded by `requireNamespace()`; Windows-only executable) and PDF reports need `quarto` — use `skip_if_not_installed("quarto")` in tests for optional features.

### 4. Update Documentation
- Regenerate man pages and NAMESPACE: `roxygen2::roxygenise()` (or `devtools::document()`). Never edit `NAMESPACE` or `man/*.Rd` by hand — they are generated from roxygen comments.
- Update `.posit/SPEC.md` if the change alters a stage's contract, options table, or data structures; record decisions in its log (section 19).

### 5. Verify Build
- Full package check: `devtools::check()` (or `R CMD CHECK`) — no errors, warnings, or notes.
- Review test coverage for edited files with covr; the project target is 100% per file, excluding `R/moosaic-package.R` and `R/aaa-*.R`.
- Ensure no regressions in existing tests and that all file references remain valid.

## Testing Philosophy

- TDD: unit tests are written before implementation for every function; a stage is not done until its gate sequence (unit → stage → challenge) passes or the failure is logged in `dev/challenges.md`.
- Test outputs and behaviour, not just function existence: exact values on hand-built inputs, error classes (`moosaic-error-{class}`), edge cases, and ground-truth recovery from synthetic runs.
- Synthetic data with known truth via `make_synthetic_run()` mirrors real sampling rates (FID 50 Hz, MS 0.27 s scans) so stage tests exercise realistic conditions cheaply.
- Real-data fixtures (`fixtures/real_run/`, `fixtures/ri/ONSITE.CAL`) are small excerpts; large raw files are never committed. Challenge/integration tests on real data skip when fixtures or optional packages are absent.
- Snapshots (`_snaps/`) pin stable outputs (e.g. MSP text, print methods); update them deliberately with `testthat::snapshot_accept()` only when the output change is intended.
- Failing tests are valuable — address failures rather than suppressing them; do not weaken assertions to make a stage pass.
- Local testing takes about 36 minutes. Running devtools::check(cran=TRUE) skips the long tests. Alternatively use testthat::local_on_cran();devtools::test(); withr::deferred_run(), with filter and other testthat options passable to devtools::test().
