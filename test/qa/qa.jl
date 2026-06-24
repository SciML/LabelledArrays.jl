using LabelledArrays
using Aqua: Aqua
using ExplicitImports: ExplicitImports
using SciMLTesting: SciMLTesting, run_qa

# Aqua: ambiguities / unbound_args / undefined_exports are genuine pre-existing
# findings (method ambiguities, unbound type parameters, and the dead exports
# `@SLSliced`/`@LSliced`/`dimSymbols`/`rowSymbols`/`colSymbols`) tracked in
# https://github.com/SciML/LabelledArrays.jl/issues/205. JET likewise finds the
# `setfield!`-on-immutable-`LArray` dead branch in `setproperty!` (src/larray.jl)
# tracked in the same issue, so JET stays opt-out here. The remaining Aqua checks
# (incl. deps_compat) run and pass.
#
# ExplicitImports ignore-list (all_qualified_accesses_are_public): every entry is a
# non-public name from a dependency (or Base) that LabelledArrays must access by
# qualification because there is no public alternative — either a method-extension
# definition of a non-public function, or a non-public type/function used directly:
#   @_propagate_inbounds_meta, print_array, dataids, BroadcastStyle, AbstractArrayStyle,
#   Broadcasted  -> Base / Base.Broadcast internals (broadcast + indexing machinery)
#   @forward                                          -> MacroTools (method forwarding)
#   Dual                                              -> ForwardDiff (DiffCache eltype)
#   LU, size_tuple                                    -> StaticArrays internals
#   can_setindex, ismutable, restructure, undefmatrix -> ArrayInterface trait methods
#   enlargediffcache!                                 -> PreallocationTools internal
# The trailing four (@propagate_inbounds, OneTo, elsize, unsafe_convert) are Base names
# that are `public` on Julia 1.11+ but, because the `public` keyword predates the LTS,
# read as non-public to ExplicitImports on the 1.10 LTS — they are ignored only to keep
# the LTS QA lane green; on 1.11+ they are genuinely public.
run_qa(
    LabelledArrays;
    Aqua = Aqua,
    aqua_kwargs = (;
        ambiguities = false,
        unbound_args = false,
        undefined_exports = false,
    ),
    ExplicitImports = ExplicitImports,
    explicit_imports = true,
    ei_kwargs = (;
        all_qualified_accesses_are_public = (;
            ignore = (
                Symbol("@_propagate_inbounds_meta"), Symbol("@forward"),
                :AbstractArrayStyle, :BroadcastStyle, :Broadcasted, :Dual, :LU,
                :can_setindex, :dataids, :enlargediffcache!, :ismutable, :print_array,
                :restructure, :size_tuple, :undefmatrix,
                # public on 1.11+, read as non-public on the 1.10 LTS only:
                Symbol("@propagate_inbounds"), :OneTo, :elsize, :unsafe_convert,
            ),
        ),
    ),
)
