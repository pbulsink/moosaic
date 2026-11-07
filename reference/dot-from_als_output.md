# Convert an `ALS::als()` result to moosaic structures

Convert an [`ALS::als()`](https://rdrr.io/pkg/ALS/man/als.html) result
to moosaic structures

## Usage

``` r
.from_als_output(fit, rt, mz, maxiter)
```

## Arguments

- fit:

  Result of [`ALS::als()`](https://rdrr.io/pkg/ALS/man/als.html),
  optionally with a `trace` element.

- rt, mz:

  Numeric vectors used as dimnames.

- maxiter:

  Integer; iteration limit used.

## Value

List with `concentration`, `spectra`, `residuals`, `rss`, `iter`,
`converged` (`iter < maxiter`), `rd` (relative RSS decrease per
iteration parsed from the trace; may be negative) and `rd_final`.
