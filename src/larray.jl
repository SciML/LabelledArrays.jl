struct LArray{T,N,D<:AbstractArray{T,N},Syms} <: DenseArray{T,N}
  __x::D
  LArray{Syms}(__x) where Syms = new{eltype(__x),ndims(__x),typeof(__x),Syms}(__x)
  LArray{T,N,D,Syms}(__x) where {T,N,D,Syms} = new{T,N,D,Syms}(__x)
end

#####################################
# NamedTuple compatibility
#####################################
## LArray to named tuple
function Base.convert(::Type{NamedTuple}, x::LArray{T,N,D,Syms}) where {T,N,D,Syms}
    tup = NTuple{length(Syms),T}(x)
    NamedTuple{Syms,typeof(tup)}(tup)
end
Base.keys(x::LArray{T,N,D,Syms}) where {T,N,D,Syms} = Syms

## Named tuple to LArray
#=
    1. `LArray((2,2), (a=1, b=2, c=3, d=4))` (need to specify size)
    2. `LArray((2,2); a=1, b=2, c=3, d=4)` : alternative form using kwargs
    3. `LVector((a=1, b=2))` : can infer size for vectors
    4. `LVector(a=1, b=2)` : alternative form using kwargs
=#
function LArray(size::NTuple{S,Int}, tup::NamedTuple{Syms,Tup}) where {S,Syms,Tup}
    __x = reshape(collect(tup), size)
    LArray{Syms}(__x)
end
LArray(size::NTuple{S,Int}; kwargs...) where {S} = LArray(size, kwargs.data)
LVector(tup::NamedTuple) = LArray((length(tup),), tup)
LVector(;kwargs...) = LVector(kwargs.data)

## pairs iterator
Base.pairs(x::LArray{T,N,D,Syms}) where {T,N,D,Syms} =
    # (label => getproperty(x, label) for label in Syms) # not type stable?
    (Syms[i] => x[i] for i in 1:length(Syms))

#####################################
# Array Interface
#####################################
Base.size(x::LArray) = size(getfield(x,:__x))
@inline Base.getindex(x::LArray,i...) = getfield(x,:__x)[i...]
@inline Base.setindex!(x::LArray,y,i...) = getfield(x,:__x)[i...] = y

Base.propertynames(::LArray{T,N,D,Syms}) where {T,N,D,Syms} = Syms
symnames(::Type{LArray{T,N,D,Syms}}) where {T,N,D,Syms} = Syms

Base.@propagate_inbounds function Base.getproperty(x::LArray,s::Symbol)
    if s == :__x
        return getfield(x,:__x)
    end
    return getindex(x,Val(s))
end

Base.@propagate_inbounds function Base.setproperty!(x::LArray,s::Symbol,y)
    if s == :__x
        return setfield!(x,:__x,y)
    end
    setindex!(x,y,Val(s))
end

Base.@propagate_inbounds Base.getindex(x::LArray,s::Symbol) = getindex(x,Val(s))
Base.@propagate_inbounds Base.getindex(x::LArray,s::Val) = __getindex(x, s)
Base.@propagate_inbounds Base.setindex!(x::LArray,v,s::Symbol) = setindex!(x,v,Val(s))

@generated function Base.setindex!(x::LArray,y,::Val{s}) where s
  syms = symnames(x)
  if syms isa NamedTuple
    idxs = syms[s]
    return :(Base.@_propagate_inbounds_meta; setindex!(getfield(x,:__x), y, $idxs))
  else # Tuple
    idx = findfirst(y->y==s,symnames(x))
    return :(Base.@_propagate_inbounds_meta; setindex!(getfield(x,:__x),y,$idx))
  end
end

Base.getindex(x::LArray,s::AbstractArray{Symbol,1}) = [getindex(x,si) for si in s]

function Base.similar(x::LArray{T,K,D,Syms},::Type{S},dims::NTuple{N,Int}) where {T,K,D,Syms,S,N}
    tmp = similar(x.__x,S,dims)
    LArray{S,N,typeof(tmp),Syms}(tmp)
end

# Allow copying LArray of uninitialized data, as with regular Array
Base.copy(x::LArray) = typeof(x)(copy(getfield(x,:__x)))
Base.deepcopy(x::LArray) = typeof(x)(deepcopy(getfield(x,:__x)))

# enable the usage of LAPACK
Base.unsafe_convert(::Type{Ptr{T}}, a::LArray{T,N,D,S}) where {T,N,D,S} = Base.unsafe_convert(Ptr{T}, getfield(a,:__x))

