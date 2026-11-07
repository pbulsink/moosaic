# Run `ALS::als()` quietly

Run [`ALS::als()`](https://rdrr.io/pkg/ALS/man/als.html) quietly

## Usage

``` r
.run_als(
  input,
  maxiter,
  thresh,
  unimodal,
  baseline,
  call = rlang::caller_env()
)
```

## Arguments

- input:

  List from
  [`.to_als_input()`](https://pbulsink.github.io/moosaic/reference/dot-to_als_input.md).

- maxiter, thresh:

  Passed to [`ALS::als()`](https://rdrr.io/pkg/ALS/man/als.html).

- unimodal:

  Logical; constrain concentration profiles to be unimodal.

- baseline:

  Logical; passed to
  [`ALS::als()`](https://rdrr.io/pkg/ALS/man/als.html) (a flat
  background column is then not altered by the baseline treatment).

- call:

  Call environment for the warning.

## Value

The `als()` result with an added `trace` element (the captured console
output). Warns with class `als_not_converged` when `iter >= maxiter`;
the result is still returned.
