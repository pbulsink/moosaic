#' Build C/H/O formulas
#'
#' @param c_n,h_n,o_n Numeric vectors of carbon, hydrogen and oxygen counts.
#'
#' @return Character vector of formulas such as `"C8H18"`; elements with a
#'   zero count are omitted.
#'
#' @keywords internal
.build_formula <- function(c_n, h_n, o_n) {
  part <- \(sym, n) ifelse(n > 0, paste0(sym, ifelse(n == 1, "", n)), "")
  paste0(part("C", c_n), part("H", h_n), part("O", o_n))
}
