targets <- tibble::tibble(
  target = c("n-heptane", "phenol"),
  synonyms = c("heptane", NA)
)

test_that(".match_targets() matches targets and synonyms ignoring case and punctuation", {
  out <- .match_targets(c("N-Heptane", "HEPTANE", "Phenol", "toluene"), targets)
  expect_equal(out, c("n-heptane", "n-heptane", "phenol", NA))
})

test_that(".match_targets() returns NA for missing names", {
  expect_equal(.match_targets(c(NA, ""), targets), c(NA_character_, NA))
})
