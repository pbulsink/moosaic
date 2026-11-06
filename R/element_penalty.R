.element_symbols <- c(
  # Hydrogen isotopes appear in NIST library formulas
  "D",
  "T",
  "H",
  "He",
  "Li",
  "Be",
  "B",
  "C",
  "N",
  "O",
  "F",
  "Ne",
  "Na",
  "Mg",
  "Al",
  "Si",
  "P",
  "S",
  "Cl",
  "Ar",
  "K",
  "Ca",
  "Sc",
  "Ti",
  "V",
  "Cr",
  "Mn",
  "Fe",
  "Co",
  "Ni",
  "Cu",
  "Zn",
  "Ga",
  "Ge",
  "As",
  "Se",
  "Br",
  "Kr",
  "Rb",
  "Sr",
  "Y",
  "Zr",
  "Nb",
  "Mo",
  "Tc",
  "Ru",
  "Rh",
  "Pd",
  "Ag",
  "Cd",
  "In",
  "Sn",
  "Sb",
  "Te",
  "I",
  "Xe",
  "Cs",
  "Ba",
  "La",
  "Ce",
  "Pr",
  "Nd",
  "Pm",
  "Sm",
  "Eu",
  "Gd",
  "Tb",
  "Dy",
  "Ho",
  "Er",
  "Tm",
  "Yb",
  "Lu",
  "Hf",
  "Ta",
  "W",
  "Re",
  "Os",
  "Ir",
  "Pt",
  "Au",
  "Hg",
  "Tl",
  "Pb",
  "Bi",
  "Po",
  "At",
  "Rn",
  "Fr",
  "Ra",
  "Ac",
  "Th",
  "Pa",
  "U",
  "Np",
  "Pu",
  "Am",
  "Cm",
  "Bk",
  "Cf",
  "Es",
  "Fm",
  "Md",
  "No",
  "Lr"
)

#' Penalty for unexpected elements in a formula
#'
#' @param formula Character vector of formulas; `NA` gives no penalty.
#' @param penalties Named numeric vector: penalty per atom of an element.
#' @param allowed Character vector of elements that may occur unpenalised.
#' @param default Penalty per atom of an element that is neither in
#'   `penalties` nor in `allowed`.
#' @param call Call environment for errors.
#'
#' @return Numeric vector. Each atom of an element in `penalties` adds that
#'   element's penalty; each atom of an element in neither `penalties` nor
#'   `allowed` adds `default`. Aborts on an unrecognised element symbol.
#'
#' @keywords internal
.element_penalty <- function(
  formula,
  penalties,
  allowed,
  default = 100,
  call = rlang::caller_env()
) {
  vapply(
    formula,
    \(f) {
      if (is.na(f)) {
        return(0)
      }
      counts <- .parse_formula(f, call = call)
      unknown <- setdiff(names(counts), .element_symbols)
      if (length(unknown) > 0L) {
        .moosaic_abort(
          "Unknown element {.val {unknown}} in formula {.val {f}}.",
          class = "bad_formula",
          call = call
        )
      }
      total <- 0
      for (el in names(counts)) {
        if (el %in% names(penalties)) {
          total <- total + counts[[el]] * penalties[[el]]
        } else if (!el %in% allowed) {
          total <- total + counts[[el]] * default
        }
      }
      total
    },
    numeric(1),
    USE.NAMES = FALSE
  )
}
