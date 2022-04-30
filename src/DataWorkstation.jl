module DataWorkstation

include("config/Config.jl")
using .Config
export ConfigObject, load_config, parse_config, update_config

include("io/IO.jl")
include("workflows/Workflows.jl")

end
