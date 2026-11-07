# Fit external calibration curves

Fit external calibration curves

## Usage

``` r
.fit_calibration(points, style = c("slope", "slope_intercept", "quadratic"))
```

## Arguments

- points:

  Calibration points: a data frame with columns `target`, `conc` and
  `resp`.

- style:

  One of `"slope"` (through the origin), `"slope_intercept"` or
  `"quadratic"`.

## Value

A tibble with one row per target: `target`, `n_points`, `intercept`,
`slope`, `quad` (concentration as a function of response) and `r2`.
Coefficients not part of `style` are 0; all are `NA` when too few points
remain.

## Details

Points with missing values or a response of zero are treated as below
detection and excluded. For `"slope"`, `r2` is the uncentered
coefficient of determination of the regression through the origin.
