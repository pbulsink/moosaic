# Evaluate calibration curves

Evaluate calibration curves

## Usage

``` r
.apply_curve(area, curve)
```

## Arguments

- area:

  Numeric vector of FID areas.

- curve:

  Tibble with columns `intercept`, `slope` and `quad`, one row per
  element of `area` (see
  [`.fit_calibration()`](https://pbulsink.github.io/moosaic/reference/dot-fit_calibration.md)).

## Value

Numeric vector of amounts, clipped at zero.
