# Merge per-library search results query by query

Merge per-library search results query by query

## Usage

``` r
.merge_search_batches(batches)
```

## Arguments

- batches:

  List of `mspepsearchr` results (one data frame per query, same query
  order).

## Value

One list of data frames, rows stacked per query, best match factor
first, with the `unknown_name` attribute kept.
