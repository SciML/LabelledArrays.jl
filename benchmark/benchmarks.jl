using LabelledArrays, BenchmarkTools
using LinearAlgebra, StableRNGs

const SUITE = BenchmarkGroup()
const rng = StableRNG(123)

vals = rand(rng, 5)
syms = (:a, :b, :c, :d, :e)

la = @LArray vals syms
la2 = @LArray rand(rng, 5) syms

# =============================================================================
# Construction and access
# =============================================================================

SUITE["larray"] = BenchmarkGroup()

SUITE["larray"]["construct"] = @benchmarkable @LArray($vals, $syms)
SUITE["larray"]["getproperty"] = @benchmarkable $la.a
SUITE["larray"]["getindex_symbol"] = @benchmarkable $la[:a]
SUITE["larray"]["broadcast"] = @benchmarkable $la .+ $la2
SUITE["larray"]["norm"] = @benchmarkable norm($la)

# =============================================================================
# Static labelled arrays
# =============================================================================

SUITE["slarray"] = BenchmarkGroup()

ABC = @SLVector (:a, :b, :c)
slv = SLVector(a = 1.0, b = 2.0, c = 3.0)
ABCD = @SLArray (2, 2) (:a, :b, :c, :d)
sla = ABCD(1.0, 2.0, 3.0, 4.0)

SUITE["slarray"]["slvector_construct"] = @benchmarkable SLVector(
    a = 1.0, b = 2.0, c = 3.0
)
SUITE["slarray"]["typed_construct"] = @benchmarkable $ABC(1.0, 2.0, 3.0)
SUITE["slarray"]["getproperty"] = @benchmarkable $slv.a
SUITE["slarray"]["matmul"] = @benchmarkable $sla * $sla

# =============================================================================
# Larger LArray
# =============================================================================

SUITE["large"] = BenchmarkGroup()

vals_big = rand(rng, 500)
syms_big = Tuple(Symbol(:x, i) for i in 1:500)
la_big = @LArray vals_big syms_big
la_big2 = @LArray rand(rng, 500) syms_big

SUITE["large"]["broadcast_500"] = @benchmarkable $la_big .+ $la_big2
SUITE["large"]["dot_500"] = @benchmarkable dot($la_big, $la_big2)
