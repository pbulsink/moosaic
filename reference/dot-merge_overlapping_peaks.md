# Merge peaks into deconvolution windows

Merge peaks into deconvolution windows

## Usage

``` r
.merge_overlapping_peaks(
  peaks,
  padding,
  gap,
  max_width = Inf,
  max_peaks = Inf,
  call = rlang::caller_env()
)
```

## Arguments

- peaks:

  Tibble from
  [`detect_peaks()`](https://pbulsink.github.io/moosaic/reference/detect_peaks.md).

- padding:

  Numeric; minutes added to each side of every peak.

- gap:

  Numeric; padded intervals separated by no more than this many minutes
  are merged.

- max_width:

  Positive maximum core width in minutes; `Inf` disables it.

- max_peaks:

  Positive whole-number target for apexes per core; coincident apexes
  stay together. `Inf` disables this limit.

- call:

  Call environment for errors.

## Value

A tibble with `window_id`, `start_rt`, `end_rt`, `n_peaks` and
`peak_ids` (list column). Zero rows when `peaks` has none. With
localization enabled, also includes `core_start_rt`, `core_end_rt` and
`core_last` (whether the right endpoint is owned).

## Details

Merged regions are partitioned between apexes, then by width. Cores do
not overlap; fitting intervals extend by `padding` on either side inside
the original region. Peak membership uses apex ownership, not tails.
