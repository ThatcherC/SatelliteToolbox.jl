#== # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Tests related to ECEF to ECI transformations.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# References
#
#   [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications.
#       Microcosm Press, Hawthorn, CA, USA.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # ==#

# Get the current EOP Data.
#
# TODO: The EOP data obtained from IERS website does not match the values in the
# examples in [1]. However, this should be enough, because 1) the individual
# functions at the low level are tested using the same values of [1], and 2) the
# difference is smaller than 30 cm.

eop_iau1980  = read_iers_eop("./eop_IAU1980.txt",  :IAU1980)
eop_iau2000a = read_iers_eop("./eop_IAU2000A.txt", :IAU2000A)

# File: ./src/transformations/ecef_to_eci.jl
# ==========================================

# Functions: rECEFtoECI
# ---------------------

################################################################################
#                                  IAU-76/FK5
################################################################################

## ITRF to GCRF
## ============

################################################################################
#                                 Test Results
################################################################################
#
# Scenario 01
# ===========
#
# Example 3-15: Performing IAU-76/FK5 reduction.
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_itrf = -1033.4793830    i + 7901.2952754    j + 6380.3565958    k [km]
#
# one gets:
#
#   r_gcrf = 5102.50895790  i + 6123.01140070   j + 6378.13692820   k [km]
#
################################################################################

@testset "Function rECEFtoECI ITRF => GCRF" begin
    JD_UTC = DatetoJD(2004, 4, 6, 7, 51, 28.386009)
    r_itrf = [-1033.4793830; 7901.2952754; 6380.3565958]

    D_GCRF_ITRF = rECEFtoECI(ITRF(), GCRF(), JD_UTC, eop_iau1980)
    r_gcrf = D_GCRF_ITRF*r_itrf

    @test r_gcrf[1] ≈ +5102.50895790 atol=3e-4
    @test r_gcrf[2] ≈ +6123.01140070 atol=3e-4
    @test r_gcrf[3] ≈ +6378.13692820 atol=3e-4

    q_GCRF_ITRF = rECEFtoECI(Quaternion, ITRF(), GCRF(), JD_UTC, eop_iau1980)
    r_gcrf = vect(conj(q_GCRF_ITRF)*r_itrf*q_GCRF_ITRF)

    @test r_gcrf[1] ≈ +5102.50895790 atol=3e-4
    @test r_gcrf[2] ≈ +6123.01140070 atol=3e-4
    @test r_gcrf[3] ≈ +6378.13692820 atol=3e-4

    D_GCRF_ITRF = rECEFtoECI(ITRF(), GCRF(), JD_UTC, eop_iau1980)
    r_gcrf = D_GCRF_ITRF*r_itrf

    @test r_gcrf[1] ≈ +5102.50895790 atol=3e-4
    @test r_gcrf[2] ≈ +6123.01140070 atol=3e-4
    @test r_gcrf[3] ≈ +6378.13692820 atol=3e-4

    q_GCRF_ITRF = rECEFtoECI(Quaternion, ITRF(), GCRF(), JD_UTC, eop_iau1980)
    r_gcrf = vect(conj(q_GCRF_ITRF)*r_itrf*q_GCRF_ITRF)

    @test r_gcrf[1] ≈ +5102.50895790 atol=3e-4
    @test r_gcrf[2] ≈ +6123.01140070 atol=3e-4
    @test r_gcrf[3] ≈ +6378.13692820 atol=3e-4
end

## ITRF to J2000
## =============

################################################################################
#                                 Test Results
################################################################################
#
# Scenario 01
# ===========
#
# Example 3-15: Performing IAU-76/FK5 reduction.
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_itrf = -1033.4793830    i + 7901.2952754    j + 6380.3565958    k [km]
#
# one gets:
#
#   r_j2000 = 5102.50960000  i + 6123.01152000   j + 6378.13630000   k [km]
#
################################################################################

