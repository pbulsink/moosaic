# Summarise a quantified result for reporting

Summarise a quantified result for reporting

## Usage

``` r
summarize_report(quantified, include_solvents = FALSE)
```

## Arguments

- quantified:

  A `moosaic_result` after
  [`quantify()`](https://pbulsink.github.io/moosaic/reference/quantify.md).

- include_solvents:

  Include solvent peaks in the family and element totals.

## Value

`quantified` with a `summary` list:

- `families`: tibble(`compound_type`, `wt_pct`) over the eight families;

- `elements`: tibble(`element`, `wt_pct`) for C, H, N, O, S, normalised
  to 100 (zeros when nothing was quantified);

- `totals`: list(`gc_recovery`, `methanol`, `water`, `total`,
  `element_sum`);

- `qc`: list(`aligned_peaks` (library-identified), `unique_peaks`
  (estimated), `total_peaks`, `interpolated_peaks`, `ms_fid_offset`
  (min, `NA` if unknown));

- `info`, `include_solvents`.

## Details

GC recovery sums `wt_pct` over peaks other than solvents and the names
from
[`.recovery_excluded()`](https://pbulsink.github.io/moosaic/reference/dot-recovery_excluded.md)
(methanol too when the sample has added methanol, which is reported
separately).

## Examples

``` r
if (FALSE) { # \dontrun{
summarize_report(quantify(identified, sample_info("S1")))
} # }
```
