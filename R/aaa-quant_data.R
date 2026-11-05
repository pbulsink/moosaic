# Lookup tables ported from fidms (not a dependency). ASCII only.

#' Atomic weights (g/mol)
#'
#' Ported from fidms.
#'
#' @format A tibble with 12 rows.
#' @keywords internal
#' @noRd
atomic_weights <- tibble::tibble(
  symbol = c("H", "B", "C", "N", "O", "F", "Si", "P", "S", "Cl", "Br", "I"),
  element = c("Hydrogen", "Boron", "Carbon", "Nitrogen", "Oxygen", "Fluorine", "Silicon", 
    "Phosphorus", "Sulfur", "Chlorine", "Bromine", "Iodine"),
  mass = c(1.008, 10.81, 12.010999999999999, 14.007, 15.999000000000001, 18.998403, 
    28.085000000000001, 30.973762000000001, 32.060000000000002, 35.450000000000003, 
    79.903999999999996, 126.90447)
)

#' Calibration target compounds
#'
#' Ported from fidms.
#'
#' @format A tibble with 16 rows.
#' @keywords internal
#' @noRd
calibration_targets <- tibble::tibble(
  target = c("cyclohexane", "benzene", "n-heptane", "methylcyclohexane", "toluene", 
    "ethylcyclohexane", "p-xylene", "n-propylcyclohexane", "n-propylbenzene", 
    "1,2,3-trimethylbenzene", "n-butylcyclohexane", "n-dodecane", "methanol", 
    "ethyl acetate", "phenol", "2-methoxyphenol"),
  synonyms = c(NA, NA, "heptane", "cyclohexane, methyl-", NA, "cyclohexane, ethyl-", 
    "cyclohexane, 1,2-dimethyl-, cis-", "cyclohexane, propyl-", "benzene, propyl-", 
    "benzene, 1,2,3-trimethyl-", "Cyclohexane, butyl-", "dodecane", "methyl alcohol", 
    NA, NA, "phenol, 2-methoxy-"),
  type = c("hydrocarbon", "hydrocarbon", "hydrocarbon", "hydrocarbon", "hydrocarbon", 
    "hydrocarbon", "hydrocarbon", "hydrocarbon", "hydrocarbon", "hydrocarbon", 
    "hydrocarbon", "hydrocarbon", "oxygenate", "oxygenate", "oxygenate", "oxygenate"
    ),
  rt = c(2.754, 2.7789999999999999, 3.2839999999999998, 3.8069999999999999, 4.9020000000000001, 
    7.5220000000000002, 9.1920000000000002, 12.234999999999999, 13.375999999999999, 
    16.879999999999999, 17.616, 25.991, 1.538, 2.2709999999999999, 14.891999999999999, 
    20.300999999999998),
  ri = c(662, 654, 700, 721, 757, 834, 860, 934, 945, 1020, 1029, 1200, 379, 600, 
    959, 1063),
  carbon = c(6L, 6L, 7L, 7L, 7L, 8L, 8L, 9L, 9L, 9L, 10L, 12L, 1L, 4L, 6L, 7L),
  hydrogen = c(12L, 6L, 16L, 14L, 8L, 16L, 10L, 18L, 12L, 12L, 14L, 16L, 4L, 8L, 6L, 
    8L),
  oxygen = c(0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 1L, 2L, 1L, 2L)
)

