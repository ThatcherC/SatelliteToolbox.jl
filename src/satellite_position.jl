#== # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# INPE - Instituto Nacional de Pesquisas Espaciais
# ETE  - Engenharia e Tecnologia Espacial
# DSE  - Divisão de Sistemas Espaciais
#
# Author: Ronan Arraes Jardim Chagas <ronan.chagas@inpe.br>
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#    Compute the satellite position.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Changelog
#
# 2015-11-05: Ronan Arraes Jardim Chagas <ronan.arraes@inpe.br>
#    Remove the deprecated structure OrbitalParameters.
#
# 2014-08-12: Ronan Arraes Jardim Chagas <ronan.chagas@inpe.br>
#    Add support to the structure OrbitalParameters.
#    WARNING: the order of parameters in function satellite_position_i changed.
#
# 2014-07-28: Ronan Arraes Jardim Chagas <ronan.chagas@inpe.br>
#    Initial version.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # ==#

import Rotations: angle2dcm, angle2dcm!

export satellite_position_latlon, satellite_position_i

"""
### function satellite_position_latlon(JD::Real, r_i::Array{Float64,1})

Compute the latitude and longitude of Nadir.

##### Args

* JD: Julian day.
* r_i: Position vector represented in the Inertial (J2000) reference frame.

##### Returns

* The Nadir latitude in the interval [-π,+π] [rad].
* The Nadir longitude in the interval [-π,+π] [rad].

##### Remarks

TODO: This function uses the Greenwich Mean Sideral time. The accuracy can be
    increased if it uses the Greenwich Apparent Sideral Time.

"""

################################################################################
#                                 TEST RESULTS
################################################################################
#
# This function was extensively tested against STK v10.0.0 to verify its
# accuracy. Notice that minor discrepancy is expected since STK is using the
# Greenwich Apparent Sideral Time whereas we are using here the Greenwich Mean
# Sideral time for the sake of simplification.
#
# In the following the comparison between this algorithm and STK can be found.
#
# Scenario 01
# ===========
#
# Day:                 01-Jan-2000 12:00 (JD = 2451545.0)
# Semi-major axis:     7000.00 km
# Eccentricity:        0.0
# Inclination:         90.0°
# RAAN:                0.0°
# Argument of Perigee: 0.0°
# True anomaly:        0.0°
#
#                 +--------------+---------------+
#                 | Latitude [°] | Longitude [°] |
# +---------------+--------------+---------------+
# | STK v10.0.0   |   0.00000    |   79.53922    |
# | This Function |   0.00000    |   79.53938    |
# +---------------+--------------+---------------+
# | Error         |   0.00000    |   -0.00016    |
# |               |              |   17.81111 m  |
# +---------------+--------------+---------------+
#
# Scenario 02
# ===========
#
# Day:                 22-Set-2000 10:30 (JD = 2451809.93750)
# Semi-major axis:     9500.00 km
# Eccentricity:        0.25
# Inclination:         75.6°
# RAAN:                215.1°
# Argument of Perigee: 97.00°
# True anomaly:        10.0°
#
#                 +--------------+---------------+
#                 | Latitude [°] | Longitude [°] |
# +---------------+--------------+---------------+
# | STK v10.0.0   |  67.95133    | -163.11059    |
# | This Function |  67.85923    | -163.12144    |
# +---------------+--------------+---------------+
# | Error         |   0.09210    |    0.01085    |
# |               |  10.25257 km |    1.20761 km |
# +---------------+--------------+---------------+
#
# Scenario 03
# ===========
#
# Day:                 19-Jun-2015 18:00 (JD = 2457193.25)
# Semi-major axis:     7131.00 km
# Eccentricity:        0.05
# Inclination:         19.6°
# RAAN:                190.6°
# Argument of Perigee: 99.75°
# True anomaly:        6.0°
#
#                 +--------------+---------------+
#                 | Latitude [°] | Longitude [°] |
# +---------------+--------------+---------------+
# | STK v10.0.0   |  18.98900    |  119.79547    |
# | This Function |  18.83580    |  119.62307    |
# +---------------+--------------+---------------+
# | Error         |   0.06220    |    0.17240    |
# |               |   6.92407 km |   19.19141 km |
# +---------------+--------------+---------------+
#
# Scenario 04
# ===========
#
# Day:                 22-Set-2020 10:30 (JD = 2459114.93750)
# Semi-major axis:     9500.00 km
# Eccentricity:        0.25
# Inclination:         75.6°
# RAAN:                215.1°
# Argument of Perigee: 97.00°
# True anomaly:        10.0°
#
#                 +--------------+---------------+
#                 | Latitude [°] | Longitude [°] |
# +---------------+--------------+---------------+
# | STK v10.0.0   |  68.09124    | -163.02999    |
# | This Function |  67.85923    | -163.27545    |
# +---------------+--------------+---------------+
# | Error         |   0.23201    |    0.24546    |
# |               |  25.82728 km |   27.32436 km |
# +---------------+--------------+---------------+
#
################################################################################

