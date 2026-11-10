#' Estimate detector delay with GCalignR
#'
#' @param fid_peaks,tic_peaks Peak tibbles from [detect_fid_peaks()] for the
#'   FID and the TIC.
#' @param max_delay Numeric; largest linear shift to consider (min).
#' @param step Numeric; shift search step (min).
#' @param call Call environment for errors.
#'
#' @return Numeric; the delay (min) of the MS relative to the FID, positive
#'   when MS retention times are later. The FID is the alignment reference.
#'
#' @details Aborts with class `too_few_peaks` when either trace has fewer than
#'   two peaks. GCalignR console output is suppressed.
#'
#' @keywords internal
.estimate_delay_gcalignr <- function(
  fid_peaks,
  tic_peaks,
  max_delay,
  step,
  call = rlang::caller_env()
) {
  if (!requireNamespace("GCalignR", quietly = TRUE)) {
    .moosaic_abort(
      "GCalignR package is not installed; the gcalignr engine is not available.",
      class = "missing_package",
      call = call
    )
  }

  if (nrow(fid_peaks) < 2L || nrow(tic_peaks) < 2L) {
    .moosaic_abort(
      "GCalignR needs at least two peaks in both the FID and the TIC (found {nrow(fid_peaks)} and {nrow(tic_peaks)}).",
      class = "too_few_peaks",
      call = call
    )
  }
  peaks <- .peaks_to_gcalignr(fid_peaks, tic_peaks)
  # Sink to the null device: capture.output() grows a text connection on every
  # progress-bar update, which dominated runtime in profiling.
  sink(nullfile())
  on.exit(sink(), add = TRUE)
  res <- suppressMessages(
    GCalignR::align_chromatograms(
      peaks,
      rt_col_name = "RT",
      reference = "fid",
      max_linear_shift = max_delay,
      step_size = step
    )
  )
  shifts <- res$Logfile$LinearShift
  # GCalignR reports the shift applied to the sample to match the reference
  -shifts$shift[shifts$sample == "tic"]
}
