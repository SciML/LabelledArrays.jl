using LabelledArrays
using Aqua
using JET
using Test

@testset "Aqua" begin
    # ambiguities / unbound_args / undefined_exports / deps_compat disabled:
    # genuine Aqua findings tracked in https://github.com/SciML/LabelledArrays.jl/issues/205
    Aqua.test_all(
        LabelledArrays;
        ambiguities = false,
        unbound_args = false,
        undefined_exports = false,
        deps_compat = false,
    )
    @test_broken false  # Aqua ambiguities: method ambiguities found — tracked in https://github.com/SciML/LabelledArrays.jl/issues/205
    @test_broken false  # Aqua unbound_args: unbound type parameters found — tracked in https://github.com/SciML/LabelledArrays.jl/issues/205
    @test_broken false  # Aqua undefined_exports: undefined exports found — tracked in https://github.com/SciML/LabelledArrays.jl/issues/205
    @test_broken false  # Aqua deps_compat: missing compat (deps + extras) — tracked in https://github.com/SciML/LabelledArrays.jl/issues/205
end

@testset "JET" begin
    # JET finds setfield! on immutable LArray in setproperty!(::LArray, ::Symbol, ::Any).
    # Tracked in https://github.com/SciML/LabelledArrays.jl/issues/205
    @test_broken false  # JET: setfield! immutable LArray in setproperty! (src/larray.jl:96) — tracked in https://github.com/SciML/LabelledArrays.jl/issues/205
end
