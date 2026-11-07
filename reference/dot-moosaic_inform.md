# Inform with moosaic message

Internal helper to issue structured cli informational messages.

## Usage

``` r
.moosaic_inform(message, class = NULL, .envir = rlang::caller_env())
```

## Arguments

- message:

  Character; informational message.

- class:

  Character; optional message class suffix (becomes
  `moosaic-message-{class}`).

- .envir:

  Environment used to evaluate [`{}`](https://rdrr.io/r/base/Paren.html)
  expressions in `message`.
