# Build a search query from a component

Build a search query from a component

## Usage

``` r
.component_to_query(component, ri = NULL, call = rlang::caller_env())
```

## Arguments

- component:

  A `moosaic_component`.

- ri:

  Observed retention index, or `NULL`/`NA` to omit it.

- call:

  Call environment for errors.

## Value

List with `name` (the component id), `mz`, `intst` (integer, scaled so
the maximum is 999, zero-intensity peaks dropped) and, when known,
`retention_index`.