@testset "Function rECEFtoECI ITRF => J2000" begin
    JD_UTC = DatetoJD(2004, 4, 6, 7, 51, 28.386009)
    r_itrf = [-1033.4793830; 7901.2952754; 6380.3565958]

    D_J2000_ITRF = rECEFtoECI(ITRF(), J2000(), JD_UTC, eop_iau1980)
    r_j2000 = D_J2000_ITRF*r_itrf

    @test r_j2000[1] ≈ +5102.50960000 atol=3e-4
    @test r_j2000[2] ≈ +6123.01152000 atol=3e-4
    @test r_j2000[3] ≈ +6378.13630000 atol=3e-4

    q_J2000_ITRF = rECEFtoECI(Quaternion, ITRF(), J2000(), JD_UTC, eop_iau1980)
    r_j2000 = vect(conj(q_J2000_ITRF)*r_itrf*q_J2000_ITRF)

    @test r_j2000[1] ≈ +5102.50960000 atol=3e-4
    @test r_j2000[2] ≈ +6123.01152000 atol=3e-4
    @test r_j2000[3] ≈ +6378.13630000 atol=3e-4

    D_J2000_ITRF = rECEFtoECI(ITRF(), J2000(), JD_UTC, eop_iau1980)
    r_j2000 = D_J2000_ITRF*r_itrf

    @test r_j2000[1] ≈ +5102.50960000 atol=3e-4
    @test r_j2000[2] ≈ +6123.01152000 atol=3e-4
    @test r_j2000[3] ≈ +6378.13630000 atol=3e-4

    q_J2000_ITRF = rECEFtoECI(Quaternion, ITRF(), J2000(), JD_UTC, eop_iau1980)
    r_j2000 = vect(conj(q_J2000_ITRF)*r_itrf*q_J2000_ITRF)

    @test r_j2000[1] ≈ +5102.50960000 atol=3e-4
    @test r_j2000[2] ≈ +6123.01152000 atol=3e-4
    @test r_j2000[3] ≈ +6378.13630000 atol=3e-4
end

## ITRF to TOD
## ===========

################################################################################
#                                 Test Results
################################################################################
#
# Scenario 01
# ===========
#
# Example 3-15: Performing IAU-76/FK5 reduction.
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_itrf = -1033.4793830    i + 7901.2952754    j + 6380.3565958    k [km]
#
# one gets:
#
#   r_tod = 5094.51620300   i + 6127.36527840   j + 6380.34453270   k [km]
#
################################################################################

@testset "Function rECEFtoECI ITRF => TOD" begin
    JD_UTC = DatetoJD(2004, 4, 6, 7, 51, 28.386009)
    r_itrf = [-1033.4793830; 7901.2952754; 6380.3565958]

    D_TOD_ITRF = rECEFtoECI(ITRF(), TOD(), JD_UTC, eop_iau1980)
    r_tod = D_TOD_ITRF*r_itrf

    @test r_tod[1] ≈ +5094.51620300 atol=3e-4
    @test r_tod[2] ≈ +6127.36527840 atol=3e-4
    @test r_tod[3] ≈ +6380.34453270 atol=3e-4

    q_TOD_ITRF = rECEFtoECI(Quaternion, ITRF(), TOD(), JD_UTC, eop_iau1980)
    r_tod = vect(conj(q_TOD_ITRF)*r_itrf*q_TOD_ITRF)

    @test r_tod[1] ≈ +5094.51620300 atol=3e-4
    @test r_tod[2] ≈ +6127.36527840 atol=3e-4
    @test r_tod[3] ≈ +6380.34453270 atol=3e-4

    D_TOD_ITRF = rECEFtoECI(ITRF(), TOD(), JD_UTC, eop_iau1980)
    r_tod = D_TOD_ITRF*r_itrf

    @test r_tod[1] ≈ +5094.51620300 atol=3e-4
    @test r_tod[2] ≈ +6127.36527840 atol=3e-4
    @test r_tod[3] ≈ +6380.34453270 atol=3e-4

    q_TOD_ITRF = rECEFtoECI(Quaternion, ITRF(), TOD(), JD_UTC, eop_iau1980)
    r_tod = vect(conj(q_TOD_ITRF)*r_itrf*q_TOD_ITRF)

    @test r_tod[1] ≈ +5094.51620300 atol=3e-4
    @test r_tod[2] ≈ +6127.36527840 atol=3e-4
    @test r_tod[3] ≈ +6380.34453270 atol=3e-4
