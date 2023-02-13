# SLArrays

The `SLArray` and `SLVector` macros create static LabelledArrays.
First, the user would create the array type, then use that constructor to generate
instances of the labelled array.

## `@SLArray` and `@SLVector` macros

Macro constructors are convenient for building most `SLArray` objects. An 
`@SLArray` may be of arbitrary dimension, while an `@SLVector` is a 
one dimensional array. 

```@docs
@SLArray
@SLVector
```

## `SLArray` and `SLVector` constructors

Alternatively, users can construct a static labelled array using the
`SLVector` and `SLArrays` constructors by writing out the entries as keyword arguments:

```@docs
SLArray
SLVector
```

## Manipulating `SLArrays` and `SLVectors`

Users may want a list of the labels or keys in an `SLArray` or `SLVector`.
The `symbols(::SLArray)` function returns a tuple of array labels.

```@docs
symbols(::SLArray)
```