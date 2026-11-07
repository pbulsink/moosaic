# Default moosaic options

Single source of all moosaic configuration defaults.

## Usage

``` r
.moosaic_default_options()
```

## Value

A named list of defaults (not assigned to
[`options()`](https://rdrr.io/r/base/options.html)).

## Examples

``` r
.moosaic_default_options()
#> $moosaic.library_path
#> NULL
#> 
#> $moosaic.search_function
#> [1] "identity"
#> 
#> $moosaic.search_hits
#> [1] 10
#> 
#> $moosaic.search_threads
#> [1] 1
#> 
#> $moosaic.ri_column_type
#> [1] "semi-standard non-polar"
#> 
#> $moosaic.min_match_factor
#> [1] 600
#> 
#> $moosaic.ri_calibration_path
#> NULL
#> 
#> $moosaic.ri_extrapolate
#> [1] FALSE
#> 
#> $moosaic.mz_min
#> [1] 35
#> 
#> $moosaic.mz_max
#> [1] 500
#> 
#> $moosaic.mz_bin
#> [1] 1
#> 
#> $moosaic.align_engine
#> [1] "xcorr"
#> 
#> $moosaic.max_delay
#> [1] 0.2
#> 
#> $moosaic.align_step
#> [1] 0.001
#> 
#> $moosaic.fid_smooth_window
#> [1] 7
#> 
#> $moosaic.fid_baseline_method
#> [1] "rolling_min"
#> 
#> $moosaic.peak_min_height_snr
#> [1] 5
#> 
#> $moosaic.window_padding
#> [1] 0.02
#> 
#> $moosaic.window_merge_gap
#> [1] 0.01
#> 
#> $moosaic.min_scans_per_window
#> [1] 8
#> 
#> $moosaic.rank_methods
#> [1] "fid" "svd" "bic" "pa" 
#> 
#> $moosaic.rank_max
#> [1] 6
#> 
#> $moosaic.svd_var_threshold
#> [1] 0.99
#> 
#> $moosaic.pa_iterations
#> [1] 50
#> 
#> $moosaic.background_component
#> [1] TRUE
#> 
#> $moosaic.als_maxiter
#> [1] 100
#> 
#> $moosaic.als_thresh
#> [1] 0.001
#> 
#> $moosaic.als_unimodal
#> [1] TRUE
#> 
#> $moosaic.ri_grace
#> [1] 10
#> 
#> $moosaic.ri_penalty_per_unit
#> [1] 1
#> 
#> $moosaic.element_penalties
#>   N   S  Cl  Br  Si   P 
#>  50  50 100 100  25 100 
#> 
#> $moosaic.allowed_elements
#> [1] "C" "H" "O" "N" "S"
#> 
#> $moosaic.disallowed_element_penalty
#> [1] 100
#> 
#> $moosaic.quant_style
#> [1] "internal"
#> 
```
