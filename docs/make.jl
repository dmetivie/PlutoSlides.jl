using PlutoSlides
using Pkg
using DocumenterLandingPage, DocumenterCodeBlocks
using Documenter

DocMeta.setdocmeta!(PlutoSlides, :DocTestSetup, :(using PlutoSlides); recursive=true)

PROJECT_TOML = Pkg.TOML.parsefile(joinpath(@__DIR__, "..", "Project.toml"))
PkgVERSION = PROJECT_TOML["version"]
NAME = PROJECT_TOML["name"]
AUTHORS = join(PROJECT_TOML["authors"], ", ") * " and contributors"
GITHUB = "https://github.com/dmetivie/PlutoSlides.jl"

fmt = Documenter.HTML(
    prettyurls=true,
    repolink=GITHUB,
    canonical="https://dmetivie.github.io/PlutoSlides.jl",
    # assets=["assets/favicon.ico"],
    assets=["assets/landing.css"],
    footer="[$NAME.jl]($GITHUB) v$PkgVERSION docs powered by [Documenter.jl](https://github.com/JuliaDocs/Documenter.jl)."
)

makedocs(
    modules=[PlutoSlides],
    sitename="PlutoSlides.jl",
    authors=AUTHORS,
    clean=true,
    doctest=false,
    format=fmt,
    pages=[
        "Home" => "index.md",
        "Style and themes" => "style.md",
        "PDF export" => "pdf.md",
        "Suggested workflow" => "workflow.md",
        "API" => "api.md",
    ],
    plugins=[LandingPage(), CodeBlocks()],
)

deploydocs(;
    repo="github.com/dmetivie/PlutoSlides.jl",
    devbranch="master",
)
