# Write the PDF report

Renders the bundled Quarto template (`inst/report/report.qmd`) with the
same content as
[`write_excel_report()`](https://pbulsink.github.io/moosaic/reference/write_excel_report.md),
minus the analyst-only QC columns. Needs the quarto package, the Quarto
CLI and LaTeX.

## Usage

``` r
write_pdf_report(x, path = NULL)
```

## Arguments

- x:

  A `moosaic_result` after
  [`quantify()`](https://pbulsink.github.io/moosaic/reference/quantify.md)
  (and optionally
  [`summarize_report()`](https://pbulsink.github.io/moosaic/reference/summarize_report.md),
  which is run if needed).

- path:

  Output `.pdf` path; `NULL` gives
  `"{project_code}_{sample_id}_GC-MS-FID.pdf"` in the working directory.

## Value

`path`, invisibly.

## Details

The template is copied to a temporary directory and rendered there, so
the package directory is never written to.

## Examples

``` r
if (FALSE) { # \dontrun{
write_pdf_report(summarize_report(quantified), "report.pdf")
} # }
```
