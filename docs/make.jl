using Documenter, LabelledArrays

cp("./docs/Manifest.toml", "./docs/src/assets/Manifest.toml", force = true)
cp("./docs/Project.toml", "./docs/src/assets/Project.toml", force = true)

include("pages.jl")

makedocs(sitename = "LabelledArrays.jl",
         authors = "Chris Rackauckas",
         modules = [LabelledArrays],
         clean = true, doctest = false, linkcheck = true,
         format = Documenter.HTML(assets = ["assets/favicon.ico"],
                                  canonical = "https://docs.sciml.ai/LabelledArrays/stable/"),
         pages = pages)

deploydocs(repo = "github.com/SciML/LabelledArrays.jl.git";
           push_preview = true)
