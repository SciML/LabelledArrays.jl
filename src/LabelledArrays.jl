module LabelledArrays

using Reexport, LinearAlgebra
@reexport using StaticArrays

include("slvector.jl")
include("lvector.jl")

export SLVector, LVector, @SLVector, @LVector

end # module
