# Abort with moosaic error

Internal helper to issue structured cli errors with moosaic-specific
classes.

## Usage

``` r
.moosaic_abort(
  message,
  class = NULL,
  call = rlang::caller_env(),
  .envir = rlang::caller_env()
)
```

## Arguments

- message:

  Character; error message. Use `{.fn}` to name the calling function.

- class:

  Character; error class suffix (becomes `moosaic-error-{class}`).

- call:

  Call environment for error location (usually
  [`rlang::caller_env()`](https://rlang.r-lib.org/reference/stack.html)).

- .envir:

  Environment used to evaluate [`{}`](https://rdrr.io/r/base/Paren.html)
  expressions in `message`.

## Value

Does not return (aborts).

## Examples

``` r
if (FALSE) { # \dontrun{
  .moosaic_abort("unknown option", "unknown_option", call = rlang::caller_env())
} # }
```
