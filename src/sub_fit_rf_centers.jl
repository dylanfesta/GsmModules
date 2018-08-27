
module FitRFCenters
using Distributions, JuMP


function response_distribution(x,y,offset,xc,yc,gain,width)
    sqr_d = (x-xc)^2 + (y - yc)^2
    offset + gain * exp(-sqr_d/width) # meh, forget normalization
end



end # of module
