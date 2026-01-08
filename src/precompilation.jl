using PrecompileTools

@setup_workload begin
    @compile_workload begin
        # LArray operations - Float64
        x = @LArray [1.0, 2.0, 3.0] (:a, :b, :c)
        _ = x.a
        _ = x.b
        x.a = 2.0
        _ = symbols(x)

        # LVector creation
        lv = LVector(a = 1.0, b = 2.0, c = 3.0)
        _ = lv.a

        # @LVector macro
        lv2 = @LVector Float64 (:x, :y, :z)
        lv2 .= [1.0, 2.0, 3.0]

        # Broadcasting with LArray (major TTFX cost)
        y = @LArray [4.0, 5.0, 6.0] (:a, :b, :c)
        _ = x .+ y
        _ = x .* 2.0
        _ = x .+ 1.0

        # SLArray operations - Float64
        SLV = @SLVector Float64 (:a, :b, :c)
        sv = SLV(1.0, 2.0, 3.0)
        _ = sv.a
        _ = sv.b
        _ = symbols(sv)

        # SLArray 2D
        SLA = @SLArray Float64 (2, 2) (:a, :b, :c, :d)
        sa = SLA(1.0, 2.0, 3.0, 4.0)
        _ = sa.a
        _ = sa.d

        # SLVector operations
        sv2 = SLVector(a = 1.0, b = 2.0)
        _ = sv2.a

        # Conversion and copy operations
        _ = convert(NamedTuple, x)
        _ = convert(NamedTuple, sv)
        _ = copy(x)

        # show methods (for REPL display)
        io = IOBuffer()
        show(io, x)
        show(io, sv)

        # LArray with Int64
        xi = @LArray [1, 2, 3] (:a, :b, :c)
        _ = xi.a
        yi = @LArray [4, 5, 6] (:a, :b, :c)
        _ = xi .+ yi

        # 2D LArray
        x2d = @LArray Float64 (2, 2) (:a, :b, :c, :d)
        x2d .= [1.0 3.0; 2.0 4.0]
        _ = x2d.a
        _ = x2d.d
    end
end
