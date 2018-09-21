abstract type SLVector{N,T} <: FieldVector{N,T} end

# SLVector Macro

"""
    @SLVector TypeName ElementType Names

Creates a static vector type with name TypeName and  eltype ElementType
with names determined from the `Names`.

For example:

```julia
@SLVector ABC Float64 [a,b,c]
x = ABC(1.0,2.5,3.0)
x.a == 1.0
x.b == 2.5
x.c == x[3]
```

"""
macro SLVector(tname,T,_names)
    names = Symbol.(_names.args)
    quote
        struct $(tname) <: SLVector{$(length(names)),$T}
            $((:($n::$T) for n in names)...)
            $(tname)($((:($n) for n in names)...)) = new($((:($n) for n in names)...))
        end
    end
end

# Fix broadcast https://github.com/JuliaArrays/StaticArrays.jl/issues/314
function StaticArrays.similar_type(::Type{V}, ::Type{T}, ::Size{N}) where
                                                        {V<:SLVector,T,N}
    V
end
