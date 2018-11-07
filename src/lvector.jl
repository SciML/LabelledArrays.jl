struct LArray{N,T,A <: AbstractArray{N,T},Syms} <: AbstractArray{N,T}
    __x::A
    LArray{Syms}(__x) where {T,A,Syms} = new{ndims(__x),eltype(__x),
                                              typeof(__x),Syms}(__x)
    LArray{N,T,Syms}(__x) where {T,Syms} = new{N,T,typeof(__x),Syms}(__x)
    LArray{N,T,A,Syms}(__x) where {T,A,Syms} = new{N,T,A,Syms}(__x)
end
#

Base.size(x::LArray) = size(getfield(x,:__x))
@inline Base.getindex(x::LArray,i...) = getfield(x,:__x)[i...]
@inline Base.setindex!(x::LArray,y,i...) = getfield(x,:__x)[i...] = y

Base.propertynames(::LArray{T,A,Syms}) where {T,A,Syms} = Syms
symnames(::Type{LArray{T,A,Syms}}) where {T,A,Syms} = Syms

@inline function Base.getproperty(x::LArray,s::Symbol)
    if s == :__x
        return getfield(x,:__x)
    end
    x[Val(s)]
end

@inline function Base.setproperty!(x::LArray,s::Symbol,y)
    if s == :__x
        return setfield!(x,:__x,y)
    end
    x[Val(s)] = y
end

@inline function Base.getindex(x::LArray,s::Symbol)
    getindex(x,Val(s))
end

@inline @generated function Base.getindex(x::LArray,::Val{s}) where s
    idx = findfirst(y->y==s,symnames(x))
    :(x.__x[$idx])
end

@inline function Base.setindex!(x::LArray,y,s::Symbol)
    setindex!(x,y,Val(s))
end

@inline @generated function Base.setindex!(x::LArray,y,::Val{s}) where s
    idx = findfirst(y->y==s,symnames(x))
    :(x.__x[$idx] = y)
end

function Base.similar(x::LArray{T,A,Syms},::Type{S},dims::NTuple{N,Int}) where {T,A,Syms,S,N}
    tmp = similar(x.__x,S,dims)
    LArray{S,typeof(tmp),Syms}(tmp)
end

function LinearAlgebra.ldiv!(Y::LArray, A::Factorization, B::LArray)
  ldiv!(Y.__x,A,B.__x)
end

#####################################
# Broadcast
#####################################
struct LVStyle{T,A,L} <: Broadcast.AbstractArrayStyle{1} end
LVStyle{T,A,L}(x::Val{1}) where {T,A,L} = LVStyle{T,A,L}()
Base.BroadcastStyle(::Type{LArray{T,A,L}}) where {T,A,L} = LVStyle{T,A,L}()

function Base.similar(bc::Broadcast.Broadcasted{LVStyle{T,A,L}}, ::Type{ElType}) where {T,A,L,ElType}
    return LArray{ElType,Vector{ElType},L}(similar(Vector{ElType},axes(bc)))
end

"""
    @LArray Type Names
    @LArray Type Names Values

Creates an `LArray` with names determined from the `Names`
vector and values determined from the `Values` vector (if no values are provided,
it defaults to not setting the values to zero). All of the values are converted
to the type of the `Type` input.

For example:

    a = @LArray Float64 (:a,:b,:c)
    b = @LArray [1,2,3] (:a,:b,:c)
"""
macro LArray(vals,syms)
    if typeof(vals) <: Symbol
        return quote
            LArray{$vals,Vector{$vals},$syms}(Vector{$vals}(undef,length($syms)))
        end
    else
        return quote
            LArray{eltype($vals),typeof($vals),$syms}($vals)
        end
    end
end