end

## ITRF to MOD
## ===========

################################################################################
#                                 Test Results
################################################################################
#
# Scenario 01
# ===========
#
# Example 3-15: Performing IAU-76/FK5 reduction.
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_itrf = -1033.4793830    i + 7901.2952754    j + 6380.3565958    k [km]
#
# one gets:
#
#   r_mod = 5094.02837450   i + 6127.87081640   j + 6380.24851640   k [km]
#
################################################################################

@testset "Function rECEFtoECI ITRF => MOD" begin
    JD_UTC = DatetoJD(2004, 4, 6, 7, 51, 28.386009)
    r_itrf = [-1033.4793830; 7901.2952754; 6380.3565958]

    D_MOD_ITRF = rECEFtoECI(ITRF(), MOD(), JD_UTC, eop_iau1980)
    r_mod = D_MOD_ITRF*r_itrf

    @test r_mod[1] ≈ +5094.02837450 atol=3e-4
    @test r_mod[2] ≈ +6127.87081640 atol=3e-4
    @test r_mod[3] ≈ +6380.24851640 atol=3e-4

    q_MOD_ITRF = rECEFtoECI(Quaternion, ITRF(), MOD(), JD_UTC, eop_iau1980)
    r_mod = vect(conj(q_MOD_ITRF)*r_itrf*q_MOD_ITRF)

    @test r_mod[1] ≈ +5094.02837450 atol=3e-4
    @test r_mod[2] ≈ +6127.87081640 atol=3e-4
    @test r_mod[3] ≈ +6380.24851640 atol=3e-4

    D_MOD_ITRF = rECEFtoECI(ITRF(), MOD(), JD_UTC, eop_iau1980)
    r_mod = D_MOD_ITRF*r_itrf

    @test r_mod[1] ≈ +5094.02837450 atol=3e-4
    @test r_mod[2] ≈ +6127.87081640 atol=3e-4
    @test r_mod[3] ≈ +6380.24851640 atol=3e-4

    q_MOD_ITRF = rECEFtoECI(Quaternion, ITRF(), MOD(), JD_UTC, eop_iau1980)
    r_mod = vect(conj(q_MOD_ITRF)*r_itrf*q_MOD_ITRF)

    @test r_mod[1] ≈ +5094.02837450 atol=3e-4
    @test r_mod[2] ≈ +6127.87081640 atol=3e-4
    @test r_mod[3] ≈ +6380.24851640 atol=3e-4
end

## ITRF to TEME
## ============

################################################################################
#                                 Test Results
################################################################################
#
# Scenario 01
# ===========
#
# Example 3-15: Performing IAU-76/FK5 reduction.
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_itrf = -1033.4793830   i + 7901.2952754    j + 6380.3565958    k [km]
#
# one gets:
#
#   r_teme = 5094.18016210   i + 6127.64465950   j + 6380.34453270   k [km]
#
################################################################################

