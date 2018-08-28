
using Revise
using GsmModules
const F = GsmModules.FitRFCenters
using Statistics, StatsBase , LinearAlgebra
using Random, Distributions

##
# make some data, make sure the cost is small for ground truth
xc = 1.
yc = -1.
gain=2.
offset = 0.5
width = 0.1

xs,ys,zs = let
    xsg = LinRange(0,2,200)
    ysg = LinRange(0,-2,200)
    _xs = rand(xsg,200)
    _ys = rand(ysg,200)
    _zs = F.response_distribution.(_xs,_ys,offset,xc,yc,gain,width)
    (_xs,_ys,_zs)
end

_cost_test = F.get_cost_fun(xs,ys,zs)

_grad_test = fill(NaN,5)
_cost_test([0.5, 1,-1,2.,0.1 ] , _grad_test)

_grad_test

##
using Plots
scatter(xs,ys,zs)

##
# fit it!

guess = [0.5, 1,-1,2.,0.3 ]
whatevs = F.fit_receptive_field(xs,ys,zs, guess, 0.01 )
