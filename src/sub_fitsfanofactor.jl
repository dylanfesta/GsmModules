
module FitsFanoFactor
using Statistics, StatsBase
"""
Assuming the data comes from a Poisson
process, computes the error over the
variance (the var itself is equal to the mean)
"""
function poisson_var_error(data::Vector{<:Real})
    n=length(data)
    n==0 && return 0.0
    nu=mean(data)
    nu == 0.0 && return 0.0

    mu2 = nu
    mu4 = nu*(1+3nu)
    _var = ((n-1)^2 * mu4 - (n-1)*(n-3)*mu2^2)/ n^3
    if _var < 0
        warn("Something wrong in calculating the error!")
    end
    sqrt(abs(_var))
end

"""
Returns Fano factor of data
and associated error (by propagation)
"""
function fano_factor_err(data::Vector{<:Real})
    n = length(data)
    mu=mean(data)
    mu == 0.0 && return (0.,0.)
    @assert mu > 0

    sigm2=var(data)
    Δmu = sqrt(sigm2/n)
    Δsigm2 = poisson_var_error(data)
    ff = sigm2/mu
    Δff = sqrt(  (Δsigm2)^2 / mu^2 + (Δmu)^2*sigm2^2/mu^4 )
    (ff,Δff)
end
function fano_factor_err(data::Matrix{<:Real})
    out = mapslices(data;dims=1) do v
        fano_factor_err(v)
    end
    [o[1] for o in out][:], [o[2] for o in out][:]
end
function fano_factor_err(data::Vector{V}) where V<:Vector{<:Real}
    fano_factor_err(hcat(data...))
end

function weighted_dumb_linear_regression(x::V,y::V,w::V) where V<:Vector{<:Real}
    n = length(x)
    @assert n == length(y) == length(w)
    @assert all(w.>0)
    sqw = sqrt.(w)
    _x = x .* sqw
    _y = y .* sqw
    coef = mean( _x .* _y ) / mean( _x .* _x )
    s_err = let
        err = _y .- (coef .* _x)
        mom = sum( (_x .- mean(_x)).^2 )
        sqrt(sum(err.^2)/(n-2)/mom)
    end
    coef,s_err
end

# spike counts are necessary to compute the error!
function fano_factor_population(spike_counts::Vector{V};useweights=true) where V<:Vector{<:Real}
    x = mean.(spike_counts)
    y = var.(spike_counts)
    weights = if !useweights
        fill!(similar(x),1.0)
        else
        inv.(poisson_var_error.(spike_counts))
    end
    # cut weights that are too high. It probably refers to bad data
    wcut = quantile(weights,0.95)
    map!(ww->min(ww,wcut), weights, weights)
    regr = weighted_dumb_linear_regression(x,y,weights)
    (regr... , x, y)
end

# """
#  fano_fact, confidence_interval, means, vars  = population_fano_factor(spike_counts::Vector{Vector{Number}})
# """
# function population_fano_factor(spike_counts::Vector{Vector{T}};useweights=true) where T<:Real
#     n_neurons=length(spike_counts)
#     x = Vector{Float64}(n_neurons)
#     y = Vector{Float64}(n_neurons)
#     weights =  Vector{Float64}(n_neurons)
#     for (i,spks) in enumerate(spike_counts)
#         x[i]=mean(spks)
#         y[i]=var(spks)
#         if useweights
#             err = poisson_var_error(spks)
#             weights[i]=1/err
#         else
#             weights[i]=1.0
#         end
#     end
#     # cut weights that are too high. It probably refers to bad data
#     wcut = quantile(weights,0.9)
#     map!(ww->min(ww,wcut), weights, weights)
#
#     dat=DataFrame(x=x,y=y,weights=weights)
#     regr = weighted_linear_regr(dat)
#     (regr... , x, y)
# end
#


end # of module
