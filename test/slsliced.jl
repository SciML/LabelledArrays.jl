using LabelledArrays, Test, StaticArrays

ABC = @SLSlicedMatrix (3, 2) (:a,:b,:c) (:x, :y) 
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
ABC_fl = @SLSlicedMatrix Float64 (3,2) (:a, :b, :c) (:x, :y)
ABC_int = @SLSlicedMatrix Int (3,2) (:a, :b, :c) (:x, :y)
@test similar_type(b, Float64) == ABC_fl
@test typeof(copy(b)) == ABC_int
@test typeof(Float64.(b)) == ABC_fl
@test typeof(b .+ b) == ABC_int
@test typeof(b .+ 1.0) == ABC_fl
@test typeof(zero(b)) == ABC_int
@test similar(b) isa MArray # similar should return a mutable copy