@testset "Function rECEFtoECI ITRF => TEME" begin
    JD_UTC = DatetoJD(2004, 4, 6, 7, 51, 28.386009)
    r_itrf = [-1033.4793830; 7901.2952754; 6380.3565958]

    D_TEME_ITRF = rECEFtoECI(ITRF(), TEME(), JD_UTC, eop_iau1980)
    r_teme = D_TEME_ITRF*r_itrf

    @test r_teme[1] ≈ +5094.18016210 atol=3e-4
    @test r_teme[2] ≈ +6127.64465950 atol=3e-4
    @test r_teme[3] ≈ +6380.34453270 atol=3e-4

    q_TEME_ITRF = rECEFtoECI(Quaternion, ITRF(), TEME(), JD_UTC, eop_iau1980)
    r_teme = vect(conj(q_TEME_ITRF)*r_itrf*q_TEME_ITRF)

    @test r_teme[1] ≈ +5094.18016210 atol=3e-4
    @test r_teme[2] ≈ +6127.64465950 atol=3e-4
    @test r_teme[3] ≈ +6380.34453270 atol=3e-4

    D_TEME_ITRF = rECEFtoECI(ITRF(), TEME(), JD_UTC, eop_iau1980)
    r_teme = D_TEME_ITRF*r_itrf

    @test r_teme[1] ≈ +5094.18016210 atol=3e-4
    @test r_teme[2] ≈ +6127.64465950 atol=3e-4
    @test r_teme[3] ≈ +6380.34453270 atol=3e-4

    q_TEME_ITRF = rECEFtoECI(Quaternion, ITRF(), TEME(), JD_UTC, eop_iau1980)
    r_teme = vect(conj(q_TEME_ITRF)*r_itrf*q_TEME_ITRF)

    @test r_teme[1] ≈ +5094.18016210 atol=3e-4
    @test r_teme[2] ≈ +6127.64465950 atol=3e-4
    @test r_teme[3] ≈ +6380.34453270 atol=3e-4
end

## PEF to GCRF
## ===========

################################################################################
#                                 Test Results
################################################################################
#
# Scenario 01
# ===========
#
# Example 3-15: Performing IAU-76/FK5 reduction.
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_pef  = -1033.47503130   i + 7901.30558560   j + 6380.34453270   k [km]
#
# one gets:
#
#   r_gcrf = 5102.50895790  i + 6123.01140070   j + 6378.13692820   k [km]
#
################################################################################

@testset "Function rECEFtoECI PEF => GCRF" begin
    JD_UTC = DatetoJD(2004, 4, 6, 7, 51, 28.386009)
    r_pef  = [-1033.47503130; 7901.30558560; 6380.34453270]

    D_GCRF_PEF = rECEFtoECI(PEF(), GCRF(), JD_UTC, eop_iau1980)
    r_gcrf = D_GCRF_PEF*r_pef

    @test r_gcrf[1] ≈ +5102.50895790 atol=3e-4
    @test r_gcrf[2] ≈ +6123.01140070 atol=3e-4
    @test r_gcrf[3] ≈ +6378.13692820 atol=3e-4

    q_GCRF_PEF = rECEFtoECI(Quaternion, PEF(), GCRF(), JD_UTC, eop_iau1980)
    r_gcrf = vect(conj(q_GCRF_PEF)*r_pef*q_GCRF_PEF)

    @test r_gcrf[1] ≈ +5102.50895790 atol=3e-4
    @test r_gcrf[2] ≈ +6123.01140070 atol=3e-4
    @test r_gcrf[3] ≈ +6378.13692820 atol=3e-4

    D_GCRF_PEF = rECEFtoECI(PEF(), GCRF(), JD_UTC, eop_iau1980)
    r_gcrf = D_GCRF_PEF*r_pef

    @test r_gcrf[1] ≈ +5102.50895790 atol=3e-4
    @test r_gcrf[2] ≈ +6123.01140070 atol=3e-4
    @test r_gcrf[3] ≈ +6378.13692820 atol=3e-4

    q_GCRF_PEF = rECEFtoECI(Quaternion, PEF(), GCRF(), JD_UTC, eop_iau1980)
    r_gcrf = vect(conj(q_GCRF_PEF)*r_pef*q_GCRF_PEF)

    @test r_gcrf[1] ≈ +5102.50895790 atol=3e-4
    @test r_gcrf[2] ≈ +6123.01140070 atol=3e-4
    @test r_gcrf[3] ≈ +6378.13692820 atol=3e-4
end

## PEF to J2000
## ============

