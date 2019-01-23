struct SLArray{S,N,L,Syms,T} <: StaticArray{S,T,N}
  __x::SArray{S,T,N,L}
  #SLArray{Syms}(__x::StaticArray{S,T,N}) where {S,N,Syms,T} = new{S,N,Syms,T}(__x)
  Base.@pure SLArray{S,N,Syms,T}(__x::SArray) where {S,N,Syms,T} = new{S,N,length(__x),Syms,T}(convert.(T,__x))
  Base.@pure SLArray{S,N,Syms}(x::Tuple) where {S,N,Syms} = new{S,N,ndims(x),Syms,eltype(x)}(SArray{S,eltype(x),N}(x))
  Base.@pure SLArray{S,N,Syms,T}(x::Tuple) where {S,N,Syms,T} = new{S,N,ndims(x),Syms,T}(SArray{S,T,N}(T.(x)))
end

#####################################
# NamedTuple compatibility
#####################################
## SLArray to named tuple
function Base.convert(::Type{NamedTuple}, x::SLArray{S,N,L,Syms,T}) where {S,N,L,Syms,T}
  tup = NTuple{length(Syms),T}(x)
  NamedTuple{Syms,typeof(tup)}(tup)
end

## Named tuple to SLArray
#=
  1. `SLArray{Tuple{2,2}}((a=1, b=2, c=3, d=4))` (need to specify size)
  2. `SLArray{Tuple{2,2}}(a=1, b=2, c=3, d=4)` : alternative form using kwargs
  3. `SLVector((a=1, b=2))` : infer size for vectors
  4. `SLVector(a=1, b=2)` : alternative form using kwargs
=#
function SLArray{Size}(tup::NamedTuple{Syms,Tup}) where {Size,Syms,Tup}
  __x = Tup(tup) # drop symbols
  SLArray{Size,length(Size.parameters),Syms}(__x)
end
SLArray{Size}(;kwargs...) where {Size} = SLArray{Size}(kwargs.data)
SLVector(tup::NamedTuple) = SLArray{Tuple{length(tup)}}(tup)
SLVector(;kwargs...) = SLVector(kwargs.data)

## pairs iterator
Base.pairs(x::SLArray{S,N,L,Syms,T}) where {S,N,L,Syms,T} =
    # (label => getproperty(x, label) for label in Syms) # not type stable?
    (Syms[i] => x[i] for i in 1:length(Syms))

#####################################
# StaticArray Interface
#####################################
@inline Base.getindex(x::SLArray, i::Int) = getfield(x,:__x)[i]
@inline Base.Tuple(x::SLArray) = Tuple(x.__x)
function StaticArrays.similar_type(::Type{SLArray{S,N,L,Syms,T}}, ::Type{NewElType},
    ::Size{NewSize}) where {S,N,L,Syms,T,NewElType,NewSize}
  @assert length(NewSize) == N
  SLArray{S,N,Syms,NewElType}
end

Base.propertynames(::SLArray{S,N,L,Syms,T}) where {S,N,L,Syms,T} = Syms
symnames(::Type{SLArray{S,N,L,Syms,T}}) where {S,N,L,Syms,T} = Syms
@inline function Base.getproperty(x::SLArray,s::Symbol)
  s == :__x ? getfield(x,:__x) : x[s]
end
@inline function Base.getindex(x::SLArray,s::Symbol)
    getindex(x,Val(s))
end
@inline @generated function Base.getindex(x::SLArray,::Val{s}) where s
    idx = findfirst(y->y==s,symnames(x))
    :(getfield(x,:__x)[$idx])
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
