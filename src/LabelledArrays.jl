module LabelledArrays

using StaticArrays

include("slvector.jl")
include("lvector.jl")
include("lmatrix.jl")

export SLVector, LVector, SLMatrix, LMatrix, @SLVector, @LVector, @SLMatrix, @LMatrix

end # module
