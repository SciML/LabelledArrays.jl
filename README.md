# LabelledArrays.jl

[![Build Status](https://travis-ci.org/JuliaDiffEq/LabelledArrays.jl.svg?branch=master)](https://travis-ci.org/JuliaDiffEq/LabelledArrays.jl)
[![Coverage Status](https://coveralls.io/repos/ChrisRackauckas/LabelledArrays.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/ChrisRackauckas/LabelledArrays.jl?branch=master)
[![codecov.io](http://codecov.io/github/ChrisRackauckas/LabelledArrays.jl/coverage.svg?branch=master)](http://codecov.io/github/ChrisRackauckas/LabelledArrays.jl?branch=master)

LabelledArrays.jl is a package which provides arrays with labels, i.e. they are
arrays which `map`, `broadcast`, and all of that good stuff, but their components
are labelled. Thus for instance you can set that the second component is named
`:second` and retrieve it with `A.second`.

## SLArrays

The `SLArray` and `SLVector` macros are for creating static LabelledArrays.
First you create the type and then you can use that constructor to generate
instances of the labelled array.

```julia
ABC = @SLVector (:a,:b,:c)
A = ABC(1,2,3)
A.a == 1

ABCD = @SLArray (2,2) (:a,:b,:c,:d)
B = ABCD(1,2,3,4)
B.c == 3
B[2,2] == B.d
```

Here we have that `A == [1,2,3]` and for example `A.b == 2`. We can create a
typed `SLArray` via:

```julia
SVType = @SLVector Float64 (:a,:b,:c)
```

Alternatively, you can also construct a static labelled array using the
`SLVector` constructor by writing out the entries as keyword arguments:

```julia
julia> SLVector(a=1, b=2, c=3)
3-element SLArray{Tuple{3},1,(:a, :b, :c),Int64}:
 1
 2
 3
```

For general N-dimensional labelled arrays, you need to specify the size
(`Tuple{dim1,dim2,...}`) as the type parameter to the `SLArray` constructor:

```julia
julia> SLArray{Tuple{2,2}}(a=1, b=2, c=3, d=4)
2×2 SLArray{Tuple{2,2},2,(:a, :b, :c, :d),Int64}:
 1  3
 2  4
```

Constructing copies with some items changed is supported by
a keyword constructor whose first argument is the source and
additonal keyword arguments change several entries.

```julia
julia> v1 = SLVector(a=1.1, b=2.2, c=3.3);
julia> v2 = SLVector(v1; b=20.20, c=30.30 )
3-element SLArray{Tuple{3},Float64,1,3,(:a, :b, :c)}:
  1.1
 20.2
 30.3
```

```julia
julia> ABCD = @SLArray (2,2) (:a,:b,:c,:d);
julia> B = ABCD(1,2,3,4);
julia> B2 = SLArray(B; c=30 )
2×2 SLArray{Tuple{2,2},Int64,2,4,(:a, :b, :c, :d)}:
 1  30
 2   4
```

One can also specify the indices directly.
```julia
julia> EFG = @SLArray (2,2) (e=1:3, f=4, g=2:4);
julia> y = EFG(1.0,2.5,3.0,5.0)
2×2 SLArray{Tuple{2,2},Float64,2,4,(e = 1:3, f = 4, g = 2:4)}:
 1.0  3.0
 2.5  5.0

julia> y.g
3-element view(reshape(::StaticArrays.SArray{Tuple{2,2},Float64,2,4}, 4), 2:4) with eltype Float64:
 2.5
 3.0
 5.0

julia> Arr = @SLArray (2, 2) (a = (2, :), b = 3);
julia> z = Arr(1, 2, 3, 4);
julia> z.a
2-element view(::StaticArrays.SArray{Tuple{2,2},Int64,2,4}, 2, :) with eltype Int64:
 2
 4
```

## LArrays

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


## Labelled slices

For a labelled array where the row and column slices are labeled, use `@SLSlice`
and `@LSlice`, similar to `@SLArray` and `@LArray` but passing a _tuple_ of label
tuples.

For static arrays with labeled rows and columns:

```
ABC = @SLSliced (3,2) (:a,:b,:c), (:x, :y)
A = ABC([1 2; 3 4; 5 6])
A.a.x == 1
A[:c, :y] == 6
```

For regular arrays with labeled rows and columns:

```
A = @LSliced [1 2; 3 4; 5 6] (:a,:b,:c), (:x, :y)
A.a.x == 1
A[:c, :y] == 6
```

The labels of LSliced and SLScliced can be accessed 
by function `symbols`.
For a two-dimensional LSliced or SLSliced, it returns a tuple
with first entry a tuple of row symbols and second entry a tuple of column symbols.
For higher-dimensional slices, it returns a Tuple-Type object with
parameters referring to the names of the dimensions.

```
A = @LSliced [1 2; 3 4; 5 6] (:a,:b,:c), (:x, :y)
symbols(A)[1] == (:a, :b, :c)
```

## Example: Nice DiffEq Syntax Without A DSL

LabelledArrays.jl are a way to get DSL-like syntax without a macro. In this case,
we can solve differential equations with labelled components by making use of
labelled arrays, and always refer to the components by name instead of index.

Let's solve the Lorenz equation. Using `@LVector`s, we can do:

```julia
using LabelledArrays, OrdinaryDiffEq

function lorenz_f(du,u,p,t)
  du.x = p.σ*(u.y-u.x)
  du.y = u.x*(p.ρ-u.z) - u.y
  du.z = u.x*u.y - p.β*u.z
end

u0 = @LArray [1.0,0.0,0.0] (:x,:y,:z)
p = @LArray [10.0, 28.0, 8/3]  (:σ,:ρ,:β)
tspan = (0.0,10.0)
prob = ODEProblem(lorenz_f,u0,tspan,p)
sol = solve(prob,Tsit5())
# Now the solution can be indexed as .x/y/z as well!
sol[10].x
```

We can also make use of `@SLVector`:

```julia
LorenzVector = @SLVector (:x,:y,:z)
LorenzParameterVector = @SLVector (:σ,:ρ,:β)

function f(u,p,t)
  x = p.σ*(u.y-u.x)
  y = u.x*(p.ρ-u.z) - u.y
  z = u.x*u.y - p.β*u.z
  LorenzVector(x,y,z)
end

u0 = LorenzVector(1.0,0.0,0.0)
p = LorenzParameterVector(10.0,28.0,8/3)
tspan = (0.0,10.0)
prob = ODEProblem(f,u0,tspan,p)
sol = solve(prob,Tsit5())
```

## Relation to NamedTuples

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
