test_that(".score_candidates() computes final = mf - ri_penalty - element_penalty", {
  cand <- tibble::tibble(
    component_id = "c1",
    mf = 900,
    ri_penalty = 20,
    element_penalty = 50
  )
  expect_equal(.score_candidates(cand)$final, 830)
})

test_that(".score_candidates() re-ranks a high-MF candidate with a large RI miss below an in-window one", {
  cand <- tibble::tibble(
    component_id = c("c1", "c1", "c2"),
    name = c("far", "near", "other"),
    mf = c(950, 800, 700),
    ri_penalty = c(250, 0, 0),
    element_penalty = c(0, 0, 0)
  )
  out <- .score_candidates(cand)
  expect_equal(out$name, c("near", "far", "other"))
  expect_equal(out$final_rank, c(1L, 2L, 1L))
})

test_that(".score_candidates() treats missing penalties as zero and handles Inf and zero rows", {
  cand <- tibble::tibble(
    component_id = c("c1", "c1"),
    mf = c(800, 900),
    ri_penalty = c(NA, 0),
    element_penalty = c(0, Inf)
  )
  out <- .score_candidates(cand)
  expect_equal(out$final, c(800, -Inf))
  expect_equal(nrow(.score_candidates(cand[0, ])), 0L)
})
