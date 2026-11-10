# Specify search parameters

Configures library search options: search function, number of hits,
threads, and scoring.

## Usage

``` r
specify_search_params(
  type = NULL,
  hits = NULL,
  threads = NULL,
  ri_column_type = NULL,
  min_match_factor = NULL
)
```

## Arguments

- type:

  Character; search function type: `"identity"`, `"simple"`, `"hybrid"`,
  or `"neutral_loss"`.

- hits:

  Integer; number of hits to return (default from options).

- threads:

  Integer; number of threads for parallel search (default from options).

- ri_column_type:

  Character; RI column type reported by MSPepSearch:
  `"semi-standard non-polar"` or `"standard non-polar"`.

- min_match_factor:

  Integer; minimum match factor to report (default from options).

## Value

Invisibly, previous option values.

## Examples

``` r
if (FALSE) { # \dontrun{
  specify_search_params(
    type = "hybrid",
    hits = 20L,
    threads = 4L,
    min_match_factor = 700
  )
} # }
```
