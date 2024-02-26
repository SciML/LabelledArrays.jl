module LabelledArrays

using LinearAlgebra, StaticArrays, ArrayInterface
import RecursiveArrayTools, PreallocationTools, ForwardDiff

include("slarray.jl")
include("larray.jl")
include("chainrules.jl")

# Common
@generated function __getindex(x::Union{LArray, SLArray}, ::Val{s}) where {s}
    syms = symnames(x)
    idx = syms isa NamedTuple ? syms[s] : findfirst(y -> y == s, syms)
    if idx === nothing
        :(error("type $(typeof(x)) has no field $(s)"))
    elseif idx isa Tuple
        :(Base.@_propagate_inbounds_meta; view(getfield(x, :__x), $idx...))
    else
        :(Base.@_propagate_inbounds_meta; @views getfield(x, :__x)[$idx])
    end
end

using MacroTools

struct PrintWrapper{T, N, F, X <: AbstractArray{T, N}} <: AbstractArray{T, N}
    f::F
    x::X
end

import Base: eltype, length, ndims, size, axes, eachindex, stride, strides
MacroTools.@forward PrintWrapper.x eltype, length, ndims, size, axes, eachindex, stride,
strides
Base.getindex(A::PrintWrapper, idxs...) = A.f(A.x, A.x[idxs...], idxs)

function lazypair(A, x, idxs)
    syms = symnames(typeof(A))
    II = LinearIndices(A)
    key = eltype(syms) <: Symbol ? syms[II[idxs...]] :
          findfirst(syms) do sym
        ii = idxs isa Tuple ? II[idxs...] : II[idxs]
        sym isa Tuple ? ii in II[sym...] : ii in II[sym]
    end
    key => x
end

Base.show(io::IO, ::MIME"text/plain", x::Union{LArray, SLArray}) = show(io, x)
function Base.show(io::IO, x::Union{LArray, SLArray})
    syms = symnames(typeof(x))
    n = length(syms)
    pwrapper = PrintWrapper(lazypair, x)
    if io isa IOContext && get(io, :limit, false) &&
       displaysize(io) isa Tuple{Integer, Integer}
        io = IOContext(io, :limit => true, :displaysize => cld.(2 .* displaysize(io), 3))
    end
    println(io, summary(x), ':')
    Base.print_array(io, pwrapper)
end

Base.NamedTuple(x::Union{LArray, SLArray}) = NamedTuple{symnames(typeof(x))}(x.__x)
@inline Base.reshape(a::SLArray, s::Size) = StaticArrays.similar_type(a, s)(Tuple(a))

function ArrayInterface.ismutable(::Type{<:LArray{T, N, D, Syms}}) where {T, N, D, Syms}
    ArrayInterface.ismutable(T)
end
ArrayInterface.can_setindex(::Type{<:SLArray}) = false

lenfun(x) = length(x)
lenfun(::Symbol) = 1
function ArrayInterface.undefmatrix(x::LArray{T, N, D, Syms}) where {T, N, D, Syms}
    n = sum(lenfun, Syms)
    similar(x.__x, n, n)
end

function PreallocationTools.get_tmp(dc::PreallocationTools.DiffCache,
        u::LArray{T, N, D, Syms}) where {T <: ForwardDiff.Dual,
        N, D, Syms}
    nelem = div(sizeof(T), sizeof(eltype(dc.dual_du))) * length(dc.du)
    if nelem > length(dc.dual_du)
        PreallocationTools.enlargedualcache!(dc, nelem)
    end
    _x = ArrayInterface.restructure(dc.du, reinterpret(T, view(dc.dual_du, 1:nelem)))
    LabelledArrays.LArray{T, N, D, Syms}(_x)
end

export SLArray, LArray, SLVector, LVector, @SLVector, @LArray, @LVector, @SLArray

export @SLSliced, @LSliced

export symbols, dimSymbols, rowSymbols, colSymbols

end # module
