# Build the argument list for `ALS::als()`

Build the argument list for
[`ALS::als()`](https://rdrr.io/pkg/ALS/man/als.html)

## Usage

``` r
.to_als_input(D, C0, S0, rt, mz, call = rlang::caller_env())
```

## Arguments

- D:

  Numeric matrix, scans x m/z.

- C0:

  Numeric matrix, scans x components (initial concentrations).

- S0:

  Numeric matrix, m/z x components (initial spectra).

- rt, mz:

  Numeric vectors; scan times and m/z values.

- call:

  Call environment for errors.

## Value

Named list `CList`, `PsiList`, `S`, `x`, `x2`.
