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
#   Functions related with the IERS (International Earth Orientation and
#   Reference Systems Service) EOP (Earth Orientation Parameters) data.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# References
#
#   [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications.
#       Microcosm Press, Hawthorn, CA, USA.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Changelog
#
# 2018-04-10: Ronan Arraes Jardim Chagas <ronan.arraes@inpe.br>
#   Initial version.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # ==#

using HTTP
using Interpolations

export EOPData_IAU1980, EOPData_IAU2000A
export get_iers_eop, get_eop_iau_1980, get_eop_iau_2000A

################################################################################
#                                    Types
################################################################################

"""
EOP Data for IAU 1980. The fields are described as follows:

* x, y: Polar motion with respect to the crust [arcsec].
* UT1_UTC: Irregularities of the rotation angle [s].
* LOD: Length of day offset [s].
* dPsi, dEps: Celestial pole offsets referred to the model IAU1980 [arcsec].
* *_err: Errors in the components [same unit as the component].

##### Remarks

Each field will be an `AbstractInterpolation` indexed by the Julian Day. Hence,
if one want to obtain, for example, the X component of the polar motion with
respect to the crust at 19 June 2018, the following can be used:

    x[DatestoJD(2018,19,06,0,0,0)]

"""

struct EOPData_IAU1980{T}
    x::T
    y::T
    UT1_UTC::T
    LOD::T
    dPsi::T
    dEps::T

    # Errors
    x_err::T
    y_err::T
    UT1_UTC_err::T
    LOD_err::T
    dPsi_err::T
    dEps_err::T
end

"""
EOP Data for IAU 2000A. The files are described as follows:

* x, y: Polar motion with respect to the crust [arcsec].
* UT1_UTC: Irregularities of the rotation angle [s].
* LOD: Length of day offset [s].
* dX, dY: Celestial pole offsets referred to the model IAU2000A [arcsec].
* *_err: Errors in the components [same unit as the component].

##### Remarks

Each field will be an `AbstractInterpolation` indexed by the Julian Day. Hence,
if one want to obtain, for example, the X component of the polar motion with
respect to the crust at 19 June 2018, the following can be used:

    x[DatestoJD(2018,19,06,0,0,0)]

"""

struct EOPData_IAU2000A{T}
    x::T
    y::T
    UT1_UTC::T
    LOD::T
    dX::T
    dY::T

    # Errors
    x_err::T
    y_err::T
    UT1_UTC_err::T
    LOD_err::T
    dX_err::T
    dY_err::T
end

"""
### function get_iers_eop(data_type::Symbol = :IAU2000A)

Download and parse the IERS EOP C04 data. The data type is specified by
`data_type` symbol. Supported values are:

* `IAU1980`: Get IERS EOP C04 IAU1980 data.
* `IAU2000A`: Get IERS EOP C04 IAU2000A data.

##### Args

* data_type: (OPTIONAL) Symbol that defines the type of data that will be
             downloaded (**DEFAULT** = `:IAU2000A`).

##### Returns

A structure (`EOPData_IAU1980` or `EOPData_IAU2000A`, depending on `data_type`)
with the interpolations of the EOP parameters. Notice that the interpolation
indexing is set to the Julian Day.

"""

function get_iers_eop(data_type::Symbol = :IAU2000A)
    if data_type == :IAU1980
        return get_iers_eop_iau_1980()
    elseif data_type == :IAU2000A
        return get_iers_eop_iau_2000A()
    else
        throw(ArgumentError("Unknow EOP type. It must be :IAU1980 or :IAU2000A."))
    end
end

"""
### function get_iers_eop_iau_1980(url::String = "https://datacenter.iers.org/eop/-/somos/5Rgv/latest/213")

Get the IERS EOP C04 IAU1980 data from the URL `url`.

##### Args

* url: (OPTIONAL) Url in which the coefficients will be obtained (**DEFAULT** =
       https://datacenter.iers.org/eop/-/somos/5Rgv/latest/213)

##### Returns

The structure `EOPData_IAU1980` with the interpolations of the EOP parameters.
Notice that the interpolation indexing is set to the Julian Day.

###### Remarks

For every field in `EOPData_IAU1980` to interpolation between two points in the
grid is linear. If extrapolation is needed, then if will use the nearest value
(flat extrapolation).

"""

