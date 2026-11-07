# Resolve a search function from its option value

Resolve a search function from its option value

## Usage

``` r
.search_fn(type, call = rlang::caller_env())
```

## Arguments

- type:

  One of `"identity"`, `"simple"`, `"hybrid"`, `"neutral_loss"`.

- call:

  Call environment for errors.

## Value

The matching `mspepsearchr` function.
