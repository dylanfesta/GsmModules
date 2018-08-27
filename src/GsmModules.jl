module GsmModules

include("./sub_readdatastuff.jl")  # module ReadDataStuff

include("./sub_fitsfanofactor.jl") # fits for the Fano Factors

include("./sub_fit_dogs.jl")

include("./sub_fit_rf_centers.jl")

end # module GsmModules
