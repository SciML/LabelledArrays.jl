
const LSliced = LArray{T,N,D,Syms} where {T,N,D<:AbstractArray{T,N},Syms<:Tuple}
const SLSliced = SLArray{S,T,N,L,Syms} where {S,T,N,L,Syms<:Tuple}
const Sliced = Union{SLSliced,LSliced}

# Allow chained getproperty with partial application of the symbol lookup
struct SlicePartial{Syms1,P}
    __p::P
end

@inline function Base.getproperty(p::SlicePartial{Val{s1}},s2::Symbol) where s1
  getfield(p, :__p)[Val(s1), Val(s2)]
end

@inline function Base.setproperty!(p::SlicePartial{Val{s1}},s2::Symbol,y) where s1
  getfield(p, :__p)[Val(s1), Val(s2)] = y
end

@inline function Base.getproperty(x::Sliced,s::Symbol)
  if s == :__x
    return getfield(x,:__x)
  end
  SlicePartial{Val{s},typeof(x)}(x)
end


#####################################
# Array Interface
# (getindex/getproperty methods are shared with SLArray
#####################################
Base.propertynames(::LArray{T,N,D,S}) where {T,N,D,S<:Tuple{Syms1,Syms2}} where {Syms1,Syms2} = Syms1, Syms2
symnames(::Type{LArray{T,N,D,S}}) where {T,N,D,S<:Tuple{Syms1,Syms2}} where {Syms1,Syms2} = Syms1, Syms2

@inline Base.getindex(x::Sliced,i::Int...) = getfield(x,:__x)[i...]
@inline Base.getindex(x::Sliced,s1::Symbol,s2::Symbol) = getindex(x,Val(s1),Val(s2))
@inline Base.getindex(x::Sliced,i1,s2::Symbol) = getindex(x,i1,Val(s2))
@inline Base.getindex(x::Sliced,s1::Symbol,i2) = getindex(x,Val(s1),i2)

@inline @generated function Base.getindex(x::Sliced,::Val{s1},::Val{s2}) where {s1,s2}
  idx1 = findfirst(y->y==s1,symnames(x)[1])
  idx2 = findfirst(y->y==s2,symnames(x)[2])
  :(getfield(x,:__x)[$idx1, $idx2])
end

@inline @generated function Base.getindex(x::Sliced,i1::Number,::Val{s2}) where s2
  idx2 = findfirst(y->y==s2,symnames(x)[2])
  :(getfield(x,:__x)[i1, $idx2])
end

@inline @generated function Base.getindex(x::Sliced,::Val{s1},i2::Number) where s1
  idx1 = findfirst(y->y==s1,symnames(x)[1])
  :(getfield(x,:__x)[$idx1, i2])
end



@inline Base.setindex!(x::LSliced,y,i...) = getfield(x,:__x)[i...] = y
@inline Base.setindex!(x::LSliced,y,s1::Symbol,s2::Symbol) = setindex!(x,y,Val(s1),Val(s2))
@inline Base.setindex!(x::LSliced,y,s1::Symbol,i2) = setindex!(x,y,Val(s1),i2)
@inline Base.setindex!(x::LSliced,y,i1,s2::Symbol) = setindex!(x,y,i1,Val(s2))

@inline @generated function Base.setindex!(x::LSliced,y,::Val{s1},::Val{s2}) where {s1, s2}
    idx1 = findfirst(y->y==s1,symnames(x)[1])
    idx2 = findfirst(y->y==s2,symnames(x)[2])
    :(x.__x[$idx1, $idx2] = y)
end

@inline @generated function Base.setindex!(x::LSliced,y,::Val{s1},i2::Number) where s1
    idx1 = findfirst(y->y==s1,symnames(x)[1])
    :(x.__x[$idx1, i2] = y)
end

@inline @generated function Base.setindex!(x::LSliced,y,i1::Number,::Val{s2}) where s2
    idx2 = findfirst(y->y==s2,symnames(x)[2])
    :(x.__x[i1, $idx2] = y)
end


#####################################
# Broadcast
#####################################
LAStyle{T,N,Syms}(x::Val{i}) where {T,N,Syms<:Tuple,i} = LAStyle{T,N,Syms}()

"""
    @LSliced Eltype Size Names
    @LSliced Values Names

Creates a `LArray` where the rows and columns are labelled instead of individual cells.
Names are determined from the `Names` tuples and values determined from the `Values` array.
Otherwise, and eltype and size are used to make an LArray with undefined values.

For example:

    a = @LSliced Float64 (4,2) (:a,:b,:c,:d), (:x,:y,:z)
    b = @LSliced [1 2; 3 4; 5 6] (:a,:b,:c), (:x,:y)
"""
macro LSliced(vals,syms)
  vals = esc(vals)
  syms = esc(syms)
  return quote
      LArray{Tuple{$syms...,}}($vals)
  end
end

macro LSliced(type,size,syms)
  type = esc(type)
  size = esc(size)
  syms = esc(syms)
  return quote
      LArray{Tuple{$syms...,}}(Array{$type}(undef,$size...))
  end
end


# """
# dimSymbols(dimSymbols(::LArray{T,N,D,Syms}, dim::Int) where {Syms<:Tuple}

# Returns the labels of the `LArray` associated with dimension `dim`.

# For example:

#     A = @LSliced [1 2; 3 4; 5 6] (:a,:b,:c), (:x, :y)
#     dimSymbols(A,1)  # (:a, :b, :c)
# """
# dimSymbols(::LArray{T,N,D,Syms}, dim::Int) where
# {T,N,D<:AbstractArray{T,N},Syms<:Tuple} = Syms.parameters[dim]

# "returns dimSymbols(,1)"
# rowSymbols(::LArray{T,N,D,Syms}) where
# {T,N,D<:AbstractArray{T,N},Syms<:Tuple} = Syms.parameters[1]

# "returns dimSymbols(,2)"
# colSymbols(::LArray{T,N,D,Syms}) where
# {T,N,D<:AbstractArray{T,N},Syms<:Tuple} = Syms.parameters[2]

symbols(::LArray{T,N,D,Syms}) where
{rows,cols,T,N,D,Syms<:Tuple{rows,cols}} = rows,cols
