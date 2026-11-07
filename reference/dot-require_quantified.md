# Check that a result has been quantified

Check that a result has been quantified

## Usage

``` r
.require_quantified(result, call = rlang::caller_env())
```

## Arguments

- result:

  Object to check.

- call:

  Call environment for errors.

## Value

`result`, invisibly. Aborts with class `bad_argument` if it is not a
`moosaic_result`, or `not_quantified` if
[`quantify()`](https://pbulsink.github.io/moosaic/reference/quantify.md)
has not been run.
