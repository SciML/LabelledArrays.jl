using LabelledArrays
using Test
using StaticArrays
using InteractiveUtils
using ChainRulesTestUtils

const GROUP = get(ENV, "GROUP", "All")

if GROUP == "All"
    @time begin
        @time @testset "SLArrays" begin
            include("slarrays.jl")
        end
        @time @testset "LArrays" begin
            include("larrays.jl")
        end
        @time @testset "DiffEq" begin
            include("diffeq.jl")
        end
        @time @testset "ChainRules" begin
            include("chainrules.jl")
        end
    end
end

if GROUP == "All" || GROUP == "RecursiveArrayTools"
    @time @testset "RecursiveArrayTools" begin
        include("recursivearraytools.jl")
    end
end

if GROUP == "nopre"
    using AllocCheck
    @time @testset "AllocCheck" begin
        include("alloc_tests.jl")
    end
end
