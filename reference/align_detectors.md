# Align MS and FID retention times

Estimates the retention-time delay between the MS and the FID and
records it in the experiment. Raw times are never changed; downstream
functions subtract the delay from MS times.

## Usage

``` r
align_detectors(exp, engine = NULL)
```

## Arguments

- exp:

  A `gcms_fid_exp` object.

- engine:

  `"xcorr"` (default) or `"gcalignr"`. `NULL` uses the
  `moosaic.align_engine` option.

## Value

`exp` with `alignment` set to a list of `delay` (min; positive when MS
times are later than FID times), `engine`, `score` (cross-correlation at
the delay), `validated` (`FALSE`) and `cross_check` (`engine` and
`delay` of the xcorr cross-check; both `NA` when no cross-check was
run). The step is logged in `processing$align_detectors`.

## Details

Cross-correlation alone is sufficient to align the FID with the MS for
guiding deconvolution windows, so with `engine = "xcorr"` GCalignR is
not run. With `engine = "gcalignr"`, xcorr is run as a cheap
cross-check; a warning of class `engine_disagreement` is issued when the
two delays differ by more than one MS scan interval. If GCalignR cannot
run because too few peaks are found, the cross-correlation result is
used with a warning of class `engine_fallback`. Search range and step
come from the `moosaic.max_delay` and `moosaic.align_step` options.

## Examples

``` r
if (FALSE) { # \dontrun{
  exp <- align_detectors(exp)
} # }
```
