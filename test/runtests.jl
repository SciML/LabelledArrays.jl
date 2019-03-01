using LabelledArrays
using Test
using StaticArrays

@time begin
@time @testset "SLArrays" begin include("slarrays.jl") end
@time @testset "LArrays" begin include("larrays.jl") end
@time @testset "LSliced" begin include("lsliced.jl") end
@time @testset "SLSliced" begin include("slsliced.jl") end
@time @testset "Display" begin include("display.jl") end
@time @testset "DiffEq" begin include("diffeq.jl") end
end
