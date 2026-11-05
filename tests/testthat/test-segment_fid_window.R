doublet <- function() {
  list(rt = seq_len(9) * 0.01, intensity = c(0, 2, 5, 2, 1, 3, 6, 3, 0))
}

test_that(".segment_fid_window() splits a hand doublet at the valley", {
  s <- .segment_fid_window(doublet(), 2)
  expect_equal(s$start, c(1L, 6L))
  expect_equal(s$end, c(5L, 9L))
  expect_equal(s$apex, c(3L, 7L))
  expect_equal(s$segment, 1:2)
})

test_that(".segment_fid_window() returns one segment spanning the window for n = 1", {
  s <- .segment_fid_window(doublet(), 1)
  expect_equal(c(s$start, s$end), c(1L, 9L))
  expect_equal(s$apex, 7L)
})

test_that(".segment_fid_window() keeps the most prominent peaks when n is smaller", {
  s <- .segment_fid_window(doublet(), 1)
  expect_equal(nrow(s), 1L)
  fid <- list(rt = 1:11, intensity = c(0, 5, 0, 9, 0, 1, 0, 6, 0, 0, 0))
  s2 <- .segment_fid_window(fid, 2)
  expect_equal(s2$apex, c(4L, 8L))
})

test_that(".segment_fid_window() splits the widest segment and informs when n exceeds the peaks", {
  fid <- doublet()
  expect_message(
    s <- .segment_fid_window(fid, 3),
    class = "moosaic-message"
  )
  expect_equal(nrow(s), 3L)
  # Segments partition the window with no gaps or overlaps
  expect_equal(s$start[-1], s$end[-3] + 1L)
  expect_equal(c(s$start[1], s$end[3]), c(1L, 9L))
})

test_that(".segment_fid_window() fills missing values and rejects bad input", {
  fid <- doublet()
  fid$intensity[4] <- NA
  expect_equal(nrow(.segment_fid_window(fid, 2)), 2L)
  expect_error(
    .segment_fid_window(1:5, 1),
    class = "moosaic-error-bad_argument"
  )
  expect_error(
    .segment_fid_window(doublet(), 0),
    class = "moosaic-error-bad_argument"
  )
  expect_error(
    .segment_fid_window(doublet(), 10),
    class = "moosaic-error-bad_argument"
  )
})

test_that("segment apexes match the truth for a synthetic doublet", {
  s <- .segment_fid_window(make_lowrank(2)$fid, 2)
  expect_equal(s$apex, c(12L, 20L))
})
