#' Build a dense scan-by-m/z matrix from an experiment's MS data
#'
#' @param ms The `ms` slot of a `gcms_fid_exp`, or a `gcms_fid_exp` object.
#' @param rt_range Optional numeric length-2 vector (min); inclusive subset
#'   of scans.
#' @param mz_min,mz_max,mz_bin Numeric; default to the `moosaic.mz_min`,
#'   `moosaic.mz_max` and `moosaic.mz_bin` options.
#'
#' @return A list with `D` (dense numeric matrix, scans x m/z bins), `rt`
#'   (scan times) and `mz` (bin-centre m/z values).
#'
#' @details Fractional m/z values are assigned to the nearest bin centre and
#'   intensities within a bin are summed.
#'
#' @examples
#' ms <- list(
#'   data = cbind(
#'     rt = c(1, 1, 2),
#'     mz = c(40.1, 41.2, 40.2),
#'     intensity = c(10, 5, 8)
#'   ),
#'   rt = c(1, 2)
#' )
#' build_ms_matrix(ms, mz_min = 40, mz_max = 41, mz_bin = 1)
#'
#' @export
build_ms_matrix <- function(
  ms,
  rt_range = NULL,
  mz_min = .get_moosaic_option("mz_min"),
  mz_max = .get_moosaic_option("mz_max"),
  mz_bin = .get_moosaic_option("mz_bin")
) {
  call <- rlang::current_env()
  if (is_gcms_fid_exp(ms)) {
    ms <- ms$ms
  }
  sp <- .build_sparse_ms_matrix(
    ms,
    mz_min,
    mz_max,
    mz_bin,
    call = rlang::caller_env()
  )
  D <- as.matrix(sp)
  mz <- as.numeric(colnames(D))
  rt <- ms$rt
  if (!is.null(rt_range)) {
    sub <- .subset_rt(
      D,
      rt,
      rt_range[1],
      rt_range[2],
      call = rlang::caller_env()
    )
    D <- sub$D
    rt <- sub$rt
  }
  list(D = D, rt = rt, mz = mz)
}
