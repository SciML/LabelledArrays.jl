using LabelledArrays
using Test

@time begin
@time @testset "SLVector Macros" begin include("slvectors.jl") end
#@time @testset "LMArrays" begin include("lmarrays.jl") end
@time @testset "LVectors" begin include("lvectors.jl") end
@time @testset "DiffEq" begin include("diffeq.jl") end
end
