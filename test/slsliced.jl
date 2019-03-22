using LabelledArrays, Test, StaticArrays

@testset "Basic interface" begin
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

    @test @inferred(similar_type(b, Float64)) === ABC_fl
    @test @inferred(similar_type(b, Float64, Size(3,2))) === @SLSliced Float64 (3,2) (:a, :b, :c), (:x, :y)
    @test @inferred(similar_type(b, Float64, Size(3,3))) === SArray{Tuple{3,3},Float64,2,9}

    @test typeof(@inferred(similar(b))) === LArray{Int,2,Array{Int,2},Tuple{(:a,:b,:c),(:x,:y)}}
    @test typeof(@inferred(similar(b, Float64))) === LArray{Float64,2,Array{Float64,2},Tuple{(:a,:b,:c),(:x,:y)}}
    @test typeof(@inferred(similar(b, Size(3,2)))) === LArray{Int,2,Array{Int,2},Tuple{(:a, :b, :c),(:x,:y)}}
    @test typeof(@inferred(similar(b, Size(3,3)))) === MArray{Tuple{3,3},Int,2,9}

    @test @inferred(copy(b)) === ABC_int(Tuple(b))

    @test @inferred(broadcast(Float64, b)) === ABC_fl(Tuple(b))
    @test @inferred(broadcast(+, b, b)) === ABC_int(Tuple(b.__x .+ b.__x))
    @test @inferred(broadcast(+, b, 1.0)) === ABC_fl(Tuple(b.__x .+ 1.0))

    @test @inferred(zero(b)) === ABC_int(zero(b))
end

@testset "accessing dimensions symbols of SLSliced" begin
    ABC = @SLSliced (3,2) (:a,:b,:c), (:x, :y)
    A = ABC([1 2; 3 4; 5 6])
    ret = symbols(A)
    @test ret == ((:a,:b,:c),(:x,:y))
end

