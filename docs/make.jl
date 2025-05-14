using NextStride
using Documenter

DocMeta.setdocmeta!(NextStride, :DocTestSetup, :(using NextStride); recursive=true)

makedocs(;
    modules=[NextStride],
    authors="Federico Stra <stra.federico@gmail.com> and contributors",
    sitename="NextStride.jl",
    format=Documenter.HTML(;
        canonical="https://FedericoStra.github.io/NextStride.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/FedericoStra/NextStride.jl",
    devbranch="master",
)
