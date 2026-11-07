# Fit one window by MCR-ALS

Fit one window by MCR-ALS

## Usage

``` r
fit_window(D, rank, C0, background = NULL)
```

## Arguments

- D:

  Numeric matrix, scans x m/z.

- rank:

  Integer; number of analyte components.

- C0:

  Numeric matrix, scans x components: initial concentrations (see
  [`build_constraints()`](https://pbulsink.github.io/moosaic/reference/build_constraints.md)),
  background column last.

- background:

  `NULL`/`FALSE` for none, otherwise `C0` must hold a trailing
  background column (`rank + 1` columns).

## Value

List with `concentration`, `spectra`, `residuals` and `diagnostics` (see
[`.als_diagnostics()`](https://pbulsink.github.io/moosaic/reference/dot-als_diagnostics.md),
plus `rss` and `rd`). Uses the `moosaic.als_maxiter`,
`moosaic.als_thresh` and `moosaic.als_unimodal` options. Initial spectra
come from the SVD
([`.build_s0()`](https://pbulsink.github.io/moosaic/reference/dot-build_s0.md)).
