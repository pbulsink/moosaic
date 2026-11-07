# Apportion raw FID area among fitted components

Apportion raw FID area among fitted components

## Usage

``` r
.apportion_fid_area(
  fid_raw_window,
  C,
  is_background = NULL,
  call = rlang::caller_env()
)
```

## Arguments

- fid_raw_window:

  List with `rt` and `intensity` (raw FID on the window's scans).

- C:

  Numeric matrix, scans x components (fitted concentrations).

- is_background:

  Logical vector, one per column of `C`; `TRUE` columns take no share
  and get `NA`. Defaults to none.

- call:

  Call environment for errors.

## Value

Numeric vector, one area per column of `C`. At each scan the raw FID is
split in proportion to the non-background fitted signal, so the areas
sum to the trapezoidal area of the raw FID (scans where all components
are zero contribute nothing).
