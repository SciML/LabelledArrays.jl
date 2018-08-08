using LabelledArrays
using Test

tic()
@time @testset "SLVector Macros" begin include("slvectors.jl") end
@time @testset "LMArrays" begin include("lmarrays.jl") end
@time @testset "LArrays" begin include("larrays.jl") end
toc()
