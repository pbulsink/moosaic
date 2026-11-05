#' Carbon atoms per formula
#'
#' @param counts Named integer vector of atom counts, or a list of such
#'   vectors.
#'
#' @return Numeric vector of carbon counts (0 when there is no carbon).
#'
#' @keywords internal
.carbon_count <- function(counts) {
  if (!is.list(counts)) {
    counts <- list(counts)
  }
  vapply(counts, \(x) if ("C" %in% names(x)) as.numeric(x[["C"]]) else 0, 1)
}
