#' Build a search query from a component
#'
#' @param component A `moosaic_component`.
#' @param ri Observed retention index, or `NULL`/`NA` to omit it.
#' @param call Call environment for errors.
#'
#' @return List with `name` (the component id), `mz`, `intst` (integer, scaled
#'   so the maximum is 999, zero-intensity peaks dropped) and, when known,
#'   `retention_index`.
#'
#' @keywords internal
.component_to_query <- function(
  component,
  ri = NULL,
  call = rlang::caller_env()
) {
  s <- component$spectrum
  s <- s[!is.na(s) & s > 0]
  if (length(s) == 0L) {
    .moosaic_abort(
      "Component {.val {component$id}} has an empty spectrum.",
      class = "bad_argument",
      call = call
    )
  }
  q <- list(
    name = component$id,
    mz = as.numeric(names(s)),
    intst = as.integer(round(s / max(s) * 999))
  )
  if (!is.null(ri) && length(ri) == 1L && !is.na(ri)) {
    q$retention_index <- ri
  }
  q
}
