# Suggest the internal reference peak

Suggest the internal reference peak

## Usage

``` r
.suggest_reference_peak(
  peaks,
  min_score = .get_moosaic_option("min_match_factor"),
  min_area_percent = 0.001
)
```

## Arguments

- peaks:

  Peak table; see
  [`.reference_peak_ok()`](https://pbulsink.github.io/moosaic/reference/dot-reference_peak_ok.md).

- min_score, min_area_percent:

  See
  [`.reference_peak_ok()`](https://pbulsink.github.io/moosaic/reference/dot-reference_peak_ok.md).

## Value

A list: `peak_index` (row, `NA` if none), `n_peaks`, `total_area`,
`area_percent`, `score`, `name` and `approved`. `approved` is `TRUE`
when the largest peak itself qualifies; otherwise the largest qualifying
peak is returned.
