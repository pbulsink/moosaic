# Set moosaic options

Set one or more moosaic options, with validation.

## Usage

``` r
set_moosaic_options(...)
```

## Arguments

- ...:

  Named arguments, one per option (without `moosaic.` prefix).

## Value

Invisibly, the previous values of the set options.

## Examples

``` r
old <- set_moosaic_options(rank_max = 8L)
old
#> $moosaic.rank_max
#> [1] 6
#> 
```
