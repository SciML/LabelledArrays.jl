for LArrayType in [LArray, SLArray]
    @eval function RecursiveArrayTools.DiffEqArray(vec::AbstractVector{<:$LArrayType},
            ts::AbstractVector,
            p = nothing)
        RecursiveArrayTools.DiffEqArray(vec, ts, p; variables = collect(symbols(vec[1])))
    end
end
