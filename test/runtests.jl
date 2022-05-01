using DataWorkstation
using Logging
using Test

Logging.disable_logging(Logging.Info)

@testset "DataWorkstation.jl" begin
    include("config/config_object.jl")
    include("config/parse.jl")
end
