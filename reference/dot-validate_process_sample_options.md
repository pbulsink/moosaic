# Validate process_sample() arguments and processing options

Validate process_sample() arguments and processing options

## Usage

``` r
.validate_process_sample_options(
  ri_cal,
  style,
  reference_peak,
  include_solvents,
  summarize,
  verbose,
  call = rlang::caller_env()
)
```

## Arguments

- ri_cal, style, reference_peak, include_solvents, summarize, verbose:

  Arguments passed to
  [`process_sample()`](https://pbulsink.github.io/moosaic/reference/process_sample.md).

- call:

  Call environment for errors.

## Value

`NULL`, invisibly. Aborts when an argument or option is invalid.
