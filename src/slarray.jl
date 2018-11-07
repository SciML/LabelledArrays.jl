struct SLArray{S,T,N,A <: StaticArray{S,T,N},Syms} <: StaticArray{S,T,N}
    __x::A
    SLArray{Syms}(__x::StaticArray{S,T,N}) where {S,T,N,Syms} = new{S,T,N,StaticArray{S,T,N},Syms}(T.(__x))
    SLArray{S,T,N,Syms}(__x::SVector) where {S,T,N,Syms} = new{S,T,N,typeof(__x),Syms}(T.(__x))
    SLArray{S,T,N,Syms}(x::Tuple) where {S,T,N,Syms} = new{S,T,N,typeof(__x),Syms}(SVector{S}(T.(x)))
end

# Implement the StaticVector interface
@inline Base.getindex(x::SLArray, i::Int) = getfield(x,:__x)[i]
@inline Base.Tuple(x::SLArray) = Tuple(x.__x)
function StaticArrays.similar_type(::Type{SLArray{N,T,Syms}}, ::Type{NewElType},
    ::Size{NewSize}) where {N,T,Syms,NewElType,NewSize}
    @assert length(NewSize) == 1 && NewSize[1] == N
    SLArray{N,NewElType,Syms}
end

# Fast indexing by labels (x.a or x[:a], internally x[Val(:a)])
Base.propertynames(::SLArray{N,T,Syms}) where {N,T,Syms} = Syms
symnames(::Type{SLArray{N,T,Syms}}) where {N,T,Syms} = Syms
@inline function Base.getproperty(x::SLArray,s::Symbol)
    s == :__x ? getfield(x,:__x) : x[Val(s)]
end
@inline Base.getindex(x::SLArray,s::Symbol) = x[Val(s)]
@inline @generated function Base.getindex(x::SLArray,::Val{s}) where {s}
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
    quote
        SLArray{($(length(syms.args)),),$(esc(E)),1,$syms}
    end
end
