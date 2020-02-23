#== # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   International Geomagnetic Field Model.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# References
#
#   [1] https://www.ngdc.noaa.gov/IAGA/vmod/igrf.html
#   [2] https://www.ngdc.noaa.gov/IAGA/vmod/igrf12.f
#   [3] https://www.mathworks.com/matlabcentral/fileexchange/34388-international-geomagnetic-reference-field--igrf--model
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # ==#

export igrf

################################################################################
#                                  Functions
################################################################################

"""
    igrf(date::Number, r::Number, λ::Number, Ω::Number, T; show_warns = true)

**IGRF Model**

*Current version: v12*

Compute the geomagnetic field vector [nT] at the date `date` [Year A.D.] and
position (`r`, `λ`, `Ω`).

The position representation is defined by `T`. If `T` is `Val(:geocentric)`,
then the input must be **geocentric** coordinates:

1. Distance from the Earth center `r` [m];
1. Geocentric latitude `λ` (-π/2, +π/2) \\[rad]; and
2. Geocentric longitude `Ω` (-π, +π) \\[rad].

If `T` is `Val(:geodetic)`, then the input must be **geodetic** coordinates:

1 Altitude above the reference ellipsoid `h` (WGS-84) \\[m];
2. Geodetic latitude `λ` (-π/2, +π/2) \\[rad]; and
3. Geodetic longitude `Ω` (-π, +π) \\[rad].

If `T` is omitted, then it defaults to `Val(:geocentric)`.

Notice that the output vector will be represented in the same reference system
selected by the parameter `T` (geocentric or geodetic). The Y-axis of the output
reference system always points East. In case of **geocentric coordinates**, the
Z-axis points toward the center of Earth and the X-axis completes a right-handed
coordinate system. In case of **geodetic coordinates**, the X-axis is tangent to
the ellipsoid at the selected location and points toward North, whereas the
Z-axis completes a right-hand coordinate system.

# Keywords

* `show_warns`: Show warnings about the data (**Default** = `true`).

# Remarks

The `date` must be greater or equal to 1900 and less than or equal 2025. Notice
that a warning message is printed for dates greater than 2020.

# Disclaimer

This function is an independent implementation of the IGRF model. It contains a
more readable code than the original one in FORTRAN, because it uses features
available in Julia language.

"""
igrf(date::Number, r::Number, λ::Number, Ω::Number; show_warns = true) =
    igrf(date, r, λ, Ω, Val(:geocentric); show_warns = show_warns)