################################################################################
#                                 Test Results
################################################################################
#
# Scenario 01
# ===========
#
# Example 3-15: Performing IAU-76/FK5 reduction.
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_pef  = -1033.47503130   i + 7901.30558560   j + 6380.34453270   k [km]
#
# one gets:
#
#   r_j2000 = 5102.50960000  i + 6123.01152000   j + 6378.13630000   k [km]
#
################################################################################

@testset "Function rECEFtoECI PEF => J2000" begin
    JD_UTC = DatetoJD(2004, 4, 6, 7, 51, 28.386009)
    r_pef  = [-1033.47503130; 7901.30558560; 6380.34453270]

    D_J2000_PEF = rECEFtoECI(PEF(), J2000(), JD_UTC, eop_iau1980)
    r_j2000 = D_J2000_PEF*r_pef

    @test r_j2000[1] ≈ +5102.50960000 atol=3e-4
    @test r_j2000[2] ≈ +6123.01152000 atol=3e-4
    @test r_j2000[3] ≈ +6378.13630000 atol=3e-4

    q_J2000_PEF = rECEFtoECI(Quaternion, PEF(), J2000(), JD_UTC, eop_iau1980)
    r_j2000 = vect(conj(q_J2000_PEF)*r_pef*q_J2000_PEF)

    @test r_j2000[1] ≈ +5102.50960000 atol=3e-4
    @test r_j2000[2] ≈ +6123.01152000 atol=3e-4
    @test r_j2000[3] ≈ +6378.13630000 atol=3e-4

    D_J2000_PEF = rECEFtoECI(PEF(), J2000(), JD_UTC, eop_iau1980)
    r_j2000 = D_J2000_PEF*r_pef

    @test r_j2000[1] ≈ +5102.50960000 atol=3e-4
    @test r_j2000[2] ≈ +6123.01152000 atol=3e-4
    @test r_j2000[3] ≈ +6378.13630000 atol=3e-4

    q_J2000_PEF = rECEFtoECI(Quaternion, PEF(), J2000(), JD_UTC, eop_iau1980)
    r_j2000 = vect(conj(q_J2000_PEF)*r_pef*q_J2000_PEF)

    @test r_j2000[1] ≈ +5102.50960000 atol=3e-4
    @test r_j2000[2] ≈ +6123.01152000 atol=3e-4
    @test r_j2000[3] ≈ +6378.13630000 atol=3e-4
end

## PEF to TOD
## ==========

################################################################################
#                                 Test Results
################################################################################
#
# Scenario 01
# ===========
#
# Example 3-15: Performing IAU-76/FK5 reduction.
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_pef  = -1033.47503130   i + 7901.30558560   j + 6380.34453270   k [km]
#
# one gets:
#
#   r_tod = 5094.51620300   i + 6127.36527840   j + 6380.34453270   k [km]
#
################################################################################

@testset "Function rECEFtoECI PEF => TOD" begin
    JD_UTC = DatetoJD(2004, 4, 6, 7, 51, 28.386009)
    r_pef  = [-1033.47503130; 7901.30558560; 6380.34453270]

    D_TOD_PEF = rECEFtoECI(PEF(), TOD(), JD_UTC, eop_iau1980)
    r_tod = D_TOD_PEF*r_pef

    @test r_tod[1] ≈ +5094.51620300 atol=3e-4
    @test r_tod[2] ≈ +6127.36527840 atol=3e-4
    @test r_tod[3] ≈ +6380.34453270 atol=3e-4

    q_TOD_PEF = rECEFtoECI(Quaternion, PEF(), TOD(), JD_UTC, eop_iau1980)
    r_tod = vect(conj(q_TOD_PEF)*r_pef*q_TOD_PEF)

    @test r_tod[1] ≈ +5094.51620300 atol=3e-4
    @test r_tod[2] ≈ +6127.36527840 atol=3e-4
    @test r_tod[3] ≈ +6380.34453270 atol=3e-4

    D_TOD_PEF = rECEFtoECI(PEF(), TOD(), JD_UTC, eop_iau1980)
    r_tod = D_TOD_PEF*r_pef

    @test r_tod[1] ≈ +5094.51620300 atol=3e-4
    @test r_tod[2] ≈ +6127.36527840 atol=3e-4
    @test r_tod[3] ≈ +6380.34453270 atol=3e-4

    q_TOD_PEF = rECEFtoECI(Quaternion, PEF(), TOD(), JD_UTC, eop_iau1980)
    r_tod = vect(conj(q_TOD_PEF)*r_pef*q_TOD_PEF)

    @test r_tod[1] ≈ +5094.51620300 atol=3e-4
    @test r_tod[2] ≈ +6127.36527840 atol=3e-4
    @test r_tod[3] ≈ +6380.34453270 atol=3e-4
