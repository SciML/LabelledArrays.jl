module LabelledArrays

using StaticArrays

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

include("slvector.jl")
include("lvector.jl")

export SLVector, LVector, @SLVector, @LVector

end # module
