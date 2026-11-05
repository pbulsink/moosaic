#' Identify the components of a deconvolved run
#'
#' Computes each analyte component's RI, searches the spectral library once
#' for all of them, and scores the candidates as
#' `final = mf - ri_penalty - element_penalty`.
#'
#' @param result A `moosaic_result` (see [deconvolve_run()]).
#' @param ri_cal RI calibration; see [annotate_component()].
#'
#' @return `result` with annotated components (`ri`, `hits`, `name`; background
#'   components are left unannotated) and an `identifications` tibble of all
#'   scored candidates.
#'
#' @details The RI penalty is zero within `moosaic.ri_grace` of the library RI
#'   and `moosaic.ri_penalty_per_unit` per unit beyond; it is zero (and flagged
#'   in `ri_missing`) when either RI is missing. The element penalty comes from
#'   `moosaic.element_penalties` (per atom); every atom of an element that is
#'   neither listed there nor in `moosaic.allowed_elements` is also penalised by
#'   `moosaic.disallowed_element_penalty` per atom.
#'
#' @export
identify_components <- function(result, ri_cal = NULL) {
  call <- rlang::current_env()
  if (!inherits(result, "moosaic_result")) {
    .moosaic_abort(
      "{.arg result} must be a {.cls moosaic_result}.",
      class = "bad_argument",
      call = call
    )
  }
  cal <- .resolve_ri_cal(ri_cal)
  comps <- result$components
  analyte <- which(!vapply(comps, \(x) isTRUE(x$is_background), logical(1)))
  ris <- vapply(
    comps[analyte],
    \(x) if (is.null(cal)) NA_real_ else .compute_ri(x$rt, cal, call = call),
    numeric(1)
  )
  ids_all <- vapply(comps[analyte], \(x) x$id, "")
  names(ris) <- ids_all
  queries <- lapply(seq_along(analyte), \(i) {
    .component_to_query(comps[[analyte[i]]], ris[[i]], call = call)
  })
  hits <- if (length(queries) > 0L) {
    .parse_search_results(.run_mspepsearch(queries))
  } else {
    .parse_search_results(list())
  }
  ids <- .score_hits(hits, ris)
  for (i in seq_along(analyte)) {
    comps[[analyte[i]]] <- .apply_annotation(comps[[analyte[i]]], ris[[i]], ids)
  }
  result$components <- comps
  result$identifications <- ids
  result
}
