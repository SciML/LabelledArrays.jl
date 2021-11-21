using ChainRulesCore: ChainRulesCore

function ChainRulesCore.rrule(::typeof(getproperty), A::Union{SLArray,LArray}, s::Symbol)
    function getproperty_LArray_adjoint(d)
        # Hopefully this reference to `A` is optimized away.
        Δ = similar(A) .= 0
        setproperty!(Δ, s, ChainRulesCore.unthunk(d))
        return (ChainRulesCore.NoTangent(), Δ, ChainRulesCore.NoTangent())
    end
    return getproperty(A, s), getproperty_LArray_adjoint
end

function ChainRulesCore.rrule(::Type{LArray{S}}, x::AbstractArray) where {S}
    # This rule covers constructors of the form `LArray{(:a, :b)}(x)`
    # which, amongst other places, is also used in the `@LArray` macro.
    LArray_adjoint(Δlx::LArray) = ChainRulesCore.NoTangent(), Δlx.__x
    # Sometimes we're pulling back gradients which are not `LArray`.
    LArray_adjoint(Δx) = ChainRulesCore.NoTangent(), Δx
    return LArray{S}(x), LArray_adjoint
end

# TODO: Can this ruled be combined into the above definition?
function ChainRulesCore.rrule(::Type{SLArray{Size,S}}, x::AbstractArray) where {Size,S}
    # This rule covers constructors of the form `LArray{(:a, :b)}(x)`
    # which, amongst other places, is also used in the `@LArray` macro.
    SLArray_adjoint(Δlx::SLArray) = ChainRulesCore.NoTangent(), Δlx.__x
    # Sometimes we're pulling back gradients which are not `LArray`.
    SLArray_adjoint(Δx) = ChainRulesCore.NoTangent(), Δx
    return SLArray{Size,S}(x), SLArray_adjoint
end
