using LabelledArrays, Aqua
@testset "Aqua" begin
    Aqua.find_persistent_tasks_deps(LabelledArrays)
    Aqua.test_ambiguities(LabelledArrays, recursive = false, broken = true)
    Aqua.test_deps_compat(LabelledArrays)
    Aqua.test_piracies(LabelledArrays,
        treat_as_own = [])
    Aqua.test_project_extras(LabelledArrays)
    Aqua.test_stale_deps(LabelledArrays)
    Aqua.test_unbound_args(LabelledArrays)
    Aqua.test_undefined_exports(LabelledArrays)
end
