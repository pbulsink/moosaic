# Create a new gcms_fid_exp object (internal constructor)

Internal function to construct the core data structure. Use
[`gcms_fid_exp()`](https://pbulsink.github.io/moosaic/reference/gcms_fid_exp.md)
or
[`read_experiment()`](https://pbulsink.github.io/moosaic/reference/read_experiment.md)
to build objects in user code.

## Usage

``` r
.new_gcms_fid_exp(ms, fid, alignment, processing)
```

## Arguments

- ms:

  List with elements `data` (matrix, rt, tic), `metadata`.

- fid:

  List with elements `rt`, `intensity`, `metadata`.

- alignment:

  List with elements `delay`, `engine`, `score`, `validated`.

- processing:

  List (log of steps and parameters).

## Value

An object of class `gcms_fid_exp`.
