using DataWorkstation

using DataFrames
using Logging
using SimpleMock
using Test

# Disable logging output to allow easier inspection of test results
Logging.disable_logging(Logging.Info)

@testset "DataWorkstation.jl" begin
    include("config/config_object.jl")
    include("config/parse.jl")
    include("io/file_handler.jl")
    include("io/file_handlers_default.jl")
    include("io/logging.jl")
    include("workflows/logging_config.jl")
    include("workflows/step.jl")
    include("workflows/utils.jl")
    include("workflows/workflow.jl")
    include("workflows/workflow_spec.jl")
end
