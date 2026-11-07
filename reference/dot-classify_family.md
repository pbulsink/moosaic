# Chemical family of each peak

Chemical family of each peak

## Usage

``` r
.classify_family(peaks, terms = chemical_family_terms)
```

## Arguments

- peaks:

  Tibble with `name`, `C`, `H`, `O`, `N`, `F`, `Cl`, `Br`, `I`, `P`,
  `S`, `B` and `Si` columns.

- terms:

  Tibble with columns `family` and `term`.

## Value

Character vector: one of `"Aromatic"`, `"Naphthene"`, `"Oxygenate"`,
`"Unknown Heteroatomic"`, `"Unsaturate"`, `"Isoparaffin"`, `"Paraffin"`
or `"Unknown Hydrocarbon"`.

## Details

Name terms identify aromatics and naphthenes first, then oxygen (always
wins at the end), heteroatoms, and finally the double-bond equivalent
from the formula. A leading `"Unknown,"` in a name (placeholder names)
is ignored when looking for branching.
