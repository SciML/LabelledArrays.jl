# LArrays

The `LArrays`s are fully mutable arrays with labels. There is no performance
loss by using the labelled instead of indexing. Using the macro with values
and labels generates the labelled array with the given values:

```julia
A = @LArray [1,2,3] (:a,:b,:c)
A.a == 1
```

One can generate a labelled array with undefined values by instead giving
the dimensions:

```julia
A = @LArray Float64 (2,2) (:a,:b,:c,:d)
W = rand(2,2)
A .= W
A.d == W[2,2]
```

or using an `@LVector` shorthand:

```julia
A = @LVector Float64 (:a,:b,:c,:d)
A .= rand(4)
```

As with `SLArray`, alternative constructors exist that use the keyword argument
form:

```julia
julia> LVector(a=1, b=2, c=3)
3-element LArray{Int64,1,(:a, :b, :c)}:
 1
 2
 3

julia> LArray((2,2); a=1, b=2, c=3, d=4) # need to specify size as first argument
2×2 LArray{Int64,2,(:a, :b, :c, :d)}:
 1  3
 2  4
```

One can also specify the indices directly.
```julia
julia> z = @LArray [1.,2.,3.] (a = 1:2, b = 2:3);
julia> z.b
2-element view(::Array{Float64,1}, 2:3) with eltype Float64:
 2.0
 3.0
julia> z = @LArray [1 2; 3 4] (a = (2, :), b = 2:3);
julia> z.a
2-element view(::Array{Int64,2}, 2, :) with eltype Int64:
 3
 4
```

The labels of LArray and SLArray can be accessed 
by function `symbols`, which returns a tuple of symbols.
