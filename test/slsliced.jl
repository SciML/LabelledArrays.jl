using LabelledArrays, Test, StaticArrays

ABC = @SLSliced (3,2) (:a,:b,:c), (:x, :y) 
b = ABC(1,2,3,4,5,6)

@test b.a.x == 1
@test b.b.x == 2
@test b.c.y == 6
@test b[1,1] == b.a.x
@test b[2,2] == b.b.y
@test b[3,1] == b.c.x

@test_throws UndefVarError fill!(a,1)
@test typeof(b.__x) == SArray{Tuple{3,2},Int,2,6}

# Type stability tests
ABC_fl = @SLSliced Float64 (3,2) (:a, :b, :c), (:x, :y)
ABC_int = @SLSliced Int (3,2) (:a, :b, :c), (:x, :y)
@test similar_type(b, Float64) === ABC_fl
@test copy(b) === ABC_int(Tuple(b))
@test Float64.(b) === ABC_fl(Tuple(b))
@test b .+ b === ABC_int(Tuple(b.__x .+ b.__x))
@test b .+ 1.0 === ABC_fl(Tuple(b.__x .+ 1.0))
@test zero(b) === ABC_int(zero(b))
@test typeof(similar(b)) === MArray{Tuple{3,2}, Int, 2, 6} # similar should return a mutable copy
