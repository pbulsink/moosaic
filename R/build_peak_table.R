#' Peak table from an identified result
#'
#' @param result A `moosaic_result` after [identify_components()].
#'
#' @return A tibble with one row per analyte component, ordered by retention
#'   time: `component_id`, `rt`, `ri`, `area` (raw FID), `area_ms`, `fid_ms_ratio`,
#'   `rank_confidence` (`NA` unless the component carries one), `identified`, `name`,
#'   `formula`, `mw`, `score` (match factor of the top hit), `final_score`,
#'   `ri_delta` (observed minus library RI) and one count column per tracked
#'   element. Fields from the top-ranked hit are `NA` for unidentified
#'   components.
#'
#' @details `mw` is computed from the formula; if an element has no atomic
#'   weight, the library molecular weight is used instead.
#'
#' @keywords internal
.build_peak_table <- function(result) {
  comps <- Filter(\(x) !isTRUE(x[["is_background"]]), result$components)
  comps <- comps[order(vapply(comps, \(x) x$rt, numeric(1)))]
  hit <- \(x, f, type) {
    h <- x[["hits"]]
    if (is.null(h) || nrow(h) == 0L || is.null(h[[f]])) type else h[[f]][1]
  }
  chr <- \(f) vapply(comps, hit, "", f = f, type = NA_character_)
  num <- \(f) vapply(comps, hit, 1, f = f, type = NA_real_)
  formula <- chr("formula")
  mw <- vapply(
    seq_along(comps),
    \(i) {
      if (is.na(formula[i])) {
        return(NA_real_)
      }
      tryCatch(
        .molecular_weight(.parse_formula(formula[i])),
        `moosaic-error-bad_formula` = \(e) hit(comps[[i]], "mw", NA_real_)
      )
    },
    numeric(1)
  )
  name <- chr("name")
  base <- tibble::tibble(
    component_id = vapply(comps, \(x) x$id, ""),
    rt = vapply(comps, \(x) x$rt, numeric(1)),
    ri = vapply(comps, \(x) x[["ri"]] %||% NA_real_, numeric(1)),
    area = vapply(comps, \(x) x$area_fid, numeric(1)),
    area_ms = vapply(comps, \(x) x$area_ms, numeric(1)),
    fid_ms_ratio = vapply(comps, \(x) x$fid_ms_ratio, numeric(1)),
    rank_confidence = vapply(
      comps,
      \(x) x[["rank_confidence"]] %||% NA_real_,
      numeric(1)
    ),
    identified = !is.na(name),
    name = name,
    formula = formula,
    mw = mw,
    score = num("mf"),
    final_score = num("final"),
    ri_delta = num("observed_ri") - num("library_ri")
  )
  tibble::as_tibble(c(as.list(base), as.list(.element_counts(formula))))
}
