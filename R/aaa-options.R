#' Default moosaic options
#'
#' Single source of all moosaic configuration defaults.
#'
#' @return A named list of defaults (not assigned to `options()`).
#' @keywords internal
#' @examples
#' .moosaic_default_options()
#' @export
.moosaic_default_options <- function() {
  list(
    # Library and search
    moosaic.library_path = NULL,
    moosaic.search_function = "identity",
    moosaic.search_hits = 10L,
    moosaic.search_threads = 1L,
    moosaic.ri_column_type = "semi-standard non-polar",
    moosaic.min_match_factor = 600,
    moosaic.ri_calibration_path = NULL,
    moosaic.ri_extrapolate = FALSE,
    # Matrix building
    moosaic.mz_min = 35,
    moosaic.mz_max = 500,
    moosaic.mz_bin = 1,
    # Alignment
    moosaic.align_engine = "gcalignr",
    moosaic.max_delay = 0.2,
    moosaic.align_step = 0.001,
    # FID processing
    moosaic.fid_smooth_window = 7L,
    moosaic.fid_baseline_method = "rolling_min",
    moosaic.peak_min_height_snr = 5,
    # Windows
    moosaic.window_padding = 0.02,
    moosaic.window_merge_gap = 0.01,
    moosaic.min_scans_per_window = 8L,
    # Rank estimation
    moosaic.rank_methods = c("fid", "svd", "bic", "pa"),
    moosaic.rank_max = 6L,
    moosaic.svd_var_threshold = 0.99,
    moosaic.pa_iterations = 50L,
    # ALS
    moosaic.background_component = TRUE,
    moosaic.als_maxiter = 100L,
    moosaic.als_thresh = 0.001,
    moosaic.als_unimodal = TRUE,
    # RI and element penalties
    moosaic.ri_grace = 10,
    moosaic.ri_penalty_per_unit = 1,
    moosaic.element_penalties = c(
      N = 50,
      S = 50,
      Cl = 100,
      Br = 100,
      Si = 25,
      P = 100
    ),
    moosaic.allowed_elements = c("C", "H", "O", "N", "S"),
    # Quantification
    moosaic.quant_style = "internal"
  )
}
