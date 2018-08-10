abstract type SLVector{N,T} <: FieldVector{N,T} end

# LVector Macro

"""
    @SLVector Values Names

Creates a static `LVector` with names determined from the `Names`
vector and values determined from the `Values` vector (if no values are provided,
it defaults to not setting the values like `similar`). All of the values are converted
to the type of the `Type` input.

For example:

    A = @SLVector [1,2,3] [a,b,c]
"""
macro SLVector(vals,_names)
    names = Symbol.(_names.args)
    type_name = gensym(:SLVector)
    construction_call = vals==nothing ?
    quote
        ($(type_name))()
    end : quote
        ($(type_name))($(vals)...)
    end

    quote
        T = eltype($vals)
        struct $(type_name) <: SLVector{$(length(names)),T}
            $((:($n::T) for n in names)...)
            $(type_name)($((:($n) for n in names)...)) = new($((:($n) for n in names)...))
        end
        $(esc(construction_call))
    end
end

# Fix broadcast https://github.com/JuliaArrays/StaticArrays.jl/issues/314
function StaticArrays.similar_type(::Type{V}, ::Type{T}, ::Size{N}) where
                                                        {V<:SLVector,T,N}
    V
end
