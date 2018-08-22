
module FitsFanoFactor

"""
Assuming the data comes from a Poisson
process, computes the error over the
variance (the var itself is equal to the mean)
"""
function poisson_var_error(data::Vector{<:AbstractFloat})
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
function fano_factor_err(data::Vector{<:AbstractFloat})
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

function fano_factor_err(data::Matrix{<:AbstractFloat})
    out = mapslices(data;dims=1) do v
        fano_factor_err(v)
    end 
    [o[1] for o in out], [o[2] for o in out]
end


# """
# coef, confidence_interval = weighted_linear_regr(mahdata)
# mahdata is a dataframe with fields x, y and weights
# """
# function weighted_linear_regr(mahdata)
#     o = glm(@formula(y~0+x), mahdata , Normal(), IdentityLink() , wts=mahdata[:weights])
#     coef(o)[1], confint(o)
# end

#
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
