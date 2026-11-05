#' Report footnotes
#'
#' @return `.summary_notes()`: character vector of numbered-note text.
#'   `.element_note()`: the elemental-composition note.
#'
#' @keywords internal
.summary_notes <- function() {
  c(
    "Compound types are programmatically determined and may not be entirely inclusive of compound type.",
    "Additional unmatched compounds are summed in unknown heteroatomic or unknown hydrocarbon type.",
    "Oxygenate includes all compounds with an oxygen atom, including methanol.",
    "Solvents are not included in summary.",
    "Compound types reported here are not a replacement for standard PIONA analysis."
  )
}

#' @rdname dot-summary_notes
#' @keywords internal
.element_note <- function() {
  "Elemental values are wt% sum of all GC determined compounds and does not include H2O"
}
