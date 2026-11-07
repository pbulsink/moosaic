# Estimate the MS-to-FID delay with a chosen engine

Estimate the MS-to-FID delay with a chosen engine

## Usage

``` r
.estimate_delay(
  fid,
  tic,
  engine,
  max_delay = 0.1,
  step = 0.001,
  call = rlang::caller_env()
)
```

## Arguments

- fid, tic:

  Lists with numeric `rt` and `intensity`; the FID trace and the MS
  total ion chromatogram.

- engine:

  One of `"gcalignr"` or `"xcorr"`.

- max_delay:

  Numeric; largest delay magnitude searched (min).

- step:

  Numeric; search step (min).

- call:

  Call environment for errors and warnings.

## Value

A list with `delay` (min; positive when MS times are later), `engine`,
and `score` (correlation for `"xcorr"`, `NA` for `"gcalignr"`).

## Details

Warns with class `delay_at_limit` when the estimate is within one `step`
of `max_delay`, since the true delay may lie outside the search range.
