#' Tracked element counts for formulas
#'
#' @param formula Character vector of molecular formulas.
#'
#' @return A tibble with one row per formula and one numeric column per
#'   tracked element (`C`, `H`, `N`, `O`, `F`, `Cl`, `Br`, `I`, `P`, `S`, `B`,
#'   `Si`). Rows are `NA` for an `NA` formula; other elements are ignored.
#'
#' @keywords internal
.element_counts <- function(formula) {
  counts <- lapply(formula, \(f) {
    out <- stats::setNames(
      rep(NA_real_, length(.tracked_elements)),
      .tracked_elements
    )
    if (!is.na(f)) {
      parsed <- .parse_formula(f)
      out[] <- 0
      keep <- intersect(names(parsed), .tracked_elements)
      out[keep] <- parsed[keep]
    }
    out
  })
  tibble::as_tibble(stats::setNames(
    lapply(.tracked_elements, \(el) vapply(counts, \(x) x[[el]], numeric(1))),
    .tracked_elements
  ))
}
