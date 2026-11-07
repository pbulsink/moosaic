# Consensus of rank votes

Consensus of rank votes

## Usage

``` r
.consensus_rank(votes, call = rlang::caller_env())
```

## Arguments

- votes:

  Numeric vector of rank estimates, one per method (named or not). `NA`
  votes are ignored.

- call:

  Call environment for errors.

## Value

A list with `rank` (integer; the most common vote, ties going to the
higher rank) and `confidence` (the share of usable votes equal to
`rank`).
