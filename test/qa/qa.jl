using LabelledArrays
using Aqua
using JET
using Test

@testset "Aqua" begin
    Aqua.test_all(LabelledArrays)
end

@testset "JET" begin
    JET.test_package(LabelledArrays; target_defined_modules = true)
end
