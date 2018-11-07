using LabelledArrays, Test, InteractiveUtils

x = @LVector [1.0,2.0,3.0] (:a,:b,:c)
y = @LVector Float64 (:a,:b,:c)
y .= [1,2,3.]
@test x == y

syms = (:a,:b,:c)

for (i,s) in enumerate(syms)
    @show i,s
    @test x[i] == x[s]
end

x[Val(:a)]

f(x) = x[1]
g(x) = x.a
@time f(x)
@time f(x)
@time g(x)
@time g(x)

@code_warntype getindex(x,Val(:a))
@inferred getindex(x,Val(:a))
@code_warntype g(x)
@inferred g(x)

x = @LVector [1,2,3] (:a,:b,:c)
x .* x isa LArray
x .+ 1 isa LArray
x .+ 1. isa LArray
eltype(x .+ 1.) === Float64
