# Run a library search

Run a library search

## Usage

``` r
.run_mspepsearch(queries, call = rlang::caller_env())
```

## Arguments

- queries:

  List of query lists (see
  [`.component_to_query()`](https://pbulsink.github.io/moosaic/reference/dot-component_to_query.md)).

- call:

  Call environment for errors.

## Value

The `mspepsearchr` result: one data frame per query, each with an
`unknown_name` attribute. Library paths, search function, hit count,
threads and RI column type come from the `moosaic.*` options.