function get_iers_eop_iau_1980(url::String = "https://datacenter.iers.org/eop/-/somos/5Rgv/latest/213")
    r = HTTP.request("GET", url)

    # Parse the data removing the header.
    eop = readdlm(r.body; skipblanks=true, skipstart=14)

    # Check if the dimension seems correct.
    if size(eop,2) != 16
        error("The fetched data does not have the correct dimension. Please, check the URL.")
    end

    # Create the EOP Data structure by creating the interpolations.
    #
    # The interpolation will be linear between two points in the grid. The
    # extrapolation will be flat, considering the nearest point.
	knots = (eop[:,4]+2400000.5,)

    EOPData_IAU1980(
        extrapolate(interpolate(knots, eop[:, 5], Gridded(Linear())), Flat()),
        extrapolate(interpolate(knots, eop[:, 6], Gridded(Linear())), Flat()),
        extrapolate(interpolate(knots, eop[:, 7], Gridded(Linear())), Flat()),
        extrapolate(interpolate(knots, eop[:, 8], Gridded(Linear())), Flat()),
        extrapolate(interpolate(knots, eop[:, 9], Gridded(Linear())), Flat()),
        extrapolate(interpolate(knots, eop[:,10], Gridded(Linear())), Flat()),
        extrapolate(interpolate(knots, eop[:,11], Gridded(Linear())), Flat()),
        extrapolate(interpolate(knots, eop[:,12], Gridded(Linear())), Flat()),
        extrapolate(interpolate(knots, eop[:,13], Gridded(Linear())), Flat()),
        extrapolate(interpolate(knots, eop[:,14], Gridded(Linear())), Flat()),
        extrapolate(interpolate(knots, eop[:,15], Gridded(Linear())), Flat()),
        extrapolate(interpolate(knots, eop[:,16], Gridded(Linear())), Flat())
    )
end

"""
### function get_iers_eop_iau_2000A(url::String = "https://datacenter.iers.org/eop/-/somos/5Rgv/latest/214")

Get the IERS EOP C04 IAU2000A data from the URL `url`.

##### Args

* url: (OPTIONAL) Url in which the coefficients will be obtained (**DEFAULT** =
       https://datacenter.iers.org/eop/-/somos/5Rgv/latest/214)

##### Returns

The structure `EOPData_IAU2000A` with the interpolations of the EOP parameters.
Notice that the interpolation indexing is set to the Julian Day.

###### Remarks

For every field in `EOPData_IAU2000A` to interpolation between two points in the
grid is linear. If extrapolation is needed, then if will use the nearest value
(flat extrapolation).

"""

function get_iers_eop_iau_2000A(url::String = "https://datacenter.iers.org/eop/-/somos/5Rgv/latest/214")
    r = HTTP.request("GET", url)

    # Parse the data removing the header.
    eop = readdlm(r.body; skipblanks=true, skipstart=14)

    # Check if the dimension seems correct.
    if size(eop,2) != 16
        error("The fetched data does not have the correct dimension. Please, check the URL.")
    end

    # Create the EOP Data structure by creating the interpolations.
    #
    # The interpolation will be linear between two points in the grid. The
    # extrapolation will be flat, considering the nearest point.
	knots = (eop[:,4]+2400000.5,)

    EOPData_IAU2000A(
        extrapolate(interpolate(knots, eop[:, 5], Gridded(Linear())), Flat()),
        extrapolate(interpolate(knots, eop[:, 6], Gridded(Linear())), Flat()),
        extrapolate(interpolate(knots, eop[:, 7], Gridded(Linear())), Flat()),
        extrapolate(interpolate(knots, eop[:, 8], Gridded(Linear())), Flat()),
        extrapolate(interpolate(knots, eop[:, 9], Gridded(Linear())), Flat()),
        extrapolate(interpolate(knots, eop[:,10], Gridded(Linear())), Flat()),
        extrapolate(interpolate(knots, eop[:,11], Gridded(Linear())), Flat()),
        extrapolate(interpolate(knots, eop[:,12], Gridded(Linear())), Flat()),
        extrapolate(interpolate(knots, eop[:,13], Gridded(Linear())), Flat()),
        extrapolate(interpolate(knots, eop[:,14], Gridded(Linear())), Flat()),
        extrapolate(interpolate(knots, eop[:,15], Gridded(Linear())), Flat()),
        extrapolate(interpolate(knots, eop[:,16], Gridded(Linear())), Flat())
    )
end