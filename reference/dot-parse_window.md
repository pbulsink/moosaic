# Normalise a window specification

Normalise a window specification

## Usage

``` r
.parse_window(window, call = rlang::caller_env())
```

## Arguments

- window:

  A one-row data frame (e.g. a row of
  [`detect_fid_windows()`](https://pbulsink.github.io/moosaic/reference/detect_fid_windows.md))
  or a list with numeric `start_rt` and `end_rt` (FID time, min) and an
  optional `window_id`.

- call:

  Call environment for errors.

## Value

A list with `window_id` (`NA_integer_` if absent), `start_rt` and
`end_rt`.
