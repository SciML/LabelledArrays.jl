struct SLSlicedMatrix{S,N,Syms1,Syms2,T} <: StaticArray{S,T,N}
  __x::SArray{S,T,N}
  #SLSlicedMatrix{Syms1,Syms2}(__x::StaticArray{S,T,N}) where {S,N,Syms1,Syms2,T} = new{S,N,Syms1,Syms2,T}(__x)
  SLSlicedMatrix{S,N,Syms1,Syms2,T}(__x::SArray) where {S,N,Syms1,Syms2,T} = new{S,N,Syms1,Syms2,T}(T.(__x))
  SLSlicedMatrix{S,N,Syms1,Syms2}(x::Tuple) where {S,N,Syms1,Syms2} = new{S,N,Syms1,Syms2,eltype(x)}(SArray{S,eltype(x),N}(x))
  SLSlicedMatrix{S,N,Syms1,Syms2,T}(x::Tuple) where {S,N,Syms1,Syms2,T} = new{S,N,Syms1,Syms2,T}(SArray{S,T,N}(T.(x)))
end

# Implement the StaticVector interface
@inline Base.getindex(x::SLSlicedMatrix, i::Int) = getfield(x,:__x)[i]
@inline Base.Tuple(x::SLSlicedMatrix) = Tuple(x.__x)
function StaticArrays.similar_type(::Type{SLSlicedMatrix{S,N,Syms1,Syms2,T}}, ::Type{NewElType},
    ::Size{NewSize}) where {S,T,N,Syms1,Syms2,NewElType,NewSize}
  @assert length(NewSize) == N
  SLSlicedMatrix{S,N,Syms1,Syms2,NewElType}
end

Base.propertynames(::SLSlicedMatrix{S,N,Syms1,Syms2,T}) where {S,N,T,Syms1,Syms2} = Syms1,Syms2
symnames(::Type{SLSlicedMatrix{S,N,Syms1,Syms2,T}}) where {S,N,T,Syms1,Syms2} = Syms1,Syms2

"""
    @SLSlicedMatrix Size Names1 Names2
    @SLSlicedMatrix Eltype Size Names1 Names2

Creates an anonymous function that builds a labelled static vector with eltype
`ElType` with names determined from the `Names` with size `Size`. If no eltype
is given, then the eltype is determined from the arguments in the constructor.

For example:

```julia
ABC = @SLSlicedMatrix (4,2) (:a,:b,:c,:d) (:x,:y)
x = ABC([1.0 2.5; 3.0 5.0; 9.0 11.4; 12.9 17.7])
x.a.x == 1.0
x.a.y == 2.5
x.c.x == x[3,1]
x.d.y == x[4,2]
```

"""
macro SLSlicedMatrix(dims,syms1,syms2)
  dims isa Expr && (dims = dims.args)
  quote
    SLSlicedMatrix{Tuple{$dims...,},$(length(dims)),$syms1,$syms2}
  end
end

macro SLSlicedMatrix(T,dims,syms1,syms2)
  dims isa Expr && (dims = dims.args)
  quote
    SLSlicedMatrix{Tuple{$dims...,},$(length(dims)),$syms1,$syms2,$T}
  end
end
