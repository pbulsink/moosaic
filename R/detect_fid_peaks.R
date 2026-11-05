#' Detect peaks in an FID trace
#'
#' @param fid List with numeric `rt` and `intensity` (e.g. `exp$fid`).
#' @param min_snr Numeric; minimum apex height as a multiple of the noise.
#'   `NULL` uses the `moosaic.peak_min_height_snr` option.
#'
#' @return A tibble with columns `peak_id`, `apex_rt`, `start_rt`, `end_rt`,
#'   `height` (above the estimated baseline) and `shoulder` (logical; the
#'   second derivative shows an unresolved extra component inside the peak;
#'   heuristic, and conservative for noisy or narrow peaks).
#'   Zero rows when nothing is detected.
#'
#' @details Detection runs on a smoothed, baseline-corrected copy; the input
#'   is never modified. Maxima that do not rise at least half the SNR
#'   threshold above their neighbouring valley are discarded as noise.
#'
#' @examples
#' rt <- seq(0, 2, length.out = 2000)
#' fid <- list(rt = rt, intensity = 100 * exp(-0.5 * ((rt - 1) / 0.03)^2))
#' detect_fid_peaks(fid)
#'
#' @export
detect_fid_peaks <- function(fid, min_snr = NULL) {
  min_snr <- min_snr %||% .get_moosaic_option("peak_min_height_snr")
  if (!is.numeric(min_snr) || length(min_snr) != 1L || !(min_snr > 0)) {
    .moosaic_abort(
      "{.arg min_snr} must be a single positive number.",
      class = "bad_argument",
      call = rlang::current_env()
    )
  }
  pre <- .preprocess_fid_for_detection(fid)
  y <- pre$intensity
  rt <- pre$rt
  noise <- max(pre$noise, 1e-6 * max(abs(y), 1e-12))
  thr <- min_snr * noise

  cand <- .find_local_maxima(y, thr)
  # Tallest first; a candidate inside an accepted peak is a noise bump on it
  cand <- cand[order(y[cand], decreasing = TRUE)]
  peaks <- list()
  for (a in cand) {
    inside <- any(vapply(peaks, \(p) a >= p$start && a <= p$end, logical(1)))
    if (!inside) {
      b <- .find_peak_bounds(y, a, floor = noise, tol = 3 * noise)
      peaks[[length(peaks) + 1L]] <- list(
        apex = a,
        start = b[["start"]],
        end = b[["end"]]
      )
    }
  }
  peaks <- peaks[order(vapply(peaks, \(p) p$apex, numeric(1)))]
  prom <- vapply(
    peaks,
    \(p) y[p$apex] - max(y[p$start], y[p$end]),
    numeric(1)
  )
  peaks <- peaks[prom >= thr / 2]

  if (length(peaks) == 0L) {
    return(tibble::tibble(
      peak_id = integer(),
      apex_rt = numeric(),
      start_rt = numeric(),
      end_rt = numeric(),
      height = numeric(),
      shoulder = logical()
    ))
  }

  shoulder <- vapply(
    peaks,
    \(p) .has_shoulder(y, rt, p$apex, p$start, p$end),
    logical(1)
  )

  tibble::tibble(
    peak_id = seq_along(peaks),
    apex_rt = vapply(peaks, \(p) rt[p$apex], numeric(1)),
    start_rt = vapply(peaks, \(p) rt[p$start], numeric(1)),
    end_rt = vapply(peaks, \(p) rt[p$end], numeric(1)),
    height = vapply(peaks, \(p) y[p$apex], numeric(1)),
    shoulder = shoulder
  )
}
