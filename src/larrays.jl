struct LArray{S,T,N,L} <: AbstractArray{T,N}
    names::Array{Symbol,N}
    values::Array{T,N}
end

@inline Base.size(A::LArray) = size(A.values)
@inline Base.getindex(A::LArray{S,T,N,L}, i::Int) where {L,N,T,S<:Tuple} = A.values[i]
@inline Base.getindex(A::LArray{S,T,N,L}, I::Vararg{Int, N2}) where {L,N,T,S<:Tuple,N2} = A.values[I]
@inline Base.setindex!(A::LArray{S,T,N,L}, v, i::Int) where {L,N,T,S<:Tuple} = (A.values[i] = v)
@inline Base.setindex!(A::LArray{S,T,N,L}, v, I::Vararg{Int, N}) where {L,N,T,S<:Tuple} = (A.values[I] = v)

function promote_rule(::Type{<:LArray{S,T,N,L}}, ::Type{<:LArray{S,U,N,L}}) where {S,T,U,N,L}
    LArray{S,promote_type(T,U),N,L}
end

@inline function Base.getindex(A::LArray{S,T,N,L}, s::Symbol) where {L,N,T,S<:Tuple}
    A.values[symbol_to_index(A.names, s)]
end
@inline function Base.setindex!(A::LArray{S,T,N,L}, v, s::Symbol) where {L,N,T,S<:Tuple}
    A.values[symbol_to_index(A.names, s)] = v
end