#####################################
# Broadcast
#####################################
struct LAStyle{T,N,L} <: Broadcast.AbstractArrayStyle{N} end
LAStyle{T,N,L}(x::Val{i}) where {T,N,L,i} = LAStyle{T,N,L}()
Base.BroadcastStyle(::Type{LArray{T,N,D,L}}) where {T,N,D,L} = LAStyle{T,N,L}()
Base.BroadcastStyle(::LabelledArrays.LAStyle{T,N,L}, ::LabelledArrays.LAStyle{E,N,L}) where{T,E,N,L} =
    LAStyle{promote_type(T,E),N,L}()

function Base.similar(bc::Broadcast.Broadcasted{LAStyle{T,N,L}}, ::Type{ElType}) where {T,N,L,ElType}
    tmp = similar(Array{ElType},axes(bc))
    if prod(length.(axes(bc))) != prod(length.(axes(Tuple(L))))
        return tmp
    else
        return LArray{ElType,N,typeof(tmp),L}(tmp)
    end
end

"""
    @LArray Eltype Size Names
    @LArray Values Names

Creates an `LArray` with names determined from the `Names`
vector and values determined from the `Values` array. Otherwise, and eltype
and size are used to make an LArray with undefined values.

For example:

    a = @LArray Float64 (2,2) (:a,:b,:c,:d)
    b = @LArray [1,2,3] (:a,:b,:c)
    c = @LArray [1,2,3] (a=1:2, b=2:3)
    d = @LArray [1 2; 3 4] (a=(2, :), b=2:3)
"""
macro LArray(vals,syms)
  vals = esc(vals)
  syms = esc(syms)
  return quote
      LArray{$syms}($vals)
  end
end

macro LArray(type,size,syms)
  type = esc(type)
  size = esc(size)
  syms = esc(syms)
  return quote
      LArray{$syms}(Array{$type}(undef,$size...))
  end
end

"""
    @LVector Type Names

Creates an `LArray` of dimension 1 with eltype and undefined values.
Length is via the number of names given.

For example:

    b = @LVector [1,2,3] (:a,:b,:c)
"""
macro LVector(type,syms)
  type = esc(type)
  syms = esc(syms)
  return quote
      LArray{$syms}(Vector{$type}(undef,length($syms)))
  end
end

#the following gives errror: TypeError: in <:, expected Type, got TypeVar
#symbols(::LArray{T,N,D<:AbstractArray{T,N},Syms}) where {T,N,D,Syms} = Syms

"""
    symbols(::LArray{T,N,D,Syms})

Returns the labels of the `LArray` .

For example:

    z = @LVector Float64 (:a,:b,:c,:d)
    symbols(z)  # NTuple{4,Symbol} == (:a, :b, :c, :d)
"""
symbols(::LArray{T,N,D,Syms}) where {T,N,D,Syms} = Syms isa NamedTuple ? keys(Syms) : Syms


# copy constructors

"""
LVector(v1::Union{SLArray,LArray}; kwargs...)

Creates a 1D copy of v1 with corresponding items in kwargs replaced.

For example:

    z = LVector(a=1, b=2, c=3);
    z2 = LVector(z; c=30)
"""
function LVector(v1::Union{SLArray,LArray}; kwargs...)
  t2 = merge(convert(NamedTuple, v1), kwargs.data)
  LVector(t2)
end


"""
LVector(v1::Union{SLArray,LArray}; kwargs...)

Creates a copy of v1 with corresponding items in kwargs replaced.

For example:

    ABCD = @SLArray (2,2) (:a,:b,:c,:d);
    B = ABCD(1,2,3,4);
    B2 = LArray(B; c=30 )
"""
function LArray(v1::Union{SLArray,LArray}; kwargs...)
  t2 = merge(convert(NamedTuple, v1), kwargs.data)
  LArray(size(v1),t2)
end



# moved vom slarray.js to here because LArray need to be known
"""
SLVector(v1::SLArray; kwargs...)

Creates a 1D copy of v1 with corresponding items in kwargs replaced.

For example:

    z = SLVector(a=1, b=2, c=3);
    z2 = SLVector(z; c=30)
"""
function SLVector(v1::Union{SLArray,LArray}; kwargs...)
  t2 = merge(convert(NamedTuple, v1), kwargs.data)
  SLVector(t2)
end

"""
SLVector(v1::SLArray; kwargs...)

Creates a copy of v1 with corresponding items in kwargs replaced.

For example:

    ABCD = @SLArray (2,2) (:a,:b,:c,:d);
    B = ABCD(1,2,3,4);
    B2 = SLArray(B; c=30 )
"""
function SLArray(v1::Union{SLArray{S,T,N,L,Syms},LArray{T,N,D,Syms}}; kwargs...) where {S,T,N,L,Syms,D}
  t2 = merge(convert(NamedTuple, v1), kwargs.data)
  SLArray{S}(t2)
end
