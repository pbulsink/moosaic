# Components as a tibble

Components as a tibble

## Usage

``` r
components_to_tibble(components)
```

## Arguments

- components:

  A list of `moosaic_component` objects or a `moosaic_result`.

## Value

A tibble with one row per component and the component fields as columns
(`chromatogram` and `spectrum` are list-columns).
