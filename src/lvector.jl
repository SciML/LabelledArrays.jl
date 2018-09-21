struct LVector{T,A <: AbstractVector{T},Syms} <: AbstractVector{T}
    __x::A
end

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

function Base.similar(x::LVector,::Type{S},dims::NTuple{N,Int}) where {S,N}
    typeof(x)(similar(x.__x,S,dims))
end

"""
    @LVector Type Names
    @LVector Type Names Values

Creates an `LVector` with names determined from the `Names`
vector and values determined from the `Values` vector (if no values are provided,
it defaults to not setting the values to zero). All of the values are converted
to the type of the `Type` input.

For example:

    a = @LVector Float64 [a,b,c]
    b = @LVector [1,2,3] [a,b,c]
"""
macro LVector(vals,syms)
    if typeof(vals) <: Symbol
        return quote
            LVector{$vals,Vector{$vals},$syms}(Vector(undef,length($syms)))
        end
    else
        return quote
            LVector{eltype($vals),typeof($vals),$syms}($vals)
        end
    end
end
