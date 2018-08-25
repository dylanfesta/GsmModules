using GsmModules
using GsmModules.ReadDataStuff
const RD = GsmModules.ReadDataStuff
using DataFrames,DataFramesMeta
using Test
##

# let's play with dimensions
a = 3
b = 10 
c  = 11
d = 8

matrix_test = Array{NTuple{4,Int64}}(undef,a,b,c,d)

for aa in 1:a ,bb in 1:b , cc in 1:c , dd in 1:d
    tup = (aa,bb,cc,dd)
    matrix_test[tup...]=tup
end


data_values = ( da= collect(1:a) ,
    db = collect(1:b), dc = collect(1:c), dd = collect(1:d) )

data_test = RD.matlab_matrix_to_dataframe( matrix_test, data_values,
    :thingy, identity; value_type=NTuple{4,Int64})

@where(data_test , :da .== 2 , :db .== 8, :dc .== 9, :dd .==1)[1,:thingy]

# seems to work ...

##  try again with missing values !
a = 3
b = 10
c  = 4
d = 8
matrix_test = Array{NTuple{4,Int64}}(undef,a,b,c,d)
for aa in 1:a ,bb in 1:b , cc in 1:c , dd in 1:d
    tup = (aa,bb,cc,dd)
    matrix_test[tup...]=tup
end
using StatsBase
length(matrix_test)
bad_thingies = sample(matrix_test,600;replace=false)

function no_bad(tup)
    if tup in bad_thingies
        missing
    else
        tup
    end
end

data_values = ( da= collect(1:a) ,
    db = collect(1:b), dc = collect(1:c), dd = collect(1:d) )

data_test = RD.matlab_matrix_to_dataframe( matrix_test, data_values,
    :thingy, no_bad; value_type=NTuple{4,Int64})

@test nrow(data_test) + length(bad_thingies) == length(matrix_test)

thingy_test = (2,8,4,5)
thingy_test in bad_thingies
function test_thingy(tt)
    df = @where(data_test , :da .== tt[1] , :db .== tt[2], :dc .== tt[3], :dd .==tt[4])
    isempty(df) ? missing : df[1,:thingy]
end

_ = let
    thingy_test = (2,8,4,4)
    @show thingy_test in bad_thingies
    @show test_thingy(thingy_test)
end

thingy_test = bad_thingies[1]
