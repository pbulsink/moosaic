# Getting Started with Moosaic

## What moosaic does

moosaic turns raw GC-FID/MS data into a quantified compound report. If
you have ever looked at a real run, the FID trace is a stack of partly
overlapping peaks and every mass spectrum in the TIC is a blend of
whatever is eluting at that moment – basic peak picking hands you apex
times and areas for that tangle, not for the individual compounds inside
it. moosaic untangles this: given the ChemStation files of one run –
`data.ms` for the mass spectrometer and `fid.ch` for the FID – it aligns
the two detectors, deconvolves each FID window into pure components by
FID-constrained MCR-ALS, identifies the components against a NIST-format
library with retention-index and element penalties, quantifies them by
the Polyarc method, and writes Excel and PDF reports. The one-call entry
point runs every stage:

`read_experiment() -> align_detectors() -> deconvolve_run() -> identify_components() -> quantify() -> summarize_report()`

A methods write-up covering the deconvolution and identification stages
in depth is planned; this vignette gets you from raw data to a report
file.

## What you need

- The ChemStation files of one run: an MS file (`.ms`) and its FID file
  (`.ch`). The two detectors see each peak a fraction of a minute apart,
  so moosaic needs both from the same injection.
- An RI calibration file (`.CAL`) for your column and oven program, read
  by
  [`read_ri_calibration()`](https://pbulsink.github.io/moosaic/reference/read_ri_calibration.md).
  Retention times are instrument-specific; the retention index
  re-expresses them on a standard scale, which is what lets peaks be
  matched against library RIs later.
- Sample metadata from
  [`sample_info()`](https://pbulsink.github.io/moosaic/reference/sample_info.md):
  a sample ID, density, and water or methanol content in wt% if present
  in the matrix. Density anchors the mass balance for internal
  quantification, and declared water/methanol keeps those out of the
  compound accounting.
- For identification: NIST-format library directories and the
  mspepsearchr package (Windows). Without them everything upstream still
  runs – deconvolution and quantification work fine; you just get
  unnamed peaks with interpolated formulas.
- For reports: openxlsx for the Excel workbook, and the Quarto CLI with
  LaTeX for the PDF.

## Run it

The example we work on here is diesel fuel, with a spike of phenols and
octanol (in isopropanol) added. The file names below are simply those in
your working directory; on a desktop PC this run takes roughly an hour
end to end, most of it per-window deconvolution and library searching.

The NIST-format library directories are supplied through the
`moosaic.library_path` option rather than as an argument – set once,
every call in the session uses them (here they point at our local NIST
23 install; adjust to your own).

``` r

info <- sample_info(
  "phenols-in-diesel",
  sample_name = "phenols-in-diesel",
  density = 0.85554,
  water_wt_pct = 36e-4 # 36 ppm water
)

res <- process_sample("./data.ms", "./fid.ch", info, ri_cal = "./ONSITE.CAL")
#> Warning in .check_fid_baseline(exp$fid): FID baseline is curved (departs from a straight line by 13); Polyarc areas may
#> be biased.
#> Warning in detect_fid_windows(exp): `detect_fid_windows()`: 1 window has fewer than 8 MS scans.
#> ℹ Window id: 1
#> `estimate_rank()`: `max_rank` (6) reduced to 3, the smallest dimension of `D`.
#> `estimate_rank()`: no method found signal in the window; using rank 1.
#> `estimate_rank()`: `max_rank` (6) reduced to 2, the smallest dimension of `D`.
#> Window has 1 resolvable peak; splitting the widest segment to reach 4 segments.
#> Parallel analysis ■■■■■■■■■■■                       32% | ETA:  5s
#> 
#> Parallel analysis ■■■■■■■■■■■■■■■■■■■■■■■           74% | ETA:  3s
#> Warning in identify_components(result, ri_cal = ri_cal): 1 retention time outside the calibrated range (1.42 to 82.302 min); RI set to
#> `NA`.
#> Warning in identify_components(result, ri_cal = ri_cal): 1 retention time outside the calibrated range (1.42 to 82.302 min); RI set to
#> `NA`.
#> 1 retention time outside the calibrated range (1.42 to 82.302 min); RI set to
#> `NA`.
#> 1 retention time outside the calibrated range (1.42 to 82.302 min); RI set to
#> `NA`.
#> 1 retention time outside the calibrated range (1.42 to 82.302 min); RI set to
#> `NA`.
#> 1 retention time outside the calibrated range (1.42 to 82.302 min); RI set to
#> `NA`.
#> 1 retention time outside the calibrated range (1.42 to 82.302 min); RI set to
#> `NA`.
#> 1 retention time outside the calibrated range (1.42 to 82.302 min); RI set to
#> `NA`.
#> 1 retention time outside the calibrated range (1.42 to 82.302 min); RI set to
#> `NA`.
#> 1 retention time outside the calibrated range (1.42 to 82.302 min); RI set to
#> `NA`.
#> 1 retention time outside the calibrated range (1.42 to 82.302 min); RI set to
#> `NA`.
#> 1 retention time outside the calibrated range (1.42 to 82.302 min); RI set to
#> `NA`.
#> 1 retention time outside the calibrated range (1.42 to 82.302 min); RI set to
#> `NA`.
#> 1 retention time outside the calibrated range (1.42 to 82.302 min); RI set to
#> `NA`.
#> 1 retention time outside the calibrated range (1.42 to 82.302 min); RI set to
#> `NA`.
#> 1 retention time outside the calibrated range (1.42 to 82.302 min); RI set to
#> `NA`.
#> 1 retention time outside the calibrated range (1.42 to 82.302 min); RI set to
#> `NA`.
#> 1 retention time outside the calibrated range (1.42 to 82.302 min); RI set to
#> `NA`.
#> 1 retention time outside the calibrated range (1.42 to 82.302 min); RI set to
#> `NA`.
#> Error in `identify_components()`:
#> ! Component "w40_c2" has an empty spectrum.
```

[`process_sample()`](https://pbulsink.github.io/moosaic/reference/process_sample.md)
reads the two files, aligns the MS to the FID (the mass spectrometer
sees each peak a few seconds late), deconvolves every detected FID
window into pure components, searches the library for each one, and
quantifies with the internal (Polyarc) style so the amounts total 100
wt% of the sample density. The result is a `moosaic_result`; everything
downstream reads from it.

## Reading the results

The peak table is what you would hand to someone: one row per quantified
peak in retention-time order, from
[`total_compound_table()`](https://pbulsink.github.io/moosaic/reference/total_compound_table.md).
Columns worth knowing: `Amount (ug/mL)` is the Polyarc amount;
`Target or Relative` says how it was obtained – directly as a target, or
relative to the reference peak; `MS Match Score` and `Final Score` are
the library match factor on its 0–1000 scale with and without the RI and
element penalties applied. Peaks that were not identified have `NA`
scores and an interpolated formula.

``` r

tbl <- total_compound_table(res)
#> Error:
#> ! object 'res' not found
tbl[!is.na(tbl$`Compound Formula`), ]
#> Error:
#> ! object 'tbl' not found
```

Behind the peaks,
[`components_to_tibble()`](https://pbulsink.github.io/moosaic/reference/components_to_tibble.md)
has one row per pure component the ALS fit found in each window: fitted
areas, the `fid_ms_ratio`, and `explained_variance` – values near 1 mean
the component’s profile and spectrum reconstruct that window well. This
is where you would go to inspect a suspicious deconvolution.

``` r

comp <- components_to_tibble(res)
#> Error:
#> ! object 'res' not found
head(comp[, setdiff(names(comp), c("chromatogram", "spectrum"))])
#> Error:
#> ! object 'comp' not found
```

With internal quantification the peak amounts normalise to a total of
100 wt%:

``` r

sum(res$peaks$wt_pct)
#> Error:
#> ! object 'res' not found
```

## Reports

[`write_excel_report()`](https://pbulsink.github.io/moosaic/reference/write_excel_report.md)
writes a two-sheet workbook – a Total Compound Report (sample header
plus the peak table above) and a Summary Report (family and element
balances, QC numbers, footnotes);
[`write_pdf_report()`](https://pbulsink.github.io/moosaic/reference/write_pdf_report.md)
renders the bundled Quarto template with the same content minus the
analyst-only columns. Pass an output path as shown, or let each function
name the file from your project code and sample ID. Both packages are
Suggests, so install openxlsx / quarto to produce these yourself.

``` r

write_excel_report(res, "report.xlsx")
#> Loading required namespace: openxlsx
#> Error:
#> ! object 'res' not found
write_pdf_report(res, "report.pdf")
#> Error:
#> ! object 'res' not found
list.files(pattern = "^report\\.(xlsx|pdf)$")
#> character(0)
```

![First page of the PDF report.](report-head.png)

First page of the PDF report.

## Where to go next

- Every tunable option is documented in the [options
  vignette](https://pbulsink.github.io/moosaic/articles/moosaic-params.md).
- The stage functions
  ([`read_experiment()`](https://pbulsink.github.io/moosaic/reference/read_experiment.md),
  [`align_detectors()`](https://pbulsink.github.io/moosaic/reference/align_detectors.md),
  [`deconvolve_run()`](https://pbulsink.github.io/moosaic/reference/deconvolve_run.md),
  [`process_window()`](https://pbulsink.github.io/moosaic/reference/process_window.md),
  [`fit_window()`](https://pbulsink.github.io/moosaic/reference/fit_window.md))
  let you intervene on individual windows – for instance, to re-fit one
  whose rank confidence came out low; see their help pages.
