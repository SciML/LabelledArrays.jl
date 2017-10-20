struct LMArray{S,T,N,L} <: StaticArray{S,T,N}
    names::SArray{S,Symbol,N,L}
    values::MArray{S,T,N,L}
end

@inline Base.size(A::LMArray) = size(A.values)
@inline Base.getindex(A::LMArray{S,T,N,L}, i::Int) where {L,N,T,S<:Tuple} = A.values[i]
@inline Base.getindex(A::LMArray{S,T,N,L}, I::Vararg{Int, N2}) where {L,N,T,S<:Tuple,N2} = A.values[I]
@inline Base.setindex!(A::LMArray{S,T,N,L}, v, i::Int) where {L,N,T,S<:Tuple} = (A.values[i] = v)
@inline Base.setindex!(A::LMArray{S,T,N,L}, v, I::Vararg{Int, N}) where {L,N,T,S<:Tuple} = (A.values[I] = v)

function promote_rule(::Type{<:LMArray{S,T,N,L}}, ::Type{<:LMArray{S,U,N,L}}) where {S,T,U,N,L}
    LMArray{S,promote_type(T,U),N,L}
end

@inline function Base.getindex(A::LMArray{S,T,N,L}, s::Symbol) where {L,N,T,S<:Tuple}
    A.values[symbol_to_index(A.names, s)]
end
@inline function Base.setindex!(A::LMArray{S,T,N,L}, v, s::Symbol) where {L,N,T,S<:Tuple}
    A.values[symbol_to_index(A.names, s)] = v
end

# Simplified show for the type
Base.show(io::IO, ::Type{LMArray{S,T,N,L}}) where {L,N,T,S<:Tuple} = print(io, "LArray{$S,$T,$N,$L}")
function Base.show(io::IO, m::MIME"text/plain", ::Type{LMArray{S,T,N,L}}) where {L,N,T,S<:Tuple}
    println(io,"Names:")
    println(io, A.names)
    println(io,"Values:")
    println(io, A.values)
end

# restore the type rendering in Juno
Juno.@render Juno.Inline x::LMArray begin
  fields = fieldnames(typeof(x))
  Juno.LazyTree(typeof(x), () -> [Juno.SubTree(Juno.Text("$f → "), Juno.getfield′(x, f)) for f in fields])
end

"""
    @LMVector Type Names
    @LMVector Type Names Values

Creates an `LMArray` with names determined from the `Names`
vector and values determined from the `Values` vector (if no values are provided,
it defaults to not setting the values to zero). All of the values are converted
to the type of the `Type` input.

For example:

    a = @MLVector Float64 [a,b,c]
    b = @MLVector Float64 [a,b,c] [1,2,3]
"""
macro LMVector(T,names,vals=nothing)
    quote
        LMArray(@SArray($names),@MArray($vals))
    end
end
