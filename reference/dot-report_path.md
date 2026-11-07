# Default report file name and path check

Default report file name and path check

## Usage

``` r
.report_path(info, ext)

.check_report_path(path, call = rlang::caller_env())
```

## Arguments

- info:

  A `moosaic_sample`.

- ext:

  File extension without the dot.

- path:

  Candidate path (`NULL` or a single string).

- call:

  Call environment for errors.

## Value

`.report_path()`: `"{project_code}_{sample_id}_GC-MS-FID.{ext}"`.
`.check_report_path()`: `NULL`, invisibly; aborts with class
`bad_argument` unless `path` is `NULL` or a single string.
