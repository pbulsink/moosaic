#' Molecular weight from atom counts
#'
#' @param counts Named integer vector of atom counts (as from
#'   [.parse_formula()]), or a list of such vectors.
#' @param call Call environment for errors.
#'
#' @return Numeric vector of molecular weights (g/mol), one per element of
#'   `counts`; `numeric(0)` for an empty list.
#'
#' @details Atomic weights come from the ported `atomic_weights` table. An
#'   element without an atomic weight aborts with class
#'   `moosaic-error-bad_formula`.
#'
#' @keywords internal
.molecular_weight <- function(counts, call = rlang::caller_env()) {
  if (!is.list(counts)) {
    counts <- list(counts)
  }
  vapply(
    counts,
    \(x) {
      w <- atomic_weights$mass[match(names(x), atomic_weights$symbol)]
      if (anyNA(w)) {
        missing_el <- names(x)[is.na(w)]
        .moosaic_abort(
          "No atomic weight for element {.val {missing_el}}.",
          class = "bad_formula",
          call = call
        )
      }
      sum(as.numeric(x) * w)
    },
    numeric(1)
  )
}
