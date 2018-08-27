
using Revise
using GsmModules
const F = GsmModules.FitRFCenters
using Statistics, StatsBase , LinearAlgebra
using Random, Distributions

using Plots
##
_ = let
    xs = LinRange(0,2,200)
    ys = LinRange(0,-2,200)
    xc = 1.
    yc = -1.
    gain=2.
    offset = 0.5
    width = 0.2
    zs = broadcast(F.response_distribution,xs,ys',offset,xc,yc,gain,width)
    @show extrema(zs)
    surface(xs,ys,zs)
end
    
