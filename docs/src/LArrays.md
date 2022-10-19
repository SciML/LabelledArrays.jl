# LArrays

`LArrays` are fully mutable arrays with labels. There is no performance
loss by using labelled indexing instead of purely numerical indexing. 
Using the macro with values and labels generates the labelled array with
the given values:

Users interested in using labelled elements in their arrays should also 
consider `ComponentArrays` from the 
[ComponentArrays.jl](https://docs.sciml.ai/ComponentArrays/stable/)
library. `ComponentArrays` are well integrated into the SciML ecosystem. 

## `@LArray` and `@LVector` macros

Macro constructors are convenient for building most `LArray` objects. An 
`@LArray` may be of arbitrary dimension while an `@LVector` is a 
one dimensional array. 

```@docs
@LArray
@LVector
```

## `LArray` and `LVector` constructors

The original constructors for `LArray`s and `LVector`s are as 
follows: 

```@docs
LArray
LVector
```
## Manipulating `LArrays` and `LVectors`

User may want a list of the labels or keys in an `LArray` or `LVector`.
The `symbols(::LArray)` function returns a tuple of array labels.

```@docs
symbols
```