using LabelledArrays, Test, InteractiveUtils

x = @LMatrix [1.0 2.0; 3.0 4.0] (:a,:b) (:x,:y)

syms1 = (:a,:b)
syms2 = (:x,:y)

for (i,s) in enumerate(syms1)
    @show i,s
    @test x[i,:x] == x[s,:x]
end

x[Val(:a), Val(:x)]

f(x) = x[1,1]
g(x) = x[:a,:x]
h(x) = x.a.x

@time f(x)
@time f(x)
@time g(x)
@time g(x)
@time h(x)
@time h(x)

@code_warntype getindex(x,Val(:a),Val(:x))
@inferred getindex(x,Val(:a),Val(:x))
@code_warntype g(x)
@inferred g(x)
# @code_warntype h(x)
# @inferred h(x)


f2(x, y) = x[1,1] = y
g2(x, y) = x[:a,:x] = y
h2(x, y) = x.a.x = y

g2(x, 6.0)
@test x[1,1] == 6.0
h2(x, 7.0)
@test x[1,1] == 7.0

@time f2(x, 5.0)
@time g2(x, 5.0)
@time h2(x, 5.0)

@code_warntype g2(x, 1.0)
@inferred g2(x, 1.0)
@code_warntype h2(x, 1.0)
@inferred h2(x, 1.0)
