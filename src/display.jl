struct DisplayCell{T}
    label::Symbol
    elem::T
end
Base.show(io::IO, c::DisplayCell) = print(io, "$(c.label)=$(c.elem)")
function Base.typeinfo_prefix(io::IO, x::AbstractArray{DisplayCell{T}}) where {T}
    # print [a=1, b=2] instead of DisplayCell[a=1, b=2]
    Base.typeinfo_prefix(io, similar(x, T))
end

function Base.show(io::IO, x::LArray{T,N,Syms}) where {T,N,Syms}
    cells = Array{DisplayCell{T}, N}(undef, size(x)...)
    for (i, label) in enumerate(Syms)
        cells[i] = DisplayCell(label, x[i])
    end
    show(io, cells)
end

function Base.show(io::IO, x::SLArray{S,N,Syms,T}) where {S,N,Syms,T}
    cells = Array{DisplayCell{T}, N}(undef, size(x)...)
    for (i, label) in enumerate(Syms)
        cells[i] = DisplayCell(label, x[i])
    end
    show(io, cells)
end
