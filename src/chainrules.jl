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
    function LArray_adjoint(Δx_)
        Δx = ChainRulesCore.unthunk(Δx_)
        # Sometimes we're pulling back gradients which are not `LArray`.
        return if Δ isa LArray
            ChainRulesCore.NoTangent(), Δx.__x
        else
            ChainRulesCore.NoTangent(), Δx
        end
    end
    return LArray{S}(x), LArray_adjoint
end

# TODO: Can this ruled be combined into the above definition?
function ChainRulesCore.rrule(::Type{SLArray{Size,S}}, x::AbstractArray) where {Size,S}
    # This rule covers constructors of the form `SLArray{(2, ), (:a, :b)}(x)`
    # which, amongst other places, is also used in the `@LArray` macro.
    function SLArray_adjoint(Δx_)
        Δx = ChainRulesCore.unthunk(Δx_)
        # Sometimes we're pulling back gradients which are not `LArray`.
        return if Δ isa SLArray
            ChainRulesCore.NoTangent(), Δx.__x
        else
            ChainRulesCore.NoTangent(), Δx
        end
    end
    return SLArray{Size,S}(x), SLArray_adjoint
end
