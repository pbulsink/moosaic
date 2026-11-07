# Get all moosaic options

Returns a list of currently set moosaic options.

## Usage

``` r
moosaic_options()
```

## Value

Named list of moosaic options (those starting with `moosaic.`).

## Examples

``` r
moosaic_options()
#> $moosaic.align_engine
#> [1] "xcorr"
#> 
#> $moosaic.align_step
#> [1] 0.001
#> 
#> $moosaic.allowed_elements
#> [1] "C" "H" "O" "N" "S"
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
#> $moosaic.background_component
#> [1] TRUE
#> 
#> $moosaic.disallowed_element_penalty
#> [1] 100
#> 
#> $moosaic.element_penalties
#>   N   S  Cl  Br  Si   P 
#>  50  50 100 100  25 100 
#> 
#> $moosaic.fid_baseline_method
#> [1] "rolling_min"
#> 
#> $moosaic.fid_smooth_window
#> [1] 7
#> 
#> $moosaic.max_delay
#> [1] 0.2
#> 
#> $moosaic.min_match_factor
#> [1] 600
#> 
#> $moosaic.min_scans_per_window
#> [1] 8
#> 
#> $moosaic.mz_bin
#> [1] 1
#> 
#> $moosaic.mz_max
#> [1] 500
#> 
#> $moosaic.mz_min
#> [1] 35
#> 
#> $moosaic.pa_iterations
#> [1] 50
#> 
#> $moosaic.peak_min_height_snr
#> [1] 5
#> 
#> $moosaic.quant_style
#> [1] "internal"
#> 
#> $moosaic.rank_max
#> [1] 6
#> 
#> $moosaic.rank_methods
#> [1] "fid" "svd" "bic" "pa" 
#> 
#> $moosaic.ri_column_type
#> [1] "semi-standard non-polar"
#> 
#> $moosaic.ri_extrapolate
#> [1] FALSE
#> 
#> $moosaic.ri_grace
#> [1] 10
#> 
#> $moosaic.ri_penalty_per_unit
#> [1] 1
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
#> $moosaic.svd_var_threshold
#> [1] 0.99
#> 
#> $moosaic.window_merge_gap
#> [1] 0.01
#> 
#> $moosaic.window_padding
#> [1] 0.02
#> 
```
