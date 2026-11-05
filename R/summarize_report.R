#' Summarise a quantified result for reporting
#'
#' @param quantified A `moosaic_result` after [quantify()].
#' @param include_solvents Include solvent peaks in the family and element
#'   totals.
#'
#' @return `quantified` with a `summary` list:
#'   * `families`: tibble(`compound_type`, `wt_pct`) over the eight families;
#'   * `elements`: tibble(`element`, `wt_pct`) for C, H, N, O, S, normalised to
#'     100 (zeros when nothing was quantified);
#'   * `totals`: list(`gc_recovery`, `methanol`, `water`, `total`,
#'     `element_sum`);
#'   * `qc`: list(`aligned_peaks` (library-identified), `unique_peaks`
#'     (estimated), `total_peaks`, `interpolated_peaks`, `ms_fid_offset` (min,
#'     `NA` if unknown));
#'   * `info`, `include_solvents`.
#'
#' @details GC recovery sums `wt_pct` over peaks other than solvents and the
#'   names from `.recovery_excluded()` (methanol too when the sample has added
#'   methanol, which is reported separately).
#'
#' @examples
#' \dontrun{
#' summarize_report(quantify(identified, sample_info("S1")))
#' }
#'
#' @export
summarize_report <- function(quantified, include_solvents = FALSE) {
  .require_quantified(quantified)
  peaks <- quantified$peaks
  info <- quantified$quant$info
  used <- if (include_solvents) rep(TRUE, nrow(peaks)) else !peaks$solvent
  key <- \(x) gsub("[^a-z0-9]", "", tolower(ifelse(is.na(x), "", x)))
  in_recovery <- used &
    !key(peaks$name) %in% key(.recovery_excluded(info$methanol_wt_pct > 0))
  levels <- c(
    "Oxygenate",
    "Paraffin",
    "Isoparaffin",
    "Naphthene",
    "Aromatic",
    "Unsaturate",
    "Unknown Heteroatomic",
    "Unknown Hydrocarbon"
  )
  families <- tibble::tibble(
    compound_type = levels,
    wt_pct = vapply(
      levels,
      \(f) sum(peaks$wt_pct[used & peaks$family == f], na.rm = TRUE),
      numeric(1),
      USE.NAMES = FALSE
    )
  )
  gc_recovery <- sum(peaks$wt_pct[in_recovery], na.rm = TRUE)
  syms <- c("C", "H", "N", "O", "S")
  elements <- tibble::tibble(
    element = c("Carbon", "Hydrogen", "Nitrogen", "Oxygen", "Sulfur"),
    wt_pct = vapply(
      syms,
      \(s) {
        frac <- peaks[[s]] * atomic_weights$mass[atomic_weights$symbol == s] / peaks$mw
        sum(peaks$wt_pct[used] * frac[used], na.rm = TRUE)
      },
      numeric(1),
      USE.NAMES = FALSE
    )
  )
  if (sum(elements$wt_pct) > 0) {
    elements$wt_pct <- elements$wt_pct / sum(elements$wt_pct) * 100
  }
  quantified$summary <- list(
    families = families,
    elements = elements,
    totals = list(
      gc_recovery = gc_recovery,
      methanol = info$methanol_wt_pct,
      water = info$water_wt_pct,
      total = gc_recovery + info$methanol_wt_pct + info$water_wt_pct,
      element_sum = sum(elements$wt_pct)
    ),
    qc = list(
      aligned_peaks = sum(peaks$origin == "library", na.rm = TRUE),
      unique_peaks = sum(peaks$origin != "library", na.rm = TRUE),
      total_peaks = nrow(peaks),
      interpolated_peaks = sum(peaks$origin %in% c("interpolated", "extrapolated")),
      ms_fid_offset = quantified$alignment$delay %||% NA_real_
    ),
    info = info,
    include_solvents = include_solvents
  )
  quantified
}
