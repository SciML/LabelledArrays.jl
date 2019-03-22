
#####################################
# StaticArray Interface
#####################################
Base.propertynames(::SLArray{S,T,N,L,Syms}) where {S,T,N,L,Syms<:Tuple{Syms1,Syms2}} where {Syms1,Syms2} = Syms1,Syms2
symnames(::Type{SLArray{S,T,N,L,Syms}}) where {S,T,N,L,Syms<:Tuple{Syms1,Syms2}} where {Syms1,Syms2} = Syms1,Syms2

"""
    @SLSliced Size Names1, Names2
    @SLSlice Eltype Size Names1, Names2

Creates an anonymous function that builds a labelled static vector with eltype
`ElType` with names determined from the `Names` tuple with size `Size`. If no eltype
is given, then the eltype is determined from the arguments in the constructor.

For example:

```julia
ABC = @SLSliced (4,2) (:a,:b,:c,:d), (:x,:y)
x = ABC([1.0 2.5; 3.0 5.0; 9.0 11.4; 12.9 17.7])
x.a.x == 1.0
x.a.y == 2.5
x.c.x == x[3,1]
x.d.y == x[4,2]
```

"""
macro SLSliced(dims,syms)
  dims = esc(dims)
  syms = esc(syms)
  quote
    SLArray{Tuple{$dims...,},Tuple{$syms...,}}
  end
end

macro SLSliced(T,dims,syms)
  T = esc(T)
  dims = esc(dims)
  syms = esc(syms)
  quote
      SLArray{Tuple{$dims...},$T,length($dims),prod($dims),Tuple{$syms...}}
  end
end


# """
#     dimSymbols(::SLArray{S,T,N,L,Syms}, dim::Int) where {Syms<:Tuple}

# Returns the labels of the `SLArray` associated with dimension `dim`.

# For example:

#     A = @LSliced [1 2; 3 4; 5 6] (:a,:b,:c), (:x, :y)
#     dimSymbols(A,2)  # (:x, :y)
# """
# dimSymbols(::SLArray{S,T,N,L,Syms}, dim::Int) where 
# {S,T,N,L,Syms<:Tuple} = Syms.parameters[dim]

# "returns dimSymbols(,1)"
# rowSymbols(::SLArray{S,T,N,L,Syms}) where 
# {S,T,N,L,Syms<:Tuple} = Syms.parameters[1]

# "returns dimSymbols(,2)"
# colSymbols(::SLArray{S,T,N,L,Syms}) where 
# {S,T,N,L,Syms<:Tuple} = Syms.parameters[2]

symbols(::SLArray{S,T,N,L,Syms}) where 
{rows,cols,S,T,N,L,Syms<:Tuple{rows,cols}} = rows,cols

