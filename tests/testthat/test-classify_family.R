fam_peaks <- function(name, C, H, O = 0, N = 0) {
  tbl <- tibble::tibble(name = name, C = C, H = H, O = O, N = N)
  for (el in c("F", "Cl", "Br", "I", "P", "S", "B", "Si")) {
    tbl[[el]] <- 0
  }
  tbl
}

test_that(".classify_family() assigns families from name terms and formula", {
  pk <- fam_peaks(
    name = c(
      "Toluene",
      "Cyclohexane",
      "Phenol",
      "Octane",
      "Heptane, 2-methyl-",
      "1-Octene",
      "Trimethylamine",
      "Pyridine",
      "Xylene-like",
      "Benzoid"
    ),
    C = c(7, 6, 6, 8, 8, 8, 3, 5, 8, 10),
    H = c(8, 12, 6, 18, 18, 16, 9, 5, 10, 8),
    O = c(0, 0, 1, 0, 0, 0, 0, 0, 0, 0),
    N = c(0, 0, 0, 0, 0, 0, 1, 1, 0, 0)
  )
  expect_equal(
    .classify_family(pk),
    c(
      "Aromatic",
      "Naphthene",
      "Oxygenate",
      "Paraffin",
      "Isoparaffin",
      "Unsaturate",
      "Unknown Heteroatomic",
      "Aromatic",
      "Aromatic",
      "Aromatic"
    )
  )
})

test_that(".classify_family() labels unclassifiable peaks as unknown hydrocarbons", {
  pk <- fam_peaks(name = c(NA, "Unknown"), C = c(NA, NA), H = c(NA, NA))
  expect_equal(.classify_family(pk), rep("Unknown Hydrocarbon", 2))
})

test_that(".classify_family() does not read the comma in placeholder names as branching", {
  pk <- fam_peaks(name = "Unknown, Interpolated", C = 8, H = 18)
  expect_equal(.classify_family(pk), "Paraffin")
})
