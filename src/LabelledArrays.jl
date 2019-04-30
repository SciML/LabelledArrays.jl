module LabelledArrays

using LinearAlgebra, StaticArrays

include("slarray.jl")
include("larray.jl")
include("slsliced.jl")
include("lsliced.jl")
include("display.jl")

export SLArray, LArray, SLVector, LVector, @SLVector, @LArray, @LVector, @SLArray

export @SLSliced, @LSliced

export symbols, dimSymbols, rowSymbols, colSymbols

end # module
