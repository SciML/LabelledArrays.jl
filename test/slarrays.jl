using LabelledArrays, StaticArrays
using Test, InteractiveUtils

@testset "Basic interface" begin
    ABC = @SLVector (:a,:b,:c)
    b = ABC(1,2,3)

    @test b.a == 1
    @test b.b == 2
    @test b.c == 3
    @test b[1] == b.a
    @test b[2] == b.b
    @test b[3] == b.c

    @test_throws UndefVarError fill!(a,1)
    @test typeof(b.__x) == SVector{3,Int}

    # Type stability tests
    ABC_fl = @SLVector Float64 (:a, :b, :c)
    ABC_int = @SLVector Int (:a, :b, :c)
    @test similar_type(b, Float64) === ABC_fl
    @test copy(b) === ABC_int(Tuple(b))
    @test Float64.(b) === ABC_fl(Tuple(b))
    @test b .+ b === ABC_int(Tuple(b.__x .+ b.__x))
    @test b .+ 1.0 === ABC_fl(Tuple(b.__x .+ 1.0))
    @test zero(b) === ABC_int(zero(b))
    @test typeof(similar(b)) === MArray{Tuple{3}, Int, 1, 3} # similar should return a mutable copy
end

@testset "NamedTuple conversion" begin
    x_tup = (a=1, b=2)
    y_tup = (a=1, b=2, c=3, d=4)
    x = SLVector(a=1, b=2)
    y = SLArray{Tuple{2,2}}(a=1, b=2, c=3, d=4)
    @test convert(NamedTuple, x) == x_tup
    @test convert(NamedTuple, y) == y_tup
    @test collect(pairs(x)) == collect(pairs(x_tup))
    @test collect(pairs(y)) == collect(pairs(y_tup))

    @code_warntype SLArray{Tuple{2,2}}(a=1, b=2, c=3, d=4)
    @code_warntype convert(NamedTuple, y)
    @code_warntype collect(pairs(y))
end
