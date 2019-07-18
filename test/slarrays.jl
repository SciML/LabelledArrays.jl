using LabelledArrays, StaticArrays
using Test, InteractiveUtils

@testset "Basic interface" begin
    ABC = @SLVector (:a,:b,:c)
    b = ABC(1,2,3)
    @test_nowarn display(b)

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

    @test @inferred(similar_type(b, Float64)) === ABC_fl
    @test @inferred(similar_type(b, Float64, Size(1,3))) === @SLArray Float64 (1,3) (:a, :b, :c)
    @test @inferred(similar_type(b, Float64, Size(3,3))) === SArray{Tuple{3,3},Float64,2,9}

    @test typeof(@inferred(similar(b))) === LArray{Int,1,Array{Int64,1},(:a,:b,:c)}
    @test typeof(@inferred(similar(b, Float64))) === LArray{Float64,1,Array{Float64,1},(:a,:b,:c)}
    @test typeof(@inferred(similar(b, Size(1,3)))) === LArray{Int,2,Array{Int64,2},(:a, :b, :c)}
    @test typeof(@inferred(similar(b, Size(3,3)))) === MArray{Tuple{3,3},Int,2,9}

    @test @inferred(copy(b)) === ABC_int(Tuple(b))

    @test @inferred(broadcast(Float64, b)) === ABC_fl(Tuple(b))
    @test @inferred(broadcast(+, b, b)) === ABC_int(Tuple(b.__x .+ b.__x))
    @test @inferred(broadcast(+, b, 1.0)) === ABC_fl(Tuple(b.__x .+ 1.0))

    @test @inferred(zero(b)) === ABC_int(zero(b))
end

@testset "NamedTuple conversion" begin
    x_tup = (a=1, b=2)
    y_tup = (a=1, b=2, c=3, d=4)
    x = SLVector(a=1, b=2)
    y = SLArray{Tuple{2,2}}(a=1, b=2, c=3, d=4)
    @test @inferred(convert(NamedTuple, x)) == x_tup
    @test @inferred(convert(NamedTuple, y)) == y_tup
    @test @inferred(collect(pairs(x))) == collect(pairs(x_tup))
    @test @inferred(collect(pairs(y))) == collect(pairs(y_tup))

    @inferred(SLArray{Tuple{2,2}}(a=1, b=2, c=3, d=4))
    @inferred(convert(NamedTuple, y))
    @inferred(collect(pairs(y)))
end

@testset "accessing labels, i.e. symbols" begin
    z = SLVector(a=1, b=2, c=3)
    ret = symbols(z)
    @test ret == (:a,:b,:c)
end

@testset "Explicit indices" begin
  Arr = @SLVector (a = 1:2, b = 3)
  z = Arr(1.,2.,3.)
  @test_nowarn display(z)
  g(z) = z.a
  @inferred g(z)
  @test z.a isa SubArray
  @test z.a == [1, 2.]
  @test z.b === 3.
  Arr = @SLVector (a = 1:2, b = 2:3)
  z = Arr(1.,2.,3.)
  @test_nowarn display(z)
  @test z.b == [2, 3.]
  Arr = @SLVector (a = 1, b = 2)
  z = Arr(1, 2)
  @test_nowarn display(z)
  @test z.a === 1
  @test z.b === 2
  @test symbols(z) === (:a, :b)
  Arr = @SLArray (2, 2) (a = (2, :), b = 3)
  z = Arr(1, 2, 3, 4)
  @test_nowarn display(z)
  @test z.a == [2, 4]
end