function igrf(date::Number, r::Number, λ::Number, Ω::Number, ::Val{:geocentric};
              show_warns::Bool = true)

    # Input verification
    # ==================

    # Check the data, since this model is valid for years between 1900 and 2025.
    ( (date < 1900) || (date > 2025) ) &&
    error("This IGRF version will not work for years outside the interval [1900, 2025).")

    # Check if the latitude and longitude are valid.
    ( (λ < -pi/2) || (λ > pi/2) ) &&
    error("The latitude must be between -π/2 and +π/2 rad.")

    ( (Ω < -pi) || (Ω > pi) ) &&
    error("The longitude must be between -π and +π rad.")

    # Warn the user that for dates after the year 2020 the accuracy maybe
    # reduced.
    show_warns && (date > 2020) &&
    @warn("The magnetic field computed with this IGRF version may be of reduced accuracy for years greater than 2020.")

    # Input variables conversion
    # ==========================

    # Convert latitude / longitude to colatitude and east-longitude.
    θ = pi/2 - λ
    ϕ = (Ω >= 0) ? Ω : 2pi + Ω

    # The input variable `r` is in [m], but all the algorithm requires it to be
    # in [km].
    r /= 1000

    # Preliminary setup
    # =================

    # Compute the epoch that will be used to obtain the coefficients. This is
    # necessary because the IGRF provides coefficients every 5 years. Between
    # two epochs, those coefficients must be interpolated.
    idx   = (date < 2020) ? floor(Int, (date-1900)*0.2+1) : 24
    epoch = 1900 + (idx-1)*5

    # Compute the fraction of time from the epoch of the coefficient selected by
    # `idx`.
    Δt = date - epoch

    # Compute the maximum spherical harmonic degree for the selected date.
    n_max = (epoch < 1995) ? 10 : 13

    # Compute the Schmidt quasi-normalized associated Legendre functions and
    # their first order derivative, neglecting the phase term.
    dP, P = dlegendre(Val(:schmidt), θ, n_max, n_max, false)

    # Parameters and auxiliary variables
    # ==================================

    # Auxiliary variables to select the IGRF coefficients.
    H = H_igrf
    G = G_igrf

    # Reference radius [km].
    a = 6371.2

    # Auxiliary variables to decrease the computational burden.
    sin_ϕ,  cos_ϕ  = sincos(1ϕ)
    sin_2ϕ, cos_2ϕ = sincos(2ϕ)
    ratio   = a/r
    fact    = ratio

    # Initialization of variables
    # ===========================

    dVr = 0.0   # Derivative of the Geomagnetic potential w.r.t. r.
    dVθ = 0.0   # Derivative of the Geomagnetic potential w.r.t. θ.
    dVϕ = 0.0   # Derivative of the Geomagnetic potential w.r.t. ϕ.
    ΔG  = 0.0   # Auxiliary variable to interpolate the G coefficients.
    ΔH  = 0.0   # Auxiliary variable to interpolate the H coefficients.
    kg  = 1     # Index to obtain the values of the matrix `G`.
    kh  = 1     # Index to obtain the values of the matrix `H`.

    # Geomagnetic potential
    # =====================

    @inbounds for n = 1:n_max
        aux_dVr = 0.0
        aux_dVθ = 0.0
        aux_dVϕ = 0.0

        # Compute the contributions when `m = 0`
        # ======================================

        # Get the coefficients in the epoch and interpolate to the desired
        # time.
        Gnm_e0 = G[kg,idx+2]

        if date < 2015
            Gnm_e1 = G[kg,idx+3]
            ΔG     = (Gnm_e1-Gnm_e0)/5
        else
            ΔG     = G[kg,27]
        end

        Gnm  = Gnm_e0 + ΔG*Δt
        kg  += 1

        aux_dVr += -(n+1)/r*Gnm*P[n+1,1]
        aux_dVθ += Gnm*dP[n+1,1]

        # Sine and cosine with m = 1
        # ==========================
        #
        # This values will be used to update recursively `sin(m*ϕ)` and
        # `cos(m*ϕ)`, reducing the computational burden.
        sin_mϕ   = +sin_ϕ    # sin( 1*λ_gc)
        sin_m_1ϕ = 0.0       # sin( 0*λ_gc)
        sin_m_2ϕ = -sin_ϕ    # sin(-1*λ_gc)
        cos_mϕ   = +cos_ϕ    # cos( 1*λ_gc)
        cos_m_1ϕ = 1.0       # cos( 0*λ_gc)
        cos_m_2ϕ = +cos_ϕ    # cos(-2*λ_gc)

        # Other auxiliary variables that depend only on `n`
        # =================================================

        fact_dVr = (n+1)/r

        # Compute the contributions when `m ∈ [1,n]`
        # ==========================================

        for m = 1:n
            # Compute recursively `sin(m*ϕ)` and `cos(m*ϕ)`.
            sin_mϕ = 2cos_ϕ*sin_m_1ϕ-sin_m_2ϕ
            cos_mϕ = 2cos_ϕ*cos_m_1ϕ-cos_m_2ϕ

            # Compute the coefficients `G_nm` and `H_nm`
            # ==========================================

            # Get the coefficients in the epoch and interpolate to the
            # desired time.
            Gnm_e0 = G[kg,idx+2]
            Hnm_e0 = H[kh,idx+2]

            if date < 2015
                Gnm_e1 = G[kg,idx+3]
                Hnm_e1 = H[kh,idx+3]
                ΔG     = (Gnm_e1-Gnm_e0)/5
                ΔH     = (Hnm_e1-Hnm_e0)/5
            else
                ΔG     = G[kg,27]
                ΔH     = H[kh,27]
            end

            Gnm    = Gnm_e0 + ΔG*Δt
            Hnm    = Hnm_e0 + ΔH*Δt
            kg    += 1
            kh    += 1

            GcHs_nm = Gnm*cos_mϕ + Hnm*sin_mϕ
            GsHc_nm = Gnm*sin_mϕ - Hnm*cos_mϕ

            # Compute the contributions for `m`
            # =================================

            aux_dVr += -fact_dVr*GcHs_nm*P[n+1,m+1]
            aux_dVθ += GcHs_nm*dP[n+1,m+1]
            aux_dVϕ += (θ == 0) ? -m*GsHc_nm*dP[n+1,m+1] : -m*GsHc_nm*P[n+1,m+1]

            # Update the values for the next step
            # ===================================

            sin_m_2ϕ = sin_m_1ϕ
            sin_m_1ϕ = sin_mϕ
            cos_m_2ϕ = cos_m_1ϕ
            cos_m_1ϕ = cos_mϕ
        end

        # Perform final computations related to the summation in `n`
        # ==========================================================

        # fact = (a/r)^(n+1)
        fact    *= ratio

        # aux_<> *= (a/r)^(n+1)
        aux_dVr *= fact
        aux_dVϕ *= fact
        aux_dVθ *= fact

        dVr += aux_dVr
        dVϕ += aux_dVϕ
        dVθ += aux_dVθ
    end

    dVr *= a
    dVϕ *= a
    dVθ *= a

    # Compute the Geomagnetic field vector in the geocentric reference frame
    # ======================================================================

    x = +1/r*dVθ
    y = (θ == 0) ? -1/r*dVϕ : -1/(r*sin(θ))*dVϕ
    z = dVr

    B_gc = SVector{3,Float64}(x,y,z)
end

function igrf(date::Number, h::Number, λ::Number, Ω::Number, ::Val{:geodetic};
              show_warns = true)

    # TODO: This method has a small error (≈ 0.01 nT) compared with the
    # `igrf12syn`.  However, the result is exactly the same as the MATLAB
    # function in [3]. Hence, this does not seem to be an error in the
    # conversion from geodetic to geocentric coordinates. This is probably
    # caused by a numerical error. Further verification is necessary.

    # Convert the geodetic coordinates to geocentric coordinates.
    (λ_gc, r) = GeodetictoGeocentric(λ, h)

    # Compute the geomagnetic field in geocentric coordinates.
    B_gc = igrf(date, r, λ_gc, Ω, Val(:geocentric); show_warns = show_warns)

    # Convert to geodetic coordinates.
    D_gd_gc = create_rotation_matrix(λ_gc - λ,:Y)
    B_gd    = D_gd_gc*B_gc
end
