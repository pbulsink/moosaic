#' Merge peaks into deconvolution windows
#'
#' @param peaks Tibble from [detect_peaks()].
#' @param padding Numeric; minutes added to each side of every peak.
#' @param gap Numeric; padded intervals separated by no more than this many
#'   minutes are merged.
#' @param max_width Positive maximum core width in minutes; `Inf` disables it.
#' @param max_peaks Positive whole-number target for apexes per core; coincident
#'   apexes stay together. `Inf` disables this limit.
#' @param call Call environment for errors.
#'
#' @return A tibble with `window_id`, `start_rt`, `end_rt`, `n_peaks` and
#'   `peak_ids` (list column). Zero rows when `peaks` has none.
#'   With localization enabled, also includes `core_start_rt`, `core_end_rt`
#'   and `core_last` (whether the right endpoint is owned).
#'
#' @details Merged regions are partitioned between apexes, then by width.
#'   Cores do not overlap; fitting intervals extend by `padding` on either side
#'   inside the original region. Peak membership uses apex ownership, not tails.
#'
#' @keywords internal
.merge_overlapping_peaks <- function(
  peaks,
  padding,
  gap,
  max_width = Inf,
  max_peaks = Inf,
  call = rlang::caller_env()
) {
  for (name in c("max_width", "max_peaks")) {
    value <- get(name)
    if (
      !is.numeric(value) ||
        length(value) != 1L ||
        is.na(value) ||
        value <= 0 ||
        (name == "max_peaks" && is.finite(value) && value != round(value))
    ) {
      .moosaic_abort(
        paste0(
          "{.fn .merge_overlapping_peaks}: {.arg {name}} must be positive",
          "{if (name == 'max_peaks') ' and a whole number'}, or Inf."
        ),
        class = "bad_argument",
        call = call
      )
    }
  }
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
  windows <- tibble::tibble(
    window_id = unique(grp),
    start_rt = as.numeric(tapply(s, grp, min)),
    end_rt = as.numeric(tapply(e, grp, max)),
    n_peaks = as.integer(tabulate(grp)),
    peak_ids = unname(split(peaks$peak_id, grp))
  )
  if (is.infinite(max_width) && is.infinite(max_peaks)) {
    return(windows)
  }
  localized <- lapply(seq_len(nrow(windows)), function(i) {
    pk <- peaks[grp == i, ]
    pk <- pk[order(pk$apex_rt), ]
    apexes <- unique(pk$apex_rt)
    counts <- tabulate(match(pk$apex_rt, apexes), nbins = length(apexes))
    cuts <- numeric()
    count <- counts[1]
    for (j in seq_len(max(0L, length(apexes) - 1L))) {
      if (count + counts[j + 1L] > max_peaks) {
        cuts <- c(cuts, mean(apexes[c(j, j + 1L)]))
        count <- 0L
      }
      count <- count + counts[j + 1L]
    }
    bounds <- c(windows$start_rt[i], cuts, windows$end_rt[i])
    bounds <- sort(unique(unlist(lapply(
      seq_len(length(bounds) - 1L),
      function(j) {
        n <- if (is.infinite(max_width)) {
          1L
        } else {
          max(1L, ceiling(diff(bounds[c(j, j + 1L)]) / max_width))
        }
        seq(bounds[j], bounds[j + 1L], length.out = n + 1L)
      }
    ))))
    start <- utils::head(bounds, -1L)
    end <- utils::tail(bounds, -1L)
    ids <- lapply(seq_along(start), function(j) {
      inside <- pk$apex_rt >= start[j] &
        (pk$apex_rt < end[j] | (j == length(start) & pk$apex_rt <= end[j]))
      pk$peak_id[inside]
    })
    tibble::tibble(
      window_id = seq_along(start),
      start_rt = pmax(windows$start_rt[i], start - padding),
      end_rt = pmin(windows$end_rt[i], end + padding),
      n_peaks = lengths(ids),
      peak_ids = ids,
      core_start_rt = start,
      core_end_rt = end,
      core_last = seq_along(start) == length(start)
    )
  })
  out <- do.call(rbind, localized)
  out$window_id <- seq_len(nrow(out))
  out
}
