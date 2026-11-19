# Build a search query from a component

Build a search query from a component

## Usage

``` r
.component_to_query(component, ri = NULL)
```

## Arguments

- component:

  A `moosaic_component`.

- ri:

  Observed retention index, or `NULL`/`NA` to omit it.

## Value

List with `name` (the component id), `mz`, `intst` (integer, scaled so
the maximum is 999, zero-intensity peaks dropped) and, when known,
`retention_index`; `NULL` when the spectrum has no positive intensity,
in which case the component cannot be searched.
