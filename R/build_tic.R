#' Build a total ion chromatogram from raw MS data
#'
#' Fallback and cross-check for the `TIC` supplied in the data file.
#'
#' @param ms The `ms` slot of a `gcms_fid_exp`, with `data` (columns `rt`,
#'   `mz`, `intensity`) and `rt` (scan times).
#'
#' @return Numeric vector, one summed intensity per element of `ms$rt`.
#'
#' @keywords internal
.build_tic <- function(ms) {
  cn <- tolower(colnames(ms$data))
  sums <- rowsum(
    as.numeric(ms$data[, which(cn == "intensity")]),
    ms$data[, which(cn == "rt")]
  )
  tic <- sums[match(as.character(ms$rt), rownames(sums)), 1]
  tic[is.na(tic)] <- 0
  as.numeric(tic)
}
