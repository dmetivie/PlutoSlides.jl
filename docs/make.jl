using PlutoPresentations
using Documenter

DocMeta.setdocmeta!(PlutoPresentations, :DocTestSetup, :(using PlutoPresentations); recursive=true)

makedocs(;
    modules=[PlutoPresentations],
    authors="David Métivier <david.metivier@inrae.fr>",
    sitename="PlutoPresentations.jl",
    format=Documenter.HTML(;
        canonical="https://dmetivie.github.io/PlutoPresentations.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/dmetivie/PlutoPresentations.jl",
    devbranch="master",
)
