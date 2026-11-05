#' Which peaks can act as the internal reference
#'
#' @param peaks Tibble with `name`, `score`, `area`, the halogen/heteroatom
#'   count columns (`F`, `Cl`, `Br`, `I`, `B`, `P`, `Si`) and optionally a
#'   logical `combined_peak`.
#' @param min_score Minimum library match factor; defaults to option
#'   `moosaic.min_match_factor`.
#' @param min_area_percent Minimum share of the total area (percent).
#'
#' @return Logical vector: named, sufficiently well matched, not combined, free
#'   of disqualifying elements and large enough.
#'
#' @keywords internal
.reference_peak_ok <- function(
  peaks,
  min_score = .get_moosaic_option("min_match_factor"),
  min_area_percent = 0.001
) {
  named <- !is.na(peaks$name) & nzchar(peaks$name)
  scored <- !is.na(peaks$score) & peaks$score >= min_score
  combined <- if (is.null(peaks[["combined_peak"]])) {
    FALSE
  } else {
    peaks[["combined_peak"]] %in% TRUE
  }
  disqualifying <- intersect(
    c("F", "Cl", "Br", "I", "B", "P", "Si"),
    names(peaks)
  )
  hetero <- rowSums(peaks[, disqualifying, drop = FALSE], na.rm = TRUE) > 0
  total_area <- sum(peaks$area, na.rm = TRUE)
  big_enough <- !is.na(peaks$area) &
    total_area > 0 &
    peaks$area / total_area * 100 >= min_area_percent
  named & scored & !combined & !hetero & big_enough
}
