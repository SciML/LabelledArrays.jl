module LabelledArrays

using StaticArrays

include("slvector.jl")
include("lvector.jl")
include("lmatrix.jl")

export SLVector, LVector, LMatrix, @SLVector, @LVector, @LMatrix

end # module
