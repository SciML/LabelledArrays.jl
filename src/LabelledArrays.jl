module LabelledArrays

using LinearAlgebra, StaticArrays

include("slarray.jl")
include("larray.jl")
include("slsliced.jl")
include("lsliced.jl")

export SLArray, LArray, @SLVector, @LArray, @LVector, @SLArray

export SLSlicedMatrix, LSlicedMatrix, @LSlicedMatrix, @SLSlicedMatrix

end # module
