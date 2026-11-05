#' Estimate formulas for unidentified peaks
#'
#' @param peaks Peak table (see `.build_peak_table()`) ordered by retention
#'   time, with `identified`, `name`, `formula`, `mw`, `rt`, `ri` and the
#'   tracked element columns.
#'
#' @return `peaks` with `origin` (`"library"`, `"interpolated"`,
#'   `"extrapolated"` or `NA`) and, for unidentified peaks, estimated `C`,
#'   `H`, `O`, `formula`, `mw` and a placeholder `name`.
#'
#' @details Peaks between two identified peaks take the rounded linear
#'   interpolation of C, H and O by position. Peaks after the last identified
#'   peak get a carbon count from a linear fit of C against RI (against rt
#'   where RI is missing) over the identified peaks, with the alkane hydrogen
#'   count and no oxygen; peaks before the first copy its composition. Other
#'   elements are set to zero. With nothing identified, a warning of class
#'   `moosaic-warning-no_identified` is raised and no estimates are made.
#'
#' @keywords internal
.interpolate_unknowns <- function(peaks) {
  peaks$origin <- ifelse(peaks$identified, "library", NA_character_)
  known <- which(peaks$identified)
  if (length(known) == 0L) {
    .moosaic_warn(
      "No identified components; nothing to interpolate from.",
      class = "no_identified"
    )
    return(peaks)
  }
  for (k in seq_len(length(known) - 1L)) {
    lo <- known[k]
    hi <- known[k + 1L]
    gap <- seq_len(hi - lo - 1L) + lo
    if (!length(gap)) {
      next
    }
    frac <- (gap - lo) / (hi - lo)
    for (el in c("C", "H", "O")) {
      peaks[[el]][gap] <- round(
        peaks[[el]][lo] + frac * (peaks[[el]][hi] - peaks[[el]][lo])
      )
    }
    peaks$origin[gap] <- "interpolated"
  }
  tail_idx <- seq_len(nrow(peaks))[-seq_len(max(known))]
  if (length(tail_idx)) {
    c_hat <- rep(NA_real_, length(tail_idx))
    for (x in c("ri", "rt")) {
      xk <- peaks[[x]][known]
      yk <- peaks$C[known]
      ok <- !is.na(xk) & !is.na(yk)
      if (sum(ok) >= 2L && stats::var(xk[ok]) > 0) {
        slope <- stats::cov(xk[ok], yk[ok]) / stats::var(xk[ok])
        pred <- mean(yk[ok]) + slope * (peaks[[x]][tail_idx] - mean(xk[ok]))
        c_hat[is.na(c_hat)] <- pred[is.na(c_hat)]
      }
    }
    c_hat[is.na(c_hat)] <- peaks$C[max(known)]
    c_hat <- pmax(1, round(c_hat))
    peaks$C[tail_idx] <- c_hat
    peaks$H[tail_idx] <- 2 * c_hat + 2
    peaks$O[tail_idx] <- 0
    peaks$origin[tail_idx] <- "extrapolated"
  }
  first <- min(known)
  if (first > 1L) {
    head_idx <- seq_len(first - 1L)
    for (el in c("C", "H", "O")) {
      peaks[[el]][head_idx] <- peaks[[el]][first]
    }
    peaks$origin[head_idx] <- "extrapolated"
  }
  filled <- !peaks$identified
  for (el in setdiff(.tracked_elements, c("C", "H", "O"))) {
    peaks[[el]][filled] <- 0
  }
  peaks$formula[filled] <- .build_formula(
    peaks$C[filled],
    peaks$H[filled],
    peaks$O[filled]
  )
  peaks$name[filled] <- ifelse(
    peaks$origin[filled] == "interpolated",
    "Unknown, Interpolated",
    "Unknown, Extrapolated"
  )
  peaks$mw[filled] <- .molecular_weight(lapply(
    peaks$formula[filled],
    .parse_formula
  ))
  peaks
}
