using LabelledArrays
using Test

@time begin
@time @testset "SLArrays Macros" begin include("slarrays.jl") end
@time @testset "LArrays" begin include("larrays.jl") end
@time @testset "DiffEq" begin include("diffeq.jl") end
end
