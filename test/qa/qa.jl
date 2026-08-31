using SciMLTesting, LabelledArrays

# These qualified accesses are non-public API of Base/StaticArrays/ForwardDiff that
# LabelledArrays must use to implement the broadcast, indexing, and linear algebra
# interfaces (e.g. Base.BroadcastStyle/Base.dataids overloads, StaticArrays.LU dispatch).
run_qa(
    LabelledArrays;
    ei_kwargs = (;
        all_qualified_accesses_are_public = (;
            ignore = (
                Symbol("@_propagate_inbounds_meta"), :AbstractArrayStyle, :BroadcastStyle,
                :Dual, :LU, :dataids, :print_array, :size_tuple,
            ),
        ),
    ),
)
