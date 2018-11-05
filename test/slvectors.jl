using LabelledArrays
using Test

ABC = @SLVector Int (:a,:b,:c)
b = ABC(1,2,3)

@test b.a == 1
@test b.b == 2
@test b.c == 3
@test b[1] == b.a
@test b[2] == b.b
@test b[3] == b.c

@test_throws UndefVarError fill!(a,1)
@test typeof(b.__x) <: SVector{3,Int}
bb = b.+b
@test bb isa LVector
@test eltype(bb) == Int
b1 = b.+1.0
@test b1 isa LVector
@test eltype(b1) == Float64

# Type stability tests
ABC_int = @SLVector Int (:a,:b,:c)
ABC_float = @SLVector Float64 (:a, :b, :c)
x = ABC_int(1,2,3)
y = ABC_float(4.,5.,6.)

@test typeof(copy(x)) == typeof(x)
@test typeof(similar(x)) == typeof(x)
@test typeof(similar(x, Float64)) == typeof(y)
@test typeof(convert(AbstractVector{Float64}, x)) == typeof(y)
@test_broken typeof(x .+ x) == typeof(x) # degrades to LVector of Vector{Int}
@test typeof(broadcast(+, x, x)) == typeof(x) # why does this work then?
@test_broken typeof(Float64.(x)) == typeof(y) # degrades to LVector of Vector{Float}
@test typeof(broadcast(Float64, x)) == typeof(y) # why does this work then?
@test_broken broadcast(+, x, y) # ERROR: conflicting broadcast rules defined
