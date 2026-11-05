#' Specify identification penalties
#'
#' Configures RI and element-based penalties for candidate scoring.
#'
#' @param ri_grace Integer; RI value within this range incurs zero penalty (default from options).
#' @param ri_penalty_per_unit Numeric; penalty per RI unit outside grace range (default from options).
#' @param element_penalties Named numeric vector; penalties for each element (default from options).
#' @param allowed_elements Character vector; elements allowed in formulas (default from options).
#' @param disallowed_element_penalty Numeric; penalty per atom of an element that is neither allowed nor in `element_penalties` (default from options).
#'
#' @return Invisibly, previous option values.
#'
#' @examples
#' \dontrun{
#'   specify_identification_penalties(
#'     ri_grace = 15,
#'     element_penalties = c(N = 50, S = 100)
#'   )
#' }
#'
#' @export
specify_identification_penalties <- function(
  ri_grace = NULL,
  ri_penalty_per_unit = NULL,
  element_penalties = NULL,
  allowed_elements = NULL,
  disallowed_element_penalty = NULL
) {
  opts <- list()
  if (!is.null(ri_grace)) {
    opts$ri_grace <- ri_grace
  }
  if (!is.null(ri_penalty_per_unit)) {
    opts$ri_penalty_per_unit <- ri_penalty_per_unit
  }
  if (!is.null(element_penalties)) {
    opts$element_penalties <- element_penalties
  }
  if (!is.null(disallowed_element_penalty)) {
    if (!is.numeric(disallowed_element_penalty) || length(disallowed_element_penalty) != 1L || is.na(disallowed_element_penalty) || disallowed_element_penalty < 0) {
      .moosaic_abort(
        "{.arg disallowed_element_penalty} must be a single non-negative number.",
        class = "bad_input",
        call = rlang::caller_env()
      )
    }
    opts$disallowed_element_penalty <- disallowed_element_penalty
  }
  if (!is.null(allowed_elements)) {
    opts$allowed_elements <- allowed_elements
  }

  if (length(opts) > 0) {
    do.call(set_moosaic_options, opts)
  }

  invisible(moosaic_options())
}
