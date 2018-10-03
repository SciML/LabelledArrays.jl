struct LMatrix{T,A <: AbstractMatrix{T},Syms1,Syms2} <: AbstractMatrix{T}
    __x::A
end

struct LMatrixPartial{Sym1,LM <: LMatrix}
    __m::LM
end

Base.size(x::LMatrix) = size(getfield(x,:__x))
@inline Base.getindex(x::LMatrix,i...) = getfield(x,:__x)[i...]
@inline Base.setindex!(x::LMatrix,y,i...) = getfield(x,:__x)[i...] = y

Base.propertynames(::LMatrix{T,A,Syms1,Syms2}) where {T,A,Syms1,Syms2} = Syms1, Syms2
symnames(::Type{LMatrix{T,A,Syms1,Syms2}}, dim) where {T,A,Syms1,Syms2} = (Syms1, Syms2)[dim]

@inline function Base.getproperty(x::LMatrix,s::Symbol)
    if s == :__x
        return getfield(x,:__x)
    end
    LMatrixPartial{Val{s},typeof(x)}(x)
end

@inline function Base.getproperty(p::LMatrixPartial{Val{s1}},s2::Symbol) where s1
    if s2 == :__m
        return getfield(p,:__m)
    end
    p.__m[Val(s1), Val(s2)]
end


@inline function Base.setproperty!(x::LMatrix,s::Symbol,y)
    if s == :__x
        return setfield!(x,:__x,y)
    end
    x[s,:] .= y
end

@inline function Base.setproperty!(p::LMatrixPartial{Val{s1}},s2::Symbol,y) where s1
    p.__m[Val(s1), Val(s2)] = y
end

@inline Base.getindex(x::LMatrix,s1::Symbol,s2::Symbol) = getindex(x,Val(s1),Val(s2))
@inline Base.getindex(x::LMatrix,i1,s2::Symbol) = getindex(x,i1,Val(s2))
@inline Base.getindex(x::LMatrix,s1::Symbol,i2) = getindex(x,Val(s1),i2)

@inline @generated function Base.getindex(x::LMatrix,::Val{s1},::Val{s2}) where {s1, s2}
    idx1 = findfirst(y->y==s1,symnames(x,1))
    idx2 = findfirst(y->y==s2,symnames(x,2))
    :(x.__x[$idx1, $idx2])
end

@inline @generated function Base.getindex(x::LMatrix,i1,::Val{s2}) where s2
    idx2 = findfirst(y->y==s2,symnames(x,2))
    :(x.__x[i1, $idx2])
end

@inline @generated function Base.getindex(x::LMatrix,::Val{s1},i2) where s1
    idx1 = findfirst(y->y==s1,symnames(x,1))
    :(x.__x[$idx1, i2])
end

@inline Base.setindex!(x::LMatrix,y,s1::Symbol,s2::Symbol) = setindex!(x,y,Val(s1),Val(s2))
@inline Base.setindex!(x::LMatrix,y,s1::Symbol,i2) = setindex!(x,y,Val(s1),i2)
@inline Base.setindex!(x::LMatrix,y,i1,s2::Symbol) = setindex!(x,y,i1,Val(s2))

@inline @generated function Base.setindex!(x::LMatrix,y,::Val{s1},::Val{s2}) where {s1, s2}
    idx1 = findfirst(y->y==s1,symnames(x,1))
    idx2 = findfirst(y->y==s2,symnames(x,2))
    :(x.__x[$idx1, $idx2] = y)
end

@inline @generated function Base.setindex!(x::LMatrix,y,::Val{s1},i2) where s1
    idx1 = findfirst(y->y==s1,symnames(x,1))
    :(x.__x[$idx1, i2] = y)
end

@inline @generated function Base.setindex!(x::LMatrix,y,i1,::Val{s2}) where s2
    idx2 = findfirst(y->y==s2,symnames(x,2))
    :(x.__x[i1, $idx2] = y)
end


function Base.similar(x::LMatrix,::Type{S},dims::NTuple{N,Int}) where {S,N}
    typeof(x)(similar(x.__x,S,dims))
end

"""
    @LMatrix Type Names
    @LMatrix Type Names Values

Creates an `LMatrix` with names determined from the `Names`
vector and values determined from the `Values` vector (if no values are provided,
it defaults to not setting the values to zero). All of the values are converted
to the type of the `Type` input.

For example:

    a = @LMatrix Float64 [a,b,c] [x,y,z]
    b = @LMatrix [1,2,3] [a,b,c] [x,y,z]
"""
macro LMatrix(vals,syms1,syms2)
    if typeof(vals) <: Symbol
        return quote
            LMatrix{$vals,Matrix{$vals},$syms1,$syms2}(Matrix(undef,length($syms1),length($syms1)))
        end
    else
        return quote
            LMatrix{eltype($vals),typeof($vals),$syms1,$syms2}($vals)
        end
    end
end
