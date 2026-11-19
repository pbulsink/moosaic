mk <- function(s, e) {
  tibble::tibble(
    peak_id = seq_along(s),
    apex_rt = (s + e) / 2,
    start_rt = s,
    end_rt = e,
    height = rep(1, length(s)),
    has_shoulder = rep(FALSE, length(s))
  )
}

test_that(".merge_overlapping_peaks() merges overlapping peaks and keeps distant ones apart", {
  w <- .merge_overlapping_peaks(
    mk(c(5.10, 5.32, 11.4), c(5.35, 5.61, 11.9)),
    0,
    0
  )
  expect_equal(nrow(w), 2L)
  expect_equal(w$start_rt, c(5.10, 11.4))
  expect_equal(w$end_rt, c(5.61, 11.9))
  expect_equal(w$n_peaks, c(2L, 1L))
  expect_equal(w$peak_ids, list(1:2, 3L))
})

test_that(".merge_overlapping_peaks() pads windows and merges across small gaps", {
  pk <- mk(c(1, 1.5), c(1.4, 2))
  expect_equal(nrow(.merge_overlapping_peaks(pk, 0, 0.05)), 2L)
  expect_equal(nrow(.merge_overlapping_peaks(pk, 0, 0.1)), 1L)
  expect_equal(nrow(.merge_overlapping_peaks(pk, 0.06, 0)), 1L)
  expect_equal(.merge_overlapping_peaks(mk(1, 2), 0.1, 0)$start_rt, 0.9)
})

test_that(".merge_overlapping_peaks() handles a peak nested inside another", {
  w <- .merge_overlapping_peaks(mk(c(1, 1.2, 1.9), c(2, 1.4, 2.5)), 0, 0)
  expect_equal(nrow(w), 1L)
})

test_that(".merge_overlapping_peaks() returns a typed zero-row tibble for no peaks", {
  w <- .merge_overlapping_peaks(mk(numeric(), numeric()), 0.02, 0.01)
  expect_equal(nrow(w), 0L)
  expect_named(w, c("window_id", "start_rt", "end_rt", "n_peaks", "peak_ids"))
})

test_that(".merge_overlapping_peaks() localizes a crowded chain without losing peaks", {
  peaks <- mk(seq(1, 2.9, by = 0.1), seq(1.12, 3.02, by = 0.1))
  w <- .merge_overlapping_peaks(
    peaks[20:1, ],
    0.02,
    0.01,
    max_width = 0.5,
    max_peaks = 4L
  )
  expect_gt(nrow(w), 1L)
  expect_lte(max(w$core_end_rt - w$core_start_rt), 0.5 + 1e-10)
  expect_lte(max(w$n_peaks), 4L)
  expect_equal(unlist(w$peak_ids, use.names = FALSE), 1:20)
  expect_equal(w$core_start_rt[-1], head(w$core_end_rt, -1))
  expect_equal(w$start_rt[1], 0.98)
  expect_equal(tail(w$end_rt, 1), 3.04)
  expect_true(all(w$start_rt[-1] < head(w$end_rt, -1)))
})

test_that(".merge_overlapping_peaks() bounds broad peaks and keeps coincident apexes together", {
  w <- .merge_overlapping_peaks(
    mk(c(1, 1), c(3, 3)),
    0,
    0,
    max_width = 0.5,
    max_peaks = 1L
  )
  expect_equal(range(c(w$core_start_rt, w$core_end_rt)), c(1, 3))
  expect_lte(max(w$core_end_rt - w$core_start_rt), 0.5)
  expect_equal(sort(unlist(w$peak_ids)), 1:2)
})

test_that(".merge_overlapping_peaks() validates localization limits", {
  for (value in list(0, -1, NA_real_, NaN, c(1, 2), "wide")) {
    expect_error(
      .merge_overlapping_peaks(mk(1, 2), 0, 0, max_width = value),
      class = "moosaic-error-bad_argument"
    )
    expect_error(
      .merge_overlapping_peaks(mk(1, 2), 0, 0, max_peaks = value),
      class = "moosaic-error-bad_argument"
    )
  }
  expect_error(
    .merge_overlapping_peaks(mk(1, 2), 0, 0, max_peaks = 1.5),
    class = "moosaic-error-bad_argument"
  )
})

test_that(".merge_overlapping_peaks() can localize by peak count alone", {
  w <- .merge_overlapping_peaks(
    mk(c(1, 1.1, 1.2), c(1.2, 1.3, 1.4)),
    0,
    0,
    max_width = Inf,
    max_peaks = 2L
  )
  expect_equal(w$n_peaks, c(2L, 1L))
  expect_equal(w$core_end_rt[1], 1.25)
})
