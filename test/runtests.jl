using LabelledArrays
using Test
using StaticArrays
using InteractiveUtils

@time begin
@time @testset "SLArrays" begin include("slarrays.jl") end
@time @testset "LArrays" begin include("larrays.jl") end
@time @testset "DiffEq" begin include("diffeq.jl") end
end
