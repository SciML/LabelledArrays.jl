using LabelledArrays, Test, InteractiveUtils

@testset "Basic interface" begin
    x = @LSliced [1.0 2.0; 3.0 4.0; 5.0 6.0] (:a,:b,:c), (:x, :y)

    syms1 = (:a,:b,:c)
    syms2 = (:x, :y)

    for (i,s1) in enumerate(syms1), (j,s2) in enumerate(syms2)
        @show i,s2,j,s2
        @test x[i,j] == x[s1,s2]
    end

    f(x) = x[1,1]
    g(x) = x.a.x
    @time f(x)
    @time f(x)
    @time g(x)
    @time g(x)

    #@code_warntype x.a
    #@inferred getindex(x,:a)
    @code_warntype g(x)
    @inferred g(x)

    x = @LSliced [1 2; 3 4; 5 6] (:a,:b,:c), (:x, :y)
    @test x .* x isa LArray
    @test x .+ 1 isa LArray
    @test x .+ 1. isa LArray
    z = x .+ ones(Int, 3)
    @test z isa LArray && eltype(z) === Int
    z = x .+ ones(Float64, 3)
    @test z isa LArray && eltype(z) === Float64
    @test eltype(x .+ 1.) === Float64

    z = @LSliced Float64 (2,2) (:a,:b), (:c,:d)
    w = rand(2,2)
    z .= w

    @test z[:a,:c] == w[1,1]
    @test z[:b,:c] == w[2,1]
    @test z[:a,:d] == w[1,2]
    @test z[:b,:d] == w[2,2]

    vals = [1 2; 3 4; 5 6]
    syms = (:a,:b,:c), (:x, :y)
    x = @LSliced vals syms  
    x.a.x = 33
    x.b.y = 99
    x[:a,:y] = 44
    x[:b,:x] = 77
    @test x[1,1] == 33
    @test x[2,2] == 99
    @test x[1,2] == 44
    @test x[2,1] == 77
end

@testset "Alternate array backends" begin
    v = view([1 2 3; 4 5 6; 7 8 9], 2:3, 2:3)
    x = LArray{Tuple{(:a,:b),(:c,:d)}}(v)
    @test x.a.c == 5
    @test x[:b, :d] == 9

    s = similar(x)
    @test size(s) == size(x)
    @test typeof(s.__x) == Array{Int64,2}
    @test LabelledArrays.symnames(typeof(s)) == ((:a,:b), (:c,:d))
end


@testset "undef copy" begin
    z = @LSliced Float64 (4,2) (:a,:b,:c,:d), (:x, :y)
    t = similar(z, String) # t's elements are uninitialized
    @test_throws UndefRefError t[1]
    copy(t) # should be ok
    deepcopy(t) # should also be ok
end

@testset "accessing labels, i.e. symbols" begin
    A2 = @LSliced [1 2; 3 4; 5 6] (:a,:b,:c), (:x, :y)
    ret = symbols(A2)
    @test ret == ((:a, :b, :c), (:x, :y))
    #
    # higher dimensional still returns a tuple-Type object
    A3 = @LSliced cat(A2,10*A2;dims = 3) (:a,:b,:c), (:x, :y), (:u,:v)
    ret = symbols(A3)
    @test ret == Tuple{(:a, :b, :c),(:x, :y),(:u, :v)}
end

# @testset "accessing dimensions symbols of LSliced" begin
#     A = @LSliced [1 2; 3 4; 5 6] (:a,:b,:c), (:x, :y)
#     dim = 1
#     rows = dimSymbols(A,dim)
#     @test rows == (:a,:b,:c)
#     cols = dimSymbols(A,2)
#     @test cols == (:x,:y)
#     rows = rowSymbols(A)
#     @test rows == (:a,:b,:c)
#     cols = colSymbols(A)
#     @test cols == (:x,:y)
# end
