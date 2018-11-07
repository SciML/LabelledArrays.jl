struct SLArray{S,N,Syms,T} <: StaticArray{S,T,N}
  __x::SArray{S,T,N}
  #SLArray{Syms}(__x::StaticArray{S,T,N}) where {S,N,Syms,T} = new{S,N,Syms,T}(__x)
  SLArray{S,N,Syms,T}(__x::SArray) where {S,N,Syms,T} = new{S,N,Syms,T}(T.(__x))
  SLArray{S,N,Syms}(x::Tuple) where {S,N,Syms} = new{S,N,Syms,eltype(x)}(SArray{S,eltype(x),N}(x))
  SLArray{S,N,Syms,T}(x::Tuple) where {S,N,Syms,T} = new{S,N,Syms,T}(SArray{S,T,N}(T.(x)))
end

# Implement the StaticVector interface
@inline Base.getindex(x::SLArray, i::Int) = getfield(x,:__x)[i]
@inline Base.Tuple(x::SLArray) = Tuple(x.__x)
function StaticArrays.similar_type(::Type{SLArray{S,N,Syms,T}}, ::Type{NewElType},
    ::Size{NewSize}) where {S,T,N,Syms,NewElType,NewSize}
  @assert length(NewSize) == N
  SLArray{S,N,Syms,NewElType}
end

Base.propertynames(::SLArray{S,N,Syms,T}) where {S,N,T,Syms} = Syms
symnames(::Type{SLArray{S,N,Syms,T}}) where {S,N,T,Syms} = Syms
@inline function Base.getproperty(x::SLArray,s::Symbol)
  s == :__x ? getfield(x,:__x) : x[s]
end
@inline function Base.getindex(x::SLArray,s)
  idx = findfirst(==(s),symnames(typeof(x)))
  getfield(x,:__x)[idx]
end

"""
    @SLArray Size Names
    @SLArray Eltype Size Names

Creates an anonymous function that builds a labelled static vector with eltype
`ElType` with names determined from the `Names` with size `Size`. If no eltype
is given, then the eltype is determined from the arguments in the constructor.

For example:

```julia
ABC = @SLArray (2,2) (:a,:b,:c,:d)
x = ABC(1.0,2.5,3.0,5.0)
x.a == 1.0
x.b == 2.5
x.c == x[3]
x.d == x[2,2]
```

"""
macro SLArray(dims,syms)
  dims isa Expr && (dims = dims.args)
  quote
    SLArray{Tuple{$dims...,},$(length(dims)),$syms}
  end
end

macro SLArray(T,dims,syms)
  dims isa Expr && (dims = dims.args)
  quote
    SLArray{Tuple{$dims...,},$(length(dims)),$syms,$T}
  end
end

"""
    @SLVector Names
    @SLVector Eltype Names

Creates an anonymous function that builds a labelled static vector with eltype
`ElementType` with names determined from the `Names`. If no eltype is given,
then the eltype is determined from the values in the constructor.

For example:

```julia
ABC = @SLVector (:a,:b,:c)
x = ABC(1.0,2.5,3.0)
x.a == 1.0
x.b == 2.5
x.c == x[3]
```

"""
macro SLVector(syms)
  n = syms isa Expr ? length(syms.args) : length(syms)
  quote
    SLArray{Tuple{$n},1,$syms}
  end
end

macro SLVector(T,syms)
  n = syms isa Expr ? length(syms.args) : length(syms)
  quote
    SLArray{Tuple{$n},1,$syms,$T}
  end
end
