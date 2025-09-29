using PlutoSlides
using Documenter

DocMeta.setdocmeta!(PlutoSlides, :DocTestSetup, :(using PlutoSlides); recursive=true)

makedocs(;
    modules=[PlutoSlides],
    authors="David Métivier <david.metivier@inrae.fr>",
    sitename="PlutoSlides.jl",
    format=Documenter.HTML(;
        canonical="https://dmetivie.github.io/PlutoSlides.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/dmetivie/PlutoSlides.jl",
    devbranch="master",
)
