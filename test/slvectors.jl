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
