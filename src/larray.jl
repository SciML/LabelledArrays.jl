struct LArray{T, N, D <: AbstractArray{T, N}, Syms} <: DenseArray{T, N}
    __x::D
    LArray{Syms}(__x) where {Syms} = new{eltype(__x), ndims(__x), typeof(__x), Syms}(__x)
    LArray{T, N, D, Syms}(__x) where {T, N, D, Syms} = new{T, N, D, Syms}(__x)
end

function LArray{T, N, D, Syms}(::UndefInitializer, n::Int64) where {T, N, D, Syms}
    @assert sum(lenfun, Syms) == n
    LArray{T, N, D, Syms}(similar(D, n))
end

#####################################
# NamedTuple compatibility
#####################################
## LArray to named tuple
function Base.convert(::Type{NamedTuple}, x::LArray{T, N, D, Syms}) where {T, N, D, Syms}
    tup = NTuple{length(Syms), T}(x)
    NamedTuple{Syms, typeof(tup)}(tup)
end
Base.keys(x::LArray{T, N, D, Syms}) where {T, N, D, Syms} = Syms

## Named tuple to LArray
#=
    1. `LArray((2,2), (a=1, b=2, c=3, d=4))` (need to specify size)
    2. `LArray((2,2); a=1, b=2, c=3, d=4)` : alternative form using kwargs
    3. `LVector((a=1, b=2))` : can infer size for vectors
    4. `LVector(a=1, b=2)` : alternative form using kwargs
=#
"""
```julia
LArray(::Tuple, ::NamedTuple)
LArray(::Tuple, kwargs)
```

The standard constructors for `LArray`.

For example:

```julia
LArray((2, 2), (a = 1, b = 2, c = 3, d = 4))  # need to specify size
LArray((2, 2); a = 1, b = 2, c = 3, d = 4)
```
"""
function LArray(size::NTuple{S, Int}, tup::NamedTuple{Syms, Tup}) where {S, Syms, Tup}
    __x = reshape(collect(tup), size)
    LArray{Syms}(__x)
end
LArray(size::NTuple{S, Int}; kwargs...) where {S} = LArray(size, values(kwargs))

"""
```julia
LVector(::NamedTuple)
LVector(kwargs)
```

The standard constructor for `LVector`.

For example:

```julia
LVector((a = 1, b = 2))
LVector(a = 1, b = 2)
```
"""
LVector(tup::NamedTuple) = LArray((length(tup),), tup)
LVector(; kwargs...) = LVector(values(kwargs))

## pairs iterator
function Base.pairs(x::LArray{T, N, D, Syms}) where {T, N, D, Syms}
    # (label => getproperty(x, label) for label in Syms) # not type stable?
    (Syms[i] => x[i] for i in 1:length(Syms))
end

#####################################
# Array Interface
#####################################
Base.size(x::LArray) = size(getfield(x, :__x))
Base.@propagate_inbounds Base.getindex(x::LArray, i...) = getfield(x, :__x)[i...]
Base.@propagate_inbounds function Base.setindex!(x::LArray, y, i...)
    getfield(x, :__x)[i...] = y
    return x
end

Base.propertynames(::LArray{T, N, D, Syms}) where {T, N, D, Syms} = Syms
symnames(::Type{LArray{T, N, D, Syms}}) where {T, N, D, Syms} = Syms

Base.@propagate_inbounds function Base.getproperty(x::LArray, s::Symbol)
    if s == :__x
        return getfield(x, :__x)
    end
    return getindex(x, Val(s))
end

Base.@propagate_inbounds function Base.setproperty!(x::LArray, s::Symbol, y)
    if s == :__x
        return setfield!(x, :__x, y)
    end
    setindex!(x, y, Val(s))
end

Base.@propagate_inbounds Base.getindex(x::LArray, s::Symbol) = getindex(x, Val(s))
Base.@propagate_inbounds Base.getindex(x::LArray, s::Val) = __getindex(x, s)
Base.@propagate_inbounds Base.setindex!(x::LArray, v, s::Symbol) = setindex!(x, v, Val(s))

