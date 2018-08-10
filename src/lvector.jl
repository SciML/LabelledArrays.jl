struct LVector{T,A <: AbstractVector{T},Syms} <: AbstractVector{T}
    x::A
end

Base.size(x::LVector) = size(getfield(x,:x))
@inline Base.getindex(x::LVector,i...) = getfield(x,:x)[i...]
@inline Base.setindex!(x::LVector,y,i...) = getfield(x,:x)[i...] = y

Base.propertynames(x::LVector{T,A,Syms}) where {T,A,Syms} = Syms
@inline function Base.getproperty(x::LVector,s::Symbol)
    if s == :x
        return getfield(x,:x)
    end
    x[s]
end

@inline function Base.setproperty!(x::LVector,s::Symbol,y)
    if s == :x
        return setfield!(x,:x,y)
    end
    x[s] = y
end

@inline function Base.getindex(x::LVector,s::Symbol)
    x.x[findfirst(y->y==s,propertynames(x))]
end

@inline function Base.setindex!(x::LVector,y,s::Symbol)
    x.x[findfirst(y->y==s,propertynames(x))] = y
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
