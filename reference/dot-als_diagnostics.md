# Fit diagnostics for an ALS solution

Fit diagnostics for an ALS solution

## Usage

``` r
.als_diagnostics(D, C, S, fit)
```

## Arguments

- D:

  Numeric matrix, scans x m/z.

- C, S:

  Fitted concentrations (scans x comp) and spectra (m/z x comp).

- fit:

  List with `iter`, `converged` and `rd_final` (see
  [`.from_als_output()`](https://pbulsink.github.io/moosaic/reference/dot-from_als_output.md)).

## Value

List with `lack_of_fit` (percent), `r2`, `iter`, `converged`, `rd_final`
and `explained_variance` (per component, fraction of `sum(D^2)`).
