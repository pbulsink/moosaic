# Leading singular values of a matrix

Leading singular values of a matrix

## Usage

``` r
.leading_singular_values(X, k)
```

## Arguments

- X:

  Numeric matrix.

- k:

  Integer; number of singular values wanted.

## Value

Numeric vector of the `min(k, min(dim(X)))` largest singular values, in
decreasing order.

## Details

Computed as square roots of the eigenvalues of the smaller Gram matrix
(`X X'` or `X' X`), which is several times faster than a full SVD for
the wide matrices used here. Accuracy is about 1e-8 relative to the
largest value, which is ample for rank decisions but not for recovering
tiny singular values.
