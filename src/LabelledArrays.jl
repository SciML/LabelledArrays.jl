__precompile__()

module LabelledArrays

using StaticArrays, Juno

function symbol_to_index(names, s::Symbol)
    findfirst((t)->s==t,names)
end
Base.@pure function symbol_to_index(names::SArray, s::Symbol)
    findfirst((t)->s==t,names)
end

#=
Base.@pure function symbol_to_index(names, s::Symbol)
    i = 0
    for n in names
        i += 1
        n == s && return i
    end
    return error("Label not valid")
end
=#

include("slvectors.jl")
include("lmarrays.jl")
include("larrays.jl")

export SLVector, LMArray, LArray, @SLVector, @LMVector

end # module