#' Calibration points (concentration vs response)
#'
#' Ported from fidms.
#'
#' @format A tibble with 127 rows.
#' @keywords internal
#' @noRd
calibration_points <- tibble::tibble(
  target = c("1,2,3-trimethylbenzene", "1,2,3-trimethylbenzene", "1,2,3-trimethylbenzene", 
    "1,2,3-trimethylbenzene", "1,2,3-trimethylbenzene", "1,2,3-trimethylbenzene", 
    "1,2,3-trimethylbenzene", "1,2,3-trimethylbenzene", "1,2,3-trimethylbenzene", 
    "2-methoxyphenol", "2-methoxyphenol", "2-methoxyphenol", "2-methoxyphenol", 
    "2-methoxyphenol", "2-methoxyphenol", "benzene", "benzene", "benzene", 
    "benzene", "benzene", "benzene", "benzene", "benzene", "benzene", "cyclohexane", 
    "cyclohexane", "cyclohexane", "cyclohexane", "cyclohexane", "cyclohexane", 
    "cyclohexane", "cyclohexane", "cyclohexane", "ethyl acetate", "ethyl acetate", 
    "ethyl acetate", "ethyl acetate", "ethyl acetate", "ethylcyclohexane", 
    "ethylcyclohexane", "ethylcyclohexane", "ethylcyclohexane", "ethylcyclohexane", 
    "ethylcyclohexane", "ethylcyclohexane", "ethylcyclohexane", "ethylcyclohexane", 
    "ethylcyclohexane", "methanol", "methanol", "methanol", "methanol", "methanol", 
    "methanol", "methanol", "methanol", "methanol", "methylcyclohexane", "methylcyclohexane", 
    "methylcyclohexane", "methylcyclohexane", "methylcyclohexane", "methylcyclohexane", 
    "methylcyclohexane", "methylcyclohexane", "methylcyclohexane", "n-butylcyclohexane", 
    "n-butylcyclohexane", "n-butylcyclohexane", "n-butylcyclohexane", "n-butylcyclohexane", 
    "n-butylcyclohexane", "n-butylcyclohexane", "n-butylcyclohexane", "n-butylcyclohexane", 
    "n-butylcyclohexane", "n-dodecane", "n-dodecane", "n-dodecane", "n-dodecane", 
    "n-dodecane", "n-dodecane", "n-dodecane", "n-dodecane", "n-heptane", "n-heptane", 
    "n-heptane", "n-heptane", "n-heptane", "n-heptane", "n-heptane", "n-propylbenzene", 
    "n-propylbenzene", "n-propylbenzene", "n-propylbenzene", "n-propylbenzene", 
    "n-propylbenzene", "n-propylbenzene", "n-propylcyclohexane", "n-propylcyclohexane", 
    "n-propylcyclohexane", "n-propylcyclohexane", "n-propylcyclohexane", "n-propylcyclohexane", 
    "n-propylcyclohexane", "n-propylcyclohexane", "n-propylcyclohexane", "n-propylcyclohexane", 
    "p-xylene", "p-xylene", "p-xylene", "p-xylene", "p-xylene", "p-xylene", 
    "p-xylene", "phenol", "phenol", "phenol", "phenol", "phenol", "toluene", 
    "toluene", "toluene", "toluene", "toluene", "toluene", "toluene"),
  level = c(25, 50, 100, 250, 500, 1000, 2500, 5000, 10000, 250, 500, 1000, 2500, 
    5000, 10000, 10, 25, 50, 100, 250, 500, 1000, 2500, 5000, 10, 25, 50, 100, 
    250, 500, 1000, 2500, 5000, 250, 500, 1000, 2500, 5000, 10, 25, 50, 100, 
    250, 500, 1000, 2500, 5000, 10000, 25, 50, 100, 250, 500, 1000, 2500, 5000, 
    10000, 10, 25, 50, 100, 250, 500, 1000, 2500, 5000, 10, 25, 50, 100, 250, 
    500, 1000, 2500, 5000, 10000, 50, 100, 250, 500, 1000, 2500, 5000, 10000, 
    50, 100, 250, 500, 1000, 2500, 5000, 100, 250, 500, 1000, 2500, 5000, 10000, 
    10, 25, 50, 100, 250, 500, 1000, 2500, 5000, 10000, 100, 250, 500, 1000, 
    2500, 5000, 10000, 500, 1000, 2500, 5000, 10000, 100, 250, 500, 1000, 2500, 
    5000, 10000),
  conc = c(25.074999999999999, 50.149999999999999, 100.3, 250.75, 501.5, 1003, 2507.5, 
    5015, 10030, 250, 500, 1000, 2500, 5000, 10000, 20.07, 50.174999999999997, 
    100.34999999999999, 200.69999999999999, 501.75, 1003.5, 2007, 5017.5, 10035, 
    20.07, 50.174999999999997, 100.34999999999999, 200.69999999999999, 501.75, 
    1003.5, 2007, 5017.5, 10035, 250.75, 501.5, 1003, 2507.5, 5015, 10, 25, 
    50, 100, 250, 500, 1000, 2500, 5000, 10000, 25, 50, 100, 250, 500, 1000, 
    2500, 5000, 10000, 10.039999999999999, 25.100000000000001, 50.200000000000003, 
    100.40000000000001, 251, 502, 1004, 2510, 5020, 9.9199999999999999, 24.800000000000001, 
    49.600000000000001, 99.200000000000003, 248, 496, 992, 2480, 4960, 9920, 
    50.100000000000001, 100.2, 250.5, 501, 1002, 2505, 5010, 10020, 50.200000000000003, 
    100.40000000000001, 251, 502, 1004, 2510, 5020, 100.2, 250.5, 501, 1002, 
    2505, 5010, 10020, 10.02, 25.050000000000001, 50.100000000000001, 100.2, 
    250.5, 501, 1002, 2505, 5010, 10020, 100.09999999999999, 250.25, 500.5, 
    1001, 2502.5, 5005, 10010, 501, 1002, 2505, 5010, 10020, 100, 250, 500, 
    1000, 2500, 5000, 10000),
  resp = c(5527, 14255, 59398, 234819, 663610, 1305264, 3370639, 8016009, 13399414, 
    32040, 166550, 483975, 1654258, 4792933, 8655958, 10866, 32174, 74013, 
    183629, 500020, 971038, 1666209, 3400311, 6111694, 10866, 32174, 74013, 
    183629, 500020, 971038, 1666209, 3400311, 6111694, 2362, 23495, 69451, 
    253455, 656634, 3420, 19587, 44722, 124855, 361779, 708790, 1217783, 2689620, 
    6177998, 10120638, 630, 2642, 14950, 71604, 175778, 366657, 1020918, 2582831, 
    4537401, 7510, 28070, 57796, 140634, 365920, 711737, 1222348, 2283557, 
    4307732, 3059, 16986, 38611, 134862, 369883, 763691, 1397102, 3405838, 
    7989464, 13223004, 9446, 66433, 269555, 680603, 1344196, 3513905, 9725911, 
    18900260, 10631, 55224, 224398, 575721, 1078732, 2227435, 4060253, 22028, 
    150448, 448559, 1006653, 2905493, 7332117, 12409760, 2162, 20494, 43171, 
    127820, 367793, 718659, 1289015, 3087184, 7263217, 11973239, 9274, 101872, 
    361091, 839912, 2515326, 6517191, 11070614, 56865, 357405, 1590952, 4520685, 
    8335891, 16486, 125418, 328854, 686505, 1966976, 4986691, 8451143)
)

