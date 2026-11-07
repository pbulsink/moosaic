# Turn a window fit into components

Turn a window fit into components

## Usage

``` r
.build_components(
  fit,
  fid_window,
  window,
  background = FALSE,
  call = rlang::caller_env()
)
```

## Arguments

- fit:

  Result of
  [`fit_window()`](https://pbulsink.github.io/moosaic/reference/fit_window.md).

- fid_window:

  List with `rt` and `intensity`: the **raw** FID on the window's scans.

- window:

  Window specification (see
  [`.parse_window()`](https://pbulsink.github.io/moosaic/reference/dot-parse_window.md)).

- background:

  Logical; the last fitted column is a background component.

- call:

  Call environment for errors.

## Value

List of `moosaic_component` objects, one per fitted column. `rt` is the
time of the maximum of the fitted profile; `area_fid` is the apportioned
raw FID area (`NA` for background); `area_ms` is the area of the fitted
profile scaled by the summed spectrum; `fid_ms_ratio` is their quotient;
`residual` is the window's lack of fit (%).
