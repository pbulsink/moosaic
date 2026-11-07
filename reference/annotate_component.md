# Annotate one component by library search

Annotate one component by library search

## Usage

``` r
annotate_component(component, ri_cal = NULL)
```

## Arguments

- component:

  A `moosaic_component`.

- ri_cal:

  RI calibration: a data frame (see
  [`read_ri_calibration()`](https://pbulsink.github.io/moosaic/reference/read_ri_calibration.md)),
  a path to a `.CAL` file, or `NULL` to use
  `moosaic.ri_calibration_path` (no RI scoring if that is also unset).

## Value

The component with added `ri` (observed RI or `NA`), `hits` (scored
candidates, best first) and `name` (best candidate, `NA` if none).

## Details

Hits below `moosaic.min_match_factor` are dropped. See
[`identify_components()`](https://pbulsink.github.io/moosaic/reference/identify_components.md)
for the scoring.
