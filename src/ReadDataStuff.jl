
module ReadDataStuff
export  list_matfiles, list_matfile_content,read_matfile_variable, matlab_to_dataframe
using MAT , DataFrames, CategoricalArrays

global dir_read = "./"

function set_dir(newdir)
    println("setting files directory to $newdir")
    global dir_read = newdir
end

function list_matfiles()
    matfiles=readdir(dir_read)
    filter!(s->ismatch(r".mat\b",s),matfiles)
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

"""
function add_neuron_abs_idx(dataframe,fields_abs ; neuron_idx_start=0 , is_compact=true)
accepts a single dataframe
field_abs is an array of fields. Every unuique combination has a separate
absolute index.
returns a new dataframe, where the neuron column is replaced with unique indexes
the old neurons are stored in neuron_old
"""
function add_absolute_index!(dataframe,fields_absolute,new_field ; idx_start=0)
    df = dataframe
    df_uni = unique(df[fields_absolute])
    idx_absolute = collect(1:nrow(df_uni)) .+ idx_start
    same_name = new_field in names(dataframe)
    _new_field = same_name ? :temp : new_field
    if is_compact
        df_uni[_new_field] = CategoricalArray(idx_absolute) |> compress
    else
        df_uni[_new_field] = idx_absolute
    end
    df_out = join(df,df_uni, on=fields_abs,kind=:inner)
    if same_name
        _name = Symbol(new_field,"_old")
        rename!(df_out, new_field=>_name, :temp=>new_field)
    end
    df_out
end


# the rate function returns missing when we do not want to save
# the value (so for binned spikes both 0 and NaN should be missing!)
function matlab_matrix_to_dataframe(mat_matrix,mat_fields,
        value_fun ;verbose=true , value_type=Float64)
    #some controls
    field_names=keys(mat_fields)
    field_vects = values(mat_fields)
    @assert ( length(field_names)-1) == length(field_vects) == ndims(mat_matrix)
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
    cols_fields = [ Vector{eltype(v)}(n) for v in field_vects ]
    col_value = Vector{value_type}(n)
    v_fill=0
    for i in eachindex(vals)
        val = vals[i]
        if !ismissing(val)
            v_fill += 1
            col_value[v_fill]=val
            inds = ind2sub(mat_matrix,i)
            for (field,k) in enumerate(inds)
                cols_fields[field][v_fill] = field_vects[field][k]
            end
            if verbose && (v_fill%10_000 == 0 )
                println(" $(v_fill) out of $n rows completed ")
            end
        end
    end
    verbose && println("Building the dataframe ... ")
    df=DataFrame()
    for (col,field) in zip(cols_fields,field_names)
        df[field]= compress(CategoricalVector(col))
    end
    df[field_names[end]]=col_value
    df
end

end # of module ReadDataStuff
