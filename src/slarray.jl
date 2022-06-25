struct SLArray{S, T, N, L, Syms} <: StaticArray{S, T, N}
    __x::SArray{S, T, N, L}
    #SLArray{Syms}(__x::StaticArray{S,T,N}) where {S,N,Syms,T} = new{S,N,Syms,T}(__x)
    function SLArray{S, T, N, Syms}(__x::SArray) where {S, T, N, Syms}
        new{S, T, N, length(__x), Syms}(convert.(T, __x))
    end
    function SLArray{S, Syms}(__x::SArray{S, T, N, L}) where {S, T, N, L, Syms}
        new{S, T, N, L, Syms}(__x)
    end
    function SLArray{S, T, Syms}(__x::SArray{S, T, N, L}) where {S, T, N, L, Syms}
        new{S, T, N, L, Syms}(__x)
    end
    function SLArray{S, Syms}(x::Tuple) where {S, Syms}
        __x = SArray{S}(x)
        SLArray{S, Syms}(__x)
    end
    function SLArray{S, T, Syms}(x::Tuple) where {S, T, Syms}
        __x = SArray{S, T}(x)
        SLArray{S, T, Syms}(__x)
    end
    function SLArray{S, T, N, L, Syms}(x::Tuple) where {S, T, N, L, Syms}
        __x = SArray{S, T, N, L}(x)
        new{S, T, N, L, Syms}(__x)
    end
end

#####################################
# NamedTuple compatibility
#####################################
## SLArray to named tuple
function Base.convert(::Type{NamedTuple},
                      x::SLArray{S, T, N, L, Syms}) where {S, T, N, L, Syms}
    tup = NTuple{length(Syms), T}(x.__x)
    NamedTuple{Syms, typeof(tup)}(tup)
end
Base.keys(x::SLArray{S, T, N, L, Syms}) where {S, T, N, L, Syms} = Syms

function StaticArrays.similar_type(::Type{SLArray{S, T, N, L, Syms}}, T2,
                                   ::Size{S}) where {S, T, N, L, Syms}
    SLArray{S, T2, N, L, Syms}
end
RecursiveArrayTools.recursive_unitless_eltype(a::Type{T}) where {T<:SLArray} = 
                        StaticArrays.similar_type(a,recursive_unitless_eltype(eltype(a)))

## Named tuple to SLArray
#=
  1. `SLArray{Tuple{2,2}}((a=1, b=2, c=3, d=4))` (need to specify size)
  2. `SLArray{Tuple{2,2}}(a=1, b=2, c=3, d=4)` : alternative form using kwargs
  3. `SLVector((a=1, b=2))` : infer size for vectors
  4. `SLVector(a=1, b=2)` : alternative form using kwargs
=#

"""
```julia
SLArray{::Tuple}(::NamedTuple)
SLArray{::Tuple}(kwargs)
```

These are the standard constructors for `SLArray`. For general N-dimensional 
labelled arrays, users need to specify the size
(`Tuple{dim1,dim2,...}`) in the type parameter to the `SLArray` constructor:

```julia
julia> SLArray{Tuple{2,2}}((a=1, b=2, c=3, d=4))
2×2 SLArray{Tuple{2, 2}, Int64, 2, 4, (:a, :b, :c, :d)} with indices SOneTo(2)×SOneTo(2):
 :a => 1  :c => 3
 :b => 2  :d => 4

julia> SLArray{Tuple{2,2}}(a=1, b=2, c=3, d=4)
 2×2 SLArray{Tuple{2,2},2,(:a, :b, :c, :d),Int64}:
 1  3
 2  4
```

Constructing copies with some changed elements is supported by
a keyword constructor whose first argument is the source and
whose additional keyword arguments indicate the changes.

```julia
julia> ABCD = @SLArray (2,2) (:a,:b,:c,:d);
julia> B = ABCD(1,2,3,4);
julia> B2 = SLArray(B; c=30 )
2×2 SLArray{Tuple{2,2},Int64,2,4,(:a, :b, :c, :d)}:
 1  30
 2   4
```

Additional examples:

```julia
SLArray{Tuple{2,2}}((a=1, b=2, c=3, d=4))
```
"""
function SLArray{Size}(tup::NamedTuple{Syms, Tup}) where {Size, Syms, Tup}
    __x = Tup(tup) # drop symbols
    SLArray{Size, Syms}(__x)
