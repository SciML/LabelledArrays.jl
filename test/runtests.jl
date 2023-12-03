using LabelledArrays
using Test
using StaticArrays
using InteractiveUtils
using ChainRulesTestUtils

@time begin
    @time @testset "Quality Assurance" begin include("qa.jl") end
    @time @testset "SLArrays" begin include("slarrays.jl") end
    @time @testset "LArrays" begin include("larrays.jl") end
    @time @testset "DiffEq" begin include("diffeq.jl") end
    @time @testset "ChainRules" begin include("chainrules.jl") end
end
