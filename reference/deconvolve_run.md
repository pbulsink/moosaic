# Deconvolve every FID window of a run

Deconvolve every FID window of a run

## Usage

``` r
deconvolve_run(exp, verbose = FALSE)
```

## Arguments

- exp:

  A `gcms_fid_exp` object, ideally after
  [`align_detectors()`](https://pbulsink.github.io/moosaic/reference/align_detectors.md).

- verbose:

  Logical; display a progress bar. Defaults to `FALSE`.

## Value

A `moosaic_result`: a list with `components` (all `moosaic_component`s,
in window order) and `windows` (the
[`detect_fid_windows()`](https://pbulsink.github.io/moosaic/reference/detect_fid_windows.md)
table).

## Details

Localized fits overlap for context. Only components whose apex is owned
by each window's core are returned, avoiding repeated assignment of an
identical boundary apex. Shifted duplicate estimates can remain.

## Examples

``` r
if (FALSE) { # \dontrun{
result <- deconvolve_run(exp)
} # }
```