end
SLArray{Size}(; kwargs...) where {Size} = SLArray{Size}(values(kwargs))

"""
```julia
SLVector(::NamedTuple)
SLVector(kwargs)
```
The standard constructors for `SLArray`.

```julia
julia> SLVector(a=1, b=2, c=3)
3-element SLArray{Tuple{3},1,(:a, :b, :c),Int64}:
 1
 2
 3
```

Constructing copies with some items changed is supported by
a keyword constructor whose first argument is the source and
whose additional keyword arguments indicate the changes.

```julia
julia> v1 = SLVector(a=1.1, b=2.2, c=3.3);
julia> v2 = SLVector(v1; b=20.20, c=30.30 )
3-element SLArray{Tuple{3},Float64,1,3,(:a, :b, :c)}:
  1.1
 20.2
 30.3
```

Additional examples:

```julia
SLVector((a=1, b=2)) 
SLVector(a=1, b=2) 
```
"""
SLVector(tup::NamedTuple) = SLArray{Tuple{length(tup)}}(tup)
SLVector(; kwargs...) = SLVector(values(kwargs))

## pairs iterator
function Base.pairs(x::SLArray{S, T, N, L, Syms}) where {S, T, N, L, Syms}
    # (label => getproperty(x, label) for label in Syms) # not type stable?
    (Syms[i] => x[i] for i in 1:length(Syms))
end

function Base.iterate(x::SLArray, args...)
    iterate(convert(NamedTuple, x), args...)
end

#####################################
# StaticArray Interface
#####################################
Base.@propagate_inbounds Base.getindex(x::SLArray, i::Int) = getfield(x, :__x)[i]
@inline Base.Tuple(x::SLArray) = Tuple(x.__x)

function StaticArrays.similar_type(::Type{SLArray{S, T, N, L, Syms}}, ::Type{NewElType},
                                   ::Size{NewSize}) where {S, T, N, L, Syms, NewElType,
                                                           NewSize}
    n = prod(NewSize)
    if n == L
        SLArray{Tuple{NewSize...}, NewElType, length(NewSize), L, Syms}
    else
        SArray{Tuple{NewSize...}, NewElType, length(NewSize), n}
    end
end

function Base.similar(::Type{SLArray{S, T, N, L, Syms}}, ::Type{NewElType},
                      ::Size{NewSize}) where {S, T, N, L, Syms, NewElType, NewSize}
    n = prod(NewSize)
    if n == L
        tmp = Array{NewElType}(undef, NewSize)
        LArray{NewElType, length(NewSize), typeof(tmp), Syms}(tmp)
    else
        MArray{Tuple{NewSize...}, NewElType, length(NewSize), n}(undef)
    end
end

@inline Base.propertynames(::SLArray{S, T, N, L, Syms}) where {S, T, N, L, Syms} = Syms
@inline symnames(::Type{SLArray{S, T, N, L, Syms}}) where {S, T, N, L, Syms} = Syms
Base.@propagate_inbounds function Base.getproperty(x::SLArray, s::Symbol)
    s == :__x || s == :data ? getfield(x, :__x) : getindex(x, Val(s))
end
Base.@propagate_inbounds function Base.getindex(x::SLArray, s::Symbol)
    return getindex(x, Val(s))
end
Base.@propagate_inbounds Base.getindex(x::SLArray, s::Val) = __getindex(x, s)
Base.@propagate_inbounds function Base.getindex(x::SLArray,
                                                inds::AbstractArray{I, 1}) where {
                                                                                  I <:
                                                                                  Integer}
    getindex(x.__x, inds)
end
Base.@propagate_inbounds function Base.getindex(x::SLArray, inds::StaticVector{<:Any, Int})
    getindex(x.__x, inds)
end

# Note: This could in the future return an SLArray with the right names
Base.@propagate_inbounds function Base.getindex(x::SLArray, s::AbstractArray{Symbol, 1})
    [getindex(x, si) for si in s]
end

