# Combine match factor and penalties into a final score

Combine match factor and penalties into a final score

## Usage

``` r
.score_candidates(candidates)
```

## Arguments

- candidates:

  Data frame with `component_id`, `mf`, `ri_penalty` and
  `element_penalty`. Missing penalties count as 0.

## Value

`candidates` ordered by component (first-appearance order) and
descending `final`, with `final = mf - ri_penalty - element_penalty` and
`final_rank` (1 is best within the component).
