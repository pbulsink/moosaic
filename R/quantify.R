#' Quantify identified components (Polyarc)
#'
#' Converts raw FID component areas to amounts using the Polyarc response
#' model
#' \deqn{m_i = m_t \frac{F_i}{F_t} \frac{C_t}{C_i} \frac{M_i}{M_t}}
#' where `F` is the FID area, `C` the carbon count and `M` the molar mass.
#'
#' @param result A `moosaic_result` after [identify_components()].
#' @param info Sample metadata from `sample_info()`.
#' @param style `"internal"` (relative to a reference peak), or an external
#'   calibration curve: `"slope"`, `"slope_intercept"` or `"quadratic"`.
#'   `NULL` uses option `moosaic.quant_style`.
#' @param reference_peak Component id of the reference peak for
#'   `style = "internal"`; `NULL` picks the largest well-identified peak.
#'   Ignored for external styles.
#'
#' @return `result` with a `peaks` tibble (one row per analyte component by
#'   retention time: the peak table columns plus `origin`, `family`,
#'   `solvent`, `amount_ug_ml`, `wt_pct`, `quant_basis` and
#'   `calibration_target`) and a `quant` list (`style`, `reference_peak`,
#'   `info`).
#'
#' @details Only the raw (unsmoothed) FID component areas are used. Peaks
#'   without an identification receive an estimated formula by interpolation
#'   along the run (see `.interpolate_unknowns()`), so every peak is quantified.
#'   With `"internal"`, amounts are normalised to total `1e6 * density`
#'   ug/mL (100 wt%); the reference peak is marked `"Target"`. With an external
#'   curve, calibration targets found in the sample (matched by name) are read
#'   off their curve, scaled by the dilution, and all other peaks are scaled
#'   from the nearest preceding target of the same type (hydrocarbon or
#'   oxygenate). Calibration points with a zero response are treated as below
#'   detection. Overlapping components share the raw FID area according to the
#'   fitted profiles (see `.apportion_fid_area()`).
#'
#' @examples
#' \dontrun{
#' res <- identify_components(deconvolve_run(exp))
#' quantify(res, sample_info("S1", density = 0.85))$peaks
#' }
#'
#' @export
quantify <- function(result, info, style = NULL, reference_peak = NULL) {
  call <- rlang::current_env()
  if (!inherits(result, "moosaic_result")) {
    .moosaic_abort(
      "{.arg result} must be a {.cls moosaic_result}.",
      class = "bad_argument",
      call = call
    )
  }
  if (!inherits(info, "moosaic_sample")) {
    .moosaic_abort(
      "{.arg info} must come from {.fn sample_info}.",
      class = "bad_argument",
      call = call
    )
  }
  style <- rlang::arg_match0(
    style %||% .get_moosaic_option("quant_style"),
    c("internal", "slope", "slope_intercept", "quadratic"),
    arg_nm = "style",
    error_call = call
  )
  if (is.null(result$identifications)) {
    .moosaic_abort(
      "{.arg result} has not been identified; run {.fn identify_components} first.",
      class = "not_identified",
      call = call
    )
  }
  peaks <- .build_peak_table(result)
  if (nrow(peaks) == 0L) {
    .moosaic_abort(
      "{.arg result} has no analyte components to quantify.",
      class = "no_components",
      call = call
    )
  }
  peaks <- .interpolate_unknowns(peaks)

  ref_id <- NA_character_
  if (style == "internal") {
    if (is.null(reference_peak)) {
      ref <- .suggest_reference_peak(peaks)$peak_index
      if (is.na(ref)) {
        .moosaic_abort(
          "No component qualifies as an internal reference peak; supply {.arg reference_peak}.",
          class = "no_reference_peak",
          call = call
        )
      }
    } else {
      ref <- if (is.character(reference_peak) && length(reference_peak) == 1L) {
        match(reference_peak, peaks$component_id)
      } else {
        NA_integer_
      }
      usable <- !is.na(ref) &&
        isTRUE(peaks$area[ref] > 0) &&
        isTRUE(peaks$C[ref] > 0) &&
        isTRUE(is.finite(peaks$mw[ref]))
      if (!usable) {
        .moosaic_abort(
          "{.arg reference_peak} must be the id of an analyte component with a positive area, carbon count and molar mass.",
          class = "bad_argument",
          call = call
        )
      }
    }
    ref_id <- peaks$component_id[ref]
    rel <- .polyarc_mass(
      peaks$area,
      peaks$C,
      peaks$mw,
      peaks$area[ref],
      peaks$C[ref],
      peaks$mw[ref]
    )
    peaks$amount_ug_ml <- rel / sum(rel, na.rm = TRUE) * 1e6 * info$density
    peaks$quant_basis <- ifelse(
      seq_len(nrow(peaks)) == ref,
      "Target",
      "Relative"
    )
    peaks$calibration_target <- NA_character_
  } else {
    curves <- .fit_calibration(calibration_points, style)
    matched <- .match_targets(peaks$name, calibration_targets)
    if (all(is.na(matched))) {
      .moosaic_abort(
        "No calibration targets were identified; use {.code style = \"internal\"} instead.",
        class = "no_calibration_targets",
        call = call
      )
    }
    is_target <- !is.na(matched)
    amount <- rep(NA_real_, nrow(peaks))
    amount[is_target] <- .apply_curve(
      peaks$area[is_target],
      curves[match(matched[is_target], curves$target), ]
    ) *
      info$dilution
    gov <- .assign_target_rows(peaks, matched, calibration_targets)
    relative <- !is_target & !is.na(gov)
    g <- gov[relative]
    amount[relative] <- .polyarc_mass(
      peaks$area[relative],
      peaks$C[relative],
      peaks$mw[relative],
      peaks$area[g],
      peaks$C[g],
      peaks$mw[g],
      ref_mass = amount[g]
    )
    peaks$amount_ug_ml <- amount
    peaks$quant_basis <- ifelse(is_target, "Target", "Relative")
    peaks$calibration_target <- ifelse(is_target, matched, matched[gov])
  }
  peaks$wt_pct <- peaks$amount_ug_ml / 10000 / info$density
  peaks$family <- .classify_family(peaks)
  peaks$solvent <- .is_solvent(peaks$name)

  result$peaks <- peaks
  result$quant <- list(style = style, reference_peak = ref_id, info = info)
  result
}
