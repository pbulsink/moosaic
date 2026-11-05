sug_peaks <- function(area, name, score = 900, Cl = 0) {
  tbl <- tibble::tibble(name = name, score = score, area = area)
  for (el in c("F", "Cl", "Br", "I", "B", "P", "Si")) {
    tbl[[el]] <- 0
  }
  tbl$Cl <- Cl
  tbl
}

test_that(".suggest_reference_peak() approves the largest peak when it qualifies", {
  out <- .suggest_reference_peak(sug_peaks(c(10, 90), c("a", "b")))
  expect_equal(out$peak_index, 2L)
  expect_true(out$approved)
  expect_equal(out$name, "b")
  expect_equal(out$area_percent, 90)
  expect_equal(out$n_peaks, 2L)
})

test_that(".suggest_reference_peak() falls back to the largest qualifying peak", {
  out <- .suggest_reference_peak(
    sug_peaks(c(10, 90), c("a", "b"), Cl = c(0, 1))
  )
  expect_equal(out$peak_index, 1L)
  expect_false(out$approved)
})

test_that(".suggest_reference_peak() returns NA when nothing qualifies", {
  out <- .suggest_reference_peak(sug_peaks(c(10, 90), c(NA, NA)))
  expect_true(is.na(out$peak_index))
  expect_true(is.na(out$area_percent))
  expect_true(is.na(out$score))
  expect_true(is.na(out$name))
  expect_false(out$approved)
})
