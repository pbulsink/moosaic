ref_peaks <- function() {
  tbl <- tibble::tibble(
    name = c("good", NA, "lowscore", "chlorinated", "tiny", ""),
    score = c(900, 900, 100, 900, 900, 900),
    area = c(1000, 1000, 1000, 1000, 0.001, 1000)
  )
  for (el in c("F", "Cl", "Br", "I", "B", "P", "Si")) {
    tbl[[el]] <- 0
  }
  tbl$Cl[4] <- 1
  tbl
}

test_that(".reference_peak_ok() requires a name, score, no halogens and enough area", {
  expect_equal(
    .reference_peak_ok(ref_peaks(), min_score = 600, min_area_percent = 0.001),
    c(TRUE, FALSE, FALSE, FALSE, FALSE, FALSE)
  )
})

test_that(".reference_peak_ok() rejects combined peaks when flagged", {
  pk <- ref_peaks()
  pk$combined_peak <- c(TRUE, rep(FALSE, 5))
  expect_false(.reference_peak_ok(pk, min_score = 600)[1])
})
