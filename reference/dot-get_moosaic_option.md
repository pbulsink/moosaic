# Get a moosaic option by name

Internal helper to read a moosaic option, with validation.

## Usage

``` r
.get_moosaic_option(name, call = rlang::caller_env())
```

## Arguments

- name:

  Character; option name (without `moosaic.` prefix).

- call:

  Call environment for errors.

## Value

The option value, or aborts if unknown.
