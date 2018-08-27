#=
Fitting difference of gaussians


=#

module FitDiffOfSigms
using JuMP, Random
using Statistics, StatsBase, Distributions


struct DiffOfSimgs{F}
    baseline::F
    gain_p::F
    steep_p::F
    gain_m::F
    steep_m::F
end

function (sc::DiffOfSimgs)()
    x -> sc.baseline +
        sc.gain_p*tanh(x/sc.steep_p) - sc.gain_m*tanh(x/sc.steep_m)
end

function (scc::DiffOfSimgs)(x::Vector{<:Real})
    broadcast(scc(),x)
end
function (scc::DiffOfSimgs)(x::Vector{<:Real},noise_std)
    noise = rand!(Normal(0.0,noise_std),similar(x))
    scc(x) .+ noise
end

# function make(c::SigmsCurve)
#     (baseline,gain_p,steep_p,gain_m,steep_m) = c.p
#     x -> baseline + gain_p*tanh(x/steep_p) - gain_m*tanh(x/steep_m)
# end
#
# function make(c::SigmsCurve,noise_std)
#     noise_dist = Normal(0.0,noise_std)
#     f_no_noise=make(c)
#     x -> f_no_noise(x) + rand(noise_dist)
# end
#
# function compute(c::SigmsCurve,x_vals::Vector)
#     make(c).(x_vals)
# end
# function compute(c::SigmsCurve,x_vals::Vector,noise_std)
#     noise_dist = Normal(0.0,noise_std)
#     make(c).(x_vals) + rand(noise_dist,length(x_vals))
# end

function find_max(c::DiffOfSimgs)
    f = c()
    df(x)= ForwardDiff.derivative(f,x)
    _max = try
            find_zero(df,[0.7,20])
        catch
            warn("could not find the max of this one!")
            return missing
        end

    # is a min ?
    ismax = f(_max) > f(_max+0.01)
    if ismax
        _max
    else
        warn("this curve has a minimum!")
        missing
    end
end



end #of module
