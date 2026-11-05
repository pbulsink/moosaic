#' Create a gcms_fid_exp object from raw data
#'
#' High-level constructor for a GC-FID/MS experiment from MS and FID matrices.
#'
#' @param ms_data Numeric matrix with columns `rt`, `mz`, `intensity` (long format),
#'   or matrix with row scans, column m/z (dense format) with `rt` and `tic` as attributes.
#' @param fid_rt Numeric vector; FID retention times (min).
#' @param fid_intensity Numeric vector; FID intensities (pA).
#' @param ms_metadata List; metadata for MS detector.
#' @param fid_metadata List; metadata for FID detector.
#'
#' @return A `gcms_fid_exp` object.
#'
#' @examples
#' \dontrun{
#'   # From long-format MS data
#'   exp <- gcms_fid_exp(
#'     ms_data = ms_long,  # matrix: rt, mz, intensity
#'     fid_rt = fid$rt,
#'     fid_intensity = fid$intensity,
#'     ms_metadata = list(sample_name = "sample1"),
#'     fid_metadata = list(units = "pA")
#'   )
#' }
#'
#' @export
gcms_fid_exp <- function(
  ms_data,
  fid_rt,
  fid_intensity,
  ms_metadata = list(),
  fid_metadata = list()
) {
  ms <- .standardize_ms(ms_data, call = rlang::caller_env())
  fid <- .standardize_fid(
    list(rt = fid_rt, intensity = fid_intensity),
    call = rlang::caller_env()
  )

  # Add metadata
  ms$metadata <- ms_metadata
  fid$metadata <- fid_metadata

  exp <- .new_gcms_fid_exp(
    ms = ms,
    fid = fid,
    alignment = list(delay = 0, engine = NULL, score = NA, validated = FALSE),
    processing = list()
  )

  .validate_gcms_fid_exp(exp, call = rlang::caller_env())
  exp
}