function Base.vcat(x1::SLArray{S1, T, 1, L1, Syms1},
                   x2::SLArray{S2, T, 1, L2, Syms2}) where {S1, S2, T, L1, L2, Syms1, Syms2}
    __x = vcat(x1.__x, x2.__x)
    SLArray{StaticArrays.size_tuple(Size(__x)), (Syms1..., Syms2...)}(__x)
end

"""
    @SLArray Size Names
    @SLArray Eltype Size Names

The macro creates a labelled static vector with element type
`ElType`, names from `Names`, and size from `Size`. If no eltype
is given, then the eltype is determined from the arguments in the constructor.

For example:

```julia
ABCD = @SLArray (2,2) (:a,:b,:c,:d)
x = ABCD(1.0, 2.5, 3.0, 5.0)
x.a == 1.0
x.b == 2.5
x.c == x[3]
x.d == x[2,2]
EFG = @SLArray (2,2) (e=1:3, f=4, g=2:4)
y = EFG(1.0,2.5,3.0,5.0)
EFG = @SLArray (2,2) (e=(2, :), f=4, g=2:4)
```
Users can also specify the indices directly.

```julia
julia> EFG = @SLArray (2,2) (e=1:3, f=4, g=2:4);
julia> y = EFG(1.0,2.5,3.0,5.0)
2×2 SLArray{Tuple{2,2},Float64,2,4,(e = 1:3, f = 4, g = 2:4)}:
 1.0  3.0
 2.5  5.0

julia> y.g
3-element view(reshape(::StaticArrays.SArray{Tuple{2,2},Float64,2,4}, 4), 2:4) with eltype Float64:
 2.5
 3.0
 5.0

julia> Arr = @SLArray (2, 2) (a = (2, :), b = 3);
julia> z = Arr(1, 2, 3, 4);
julia> z.a
2-element view(::StaticArrays.SArray{Tuple{2,2},Int64,2,4}, 2, :) with eltype Int64:
 2
 4
```
"""
macro SLArray(dims, syms)
    dims isa Expr && (dims = dims.args)
    syms = esc(syms)
    quote
        SLArray{Tuple{$dims...}, $syms}
    end
end

macro SLArray(T, dims, syms)
    dims isa Expr && (dims = dims.args)
    syms = esc(syms)
    quote
        SLArray{Tuple{$dims...}, $T, $(length(dims)), $(prod(dims)), $syms}
    end
end

"""
    @SLVector Names
    @SLVector Eltype Names

The macro creates a labelled static vector with element type
`ElType`, and names from `Names`. If no eltype is given,
then the eltype is determined from the values in the constructor.
The array size is found from the input data. 

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
    syms = esc(syms)
    quote
        n = $syms isa NamedTuple ? maximum(map(maximum, $syms)) : length($syms)
        SLArray{Tuple{n}, $syms}
    end
end

macro SLVector(T, syms)
    T = esc(T)
    syms = esc(syms)
    quote
        n = $syms isa NamedTuple ? maximum(map(maximum, $syms)) : length($syms)
        SLArray{Tuple{n}, $T, 1, n, $syms}
    end
end

"""
    symbols(::SLArray)

Returns the labels of the `SLArray` .

For example:
```julia
julia> z = SLVector(a=1, b=2, c=3)
3-element SLArray{Tuple{3}, Int64, 1, 3, (:a, :b, :c)} with indices SOneTo(3):
 :a => 1
 :b => 2
 :c => 3

julia> symbols(z)
(:a, :b, :c)
```
"""
function symbols(::SLArray{S, T, N, L, Syms}) where {S, T, N, L, Syms}
    Syms isa NamedTuple ? keys(Syms) : Syms
end

function Base.:\(A::StaticArrays.LU, b::SLArray{S, T, N, L, Syms}) where {S, T, N, L, Syms}
    SLArray{S, T, N, L, Syms}((A \ b.__x).data)
end

function Base.reshape(x::SLArray{S, T, N, L, Syms},
                      ax::Tuple{SOneTo, Vararg{SOneTo}}) where {S <: Tuple, T, N, L, Syms,
                                                                SOneTo <: SOneTo}
    SLArray{S, T, N, L, Syms}(reshape(x.__x, ax))
end
