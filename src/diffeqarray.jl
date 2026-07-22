for LArrayType in [LArray, SLArray]
    @eval function RecursiveArrayTools.DiffEqArray(
            vec::AbstractVector{<:$LArrayType},
            ts::AbstractVector,
            p = nothing
        )
        return RecursiveArrayTools.DiffEqArray(vec, ts, p; variables = collect(symbols(vec[1])))
    end

    @eval function RecursiveArrayTools.DiffEqArray(
            vec::AbstractVector{<:$LArrayType},
            ts::AbstractVector,
            p::NTuple{N, Int}
        ) where {N}
        return invoke(
            RecursiveArrayTools.DiffEqArray,
            Tuple{AbstractVector, AbstractVector, Any},
            vec,
            ts,
            p;
            variables = collect(symbols(vec[1])),
        )
    end
end
