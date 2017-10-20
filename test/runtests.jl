using LabelledArrays
using Base.Test

a = @LVector Float64 [a,b,c]
b = @LVector Float64 [a,b,c] [1,2,3]

@test b.a == 1
@test b.b == 2
@test b.c == 3
@test b[1] == b.a
@test b[2] == b.b
@test b[3] == b.c

@test_throws ErrorException fill!(a,1)
@test typeof(b) <: LabelledVector{3,Float64}
b.+b


c = @MLVector Float64 [a,b,c]
d = @MLVector Float64 [a,b,c] [1,2,3]

@test d.a == 1
@test d.b == 2
@test d.c == 3
@test d[1] == d.a
@test d[2] == d.b
@test d[3] == d.c

@test typeof(c) <: LabelledVector{3,Float64}
c.+d
c.=2d
@test c == [2,4,6]
