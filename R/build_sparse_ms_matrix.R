#' Build a sparse scan-by-m/z matrix
#'
#' @param ms The `ms` slot of a `gcms_fid_exp` (`data`, `rt`, ...), where
#'   `data` has columns `rt`, `mz`, `intensity`.
#' @param mz_min,mz_max,mz_bin Numeric; m/z range and bin width.
#' @param call Call environment for errors.
#'
#' @return A `dgCMatrix` with one row per scan in `ms$rt` and one column per
#'   m/z bin; column names are bin-centre m/z values. Intensities falling in
#'   the same bin are summed; ions outside the range are dropped.
#'
#' @keywords internal
.build_sparse_ms_matrix <- function(
  ms,
  mz_min,
  mz_max,
  mz_bin,
  call = rlang::caller_env()
) {
  if (!is.numeric(mz_min) || !is.numeric(mz_max) || mz_min >= mz_max) {
    .moosaic_abort(
      "{.arg mz_min} must be less than {.arg mz_max}.",
      class = "bad_argument",
      call = call
    )
  }
  cn <- tolower(colnames(ms$data))
  if (!all(c("rt", "mz", "intensity") %in% cn)) {
    .moosaic_abort(
      "MS data must have columns rt, mz, intensity.",
      class = "bad_format",
      call = call
    )
  }
  rt <- ms$data[, which(cn == "rt")]
  mz <- ms$data[, which(cn == "mz")]
  int <- ms$data[, which(cn == "intensity")]

  n_bins <- .bin_mz(mz_max, mz_min, mz_bin, call = call)
  j <- .bin_mz(mz, mz_min, mz_bin, call = call)
  i <- match(rt, ms$rt)
  keep <- !is.na(i) & j >= 1L & j <= n_bins

  Matrix::sparseMatrix(
    i = i[keep],
    j = j[keep],
    x = as.numeric(int[keep]),
    dims = c(length(ms$rt), n_bins),
    dimnames = list(NULL, mz_min + (seq_len(n_bins) - 1) * mz_bin)
  )
}
