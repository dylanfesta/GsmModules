
module FitRFCenters
using Distributions, NLopt, ForwardDiff


function response_distribution(x,y,offset,xc,yc,gain,width)
    sqr_d = (x-xc)^2 + (y - yc)^2
    offset + gain * exp(-sqr_d/width) # meh, forget normalization
end

function square_error(xs,ys,zs, offset,xc,yc,gain,width)
    rd(x,y) = response_distribution(x,y,offset,xc,yc,gain,width)
    out = broadcast( (x,y,z) -> (z - rd(x,y))^2 , xs,ys,zs)
    mean(out)
end

function get_cost_fun(x_data,y_data,z_data)
    function _cost(p::Vector)
        offset,xc,yc,gain,width = p
        square_error(x_data,y_data,z_data, offset,xc,yc,gain,width)
    end
    function _cost(p::Vector, g::Vector)
        obj=_cost(p)
        if length(g) > 0
            ForwardDiff.gradient!(g,_cost,p)
        end
        obj
    end
    _cost
end

function fit_receptive_field(x_data,y_data,z_data,guess, min_width::Float64)

    objective_fun = get_cost_fun(x_data,y_data,z_data)
    # minimum width
    function constraint1(p::Vector,g::Vector)
        width=p[5]
        cst = min_width - p
        if length(g) > 0
            g .= [0,0,0,0,-1.]
        end
        cst
    end
    #positive offset
    function constraint2(p::Vector,g::Vector)
        offset=p[1]
        cst = 0.001 - offset
        if length(g) > 0
            g .= [-1.,0,0,0,0.]
        end
        cst
    end

    opt = Opt(:LD_MMA,5)
    lower_bounds!(opt,[0.001, -Inf, -Inf, 0.0 , min_width])
    xtol_rel!(opt,1E-4)

    min_objective!(opt,objective_fun)
    # inequality_constraint!(opt,constraint1,1E-8)
    # inequality_constraint!(opt,constraint2,1E-8)

    minf,minx,ret = optimize(opt,guess)
end



end # of module
