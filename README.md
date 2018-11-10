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

## LArrays

The `LArrayz`s are fully mutable arrays with labels. There is no performance
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

## Differences from NamedTuples

Julia's Base has NamedTuples in v0.7+. They are constructed as:

```julia
p = (σ = 10.0,ρ = 28.0,β = 8/3)
```

and they support `p[1]` and `p.σ` as well. However, there are some
crucial differences between a labelled array and static array.
But `@SLVector` also differs from a NamedTuple due to how the
type information is stored. A NamedTuple can have different types
on each element, while an `@SLVector` can only have one element
type and has the actions of a static vector. Thus `@SLVector`
has less element type information, improving compilation speed,
while giving more vector functionality than a NamedTuple.
`@LVector` also only has a single element type and, a crucial
difference, is mutable.