end

## PEF to MOD
## ==========

################################################################################
#                                 Test Results
################################################################################
#
# Scenario 01
# ===========
#
# Example 3-15: Performing IAU-76/FK5 reduction.
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_pef  = -1033.47503130   i + 7901.30558560   j + 6380.34453270   k [km]
#
# one gets:
#
#   r_mod = 5094.02837450   i + 6127.87081640   j + 6380.24851640   k [km]
#
################################################################################

@testset "Function rECEFtoECI PEF => MOD" begin
    JD_UTC = DatetoJD(2004, 4, 6, 7, 51, 28.386009)
    r_pef  = [-1033.47503130; 7901.30558560; 6380.34453270]

    D_MOD_PEF = rECEFtoECI(PEF(), MOD(), JD_UTC, eop_iau1980)
    r_mod = D_MOD_PEF*r_pef

    @test r_mod[1] ≈ +5094.02837450 atol=3e-4
    @test r_mod[2] ≈ +6127.87081640 atol=3e-4
    @test r_mod[3] ≈ +6380.24851640 atol=3e-4

    q_MOD_PEF = rECEFtoECI(Quaternion, PEF(), MOD(), JD_UTC, eop_iau1980)
    r_mod = vect(conj(q_MOD_PEF)*r_pef*q_MOD_PEF)

    @test r_mod[1] ≈ +5094.02837450 atol=3e-4
    @test r_mod[2] ≈ +6127.87081640 atol=3e-4
    @test r_mod[3] ≈ +6380.24851640 atol=3e-4

    D_MOD_PEF = rECEFtoECI(PEF(), MOD(), JD_UTC, eop_iau1980)
    r_mod = D_MOD_PEF*r_pef

    @test r_mod[1] ≈ +5094.02837450 atol=3e-4
    @test r_mod[2] ≈ +6127.87081640 atol=3e-4
    @test r_mod[3] ≈ +6380.24851640 atol=3e-4

    q_MOD_PEF = rECEFtoECI(Quaternion, PEF(), MOD(), JD_UTC, eop_iau1980)
    r_mod = vect(conj(q_MOD_PEF)*r_pef*q_MOD_PEF)

    @test r_mod[1] ≈ +5094.02837450 atol=3e-4
    @test r_mod[2] ≈ +6127.87081640 atol=3e-4
    @test r_mod[3] ≈ +6380.24851640 atol=3e-4
end

## PEF to TEME
## ===========

################################################################################
#                                 Test Results
################################################################################
#
# Scenario 01
# ===========
#
# Example 3-15: Performing IAU-76/FK5 reduction.
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_pef  = -1033.47503130   i + 7901.30558560   j + 6380.34453270   k [km]
#
# one gets:
#
#   r_teme = 5094.18016210   i + 6127.64465950   j + 6380.34453270   k [km]
#
################################################################################

