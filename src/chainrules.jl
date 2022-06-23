using ChainRulesCore: ChainRulesCore

unwrap_maybe(x) = x
unwrap_maybe(x::SLArray) = x.__x
unwrap_maybe(x::LArray) = x.__x
# Respect the thunk.
function unwrap_maybe(x::ChainRulesCore.Thunk)
    return ChainRulesCore.@thunk(unwrap_maybe(ChainRulesCore.unthunk(x)))
end

function ChainRulesCore.rrule(::typeof(getproperty), A::Union{SLArray, LArray}, s::Symbol)
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
    LArray_adjoint(Δ) = ChainRulesCore.NoTangent(), unwrap_maybe(Δ)
    return LArray{S}(x), LArray_adjoint
end

function ChainRulesCore.rrule(::Type{SLArray{Size, S}}, x::AbstractArray) where {Size, S}
    # This rule covers constructors of the form `SLArray{(2, ), (:a, :b)}(x)`
    # which, amongst other places, is also used in the `@LArray` macro.
    SLArray_adjoint(Δ) = ChainRulesCore.NoTangent(), unwrap_maybe(Δ)
    return SLArray{Size, S}(x), SLArray_adjoint
end
