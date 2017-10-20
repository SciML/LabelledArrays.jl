using LabelledArrays
using Base.Test

b = @SLVector [a,b,c] [1,2,3]

@test b.a == 1
@test b.b == 2
@test b.c == 3
@test b[1] == b.a
@test b[2] == b.b
@test b[3] == b.c

@test_throws UndefVarError fill!(a,1)
@test typeof(b) <: SLVector{3,Int}
b.+b
