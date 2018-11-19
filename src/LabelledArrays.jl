module LabelledArrays

using LinearAlgebra, StaticArrays

include("slarray.jl")
include("larray.jl")
include("display.jl")

export SLArray, LArray, SLVector, LVector, @SLVector, @LArray, @LVector, @SLArray

end # module
