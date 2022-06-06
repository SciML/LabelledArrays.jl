# Relation to NamedTuples

Julia's Base has NamedTuples in v0.7+. They are constructed as:

```julia
p = (σ = 10.0,ρ = 28.0,β = 8/3)
```

and they support `p[1]` and `p.σ` as well. The `LVector`, `SLVector`, `LArray`
and `SLArray` constructors also support named tuples as their arguments:

```julia
julia> LVector((a=1, b=2))
2-element LArray{Int64,1,(:a, :b)}:
 1
 2

julia> SLVector((a=1, b=2))
2-element SLArray{Tuple{2},1,(:a, :b),Int64}:
 1
 2

julia> LArray((2,2), (a=1, b=2, c=3, d=4))
2×2 LArray{Int64,2,(:a, :b, :c, :d)}:
 1  3
 2  4

julia> SLArray{Tuple{2,2}}((a=1, b=2, c=3, d=4))
2×2 SLArray{Tuple{2,2},2,(:a, :b, :c, :d),Int64}:
 1  3
 2  4
```

Converting to a named tuple from a labelled array x is available
using `convert(NamedTuple, x)`. Furthermore, `pairs(x)`
creates an iterator that is functionally the same as
`pairs(convert(NamedTuple, x))`, yielding `:label => x.label`
for each label of the array.

There are some crucial differences between a labelled array and
a named tuple. Labelled arrays can have any dimensions while 
named tuples are always 1D. A named tuple can have different types
on each element, while an `SLArray` can only have one element
type and furthermore it has the actions of a static vector.
As a result `SLArray` has less element type information, which 
improves compilation speed while giving more vector functionality
than a NamedTuple. `LArray` also only has a single element type and,
unlike a named tuple, is mutable.