using LabelledArrays, Test

x = @LVector [1.0,2.0,3.0] (:a,:b,:c)

syms = (:a,:b,:c)

for (i,s) in enumerate(syms)
    @show i,s
    @test x[i] == x[s]
end

f(x) = x[1]
g(x) = x.a
@time f(x)
@time g(x)

@code_warntype x.a
