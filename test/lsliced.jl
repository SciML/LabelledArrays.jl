using LabelledArrays, Test, InteractiveUtils

x = @LSlicedMatrix [1.0 2.0; 3.0 4.0; 5.0 6.0] (:a,:b,:c) (:x, :y)

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

x = @LSlicedMatrix [1 2; 3 4; 5 6] (:a,:b,:c) (:x, :y)
@test x .* x isa LSlicedMatrix
@test x .+ 1 isa LSlicedMatrix
@test x .+ 1. isa LSlicedMatrix
z = x .+ ones(Int, 3)
@test z isa LSlicedMatrix && eltype(z) === Int
z = x .+ ones(Float64, 3)
@test z isa LSlicedMatrix && eltype(z) === Float64
@test eltype(x .+ 1.) === Float64

z = @LSlicedMatrix Float64 (2,2) (:a,:b) (:c,:d)
w = rand(2,2)
z .= w

@test z[:a,:c] == w[1,1]
@test z[:b,:c] == w[2,1]
@test z[:a,:d] == w[1,2]
@test z[:b,:d] == w[2,2]
