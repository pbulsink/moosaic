#' Names excluded from GC recovery
#'
#' @param exclude_methanol Also exclude methanol (when it was added to the
#'   sample and is reported separately).
#'
#' @return Character vector of compound names.
#'
#' @keywords internal
.recovery_excluded <- function(exclude_methanol = FALSE) {
  base <- c("Methylene chloride", "Methane, dichloro-", "Acetonitrile", "Solvent")
  if (exclude_methanol) {
    c(base, "Methyl Alcohol", "Methanol")
  } else {
    base
  }
}