@generated function Base.setindex!(x::LArray, y, ::Val{s}) where {s}
    syms = symnames(x)
    if syms isa NamedTuple
        idxs = syms[s]
        return quote
            Base.@_propagate_inbounds_meta
            setindex!(getfield(x, :__x), y, $idxs)
            return x
        end
    else # Tuple
        idx = findfirst(y -> y == s, symnames(x))
        return quote
            Base.@_propagate_inbounds_meta
            setindex!(getfield(x, :__x), y, $idx)
            return x
        end
    end
end

Base.@propagate_inbounds function Base.getindex(x::LArray, s::AbstractArray{Symbol, 1})
    [getindex(x, si) for si in s]
end

function Base.similar(x::LArray{T, K, D, Syms}, ::Type{S},
                      dims::NTuple{N, Int}) where {T, K, D, Syms, S, N}
    tmp = similar(x.__x, S, dims)
    LArray{S, N, typeof(tmp), Syms}(tmp)
end

# Allow copying LArray of uninitialized data, as with regular Array
Base.copy(x::LArray) = typeof(x)(copy(getfield(x, :__x)))
Base.copyto!(x::LArray, y::LArray) = copyto!(getfield(x, :__x), getfield(y, :__x))

# enable the usage of LAPACK
function Base.unsafe_convert(::Type{Ptr{T}}, a::LArray{T, N, D, S}) where {T, N, D, S}
    Base.unsafe_convert(Ptr{T}, getfield(a, :__x))
end

Base.convert(::Type{T}, x) where {T <: LArray} = T(x)
Base.convert(::Type{T}, x::T) where {T <: LArray} = x
Base.convert(::Type{<:Array}, x::LArray) = convert(Array, getfield(x, :__x))
function Base.convert(::Type{AbstractArray{T, N}},
                      x::LArray{S, N, <:Any, Syms}) where {T, S, N, Syms}
    LArray{Syms}(convert(AbstractArray{T, N}, getfield(x, :__x)))
end
Base.convert(::Type{AbstractArray{T, N}}, x::LArray{T, N}) where {T, N} = x

function ArrayInterface.restructure(x::LArray{T, N, D, Syms},
                                        y::LArray{T2, N2, D2, Syms}) where {T, N, D, T2, N2,
                                                                            D2,
                                                                            Syms}
    reshape(y, size(x)...)
end

#####################################
# Broadcast
#####################################
struct LAStyle{T, N, L} <: Broadcast.AbstractArrayStyle{N} end
LAStyle{T, N, L}(x::Val{i}) where {T, N, L, i} = LAStyle{T, N, L}()
Base.BroadcastStyle(::Type{LArray{T, N, D, L}}) where {T, N, D, L} = LAStyle{T, N, L}()
function Base.BroadcastStyle(::LabelledArrays.LAStyle{T, N, L},
                             ::LabelledArrays.LAStyle{E, N, L}) where {T, E, N, L}
    LAStyle{promote_type(T, E), N, L}()
end

@generated function labels2axes(::Val{t}) where {t}
    if t isa NamedTuple && all(x -> x isa Union{Integer, UnitRange}, values(t)) # range labelling
        (Base.OneTo(maximum(Iterators.flatten(v for v in values(t)))),)
    elseif t isa NTuple{<:Any, Symbol}
        axes(t)
    else
        error("$t label isn't supported for broadcasting. Try to formulate it in terms of linear indexing.")
    end
end
function Base.similar(bc::Broadcast.Broadcasted{LAStyle{T, N, L}},
                      ::Type{ElType}) where {T, N, L, ElType}
    tmp = similar(Array{ElType}, axes(bc))
    if axes(bc) != labels2axes(Val(L))
        return tmp
    else
        return LArray{ElType, N, typeof(tmp), L}(tmp)
    end
end

# Broadcasting checks for aliasing with Base.dataids but the fallback
# for AbstractArrays is very slow. Instead, we just call dataids on the
# wrapped buffer
Base.dataids(A::LArray) = Base.dataids(A.__x)

