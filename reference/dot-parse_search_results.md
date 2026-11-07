# Stack search results into one tibble

Stack search results into one tibble

## Usage

``` r
.parse_search_results(hits)
```

## Arguments

- hits:

  List of data frames, one per query, each with an `unknown_name`
  attribute (see
  [`.run_mspepsearch()`](https://pbulsink.github.io/moosaic/reference/dot-run_mspepsearch.md)).

## Value

A tibble with `component_id`, `hit_rank`, `name`, `cas`, `formula`,
`mw`, `mf`, `rmf`, `prob` and `library_ri`; zero rows when there are no
hits.