#' Name fragments for chemical-family classification
#'
#' Ported from fidms.
#'
#' @format A tibble with 31 rows.
#' @keywords internal
#' @noRd
chemical_family_terms <- tibble::tibble(
  family = c("Aromatic", "Aromatic", "Aromatic", "Aromatic", "Aromatic", "Aromatic", 
    "Aromatic", "Aromatic", "Aromatic", "Aromatic", "Aromatic", "Aromatic", 
    "Aromatic", "Naphthene", "Naphthene", "Naphthene", "Naphthene", "Naphthene", 
    "Naphthene", "Naphthene", "Naphthene", "Unsaturate", "Unsaturate", "Unsaturate", 
    "Oxygenate", "Oxygenate", "Oxygenate", "Oxygenate", "Oxygenate", "Oxygenate", 
    "Oxygenate"),
  term = c("benzene", "toluene", "xylene", "phenyl", "naphthalene", "indene", "styrene", 
    "phenol", "cresol", "anisole", "thiophene", "pyridine", "furan", "cyclopropane", 
    "cyclobutane", "cyclopentane", "cyclohexane", "cycloheptane", "cyclooctane", 
    "decalin", "bicyclo", "ene", "yne", "diene", "ol", "one", "al", "acid", 
    "ether", "ester", "furan")
)

#' Solvent names
#' @keywords internal
#' @noRd
solvent_names <- c("methanol", "methyl alcohol", "dichloromethane", "methylene chloride", 
  "acetone", "hexane", "heptane", "carbon disulfide", "water", 
  "tetrahydrofuran", "acetonitrile", "pentane", "toluene")


# Elements tracked in peak tables, in column order.
.tracked_elements <- c(
  "C",
  "H",
  "N",
  "O",
  "F",
  "Cl",
  "Br",
  "I",
  "P",
  "S",
  "B",
  "Si"
)
