# Governing calibration target for each peak

Governing calibration target for each peak

## Usage

``` r
.assign_target_rows(peaks, matched, targets)
```

## Arguments

- peaks:

  Tibble with an `O` (oxygen count) column.

- matched:

  Character vector from
  [`.match_targets()`](https://pbulsink.github.io/moosaic/reference/dot-match_targets.md).

- targets:

  Tibble with columns `target` and `type` (`"hydrocarbon"` or
  `"oxygenate"`).

## Value

Integer vector of row indices into `peaks`: the nearest preceding
matched target of the same type (oxygenates use oxygenate targets), else
the first matched target; `NA` when no target matched.
