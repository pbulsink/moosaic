#' Annotate one component by library search
#'
#' @param component A `moosaic_component`.
#' @param ri_cal RI calibration: a data frame (see [read_ri_calibration()]), a
#'   path to a `.CAL` file, or `NULL` to use `moosaic.ri_calibration_path`
#'   (no RI scoring if that is also unset).
#'
#' @return The component with added `ri` (observed RI or `NA`), `hits` (scored
#'   candidates, best first) and `name` (best candidate, `NA` if none).
#'
#' @details Hits below `moosaic.min_match_factor` are dropped. See [identify_components()] for the scoring.
#'
#' @export
annotate_component <- function(component, ri_cal = NULL) {
  call <- rlang::current_env()
  if (!inherits(component, "moosaic_component")) {
    .moosaic_abort(
      "{.arg component} must be a {.cls moosaic_component}.",
      class = "bad_argument",
      call = call
    )
  }
  cal <- .resolve_ri_cal(ri_cal)
  ri <- if (is.null(cal)) {
    NA_real_
  } else {
    .compute_ri(component$rt, cal, call = call)
  }
  q <- .component_to_query(component, ri, call = call)
  hits <- .parse_search_results(.run_mspepsearch(list(q)))
  ids <- .score_hits(hits, stats::setNames(ri, component$id))
  .apply_annotation(component, ri, ids)
}

.resolve_ri_cal <- function(ri_cal) {
  ri_cal <- ri_cal %||% .get_moosaic_option("ri_calibration_path")
  if (is.character(ri_cal)) {
    ri_cal <- read_ri_calibration(ri_cal)
  }
  ri_cal
}

.score_hits <- function(hits, ri_by_component) {
  hits <- hits[
    !is.na(hits$mf) & hits$mf >= .get_moosaic_option("min_match_factor"),
  ]
  hits$observed_ri <- unname(ri_by_component[hits$component_id])
  rp <- .ri_penalty(
    hits$observed_ri,
    hits$library_ri,
    .get_moosaic_option("ri_grace"),
    .get_moosaic_option("ri_penalty_per_unit")
  )
  hits$ri_penalty <- rp$penalty
  hits$ri_missing <- rp$ri_missing
  hits$element_penalty <- .element_penalty(
    hits$formula,
    .get_moosaic_option("element_penalties"),
    .get_moosaic_option("allowed_elements"),
    default = .get_moosaic_option("disallowed_element_penalty")
  )
  out <- .score_candidates(hits)
  out[is.finite(out$final), ]
}

.apply_annotation <- function(component, ri, ids) {
  mine <- ids[ids$component_id == component$id, ]
  component$ri <- ri
  component$hits <- mine
  component$name <- if (nrow(mine) > 0L) mine$name[1] else NA_character_
  component
}
