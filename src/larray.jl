struct LArray{T,N,A <: AbstractArray{T,N},Syms} <: AbstractArray{T,N}
    __x::A
    LArray{Syms}(__x) where {T,A,Syms} = new{eltype(__x),ndims(__x),
                                              typeof(__x),Syms}(__x)
    LArray{T,N,Syms}(__x) where {T,N,Syms} = new{T,N,typeof(__x),Syms}(__x)
    LArray{T,N,A,Syms}(__x) where {T,N,A,Syms} = new{T,N,A,Syms}(__x)
end
#

Base.size(x::LArray) = size(getfield(x,:__x))
@inline Base.getindex(x::LArray,i...) = getfield(x,:__x)[i...]
@inline Base.setindex!(x::LArray,y,i...) = getfield(x,:__x)[i...] = y

Base.propertynames(::LArray{T,N,A,Syms}) where {T,N,A,Syms} = Syms
symnames(::Type{LArray{T,N,A,Syms}}) where {T,N,A,Syms} = Syms

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
struct LAStyle{T,A,L} <: Broadcast.AbstractArrayStyle{1} end
LAStyle{T,A,L}(x::Val{1}) where {T,A,L} = LAStyle{T,A,L}()
Base.BroadcastStyle(::Type{LArray{T,A,L}}) where {T,A,L} = LAStyle{T,A,L}()

function Base.similar(bc::Broadcast.Broadcasted{LAStyle{T,A,L}}, ::Type{ElType}) where {T,A,L,ElType}
    return LArray{ElType,Vector{ElType},L}(similar(Vector{ElType},axes(bc)))
end

"""
    @LVector Type Names
    @LVector Type Names Values

Creates an `LArray` with names determined from the `Names`
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
            LArray{$vals,1,Vector{$vals},$syms}(Vector{$vals}(undef,length($syms)))
        end
    else
        return quote
            LArray{eltype($vals),1,typeof($vals),$syms}($vals)
        end
    end
end
