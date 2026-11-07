# Construct a component

Construct a component

## Usage

``` r
.new_component(
  id,
  window_id,
  rt,
  chromatogram,
  spectrum,
  area_fid,
  area_ms,
  fid_ms_ratio,
  residual,
  explained_variance,
  is_background
)
```

## Arguments

- id, window_id, rt, chromatogram, spectrum, area_fid, area_ms,
  fid_ms_ratio, residual, explained_variance, is_background:

  Component fields; see
  [`.build_components()`](https://pbulsink.github.io/moosaic/reference/dot-build_components.md).

## Value

An object of class `moosaic_component` (a list).
