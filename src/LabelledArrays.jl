module LabelledArrays

using StaticArrays, LinearAlgebra

include("slvector.jl")
include("lvector.jl")

export SLVector, LVector, @SLVector, @LVector

end # module
