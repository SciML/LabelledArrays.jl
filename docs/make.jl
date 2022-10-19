using Documenter, LabelledArrays

include("pages.jl")

makedocs(sitename = "LabelledArrays.jl",
         authors = "Chris Rackauckas",
         modules = [LabelledArrays],
         clean = true, doctest = false,
         format = Documenter.HTML(analytics = "UA-90474609-3",
                                  assets = ["assets/favicon.ico"],
                                  canonical = "https://docs.sciml.ai/LabelledArrays/stable/"),
         pages = pages)

deploydocs(repo = "github.com/SciML/LabelledArrays.jl.git";
           push_preview = true)
