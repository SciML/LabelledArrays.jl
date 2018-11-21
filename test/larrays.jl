using LabelledArrays, Test, InteractiveUtils

@testset "Basic interface" begin
    x = @LArray [1.0,2.0,3.0] (:a,:b,:c)
    y = @LVector Float64 (:a,:b,:c)
    y .= [1,2,3.]
    @test x == y

    syms = (:a,:b,:c)

    for (i,s) in enumerate(syms)
        @show i,s
        @test x[i] == x[s]
    end

    x[:a]

    f(x) = x[1]
    g(x) = x.a
    @time f(x)
    @time f(x)
    @time g(x)
    @time g(x)

    #@code_warntype x.a
    #@inferred getindex(x,:a)
    @code_warntype g(x)
    @inferred g(x)

    x = @LArray [1,2,3] (:a,:b,:c)
    @test x .* x isa LArray
    @test x .+ 1 isa LArray
    @test x .+ 1. isa LArray
    z = x .+ ones(Int, 3)
    @test z isa LArray && eltype(z) === Int
    z = x .+ ones(Float64, 3)
    @test z isa LArray && eltype(z) === Float64
    @test eltype(x .+ 1.) === Float64

    z = @LArray Float64 (2,2) (:a,:b,:c,:d)
    w = rand(2,2)
    z .= w

    @test z[:a] == w[1,1]
    @test z[:b] == w[2,1]
    @test z[:c] == w[1,2]
    @test z[:d] == w[2,2]
end

@testset "NameTuple conversion" begin
    x_tup = (a=1, b=2)
    y_tup = (a=1, b=2, c=3, d=4)
    x = LVector(a=1, b=2)
    y = LArray((2,2); a=1, b=2, c=3, d=4)
    @test convert(NamedTuple, x) == x_tup
    @test convert(NamedTuple, y) == y_tup
    @test collect(pairs(x)) == collect(pairs(x_tup))
    @test collect(pairs(y)) == collect(pairs(y_tup))

    @code_warntype LArray((2,2); a=1, b=2, c=3, d=4)
    @code_warntype convert(NamedTuple, y)
    @code_warntype collect(pairs(y))
end

@testset "undef copy" begin
    z = @LArray Float64 (2,2) (:a,:b,:c,:d)
    t = similar(z, String) # t's elements are uninitialized
    @test_throws UndefRefError t[1]
    copy(t) # should be ok
    deepcopy(t) # should also be ok
end
