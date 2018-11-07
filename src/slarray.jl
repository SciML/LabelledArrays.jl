struct SLArray{S,T,N,Syms} <: StaticArray{S,T,N}
  __x::SArray{S,T,N}
  #SLArray{Syms}(__x::StaticArray{S,T,N}) where {S,T,N,Syms} = new{S,T,N,Syms}(__x)
  SLArray{S,T,N,Syms}(__x::SVector) where {S,T,N,Syms} = new{S,T,N,Syms}(T.(__x))
  SLArray{S,T,N,Syms}(x::Tuple) where {S,T,N,Syms} = new{S,T,N,Syms}(SArray{S,T,N}(T.(x)))
end

# Implement the StaticVector interface
@inline Base.getindex(x::SLArray, i::Int) = getfield(x,:__x)[i]
@inline Base.Tuple(x::SLArray) = Tuple(x.__x)
function StaticArrays.similar_type(::Type{SLArray{S,T,N,Syms}}, ::Type{NewElType},
    ::Size{NewSize}) where {S,T,N,Syms,NewElType,NewSize}
  @assert length(NewSize) == N
  SLArray{S,NewElType,N,Syms}
end

Base.propertynames(::SLArray{S,T,N,Syms}) where {S,N,T,Syms} = Syms
symnames(::Type{SLArray{S,T,N,Syms}}) where {S,N,T,Syms} = Syms
@inline function Base.getproperty(x::SLArray,s::Symbol)
  s == :__x ? getfield(x,:__x) : x[s]
end
@inline function Base.getindex(x::SLArray,s)
  idx = findfirst(==(s),symnames(typeof(x)))
  getfield(x,:__x)[idx]
end

"""
    @SLArray ElementType Size Names

Creates an anonymous function that builds a labelled static vector with eltype
`ElementType` with names determined from the `Names`.

For example:

```julia
ABC = @SLArray Float64 (2,2) (:a,:b,:c,:d)
x = ABC(1.0,2.5,3.0,5.0)
x.a == 1.0
x.b == 2.5
x.c == x[3]
x.d == x[2,2]
```

"""
macro SLArray(E,dims,syms)
  dims isa Expr && (dims = dims.args)
  quote
    SLArray{Tuple{$dims...,},$(esc(E)),$(length(dims)),$syms}
  end
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
  n = syms isa Expr ? length(syms.args) : length(syms)
  quote
    SLArray{Tuple{$n},$(esc(E)),1,$syms}
  end
end
