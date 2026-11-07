# Process a sample from raw files to a quantified result

Runs the whole pipeline:
[`read_experiment()`](https://pbulsink.github.io/moosaic/reference/read_experiment.md),
[`align_detectors()`](https://pbulsink.github.io/moosaic/reference/align_detectors.md),
a raw FID baseline check,
[`deconvolve_run()`](https://pbulsink.github.io/moosaic/reference/deconvolve_run.md),
[`identify_components()`](https://pbulsink.github.io/moosaic/reference/identify_components.md),
[`quantify()`](https://pbulsink.github.io/moosaic/reference/quantify.md)
and (by default)
[`summarize_report()`](https://pbulsink.github.io/moosaic/reference/summarize_report.md).

## Usage

``` r
process_sample(
  ms_file,
  fid_file,
  info,
  ri_cal = NULL,
  style = NULL,
  reference_peak = NULL,
  include_solvents = FALSE,
  summarize = TRUE
)
```

## Arguments

- ms_file, fid_file:

  Paths to the ChemStation MS (`.ms`) and FID (`.ch`) files.

- info:

  Sample metadata from
  [`sample_info()`](https://pbulsink.github.io/moosaic/reference/sample_info.md).

- ri_cal:

  RI calibration; see
  [`identify_components()`](https://pbulsink.github.io/moosaic/reference/identify_components.md).

- style, reference_peak:

  Quantification options; see
  [`quantify()`](https://pbulsink.github.io/moosaic/reference/quantify.md).

- include_solvents, summarize:

  Whether to include solvent peaks in the summary, and whether to run
  [`summarize_report()`](https://pbulsink.github.io/moosaic/reference/summarize_report.md)
  at all.

## Value

A `moosaic_result` with `components`, `windows`, `identifications`,
`alignment`, `peaks`, `quant` and (if `summarize`) `summary`. Pass it to
[`total_compound_table()`](https://pbulsink.github.io/moosaic/reference/total_compound_table.md),
[`write_excel_report()`](https://pbulsink.github.io/moosaic/reference/write_excel_report.md)
or
[`write_pdf_report()`](https://pbulsink.github.io/moosaic/reference/write_pdf_report.md).

## Examples

``` r
if (FALSE) { # \dontrun{
res <- process_sample("run.ms", "run.ch", sample_info("S1", density = 0.85))
write_excel_report(res)
} # }
```
