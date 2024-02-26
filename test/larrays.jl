using LabelledArrays, Test, InteractiveUtils

@testset "Basic interface" begin
    vals = [1.0, 2.0, 3.0]
    syms = (:a, :b, :c)
    x = @LArray vals syms
    @test Base.elsize(x) == Base.elsize(vals) == 8
    @test_nowarn display(x)
    y = @LVector Float64 (:a, :b, :c)
    y .= [1, 2, 3.0]
    @test x == y
    @test vec(x) === x
    @test vec(y) === y
    mat = rand(4, 3)
    @test mat * vals ≈ mat * [1.0, 2.0, 3.0]
    syms = (:a, :b, :c)
    @test typeof(typeof(x)(undef, 3)) == typeof(x)

    z = LabelledArrays.LArray{Float64, 1, Vector{Float64}, (x = 1:4, y = 5:8)}(undef, 8)
    @test length(z) == 8
    @test size(LabelledArrays.ArrayInterface.undefmatrix(z)) == (8, 8)

    for (i, s) in enumerate(syms)
        @show i, s
        @test x[i] == x[s]
    end

    x[:a]

    f(x) = x[1]
    g(x) = x.a
    g(x, y) = x.a = y
    @time f(x)
    @time f(x)
    @time g(x)
    @time g(x)

    #@code_warntype x.a
    #@inferred getindex(x,:a)
    @code_warntype g(x)
    @inferred g(x)
    @inferred g(x, 2)

    vals = [1, 2, 3]
    syms = (:a, :b, :c)
    x = @LArray vals syms
    @test x .* x isa LArray
    @test x * x' isa Array
    @test x .+ 1 isa LArray
    @test x .+ 1.0 isa LArray
    z = x .+ ones(Int, 3)
    @test z isa LArray && eltype(z) === Int
    z = x .+ ones(Float64, 3)
    @test z isa LArray && eltype(z) === Float64
    @test eltype(x .+ 1.0) === Float64
    @test Base.dataids(vals) == Base.dataids(x)

    type = Float64
    dims = (2, 2)
    syms = (:a, :b, :c, :d)
    z = @LArray type dims syms
    w = rand(2, 2)
    z .= w

    @test z[:a] == w[1, 1]
    @test z[:b] == w[2, 1]
    @test z[:c] == w[1, 2]
    @test z[:d] == w[2, 2]

    @test setindex!(x, 2, :a) == LVector(a = 2, b = 2, c = 3)
    @test setindex!(x, 2, :a) == LVector(a = 2, b = 2, c = 3)
    @test setindex!(LArray((2, 2), a = 1, b = 2, c = 3, d = 4), 1, :b) ==
          LArray((2, 2), a = 1, b = 1, c = 3, d = 4)

    x = @LArray [1, 2, 3] (:a, :b, :c)
    y = @LArray [4, 5, 6] (:d, :e, :f)
    @test LabelledArrays.symnames(typeof(vcat(x, y))) == (:a, :b, :c, :d, :e, :f)
    @test vcat(x, y) == [1, 2, 3, 4, 5, 6]

    @test_throws ErrorException x.z

    # Ref #93, #154
    @test_broken @LVector [1, 2, 3] (:a, :b, :c)
end

@testset "Alternate array backends" begin
    v = view([1 2 3 4 5 6 7 8], 3:6)
    x = LArray{(:a, :b, :c, :d)}(v)
    @test x.b == 4
    @test x[:d] == 6

    s = similar(x)
    @test size(s) == size(x)
    @test typeof(s.__x) == Array{Int64, 1}
    @test LabelledArrays.symnames(typeof(s)) == (:a, :b, :c, :d)
end

@testset "NameTuple conversion" begin
    x_tup = (a = 1, b = 2)
    y_tup = (a = 1, b = 2, c = 3, d = 4)
    x = LVector(a = 1, b = 2)
    y = LArray((2, 2); a = 1, b = 2, c = 3, d = 4)
    @test convert(NamedTuple, x) == x_tup
    @test convert(NamedTuple, y) == y_tup
    @test NamedTuple(x) == x_tup
    @test NamedTuple(y) == y_tup
    @test collect(pairs(x)) == collect(pairs(x_tup))
    @test collect(pairs(y)) == collect(pairs(y_tup))

    @code_warntype LArray((2, 2); a = 1, b = 2, c = 3, d = 4)
    @code_warntype convert(NamedTuple, y)
    @code_warntype collect(pairs(y))
end

@testset "undef copy" begin
    z = @LArray Float64 (2, 2) (:a, :b, :c, :d)
    t = similar(z, String) # t's elements are uninitialized
    @test_throws UndefRefError t[1]
    copy(t) # should be ok
    deepcopy(t) # should also be ok
end

@testset "accessing labels, i.e. symbols" begin
    z = @LArray Float64 (2, 2) (:a, :b, :c, :d)
    @test_nowarn display(z)
    ret = symbols(z)
    @test ret == (:a, :b, :c, :d)
    #ret2 = dimSymbols(z,1) # no method defined if Syms is not a tuple
end

@testset "several indices as vector" begin
    z = @LArray [1.0, 2.0, 3.0] (:a, :b, :c)
    @test z[[3, 1]] == [3.0, 1.0]
    @test z[[:c, :a]] == [3.0, 1.0]
    #i = LabelledArrays.symToInd(z, (:c,:a)) # also works with Tuples
    zs = SLVector(a = 1.0, b = 2.0, c = 3.0)
    @test zs[[3, 1]] == [3.0, 1.0]
    @test zs[[:c, :a]] == [3.0, 1.0]
end

@testset "Explicit indices" begin
    z = @LArray [1.0, 2.0, 3.0] (a = 1:2, b = 3)
    @test z * z' isa Array
    g(x) = x.a
    g(x, y) = x.a .= y
    @inferred g(z)
    @test_broken @inferred g(z, [1, 2])
    @test_nowarn display(z)
    @test z.a isa SubArray
    @test z.a == [1, 2.0]
    z.a = [100, 200.0]
    @test z.a == [100, 200.0]
    @test z.b === 3.0
    z.b = 1000.0
    @test z.b === 1000.0
    z = @LArray [1.0, 2.0, 3.0] (a = 1:2, b = 1:3)
    @inferred g(z)
    @test_broken @inferred g(z, [1, 2.0])
    @test z.b === view(z.__x, 1:3)
    z = @LArray [1.0, 2.0] (a = 1, b = 2)
    @test_nowarn display(z)
    @test z.a === 1.0
    @test z.b === 2.0
    @test symbols(z) === (:a, :b)
    z = @LArray [1 2; 3 4] (a = (2, :), b = 2:3)
    @test z.a == [3, 4]
    @test_nowarn display(z)
    @inferred g(z)
    @test_broken @inferred g(z, [1, 2])
end

@testset "1x1 broadcasting" begin
    x = @LArray [1] (:a,)
    @test x .* 1 == x
    @test x .* 1 isa LArray
    @test x .* x' == fill(1, 1, 1)
    @test x .* x' isa Array
end

@testset "broadcasting" begin
    n = 2
    lu_0 = @LArray fill(1000.0, 2 * n) (x = (1:n), y = ((n + 1):(2 * n)))
    @test lu_0 ./ 1.0 isa LArray

    x = @LArray fill(1000.0, 2 * n) (:x1, :x2, :y1, :y2)
    @test x ./ 1.0 isa LArray
end

@testset "convert" begin
    A = @LArray [1, 2, 3] (:a, :b, :c)
    @test convert(AbstractVector{Int}, A) === A
    B = convert(AbstractVector{Float64}, A)
    @test B.b === 2.0
end
