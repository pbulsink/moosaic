#' Chemical family of each peak
#'
#' @param peaks Tibble with `name`, `C`, `H`, `O`, `N`, `F`, `Cl`, `Br`, `I`,
#'   `P`, `S`, `B` and `Si` columns.
#' @param terms Tibble with columns `family` and `term`.
#'
#' @return Character vector: one of `"Aromatic"`, `"Naphthene"`,
#'   `"Oxygenate"`, `"Unknown Heteroatomic"`, `"Unsaturate"`,
#'   `"Isoparaffin"`, `"Paraffin"` or `"Unknown Hydrocarbon"`.
#'
#' @details Name terms identify aromatics and naphthenes first, then oxygen
#'   (always wins at the end), heteroatoms, and finally the double-bond
#'   equivalent from the formula. A leading `"Unknown,"` in a name (placeholder
#'   names) is ignored when looking for branching.
#'
#' @keywords internal
.classify_family <- function(peaks, terms = chemical_family_terms) {
  nm <- tolower(ifelse(is.na(peaks$name), "", peaks$name))
  nm <- sub("^unknown,[[:space:]]*", "", nm)
  hetero <- rowSums(
    peaks[, c("N", "F", "Cl", "Br", "I", "P", "S", "B", "Si")],
    na.rm = TRUE
  ) >
    0
  oxy <- !is.na(peaks$O) & peaks$O > 0
  dbe <- peaks$C - peaks$H / 2 + 1
  family <- rep(NA_character_, nrow(peaks))
  name_family <- \(f) {
    grepl(paste0(terms$term[terms$family == f], collapse = "|"), nm)
  }
  family[is.na(family) & name_family("Aromatic")] <- "Aromatic"
  family[is.na(family) & name_family("Naphthene")] <- "Naphthene"
  unk <- is.na(family)
  family[unk & oxy] <- "Oxygenate"
  unk <- is.na(family)
  family[unk & hetero] <- "Unknown Heteroatomic"
  unk <- is.na(family)
  family[unk & !is.na(dbe) & dbe >= 4] <- "Aromatic"
  unk <- is.na(family)
  family[unk & !is.na(dbe) & dbe >= 1] <- "Unsaturate"
  unk <- is.na(family) & !is.na(dbe) & dbe <= 0
  family[unk] <- ifelse(
    grepl("methyl|ethyl|propyl|iso|,", nm[unk]),
    "Isoparaffin",
    "Paraffin"
  )
  family[is.na(family)] <- "Unknown Hydrocarbon"
  family[oxy] <- "Oxygenate"
  family
}
