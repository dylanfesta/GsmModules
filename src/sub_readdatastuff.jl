module ReadDataStuff
export  list_matfiles, list_matfile_content,read_matfile_variable, matlab_matrix_to_dataframe
using MAT , DataFrames, CategoricalArrays

global dir_read = "./"

function set_dir(newdir)
    println("setting files directory to $newdir")
    global dir_read = newdir
end

function list_matfiles()
    matfiles=readdir(dir_read)
    filter!(s->occursin(r".mat\b",s),matfiles)
end

function list_matfile_content(file)
    full_path=joinpath(dir_read,file)
    @assert isfile(full_path) ("File not found in "*(full_path))
    matopen(full_path,"r") do f
        collect(names(f))
    end
end

function read_matfile_variable(file,variable;data_function=nothing)
    full_path=joinpath(dir_read,file)
    @assert isfile(full_path) ("File not found in "*(full_path))
    out = matopen(full_path,"r") do f
        read(f,variable)
    end
    if data_function != nothing
        map(data_function,out)
    else
        out
    end
end


function compress_columns(df)
    df_out=DataFrame()
    for (col,vals) in pairs(df)
        if typeof(vals) <: CategoricalArray
            df_out[col] = compress(vals)
        else
            df_out[col] = vals
        end
    end
    df_out
end


"""
function add_neuron_abs_idx(dataframe,fields_abs ; neuron_idx_start=0 , is_compact=true)
accepts a single dataframe
field_abs is an array of fields. Every unuique combination has a separate
absolute index.
returns a new dataframe, where the neuron column is replaced with unique indexes
the old neurons are stored in neuron_old
"""
function add_absolute_index(dataframe,fields_absolute,new_field ; idx_start=0)
    df = dataframe
    df_uni = unique(df[fields_absolute])
    idx_absolute = collect(1:nrow(df_uni)) .+ idx_start
    same_name = new_field in names(dataframe)
    _new_field = same_name ? :temp : new_field
    df_uni[_new_field] = CategoricalArray(idx_absolute) |> compress
    df_out = join(df,df_uni, on=fields_absolute,kind=:inner)
    if same_name
        _name = Symbol(new_field,"_old")
        rename!(df_out, new_field=>_name, :temp=>new_field)
    end
    df_out
end


# the rate function returns missing when we do not want to save
# the value (so for binned spikes both 0 and NaN should be missing!)
function matlab_matrix_to_dataframe(mat_matrix,mat_fields,value_name,
        value_fun ;verbose=true , value_type=Float64)
    #some controls
    field_names=keys(mat_fields)
    field_vects = values(mat_fields)
    @assert length(field_vects) == ndims(mat_matrix)
    if verbose
        println("Please check this:")
        for (i,d) in enumerate(length.(field_vects))
            println( "Dimension $i has size $d and indicates field ",
              field_names[i])
            @assert size(mat_matrix)[i] == d "... or NOT ?!"
        end
    end
    #preallocate :-3
    vals = value_fun.(mat_matrix)
    n =  sum( .!ismissing.(vals) )
    println("the database will have $n rows", n)
    # prepare  cols
    cols_fields = [ Vector{eltype(v)}(undef,n) for v in field_vects ]
    col_value = Vector{value_type}(undef,n)
    v_fill=0
    for idxs in findall( .!ismissing.(vals) )
        v_fill += 1
        val = vals[idxs]
        col_value[v_fill]=val
        for (field_v,col,k) in zip(field_vects,cols_fields,Tuple(idxs)) # for each dimension, attribute the indexed element to column
            col[v_fill]=field_v[k]
        end
        if verbose && (v_fill%10_000 == 0 )
            println(" $(v_fill) out of $n rows completed ")
        end
    end
    verbose && println("Building the dataframe ... ")
    df=DataFrame()
    for (col,field) in zip(cols_fields,field_names)
        col_compr = if eltype(col) == Bool
                convert(BitArray,col)
            else
                compress(CategoricalVector(col))
            end
        df[field] = col_compr
    end
    df[value_name]=col_value
    df
end

end # of module ReadDataStuff
