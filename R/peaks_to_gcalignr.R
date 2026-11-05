#' Convert detected peaks to GCalignR input
#'
#' @param fid_peaks,tic_peaks Tibbles from [detect_fid_peaks()] (applied to
#'   the FID and the TIC respectively).
#'
#' @return A named list of two data frames, `fid` and `tic`, each with numeric
#'   columns `RT` (apex time, min) and `area`. `area` holds the peak height,
#'   which is sufficient for the retention-time shift estimate.
#'
#' @keywords internal
.peaks_to_gcalignr <- function(fid_peaks, tic_peaks) {
  conv <- \(p) {
    data.frame(RT = as.numeric(p$apex_rt), area = as.numeric(p$height))
  }
  list(fid = conv(fid_peaks), tic = conv(tic_peaks))
}
