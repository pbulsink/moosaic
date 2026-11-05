#' Merge peaks into deconvolution windows
#'
#' @param peaks Tibble from [detect_fid_peaks()].
#' @param padding Numeric; minutes added to each side of every peak.
#' @param gap Numeric; padded intervals separated by no more than this many
#'   minutes are merged.
#'
#' @return A tibble with `window_id`, `start_rt`, `end_rt`, `n_peaks` and
#'   `peak_ids` (list column). Zero rows when `peaks` has none.
#'
#' @keywords internal
.merge_overlapping_peaks <- function(peaks, padding, gap) {
  if (nrow(peaks) == 0L) {
    return(tibble::tibble(
      window_id = integer(),
      start_rt = numeric(),
      end_rt = numeric(),
      n_peaks = integer(),
      peak_ids = list()
    ))
  }
  peaks <- peaks[order(peaks$start_rt), ]
  s <- peaks$start_rt - padding
  e <- peaks$end_rt + padding
  # A new window starts when the gap to the running maximum end exceeds `gap`
  new_win <- c(TRUE, s[-1] > cummax(e)[-length(e)] + gap)
  grp <- cumsum(new_win)
  tibble::tibble(
    window_id = unique(grp),
    start_rt = as.numeric(tapply(s, grp, min)),
    end_rt = as.numeric(tapply(e, grp, max)),
    n_peaks = as.integer(tabulate(grp)),
    peak_ids = unname(split(peaks$peak_id, grp))
  )
}
