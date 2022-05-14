using DataWorkstation

using DataFrames
using Logging
using Test

Logging.disable_logging(Logging.Info)

@testset "DataWorkstation.jl" begin
    include("config/config_object.jl")
    include("config/parse.jl")
    include("io/file_handler.jl")
    include("io/file_handlers_default.jl")
end
