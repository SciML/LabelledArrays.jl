# LabelledArrays.jl

[![Build Status](https://travis-ci.org/JuliaDiffEq/LabelledArrays.jl.svg?branch=master)](https://travis-ci.org/JuliaDiffEq/LabelledArrays.jl)
[![Coverage Status](https://coveralls.io/repos/ChrisRackauckas/LabelledArrays.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/ChrisRackauckas/LabelledArrays.jl?branch=master)
[![codecov.io](http://codecov.io/github/ChrisRackauckas/LabelledArrays.jl/coverage.svg?branch=master)](http://codecov.io/github/ChrisRackauckas/LabelledArrays.jl?branch=master)

LabelledArrays.jl is a package which provides arrays with labels, i.e. they are
arrays which `map`, `broadcast`, and all of that good stuff, but their components
are labelled. Thus for instance you can set that the second component is named
`:second` and retrieve it with `A.second`.

## SLVectors

The `SLVector` macros are for creating static LabelledArrays. First you create
the type and then you can use that type.

```julia
# Constructor 1
@SLVector ABC Int [a,b,c]
A = ABC(1,2,3)
A.a == 1
```

Here we have that `A == [1,2,3]` and for example `A.b == 2`. `SLVector`s are just
`FieldVectors`.

## LVectors

The `LVectors`s are fully mutable vectors with labels. There is no performance
loss by using the labelled instead of indexing.

```julia
# Constructor 1
A = @LVector [1,2,3] (:a,:b,:c)
A.a == 1
```
