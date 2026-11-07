# Write the Excel report

Writes a workbook with a "Total Compound Report" sheet (sample header
and
[`total_compound_table()`](https://pbulsink.github.io/moosaic/reference/total_compound_table.md))
and a "Summary Report" sheet (families, elements and notes).

## Usage

``` r
write_excel_report(x, path = NULL)
```

## Arguments

- x:

  A `moosaic_result` after
  [`quantify()`](https://pbulsink.github.io/moosaic/reference/quantify.md)
  (and optionally
  [`summarize_report()`](https://pbulsink.github.io/moosaic/reference/summarize_report.md),
  which is run if needed).

- path:

  Output `.xlsx` path; `NULL` gives
  `"{project_code}_{sample_id}_GC-MS-FID.xlsx"` in the working
  directory.

## Value

`path`, invisibly. Sheet names are truncated to Excel's 31 characters
and stripped of characters Excel forbids.

## Examples

``` r
if (FALSE) { # \dontrun{
write_excel_report(summarize_report(quantified), tempfile(fileext = ".xlsx"))
} # }
```