@testset "Function rECEFtoECI PEF => TEME" begin
    JD_UTC = DatetoJD(2004, 4, 6, 7, 51, 28.386009)
    r_pef  = [-1033.47503130; 7901.30558560; 6380.34453270]

    D_TEME_PEF = rECEFtoECI(PEF(), TEME(), JD_UTC, eop_iau1980)
    r_teme = D_TEME_PEF*r_pef

    @test r_teme[1] ≈ +5094.18016210 atol=3e-4
    @test r_teme[2] ≈ +6127.64465950 atol=3e-4
    @test r_teme[3] ≈ +6380.34453270 atol=3e-4

    q_TEME_PEF = rECEFtoECI(Quaternion, PEF(), TEME(), JD_UTC, eop_iau1980)
    r_teme = vect(conj(q_TEME_PEF)*r_pef*q_TEME_PEF)

    @test r_teme[1] ≈ +5094.18016210 atol=3e-4
    @test r_teme[2] ≈ +6127.64465950 atol=3e-4
    @test r_teme[3] ≈ +6380.34453270 atol=3e-4

    D_TEME_PEF = rECEFtoECI(PEF(), TEME(), JD_UTC, eop_iau1980)
    r_teme = D_TEME_PEF*r_pef

    @test r_teme[1] ≈ +5094.18016210 atol=3e-4
    @test r_teme[2] ≈ +6127.64465950 atol=3e-4
    @test r_teme[3] ≈ +6380.34453270 atol=3e-4

    q_TEME_PEF = rECEFtoECI(Quaternion, PEF(), TEME(), JD_UTC, eop_iau1980)
    r_teme = vect(conj(q_TEME_PEF)*r_pef*q_TEME_PEF)

    @test r_teme[1] ≈ +5094.18016210 atol=3e-4
    @test r_teme[2] ≈ +6127.64465950 atol=3e-4
    @test r_teme[3] ≈ +6380.34453270 atol=3e-4
end

################################################################################
#                                IAU-2006/2010
################################################################################

## ITRF => CIRS
## ============

################################################################################
#                                 Test Results
################################################################################
#
# Scenario 01
# ===========
#
# Example 3-14: Performing an IAU-2000 reduction [1, p. 220]
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_itrf = -1033.4793830    i + 7901.2952754    j + 6380.3565958    k [km]
#
# one gets:
#
#   r_cirs = -5100.01840470   i + 6122.78636480   j + 6380.34453270   k [km]
#
################################################################################

@testset "Function rECEFtoECI ITRF => CIRS" begin
    JD_UTC = DatetoJD(2004, 4, 6, 7, 51, 28.386009)
    r_itrf = [-1033.4793830; 7901.2952754; 6380.3565958]

    D_CIRS_ITRF = rECEFtoECI(ITRF(), CIRS(), JD_UTC, eop_iau2000a)
    r_cirs = D_CIRS_ITRF*r_itrf

    @test r_cirs[1] ≈ +5100.01840470 atol=3e-4
    @test r_cirs[2] ≈ +6122.78636480 atol=3e-4
    @test r_cirs[3] ≈ +6380.34453270 atol=3e-4

    q_CIRS_ITRF = rECEFtoECI(Quaternion, ITRF(), CIRS(), JD_UTC, eop_iau2000a)
    r_cirs = vect(q_CIRS_ITRF\r_itrf*q_CIRS_ITRF)

    @test r_cirs[1] ≈ +5100.01840470 atol=3e-4
    @test r_cirs[2] ≈ +6122.78636480 atol=3e-4
    @test r_cirs[3] ≈ +6380.34453270 atol=3e-4
end

## ITRF => GCRF
## ============

################################################################################
#                                 Test Results
################################################################################
#
# Scenario 01
# ===========
#
# Example 3-14: Performing an IAU-2000 reduction [1, p. 220]
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_itrf = -1033.4793830    i + 7901.2952754    j + 6380.3565958    k [km]
#
# one gets:
#
#   r_gcrf = 5102.50895290  i + 6123.01139910 j + 6378.13693380 k [km]
#
################################################################################

