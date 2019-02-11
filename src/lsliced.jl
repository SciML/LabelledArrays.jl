struct LSlicedMatrix{T,N,Syms1,Syms2} <: DenseArray{T,N}
  __x::Array{T,N}
  LSlicedMatrix{Syms1,Syms2}(__x) where {Syms1,Syms2} = new{eltype(__x),ndims(__x),Syms1,Syms2}(__x)
  LSlicedMatrix{T,N,Syms1,Syms2}(__x) where {T,N,Syms1,Syms2} = new{T,N,Syms1,Syms2}(__x)
end

# Allow chained getproperty with partial application of symbol lookup
struct SlicePartial{Sym1,P}
    __p::P
end


Base.size(x::LSlicedMatrix) = size(getfield(x,:__x))
Base.propertynames(::LSlicedMatrix{T,A,Syms1,Syms2}) where {T,A,Syms1,Syms2} = Syms1, Syms2
symnames(::Type{LSlicedMatrix{T,A,Syms1,Syms2}}) where {T,A,Syms1,Syms2} = Syms1, Syms2

@inline function Base.getproperty(p::SlicePartial{Val{s1}},s2::Symbol) where s1
  getfield(p, :__p)[Val(s1), Val(s2)]
end

@inline function Base.setproperty!(p::SlicePartial{Val{s1}},s2::Symbol,y) where s1
  getfield(p, :__p)[Val(s1), Val(s2)] = y
end


@inline function Base.getproperty(x::Union{LSlicedMatrix,SLSlicedMatrix},s::Symbol)
  if s == :__x
    return getfield(x,:__x)
  end
  SlicePartial{Val{s},typeof(x)}(x)
end

@inline function Base.setproperty!(x::Union{LSlicedMatrix,SLSlicedMatrix},s::Symbol,y)
  if s == :__x
    return setfield!(x,:__x,y)
  end
  x[s] = y end

@inline Base.getindex(x::Union{LSlicedMatrix,SLSlicedMatrix},i::Int...) = getfield(x,:__x)[i...]
@inline Base.getindex(x::Union{LSlicedMatrix,SLSlicedMatrix},s1::Symbol,s2::Symbol) = getindex(x,Val(s1),Val(s2))
@inline Base.getindex(x::Union{LSlicedMatrix,SLSlicedMatrix},i1::Int,s2::Symbol) = getindex(x,i1::Int,Val(s2))
@inline Base.getindex(x::Union{LSlicedMatrix,SLSlicedMatrix},s1::Symbol,i2) = getindex(x,Val(s1),i2)

@inline @generated function Base.getindex(x::Union{LSlicedMatrix,SLSlicedMatrix},::Val{s1},::Val{s2}) where {s1, s2}
  idx1 = findfirst(y->y==s1,symnames(x)[1])
  idx2 = findfirst(y->y==s2,symnames(x)[2])
  :(getfield(x,:__x)[$idx1, $idx2])
end

@inline @generated function Base.getindex(x::Union{LSlicedMatrix,SLSlicedMatrix},i1::Int,::Val{s2}) where s2
  idx2 = findfirst(y->y==s2,symnames(x)[2])
  :(getfield(x,:__x)[i1, $idx2])
end

@inline @generated function Base.getindex(x::Union{LSlicedMatrix,SLSlicedMatrix},::Val{s1},i2::Int) where s1
  idx1 = findfirst(y->y==s1,symnames(x)[1])
  :(getfield(x,:__x)[$idx1, i2])
end


@inline Base.setindex!(x::LSlicedMatrix,y,i...) = getfield(x,:__x)[i...] = y
@inline Base.setindex!(x::LSlicedMatrix,y,s1::Symbol,s2::Symbol) = setindex!(x,y,Val(s1),Val(s2))
@inline Base.setindex!(x::LSlicedMatrix,y,s1::Symbol,i2) = setindex!(x,y,Val(s1),i2)
@inline Base.setindex!(x::LSlicedMatrix,y,i1,s2::Symbol) = setindex!(x,y,i1,Val(s2))
@inline Base.setindex!(x::LSlicedMatrix,y,s1::Symbol,i2::Val) = setindex!(x,y,Val(s1),i2)
@inline Base.setindex!(x::LSlicedMatrix,y,i1::Val,s2::Symbol) = setindex!(x,y,i1,Val(s2))

@inline @generated function Base.setindex!(x::LSlicedMatrix,y,::Val{s1},::Val{s2}) where {s1, s2}
    idx1 = findfirst(y->y==s1,symnames(x)[1])
    idx2 = findfirst(y->y==s2,symnames(x)[2])
    :(x.__x[$idx1, $idx2] = y)
end
@inline @generated function Base.setindex!(x::LSlicedMatrix,y,::Val{s1},i2::Number) where s1
    idx1 = findfirst(y->y==s1,symnames(x)[1])
    :(x.__x[$idx1, i2] = y)
end
@inline @generated function Base.setindex!(x::LSlicedMatrix,y,i1::Number,::Val{s2}) where s2
    idx2 = findfirst(y->y==s2,symnames(x)[2])
    :(x.__x[i1, $idx2] = y)
end



function Base.similar(x::LSlicedMatrix{T,K,Syms1,Syms2},::Type{S},dims::NTuple{N,Int}) where {T,Syms1,Syms2,S,N,K}
  tmp = similar(x.__x,S,dims)
  LSlicedMatrix{S,N,Syms1,Syms2}(tmp)
end

# enable the usage of LAPACK
Base.unsafe_convert(::Type{Ptr{T}}, a::LSlicedMatrix{T,N,S}) where {T,N,S} = Base.unsafe_convert(Ptr{T}, getfield(a,:__x))

#####################################
# Broadcast
#####################################
struct LASlicedStyle{T,N,L1,L2} <: Broadcast.AbstractArrayStyle{N} end
LASlicedStyle{T,N,L1,L2}(x::Val{2}) where {T,N,L1,L2} = LASlicedStyle{T,N,L1,L2}()
Base.BroadcastStyle(::Type{LSlicedMatrix{T,N,L1,L2}}) where {T,N,L1,L2} = LASlicedStyle{T,N,L1,L2}()
Base.BroadcastStyle(::LabelledArrays.LASlicedStyle{T,N,L1,L2}, ::LabelledArrays.LASlicedStyle{E,N,L1,L2}) where {T,E,N,L1,L2} = 
  LASlicedStyle{promote_type(T,E),N,L1,L2}()

function Base.similar(bc::Broadcast.Broadcasted{LASlicedStyle{T,N,L1,L2}}, ::Type{ElType}) where {T,N,L1,L2,ElType}
  return LSlicedMatrix{ElType,N,L1,L2}(similar(Array{ElType,N},axes(bc)))
end

"""
    @LSlicedMatrix Eltype Size Names
    @LSlicedMatrix Values Names

Creates an `LSlicedMatrix` with names determined from the `Names`
vector and values determined from the `Values` array. Otherwise, and eltype
and size are used to make an LSlicedMatrix with undefined values.

For example:

    a = @LSlicedMatrix Float64 (4,2) (:a,:b,:c,:d) (:x,:y,:z)
    b = @LSlicedMatrix [1 2; 3 4; 5 6] (:a,:b,:c) (:x,:y)
"""
macro LSlicedMatrix(vals,syms1,syms2)
  return quote
    LSlicedMatrix{$syms1,$syms2}($vals)
  end
end

macro LSlicedMatrix(type,size,syms1,syms2)
  return quote
    LSlicedMatrix{$syms1,$syms2}(Array{$type}(undef,$size...))
  end
end
