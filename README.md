# LabelledArrays.jl

[![Build Status](https://travis-ci.org/ChrisRackauckas/LabelledArrays.jl.svg?branch=master)](https://travis-ci.org/ChrisRackauckas/LabelledArrays.jl)
[![Coverage Status](https://coveralls.io/repos/ChrisRackauckas/LabelledArrays.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/ChrisRackauckas/LabelledArrays.jl?branch=master)
[![codecov.io](http://codecov.io/github/ChrisRackauckas/LabelledArrays.jl/coverage.svg?branch=master)](http://codecov.io/github/ChrisRackauckas/LabelledArrays.jl?branch=master)

LabelledArrays.jl is a package which provides arrays with labels, i.e. they are
arrays which `map`, `broadcast`, and all of that good stuff, but their components
are labelled. Thus for instance you can set that the second component is named
`:second` and retrieve it with `A[:second]`.

## SLVectors

The `SLVector` macros are for creating static LabelledArrays:

```julia
A = @SLVector [a,b,c] [1,2,3]
```

Here we have that `A == [1,2,3]` and for example `A.b == 2`
