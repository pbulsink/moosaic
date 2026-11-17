#' Detect peaks in a chromatographic trace
#'
#' Finds resolved peaks (local maxima) and, optionally, unresolved shoulders
#' (second-derivative minima) in an FID trace or a TIC.
#'
#' @param trace List with numeric `rt` and `intensity` (e.g. `exp$fid`).
#' @param min_snr Numeric; minimum apex height as a multiple of the noise.
#'   `NULL` uses the `moosaic.peak_min_height_snr` option.
#' @param smooth_window Odd integer; Savitzky-Golay smoothing window in points
#'   for the detection copy. `NULL` uses the `moosaic.fid_smooth_window`
#'   option, which is tuned for the FID sampling rate.
#' @param include_shoulders Logical; if `TRUE`, each shoulder is returned as
#'   its own row.
#'
#' @return A tibble, sorted by `apex_rt`, with columns:
#'   * `peak_id`: integer, 1..n in retention order.
#'   * `apex_rt`, `start_rt`, `end_rt`: apex and bounds (min).
#'   * `height`: smoothed signal at the apex, above the estimated baseline.
#'   * `has_shoulder`: logical; the resolved peak contains at least one
#'     unresolved shoulder. Always `FALSE` on shoulder rows.
#'   * `is_shoulder`: logical; the row is a shoulder (apex at a
#'     second-derivative minimum) rather than a resolved maximum.
#'   * `parent_id`: integer; for shoulder rows the `peak_id` of the resolved
#'     peak containing it, otherwise `NA`.
#'
#'   Zero rows when nothing is detected.
#'
#' @details Detection runs on a smoothed, baseline-corrected copy; the input
#'   is never modified. Maxima that do not rise at least half the SNR
#'   threshold above their neighbouring valley are discarded as noise.
#'
#'   Shoulders are heuristic and conservative for noisy or narrow peaks. When
#'   shoulders are returned, the parent peak's span is split between the apex
#'   and its shoulders at the midpoints between neighbouring apexes, so rows
#'   do not overlap and their union equals the parent's original span.
#'
#' @examples
#' rt <- seq(0, 2, length.out = 2000)
#' trace <- list(rt = rt, intensity = 100 * exp(-0.5 * ((rt - 1) / 0.03)^2))
#' detect_peaks(trace)
#'
#' @export
detect_peaks <- function(
  trace,
  min_snr = NULL,
  smooth_window = NULL,
  include_shoulders = TRUE
) {
  call <- rlang::current_env()
  min_snr <- min_snr %||% .get_moosaic_option("peak_min_height_snr")
  if (!is.numeric(min_snr) || length(min_snr) != 1L || !(min_snr > 0)) {
    .moosaic_abort(
      "{.fn detect_peaks}: {.arg min_snr} must be a single positive number.",
      class = "bad_argument",
      call = call
    )
  }
  if (!rlang::is_bool(include_shoulders)) {
    .moosaic_abort(
      "{.fn detect_peaks}: {.arg include_shoulders} must be TRUE or FALSE.",
      class = "bad_argument",
      call = call
    )
  }
  pre <- .preprocess_for_detection(trace, smooth_window)
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
      has_shoulder = logical(),
      is_shoulder = logical(),
      parent_id = integer()
    ))
  }

  rows <- lapply(seq_along(peaks), \(k) {
    p <- peaks[[k]]
    sh <- .peak_shoulders(
      y,
      rt,
      p$apex,
      p$start,
      p$end,
      noise = noise,
      min_height = thr
    )
    parent <- data.frame(
      apex = p$apex,
      start = p$start,
      end = p$end,
      has_shoulder = length(sh) > 0L,
      is_shoulder = FALSE,
      parent = k
    )
    if (!include_shoulders || length(sh) == 0L) {
      return(parent)
    }
    apexes <- sort(c(p$apex, sh))
    cuts <- floor((apexes[-1] + apexes[-length(apexes)]) / 2)
    is_sh <- apexes != p$apex
    data.frame(
      apex = apexes,
      start = c(p$start, cuts + 1L),
      end = c(cuts, p$end),
      has_shoulder = !is_sh,
      is_shoulder = is_sh,
      parent = k
    )
  })
  rows <- do.call(rbind, rows)
  ids <- seq_len(nrow(rows))
  parent_row <- ids[!rows$is_shoulder][rows$parent]

  tibble::tibble(
    peak_id = ids,
    apex_rt = rt[rows$apex],
    start_rt = rt[rows$start],
    end_rt = rt[rows$end],
    height = y[rows$apex],
    has_shoulder = rows$has_shoulder,
    is_shoulder = rows$is_shoulder,
    parent_id = ifelse(rows$is_shoulder, parent_row, NA_integer_)
  )
}
