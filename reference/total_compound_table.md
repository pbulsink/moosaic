# Total compound table

Total compound table

## Usage

``` r
total_compound_table(x)
```

## Arguments

- x:

  A `moosaic_result` after
  [`quantify()`](https://pbulsink.github.io/moosaic/reference/quantify.md).

## Value

A tibble with one row per peak and columns `Peak No.`, `Compound Name`,
`Retention Time` (text, minutes), `Compound Formula`,
`Compound Molar Mass`, `Area (FID)`, `Amount (ug/mL)`,
`Target or Relative`, `MS Match Score`, `Area (MS)`, `FID/MS Ratio`,
`Rank Confidence`, `RI Delta` (observed minus library) and `Final Score`
(match factor less RI and element penalties). Scores are `NA` for
unidentified peaks.

## Examples

``` r
if (FALSE) { # \dontrun{
total_compound_table(quantify(identified, sample_info("S1")))
} # }
```
