#== # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# INPE - Instituto Nacional de Pesquisas Espaciais
# ETE  - Engenharia e Tecnologia Espacial
# DSE  - Divisão de Sistemas Espaciais
#
# Author: Ronan Arraes Jardim Chagas <ronan.arraes@inpe.br>
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Functions related to the associated Legendre functions.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# References
#
#   [1] Holmes, S. A. and W. E. Featherstone, 2002. A unified approach to the
#       Clenshaw summation and the recursive computation of very high degree and
#       order normalised associated Legendre functions Journal of Geodesy,
#       76(5), pp. 279-299.
#
#       For more info.: http://mitgcm.org/~mlosch/geoidcookbook/node11.html
#
#   [2] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications.
#       Microcosm Press, Hawthorn, CA, USA.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Changelog
#
# 2018-04-06: Ronan Arraes Jardim Chagas <ronan.arraes@inpe.br>
#   Initial version.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # ==#

export denormalize_legendre, legendre!, legendre

"""
### function denormalize_legendre(P_lm::Number, n::Number, m::Number)

Compute the conventional associated Legendre function from a fully normalized
value `P_nm` that has order `n` and degree `m`.

##### Args

* P_nm: Fully normalized Legendre associated function with degree `n` and order
        `m`.
* n: Degree of `P_nm`.
* m: Order of `P_nm`.

##### Returns

The conventional associated Legendre function.

"""

function denormalize_legendre(P_nm::Number, n::Number, m::Number)
    (n-m < 0) && throw(ArgumentError("n must be equal or bigger than m."))

    k = (m == 0) ? 1 : 2

    P_nm/sqrt(k*(2n+1)*factorial(n-m)/factorial(n+m))
end

"""
### function legendre!(P::Matrix, ϕ::Number)

Compute the fully normalized associated Legendre function `P_n,m[sin(ϕ)]`.
The maximum degree and order that will be computed are given by the dimensions
of matrix `P`.  Notice, however, that `P` must be a square matrix.

The result will be stored at matrix `P`.

##### Args

* P: Matrix that will store the computed associated Legendre function.
* ϕ: Angle [rad].

##### Remarks

This algorithm was based on [1]. Our definition of fully normalized associated
Legendre function can be seen in [2, p. 546]. The conversion is obtained by:

                 _                     -
                |        (l+m)!         |      k = 1 if m  = 0
    K_n,m = sqrt| --------------------- |,     k = 2 if m != 0
                |  (l-1)! . k . (2l+1)  |
                 -                     -

            _
    P_n,m = P_n,m * K_n,m,

          _
    where P_n,m is the fully normalized Legendre associated function.
"""

function legendre!(P::Matrix, ϕ::Number)
    (rows, cols) = size(P)

    # Check if the matrix P is a square matrix.
    (rows != cols) && throw(ArgumentError("P must be a square matrix."))

    # The matrix must be, at least, 2 rows and 2 columns.
    (rows < 2) && throw(ArgumentError("P must have at least 2 rows."))

    # Auxiliary variables to improve code performance.
    c = cos(ϕ)
    s = sin(ϕ)

    # Starting values.
    P[0+1,0+1] = 1
    P[1+1,0+1] = sqrt(3)*s
    P[1+1,1+1] = sqrt(3)*c

    for n = 2:rows-1
        for m = 0:n-1
            a_nm = sqrt( ( (2n-1)*(2n+1) ) / ( (n-m)*(n+m) ) )
            b_nm = sqrt( ( (2n+1)*(n+m-1)*(n-m-1) ) / ( (n-m)*(n+m)*(2n-3) ) )
            P[n+1,m+1] = a_nm*s*P[n-1+1,m+1] - b_nm*P[n-2+1,m+1]
        end

        P[n+1,n+1] = c*sqrt( (2n+1)/(2n) )*P[n-1+1,n-1+1]
    end

    nothing
end

"""
### function legendre(ϕ::Number, n_max::Number)

Compute the fully normalized associated Legendre function `P_n,m[sin(ϕ)]`.
The maximum degree that will be computed is `n_max`.

##### Args

* ϕ: Angle [rad].
* n_max: The maximum degree that will be computed.

##### Returns

A square matrix with the Legendre associated functions `P_n,m[sin(ϕ)]`.

##### Remarks

This algorithm was based on [1]. Our definition of fully normalized associated
Legendre function can be seen in [2, p. 546]. The conversion is obtained by:

                 _                     -
                |        (l+m)!         |      k = 1 if m  = 0
    K_n,m = sqrt| --------------------- |,     k = 2 if m != 0
                |  (l-1)! . k . (2l+1)  |
                 -                     -

            _
    P_n,m = P_n,m * K_n,m,

          _
    where P_n,m is the fully normalized Legendre associated function.

"""

function legendre(ϕ::Number, n_max::Number)
    (n_max < 1) && throw(ArgumentError("n_max must be at least 1."))

    P = zeros(n_max+1, n_max+1)
    legendre!(P, ϕ)
    P
end