function satellite_position_latlon(JD::Real, r_i::Array{Float64,1})
    # Get the Mean Greenwich sideral time [rad].
    GMST = JDtoGMST(JD)

    # DCM to convert the Inertial (J2000) reference frame to the ECEF frame.
    Dei = angle2dcm(GMST, 0.0, 0.0, "ZYX")

    # Position represented in the ECEF frame.
    r_e = Dei*r_i

    # Get the longitude in the interval [-π,+π].
    lon = atan2(r_e[2], r_e[1])

    # Get the latitude in the interval [-π,+π].
    lat = atan2(r_e[3], sqrt(r_e[1]^2 + r_e[2]^2))

    (lat, lon)
end

"""
### function function satellite_position_latlon(JD::Real, a::Real, e::Real, i::Real, RAAN::Real, w::Real, f::Real)

Compute the latitude and longitude of Nadir.

##### Args

* a: Semi-major axis.
* e: Eccentricity.
* i: Inclination [rad].
* RAAN: Right ascension of the ascending node [rad].
* w: Argument of perigee [rad].
* f: True anomaly [rad].

##### Returns

* The Nadir latitude in the interval [-π,+π] [rad].
* The Nadir longitude in the interval [0,+2π] [rad].

"""

function satellite_position_latlon(JD::Real, a::Real, e::Real, i::Real, RAAN::Real, w::Real, f::Real)
    # Get the satellite position represented in the Inertial (J2000) coordinate
    # frame.
    (r_i, rt_i) = satellite_position_i(a, e, i, RAAN, w, f)

    # Compute the latitude and longitude of Nadir.
    satellite_position_latlon(JD, r_i)
end

"""
### function satellite_position_i(a::Real, e::Real, i::Real, RAAN::Real, w::Real, f::Real)

Compute the satellite position on the Inertial coordinate frame.

##### Args

* a: Semi-major axis.
* e: Eccentricity.
* i: Inclination [rad].
* RAAN: Right ascension of the ascending node [rad].
* w: Argument of perigee [rad].
* f: True anomaly [rad].

##### Returns

* The satellite position vector represented in the Inertial coordinate frame.
* The versor perpendicular to the satellite position vector that lies on the
orbit plane represented in the Inertial coordinate frame.

###### Remarks

The satellite position vector will have the same unit of the semi-major axis.

"""

function satellite_position_i(a::Real, e::Real, i::Real, RAAN::Real,
                              w::Real, f::Real)
    # Compute the radius from the focus.
    norm_r = a*(1-e^2)/(1+e*cos(f))

    # Let s be the coordinate system in which:
    #     - The X axis points towards the satellite;
    #     - The Z axis is normal to the orbit plane (right-hand direction);
    #     - The Y axis completes a right-hand coordinate system.
    #
    # Thus, the satellite vector represented in the s coordinate frame is:
    r_s = [1;0;0]*norm_r

    # rt is the versor perpendicular to the r vector that lies on the orbit
    # plane.
    rt_s = [0;1;0]

    # Compute the matrix that rotates from the S coordinate frame to the
    # Inertial coordinate Frame.
    Dsi = Array(Float64,(3,3))
    angle2dcm!(Dsi, RAAN, i, w+f, "ZXZ")

    # Compute the satellite vector represented in the Inertial coordinate
    # frame.
    r_i = Dsi'*r_s

    # Compute versor rt represented in the Inertial coordinate frame.
    rt_i = Dsi'*rt_s

    # Return.
    return r_i, rt_i
end
