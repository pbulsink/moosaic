# Peak table from an identified result

Peak table from an identified result

## Usage

``` r
.build_peak_table(result)
```

## Arguments

- result:

  A `moosaic_result` after
  [`identify_components()`](https://pbulsink.github.io/moosaic/reference/identify_components.md).

## Value

A tibble with one row per analyte component, ordered by retention time:
`component_id`, `rt`, `ri`, `area` (raw FID), `area_ms`, `fid_ms_ratio`,
`rank_confidence` (`NA` unless the component carries one), `identified`,
`name`, `formula`, `mw`, `score` (match factor of the top hit),
`final_score`, `ri_delta` (observed minus library RI) and one count
column per tracked element. Fields from the top-ranked hit are `NA` for
unidentified components.

## Details

`mw` is computed from the formula; if an element has no atomic weight,
the library molecular weight is used instead.
