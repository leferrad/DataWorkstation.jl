using DataWorkstation
using Documenter

DocMeta.setdocmeta!(DataWorkstation, :DocTestSetup, :(using DataWorkstation); recursive=true)

makedocs(;
    modules=[DataWorkstation],
    authors="Leandro Ferrado <leferrad@gmail.com> and contributors",
    repo="https://github.com/leferrad/DataWorkstation.jl/blob/{commit}{path}#{line}",
    sitename="DataWorkstation.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://leferrad.github.io/DataWorkstation.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/leferrad/DataWorkstation.jl",
    devbranch="main",
)
