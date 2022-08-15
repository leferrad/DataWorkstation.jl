using DataWorkstation
using Documenter

DocMeta.setdocmeta!(
    DataWorkstation,
    :DocTestSetup,
    :(using DataWorkstation);
    recursive = true,
)

makedocs(;
    modules = [DataWorkstation],
    authors = "Leandro Ferrado <leferrad@gmail.com> and contributors",
    sitename = "DataWorkstation.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", nothing) == "true",
        canonical = "https://leferrad.github.io/DataWorkstation.jl",
        assets = String[],
    ),
    pages = [
        "Introduction" => ["index.md",],
        "User Guide" => ["basics.md", "quick_example.md"],
        "API" => ["api_reference.md"],
    ],
)

deploydocs(;
    repo = "github.com/leferrad/DataWorkstation.jl.git",
    target = "build",
    push_preview = true,
)