"""
```julia
@LArray Eltype Size Names
@LArray Values Names
```

The `@LArray` macro creates an `LArray` with names determined from the `Names`
vector and values determined from the `Values` vector. Otherwise, the eltype
and size are used to make an `LArray` with undefined values.

```julia
A = @LArray [1, 2, 3] (:a, :b, :c)
A.a == 1
```

Users can also generate a labelled array with undefined values by instead giving
the dimensions. This approach is useful if the user intends to pre-allocate an
array for some later input.

```julia
A = @LArray Float64 (2, 2) (:a, :b, :c, :d)
W = rand(2, 2)
A .= W
A.d == W[2, 2]
```

Users may also use an alternative constructor to set the Names and Values
and ranges at the same time.

```julia
julia> z = @LArray [1.0, 2.0, 3.0] (a = 1:2, b = 2:3);

julia> z.b
2-element view(::Array{Float64,1}, 2:3) with eltype Float64:
 2.0
 3.0

julia> z = @LArray [1 2; 3 4] (a = (2, :), b = 2:3);

julia> z.a
2-element view(::Array{Int64,2}, 2, :) with eltype Int64:
 3
 4
```

The labels of LArray and SLArray can be accessed
by function `symbols`, which returns a tuple of symbols.
"""
macro LArray(vals, syms)
    vals = esc(vals)
    syms = esc(syms)
    return quote
        LArray{$syms}($vals)
    end
end

macro LArray(type, size, syms)
    type = esc(type)
    size = esc(size)
    syms = esc(syms)
    return quote
        LArray{$syms}(Array{$type}(undef, $size...))
    end
end

"""
```julia
@LVector Type Names
```

The `@LVector` macro creates an `LArray` of dimension 1 with eltype and undefined values.
The vector's length is equal to the number of names given.

As with an `LArray`, the user can initialize the vector and set its values later.

```julia
A = @LVector Float64 (:a, :b, :c, :d)
A .= rand(4)
```

To initialize the vector and set its values at the
same time, use [`@LArray`](@ref) instead:

```julia
b = @LArray [1, 2, 3] (:a, :b, :c)
```
"""
macro LVector(type, syms)
    type = esc(type)
    syms = esc(syms)
    return quote
        LArray{$syms}(Vector{$type}(undef, length($syms)))
    end
end

#the following gives error: TypeError: in <:, expected Type, got TypeVar
#symbols(::LArray{T,N,D<:AbstractArray{T,N},Syms}) where {T,N,D,Syms} = Syms

"""
    symbols(::LArray)

Returns the labels of the `LArray`.

For example:

```julia
julia> z = @LVector Float64 (:a, :b, :c, :d);

julia> symbols(z)
(:a, :b, :c, :d)
```
"""
function symbols(::LArray{T, N, D, Syms}) where {T, N, D, Syms}
    Syms isa NamedTuple ? keys(Syms) : Syms
end

# copy constructors

"""
    LVector(v1::Union{SLArray,LArray}; kwargs...)

Creates a 1D copy of v1 with corresponding items in kwargs replaced.

For example:

    z = LVector(a=1, b=2, c=3);
    z2 = LVector(z; c=30)
"""
function LVector(v1::Union{SLArray, LArray}; kwargs...)
    t2 = merge(convert(NamedTuple, v1), values(kwargs))
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
function LArray(v1::Union{SLArray, LArray}; kwargs...)
    t2 = merge(convert(NamedTuple, v1), values(kwargs))
    LArray(size(v1), t2)
end

# moved vom slarray.js to here because LArray need to be known
"""
    SLVector(v1::SLArray; kwargs...)

Creates a 1D copy of v1 with corresponding items in kwargs replaced.

For example:

    z = SLVector(a=1, b=2, c=3);
    z2 = SLVector(z; c=30)
"""
function SLVector(v1::Union{SLArray, LArray}; kwargs...)
    t2 = merge(convert(NamedTuple, v1), values(kwargs))
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
function SLArray(v1::SLArray{S, T, N, L, Syms};
                 kwargs...) where {S, T, N, L, Syms}
    t2 = merge(convert(NamedTuple, v1), values(kwargs))
    SLArray{S}(t2)
end

function Base.vcat(x::LArray, y::LArray)
    LArray{(LabelledArrays.symnames(typeof(x))..., LabelledArrays.symnames(typeof(y))...)}(vcat(x.__x,
                                                                                                y.__x))
end

Base.elsize(::Type{<:LArray{T}}) where {T} = sizeof(T)

function RecursiveArrayTools.recursive_unitless_eltype(a::Type{LArray{T, N, D, Syms}}) where {
                                                                                              T,
                                                                                              N,
                                                                                              D,
                                                                                              Syms
                                                                                              }
    LArray{typeof(one(T)), N, D, Syms}
end
