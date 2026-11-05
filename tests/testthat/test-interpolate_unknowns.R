test_that(".interpolate_unknowns() interpolates between neighbouring identified peaks", {
  pk <- mk_peaks(
    c(TRUE, FALSE, TRUE),
    C = c(6, NA, 10),
    H = c(14, NA, 22),
    O = c(0, NA, 0)
  )
  out <- .interpolate_unknowns(pk)
  expect_equal(out$C[2], 8)
  expect_equal(out$H[2], 18)
  expect_equal(out$O[2], 0)
  expect_equal(out$origin, c("library", "interpolated", "library"))
  expect_equal(out$name[2], "Unknown, Interpolated")
  expect_equal(out$formula[2], "C8H18")
  expect_equal(out$mw[2], 8 * 12.011 + 18 * 1.008)
  expect_equal(out$N[2], 0)
})

test_that(".interpolate_unknowns() extrapolates later peaks along RI", {
  pk <- mk_peaks(
    c(TRUE, TRUE, FALSE, FALSE),
    C = c(7, 8, NA, NA),
    H = c(16, 18, NA, NA),
    O = c(0, 0, NA, NA),
    ri = c(700, 800, 900, 1000)
  )
  out <- .interpolate_unknowns(pk)
  expect_equal(out$C[3:4], c(9, 10))
  expect_equal(out$H[3:4], c(20, 22))
  expect_equal(out$O[3:4], c(0, 0))
  expect_equal(out$origin[3:4], rep("extrapolated", 2))
  expect_equal(out$name[3], "Unknown, Extrapolated")
})

test_that(".interpolate_unknowns() extrapolates along rt when RI is missing", {
  pk <- mk_peaks(
    c(TRUE, TRUE, FALSE),
    C = c(7, 8, NA),
    H = c(16, 18, NA),
    O = c(0, 0, NA),
    ri = c(700, 800, NA)
  )
  expect_equal(.interpolate_unknowns(pk)$C[3], 9)
})

test_that(".interpolate_unknowns() repeats a lone identified peak's carbon count", {
  pk <- mk_peaks(c(TRUE, FALSE), C = c(7, NA), H = c(16, NA), O = c(0, NA))
  expect_equal(.interpolate_unknowns(pk)$C[2], 7)
})

test_that(".interpolate_unknowns() copies the first identified peak to earlier unknowns", {
  pk <- mk_peaks(
    c(FALSE, TRUE, TRUE),
    C = c(NA, 6, 7),
    H = c(NA, 14, 16),
    O = c(NA, 0, 0)
  )
  out <- .interpolate_unknowns(pk)
  expect_equal(c(out$C[1], out$H[1], out$O[1]), c(6, 14, 0))
  expect_equal(out$origin[1], "extrapolated")
})

test_that(".interpolate_unknowns() warns and returns the table when nothing is identified", {
  pk <- mk_peaks(c(FALSE, FALSE), C = c(NA, NA), H = c(NA, NA), O = c(NA, NA))
  expect_warning(
    out <- .interpolate_unknowns(pk),
    class = "moosaic-warning-no_identified"
  )
  expect_equal(out$origin, c(NA_character_, NA))
  expect_true(all(is.na(out$C)))
})
