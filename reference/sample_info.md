# Sample metadata for quantification and reports

Sample metadata for quantification and reports

## Usage

``` r
sample_info(
  sample_id,
  sample_name = "",
  project_code = "",
  analyst = "",
  density = 1,
  methanol_wt_pct = 0,
  water_wt_pct = 0,
  dilution = 1,
  report_date = Sys.Date()
)
```

## Arguments

- sample_id:

  Sample identifier (single string).

- sample_name, project_code:

  Optional descriptive strings.

- analyst:

  Character vector of analysts; joined with `"/"`.

- density:

  Sample density (g/mL), positive.

- methanol_wt_pct, water_wt_pct:

  Methanol and water content (wt%), from 0 to 100, not seen by GC.

- dilution:

  Dilution factor, positive; scales external calibration amounts.

- report_date:

  Report date.

## Value

An object of class `moosaic_sample`: a list of the validated arguments.

## Examples

``` r
sample_info("S1", density = 0.85, analyst = c("A", "B"))
#> $sample_id
#> [1] "S1"
#> 
#> $sample_name
#> [1] ""
#> 
#> $project_code
#> [1] ""
#> 
#> $analyst
#> [1] "A/B"
#> 
#> $density
#> [1] 0.85
#> 
#> $methanol_wt_pct
#> [1] 0
#> 
#> $water_wt_pct
#> [1] 0
#> 
#> $dilution
#> [1] 1
#> 
#> $report_date
#> [1] "2026-11-10"
#> 
#> attr(,"class")
#> [1] "moosaic_sample"
```
