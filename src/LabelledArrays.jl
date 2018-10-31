module LabelledArrays

using LinearAlgebra
using Reexport

@reexport using StaticArrays

include("lvector.jl")

export LVector, @SLVector, @LVector

end # module
