mk <- function(s, e) {
  tibble::tibble(
    peak_id = seq_along(s),
    apex_rt = (s + e) / 2,
    start_rt = s,
    end_rt = e,
    height = rep(1, length(s)),
    shoulder = rep(FALSE, length(s))
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
