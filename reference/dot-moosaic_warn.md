# Warn with moosaic warning

Internal helper to issue structured cli warnings with moosaic-specific
classes.

## Usage

``` r
.moosaic_warn(
  message,
  class = NULL,
  call = rlang::caller_env(),
  .envir = rlang::caller_env()
)
```

## Arguments

- message:

  Character; warning message.

- class:

  Character; warning class suffix (becomes `moosaic-warning-{class}`).

- call:

  Call environment for warning location.

- .envir:

  Environment used to evaluate [`{}`](https://rdrr.io/r/base/Paren.html)
  expressions in `message`.
