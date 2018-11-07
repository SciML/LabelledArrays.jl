module LabelledArrays

using Reexport, LinearAlgebra
@reexport using StaticArrays

include("slarray.jl")
include("larray.jl")

export SLArray, LArray, @SLVector, @LArray, @LVector

end # module
