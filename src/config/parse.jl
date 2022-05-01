import TOML

# Regex to identify configuration filenames
CONFIG_FILE_REGEX = r"\$\((.*?).toml\)"

@doc raw"""
    parse_config(d::Dict, root::AbstractString = "") -> ConfigObject
    parse_config(s::AbstractString, root) -> Union{ConfigObject, String}

Parse an input to build a ConfigObject instance. If the input is a Dict, the content
will be converted into entries for a ConfigObject. If some entry contains a string of
the kind "$(filename.toml)", it is taken as a file to load as a ConfigObject.

# Arguments
- `d::Dict`: the dict to convert to a ConfigObject instance
- `s::AbstractString`: when a value is a string with a format like "$(filename.toml)",
    the file is loaded from that path as a ConfigObject
- `root::AbstractString=""`: in case of loading a file,
    this is the root for the path to load (optional)

# Returns
- `ConfigObject`: having the content parsed from the input

# Examples
```jldoctest
julia> config_dict = Dict("a" => 1, "b" => Dict("c" => 2, "d" => 3))
Dict{String, Any} with 2 entries:
  "b" => Dict("c"=>2, "d"=>3)
  "a" => 1

julia> parse_config(config_dict)
ConfigObject((b = ConfigObject((c = 2, d = 3)), a = 1))

julia> using TOML

julia> filename = tempdir() * "/cfg.toml"
"/tmp/cfg.toml"

julia> open(filename, "w") do io
       TOML.print(io, config_dict)
       end;

julia> parse_config(Dict("cfg" => "\$($(filename))"))
ConfigObject((cfg = ConfigObject((b = ConfigObject((c = 2, d = 3)), a = 1)),))
```
"""
parse_config(d::Dict, root::AbstractString = "") =
    ConfigObject((; (Symbol(p.first) => parse_config(p.second, root) for p in d)...))
parse_config(s::AbstractString, root::AbstractString = "") = begin
    m = match(CONFIG_FILE_REGEX, s)
    if m !== nothing
        fn = "$(m.captures[1]).toml"
        return parse_config(TOML.tryparsefile(root * "/" * fn), root)
    end
    s
end
parse_config(x, root = "") = x

@doc raw"""
    load_config(filename, root) -> ConfigObject

Load a file as a ConfigObject instance.

# Arguments
- `filename::AbstractString`: the path to load to get the configuration content
- `root::AbstractString`: root for the path to load (optional)

# Returns
- `ConfigObject`: having the content loaded from the file

# Examples
```jldoctest
julia> config_dict = Dict("a" => 1, "b" => Dict("c" => 2, "d" => 3))
Dict{String, Any} with 2 entries:
  "b" => Dict("c"=>2, "d"=>3)
  "a" => 1

julia> using TOML

julia> filename = tempdir() * "/cfg.toml"
"/tmp/cfg.toml"

julia> open(filename, "w") do io
       TOML.print(io, config_dict)
       end;

julia> load_config(filename)
ConfigObject((b = ConfigObject((c = 2, d = 3)), a = 1))
```
"""
load_config(
    filename::AbstractString, root::AbstractString = "") = begin
    root = root === "" ? dirname(filename) : root
    parse_config(TOML.parsefile(filename), root)
end

@doc raw"""
    update_config(cfg::ConfigObject, entries::NamedTuple) -> ConfigObject

Get a new ConfigObject by updating the content with new entries

# Arguments
- `cfg::ConfigObject`: configuration instance to updated
- `entries::NamedTuple`: new entries to put into the configuration instance

# Returns
- `ConfigObject`: having updated entries

# Examples
```jldoctest
julia> raw = (;a=1, b=(;c=3, d=4))
(a = 1, b = (c = 3, d = 4))

julia> cfg = ConfigObject(raw)
ConfigObject((a = 1, b = ConfigObject((c = 3, d = 4))))

julia> update_config(cfg, (;e=5, f=6))
ConfigObject((a = 1, b = ConfigObject((c = 3, d = 4)), e = 5, f = 6))
```
"""
update_config(old, new) = new
update_config(cfg::ConfigObject, entries::NamedTuple) = begin
    for (k, v) in zip(keys(entries), entries)
        if k in keys(cfg)
            v = update_config(cfg[k], v)
        end
        new_entry = (; k => v)
        cfg = ConfigObject((; cfg..., new_entry...))
    end
    return cfg
end
