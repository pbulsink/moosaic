#' Parse a molecular formula
#'
#' @param formula Single string such as `"C6H5Cl"`.
#' @param call Call environment for errors.
#'
#' @return Named integer vector of atom counts, in order of first appearance.
#'   Repeated elements are summed.
#'
#' @keywords internal
.parse_formula <- function(formula, call = rlang::caller_env()) {
  if (
    !is.character(formula) ||
      length(formula) != 1L ||
      is.na(formula) ||
      !grepl("^([A-Z][a-z]?[0-9]*)+$", formula)
  ) {
    .moosaic_abort(
      "Cannot parse formula {.val {formula}}.",
      class = "bad_formula",
      call = call
    )
  }
  tok <- regmatches(formula, gregexpr("[A-Z][a-z]?[0-9]*", formula))[[1]]
  el <- sub("[0-9]*$", "", tok)
  n <- sub("^[A-Za-z]+", "", tok)
  n <- ifelse(n == "", 1L, suppressWarnings(as.integer(n)))
  vapply(unique(el), \(e) sum(n[el == e]), integer(1))
}
