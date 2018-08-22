using Revise
using GsmModules
FF = GsmModules.FitsFanoFactor

using Distributions, Random

x_data=rand(Uniform(0,10),100)

noise_data = 10.0 .* randn(length(x_data))

y_data = @. 20.0x_data  + noise_data

w_data = abs.(randn(length(x_data)))

coef, err = FF.weighted_dumb_linear_regr(x_data,y_data,w_data)

using Plots; gr() ; plot()
x_plot=0:0.01:maximum(x_data)
scatter(x_data,y_data)
plot!(x_plot, coef*x_plot, leg=false)

plot!(x_plot, (coef+err)*x_plot, leg=false)
plot!(x_plot, (coef-err)*x_plot, leg=false)
