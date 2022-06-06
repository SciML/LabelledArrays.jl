# SLArrays

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