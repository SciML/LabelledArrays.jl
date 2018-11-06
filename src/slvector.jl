struct SLVector{N,T,Syms} <: StaticVector{N,T}
    __x::SVector{N,T} # allow general StaticVector?
    SLVector{N,T,Syms}(__x::SVector{N,T}) where {N,T,Syms} = new{N,T,Syms}(__x)
    SLVector{N,T,Syms}(x::NTuple{N,T}) where {N,T,Syms} = new{N,T,Syms}(SVector{N}(x))
end

# Implement the StaticVector interface
@inline Base.getindex(x::SLVector, i::Int) = getfield(x,:__x)[i]
@inline Base.Tuple(x::SLVector) = Tuple(x.__x)
function StaticArrays.similar_type(::Type{SLVector{N,T,Syms}}, ::Type{NewElType},
    ::Size{NewSize}) where {N,T,Syms,NewElType,NewSize}
    @assert length(NewSize) == 1 && NewSize[1] == N
    SLVector{N,NewElType,Syms}
end

# Fast indexing by labels (x.a or x[:a], internally x[Val(:a)])
Base.propertynames(::SLVector{N,T,Syms}) where {N,T,Syms} = Syms
symnames(::Type{SLVector{N,T,Syms}}) where {N,T,Syms} = Syms
@inline function Base.getproperty(x::SLVector,s::Symbol)
    s == :__x ? getfield(x,:__x) : x[Val(s)]
end
@inline Base.getindex(x::SLVector,s::Symbol) = x[Val(s)]
@inline @generated function Base.getindex(x::SLVector,::Val{s}) where {s}
    idx = findfirst(==(s),symnames(x))
    :(x.__x[$idx])
end

"""
    @SLVector ElementType Names

Creates an anonymous function that builds a labelled static vector with eltype
`ElementType` with names determined from the `Names`.

For example:

```julia
ABC = @SLVector Float64 (:a,:b,:c)
x = ABC(1.0,2.5,3.0)
x.a == 1.0
x.b == 2.5
x.c == x[3]
```

"""
macro SLVector(E,syms)
    return quote
        function (vals...,)
            SLVector{$(length(syms.args)),$(esc(E)),$syms}(vals)
        end
    end
end
