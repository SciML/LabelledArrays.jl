module LabelledArrays

using StaticArrays

abstract type LabelledVector{N,T} <: FieldVector{N,T} end

# LabelledVector Macros

"""
    @LVector Type Names
    @LVector Type Names Values

Creates a `LabelledVector` with names determined from the `Names`
vector and values determined from the `Values` vector (if no values are provided,
it defaults to not setting the values like `similar`). All of the values are converted
to the type of the `Type` input.

For example:

    a = @LVector Float64 [a,b,c]
    b = @LVector Float64 [a,b,c] [1,2,3]
"""
macro LVector(T,_names,vals=nothing)
    names = Symbol.(_names.args)
    type_name = gensym(:LVector)
    construction_call = vals==nothing ?
    quote
        ($(type_name))()
    end : quote
        ($(type_name))($(vals)...)
    end

    quote
        struct $(type_name) <: LabelledVector{$(length(names)),$T}
            $((:($n::$(T)) for n in names)...)
            $(type_name)() = new()
            $(type_name)($((:($n) for n in names)...)) = new($((:($n) for n in names)...))
        end
        $(esc(construction_call))
    end
end

"""
    @MLVector Type Names
    @MLVector Type Names Values

Creates a `LabelledVector` with names determined from the `Names`
vector and values determined from the `Values` vector (if no values are provided,
it defaults to not setting the values like `similar`). All of the values are converted
to the type of the `Type` input.

For example:

    a = @MLVector Float64 [a,b,c]
    b = @MLVector Float64 [a,b,c] [1,2,3]
"""
macro MLVector(T,_names,vals=nothing)
    names = Symbol.(_names.args)
    type_name = gensym(:MLVector)
    construction_call = vals==nothing ?
    quote
        ($(type_name))()
    end : quote
        ($(type_name))($(vals)...)
    end

    quote
        mutable struct $(type_name) <: LabelledVector{$(length(names)),$T}
            $((:($n::$(T)) for n in names)...)
            $(type_name)() = new()
            $(type_name)($((:($n) for n in names)...)) = new($((:($n) for n in names)...))
        end
        $(esc(construction_call))
    end
end

# Fix broadcast https://github.com/JuliaArrays/StaticArrays.jl/issues/314
function StaticArrays.similar_type(::Type{V}, ::Type{T}, ::Size{N}) where
                                                        {V<:LabelledVector,T,N}
    V
end

export LabelledVector, @LVector, @MLVector

end # module
