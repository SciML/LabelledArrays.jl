@testset "Vector" begin
    x = randn(2)
    syms = (:a, :b)

    # Constructors
    test_rrule(LArray{syms}, x)
    constructor = @SLArray (2,) syms
    test_rrule(constructor, x)

    # `getproperty`
    lx = LArray{syms}(x)
    test_rrule(getproperty, lx, first(syms))
    test_rrule(getproperty, lx, last(syms))

    slx = constructor(x)
    test_rrule(getproperty, slx, first(syms))
    test_rrule(getproperty, slx, last(syms))
end
