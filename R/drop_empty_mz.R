#' Remove m/z channels with no signal
#'
#' @param D Numeric matrix, scans x m/z, with m/z labels as column names.
#'
#' @return `D` without columns whose entries are all zero. Remaining columns
#'   keep their names; the result has zero columns if nothing remains.
#'
#' @keywords internal
.drop_empty_mz <- function(D) {
  D[, colSums(abs(D)) > 0, drop = FALSE]
}
