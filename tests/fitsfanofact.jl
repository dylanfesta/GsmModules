using Revise
using GsmModules
FF = GsmModules.FitsFanoFactor

using Distributions, Random

x_data=rand(Uniform(0,10),100)

noise_data = 3 .* x_data .* randn(length(x_data))

y_data = @. 20.0x_data  + noise_data

scatter(x_data,y_data)
w_data = fill!(similar(x_data),1.0)


coef, err = FF.weighted_dumb_linear_regression(x_data,y_data,w_data)

using Plots; gr() ; plot()
x_plot=0:0.01:maximum(x_data)
scatter(x_data,y_data)
plot!(x_plot, coef*x_plot, leg=false)


w_data = inv.(x_data.^2)
coef, err = FF.weighted_dumb_linear_regression(x_data,y_data,w_data)
scatter(x_data,y_data)
plot!(x_plot, coef*x_plot, leg=false)


plot!(x_plot, (coef+err)*x_plot, leg=false)
plot!(x_plot, (coef-err)*x_plot, leg=false)

##

function non_lin(x,a,b,xl)
    x < xl ? a*x : a*x + b*(x-xl)^2
end
x_data=rand(Uniform(0,10),100)
noise_data = 1.0 .* x_data .* randn(length(x_data))

y_data = map(x->non_lin(x,3.,2.,5),x_data) + noise_data

scatter(x_data,y_data)

w_bad = fill(1.12343,length(x_data))
coef, err = FF.weighted_dumb_linear_regression(x_data,y_data,w_bad)
scatter(x_data,y_data)
plot!(x_plot, coef*x_plot, leg=false)

w_better = map( x-> x > 5 ? 0.0001 : 1.2 , x_data )
coef, err = FF.weighted_dumb_linear_regression(x_data,y_data,w_better)
scatter(x_data,y_data)
plot!(x_plot, coef*x_plot, leg=false)
