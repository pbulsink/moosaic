# Which peaks can act as the internal reference

Which peaks can act as the internal reference

## Usage

``` r
.reference_peak_ok(
  peaks,
  min_score = .get_moosaic_option("min_match_factor"),
  min_area_percent = 0.001
)
```

## Arguments

- peaks:

  Tibble with `name`, `score`, `area`, the halogen/heteroatom count
  columns (`F`, `Cl`, `Br`, `I`, `B`, `P`, `Si`) and optionally a
  logical `combined_peak`.

- min_score:

  Minimum library match factor; defaults to option
  `moosaic.min_match_factor`.

- min_area_percent:

  Minimum share of the total area (percent).

## Value

Logical vector: named, sufficiently well matched, not combined, free of
disqualifying elements and large enough.
