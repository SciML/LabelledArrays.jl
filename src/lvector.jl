struct LVector{T,A <: AbstractVector{T},Syms} <: AbstractVector{T}
    __x::A
    LVector{Syms}(__x) where {T,A,Syms} = new{eltype(__x),typeof(__x),Syms}(__x)
    LVector{T,Syms}(__x) where {T,Syms} = new{T,typeof(__x),Syms}(__x)
    LVector{T,A,Syms}(__x) where {T,A,Syms} = new{T,A,Syms}(__x)
end
#

Base.size(x::LVector) = size(getfield(x,:__x))
@inline Base.getindex(x::LVector,i...) = getfield(x,:__x)[i...]
@inline Base.setindex!(x::LVector,y,i...) = getfield(x,:__x)[i...] = y

Base.propertynames(::LVector{T,A,Syms}) where {T,A,Syms} = Syms
symnames(::Type{LVector{T,A,Syms}}) where {T,A,Syms} = Syms

@inline function Base.getproperty(x::LVector,s::Symbol)
    if s == :__x
        return getfield(x,:__x)
    end
    x[Val(s)]
end

@inline function Base.setproperty!(x::LVector,s::Symbol,y)
    if s == :__x
        return setfield!(x,:__x,y)
    end
    x[Val(s)] = y
end

@inline function Base.getindex(x::LVector,s::Symbol)
    getindex(x,Val(s))
end

@inline @generated function Base.getindex(x::LVector,::Val{s}) where s
    idx = findfirst(y->y==s,symnames(x))
    :(x.__x[$idx])
end

@inline function Base.setindex!(x::LVector,y,s::Symbol)
    setindex!(x,y,Val(s))
end

@inline @generated function Base.setindex!(x::LVector,y,::Val{s}) where s
    idx = findfirst(y->y==s,symnames(x))
    :(x.__x[$idx] = y)
end

function Base.similar(x::LVector{T,A,Syms},::Type{S},dims::NTuple{N,Int}) where {T,A,Syms,S,N}
    tmp = similar(x.__x,S,dims)
    LVector{S,typeof(tmp),Syms}(tmp)
end

function LinearAlgebra.ldiv!(Y::LVector, A::Factorization, B::LVector)
  ldiv!(Y.__x,A,B.__x)
end

#####################################
# Broadcast
#####################################
struct LVStyle{T,A,L} <: Broadcast.AbstractArrayStyle{1} end
LVStyle{T,A,L}(x::Val{1}) where {T,A,L} = LVStyle{T,A,L}()
Base.BroadcastStyle(::Type{LVector{T,A,L}}) where {T,A,L} = LVStyle{T,A,L}()

function Base.similar(bc::Broadcast.Broadcasted{LVStyle{T,A,L}}, ::Type{ElType}) where {T,A,L,ElType}
    return LVector{ElType,Vector{ElType},L}(similar(Vector{ElType},axes(bc)))
end

"""
    @LVector Type Names
    @LVector Type Names Values

Creates an `LVector` with names determined from the `Names`
vector and values determined from the `Values` vector (if no values are provided,
it defaults to not setting the values to zero). All of the values are converted
to the type of the `Type` input.

For example:

    a = @LVector Float64 (:a,:b,:c)
    b = @LVector [1,2,3] (:a,:b,:c)
"""
macro LVector(vals,syms)
    if typeof(vals) <: Symbol
        return quote
            LVector{$vals,Vector{$vals},$syms}(Vector{$vals}(undef,length($syms)))
        end
    else
        return quote
            LVector{eltype($vals),typeof($vals),$syms}($vals)
        end
    end
end

#####################################
# SLVector
#####################################
const SLVector = LVector{T,SVector{N,T},Syms} where {T,N,Syms}

"""
    @SLVector ElementType Names

Creates an anonymous function that builds a labelled static vector with eltype
`ElementType` with names determined from the `Names`. The labbeled static vector
is just an `LVector` whose entries are `SVector{ElementType}`.

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
    return quote
        function (vals...,)
            v = SVector{$(length(syms.args)), $E}(vals...)
            T = typeof(v)
            return LVector{$(esc(E)),T,$syms}(v)
        end
    end
end

Base.copy(x::SLVector{T,N,Syms}) where {T,N,Syms} = LVector{Syms}(x.__x)
function Base.similar(::SLVector{T,N,Syms}, ::Type{S}) where {T,N,Syms,S}
    tmp = Vector{S}(undef, N)
    LVector{Syms}(SVector{N}(tmp))
end
function Base.AbstractVector{S}(x::SLVector{T,N,Syms}) where {S,T,N,Syms}
    LVector{Syms}(S.(x.__x))
end
function Base.broadcast(f, xs::SLVector{T,N,Syms}...) where {T,N,Syms}
    result = broadcast(f, (x.__x for x in xs)...)
    LVector{Syms}(result)
end