@testset "Function rECEFtoECI ITRF => GCRF" begin
    JD_UTC = DatetoJD(2004, 4, 6, 7, 51, 28.386009)
    r_itrf = [-1033.4793830; 7901.2952754; 6380.3565958]

    D_GCRF_ITRF = rECEFtoECI(ITRF(), GCRF(), JD_UTC, eop_iau2000a)
    r_gcrf = D_GCRF_ITRF*r_itrf

    @test r_gcrf[1] ≈ +5102.50895290 atol=3e-4
    @test r_gcrf[2] ≈ +6123.01139910 atol=3e-4
    @test r_gcrf[3] ≈ +6378.13693380 atol=3e-4

    q_GCRF_ITRF = rECEFtoECI(Quaternion, ITRF(), GCRF(), JD_UTC, eop_iau2000a)
    r_gcrf = vect(q_GCRF_ITRF\r_itrf*q_GCRF_ITRF)

    @test r_gcrf[1] ≈ +5102.50895290 atol=3e-4
    @test r_gcrf[2] ≈ +6123.01139910 atol=3e-4
    @test r_gcrf[3] ≈ +6378.13693380 atol=3e-4
end

## TIRS => CIRS
## ============

################################################################################
#                                 Test Results
################################################################################
#
# Scenario 01
# ===========
#
# Example 3-14: Performing an IAU-2000 reduction [1, p. 220]
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_tirs = -1033.47503120   i + 7901.30558560   j + 6380.34453270   k [km]
#
# one gets:
#
#   r_cirs = -5100.01840470   i + 6122.78636480   j + 6380.34453270   k [km]
#
################################################################################

@testset "Function rECEFtoECI TIRS => CIRS" begin
    JD_UTC = DatetoJD(2004, 4, 6, 7, 51, 28.386009)
    r_tirs = [-1033.47503120; 7901.30558560; 6380.34453270]

    D_CIRS_TIRS = rECEFtoECI(TIRS(), CIRS(), JD_UTC, eop_iau2000a)
    r_cirs = D_CIRS_TIRS*r_tirs

    @test r_cirs[1] ≈ +5100.01840470 atol=3e-4
    @test r_cirs[2] ≈ +6122.78636480 atol=3e-4
    @test r_cirs[3] ≈ +6380.34453270 atol=3e-4

    q_CIRS_TIRS = rECEFtoECI(Quaternion, TIRS(), CIRS(), JD_UTC, eop_iau2000a)
    r_cirs = vect(q_CIRS_TIRS\r_tirs*q_CIRS_TIRS)

    @test r_cirs[1] ≈ +5100.01840470 atol=3e-4
    @test r_cirs[2] ≈ +6122.78636480 atol=3e-4
    @test r_cirs[3] ≈ +6380.34453270 atol=3e-4
end

## TIRS => GCRF
## ============

################################################################################
#                                 Test Results
################################################################################
#
# Scenario 01
# ===========
#
# Example 3-14: Performing an IAU-2000 reduction [1, p. 220]
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_tirs = -1033.47503120   i + 7901.30558560   j + 6380.34453270   k [km]
#
# one gets:
#
#   r_gcrf = 5102.50895290  i + 6123.01139910 j + 6378.13693380 k [km]
#
################################################################################

@testset "Function rECEFtoECI TIRS => GCRF" begin
    JD_UTC = DatetoJD(2004, 4, 6, 7, 51, 28.386009)
    r_tirs = [-1033.47503120; 7901.30558560; 6380.34453270]

    D_GCRF_TIRS = rECEFtoECI(TIRS(), GCRF(), JD_UTC, eop_iau2000a)
    r_gcrf = D_GCRF_TIRS*r_tirs

    @test r_gcrf[1] ≈ +5102.50895290 atol=3e-4
    @test r_gcrf[2] ≈ +6123.01139910 atol=3e-4
    @test r_gcrf[3] ≈ +6378.13693380 atol=3e-4

    q_GCRF_TIRS = rECEFtoECI(Quaternion, TIRS(), GCRF(), JD_UTC, eop_iau2000a)
    r_gcrf = vect(q_GCRF_TIRS\r_tirs*q_GCRF_TIRS)

    @test r_gcrf[1] ≈ +5102.50895290 atol=3e-4
    @test r_gcrf[2] ≈ +6123.01139910 atol=3e-4
    @test r_gcrf[3] ≈ +6378.13693380 atol=3e-4
end
