import Logging
using Dates: now, format, DateFormat, DateTime

# Supported logging levels, with easier access through Symbols
const LOG_LEVELS = Dict(
    :BelowMinLevel => Logging.BelowMinLevel,
    :Debug => Logging.Debug,
    :Info => Logging.Info,
    :Warn => Logging.Warn,
    :Error => Logging.Error,
    :AboveMaxLevel => Logging.AboveMaxLevel,
)

# Defaul colors to be used for each logging level
const DEFAULT_LOG_COLORS = Dict(
    :BelowMinLevel => Base.default_color_answer,
    :Debug => Base.default_color_debug,
    :Info => Base.default_color_info,
    :Warn => Base.default_color_warn,
    :Error => Base.default_color_error,
    :AboveMaxLevel => Base.default_color_error,
)

@doc raw"""
    ColorsConfig(colors_by_level::Dict{Symbol,Symbol})
    ColorsConfig()

Abstraction to handle the configuration of colors for logging operations.
If no arguments specified, using a default configuration.

# Arguments
- `colors_by_level::Dict{Symbol,Symbol}`: Mapping of logging level to color (i.e.
    Dict(:Info => :blue, :Debug => :grey, :Error => :red))

# Throws
- `ErrorException`: In case some logging level defined is not supported.
"""
struct ColorsConfig
    colors_by_level::Dict{Symbol,Symbol}
    ColorsConfig(colors_by_level::Dict{Symbol,Symbol}) = begin
        supported_log_levels = keys(LOG_LEVELS)
        any([!(k in supported_log_levels) for k in keys(colors_by_level)]) &&
        throw(ErrorException("""
            Argument for ColorsConfig must support the following log levels: $(
                supported_log_levels). Got: $(collect(keys(colors_by_level)))"""))
        new(colors_by_level)
    end
    ColorsConfig() = new(DEFAULT_LOG_COLORS)
end
Base.keys(c::ColorsConfig) = keys(c.colors_by_level)
Base.values(c::ColorsConfig) = values(c.colors_by_level)
Base.getindex(c::ColorsConfig, s::Symbol) = c.colors_by_level[s]

@doc raw"""
    custom_logger_meta_formatter(
        labels::Union{Vector{T}, Nothing} = nothing,
        log_level::Logging.LogLevel = Logging.Debug;
        sep::AbstractString = " | ",
        date_format::Union{AbstractString, Nothing} = "yyyy-mm-dd HH:MM:SS",
    ) where {T <: Union{Any, String}} -> Tuple{Symbol, String, String}

Function to allow a custom format for the logging messages to generate with a
[`Logging.ConsoleLogger`]
(https://docs.julialang.org/en/v1/stdlib/Logging/#Logging.ConsoleLogger)
instance. The format is the following one:
    `[ (date) (sep) (labels separated by 'sep') (log level): (message) `
For example:
    `[ 2022-01-01 00:00:00 | tag=test | INFO: Happy new year!`

# Arguments
- `labels::Union{Vector{T}, Nothing}`: labels to be used in the prefix of the logging
    messages. If `nothing` or an empty `Array`, no labels will be added to the message.
- `log_level::Logging.LogLevel`: Level for the log message to print.

# Keywords
- `sep::AbstractString`: Separator for the labels to print in the message prefix
- `date_format::Union{AbstractString, Nothing}`: Format for the timestamp
    to print in the message prefix. If nothing, no timestamp will be printed.

# Returns
- `Tuple{Symbol, String, String}`: A tuple of log level, prefix of message, and suffix of
    message to be used by a Logger instance when printing a logging message.

# Examples
```jldoctest
julia> using Logging

julia> custom_logger_meta_formatter(date_format=nothing)
(:blue, "DEBUG:", "")

julia> custom_logger_meta_formatter(["level", "sublevel"],
       Logging.Info, date_format=nothing, sep=" - ")
(:blue, "level - sublevel - INFO:", "")
```
"""
function custom_logger_meta_formatter(
    labels::Union{Vector{T},Nothing} = nothing,
    log_level::Logging.LogLevel = Logging.Debug;
    sep::AbstractString = " | ",
    date_format::Union{AbstractString,Nothing} = "yyyy-mm-dd HH:MM:SS",
    color::Symbol = DEFAULT_LOG_COLORS[:Debug],
) where {T<:Union{Any,String}}
    @nospecialize
    prefix, suffix = "", ""
    if date_format !== nothing
        date = format(now(), DateFormat(date_format))
        prefix *= "$(date)$(sep)"
    end
    if labels !== nothing && !isempty(labels)
        labels_str = join(labels, sep)
        prefix *= "$(labels_str)$(sep)"
    end
    log_level_str = uppercase(string(log_level))
    prefix *= "$(log_level_str):"
    return color, prefix, suffix
end

@doc raw"""
    get_formatted_logger(
        min_level::Symbol=:Debug,
        args...;
        stream::Base.IO=stderr,
        sep::String=" | ",
        date_format::AbstractString = "yyyy-mm-dd HH:MM:SS",
        colors_config::ColorsConfig = ColorsConfig(),
        kwargs...) -> Logging.ConsoleLogger

Get an instance of [`Logging.ConsoleLogger`]
(https://docs.julialang.org/en/v1/stdlib/Logging/#Logging.ConsoleLogger), having a format
for the messages based on the given arguments.

This is useful for the package to log the operations on a workflow with details about in
which level they occur, which is important during debugging.

# Arguments
- `min_level::Symbol`: Minimum level of log to print, represented as as symbol (e.g.
    `:Debug`, `:Info`, `:Error`, `:Warn`).
- `args...`: Labels to be printed as in the message prefix.

# Keywords
- `stream::Base.IO`: Stream for the messages to print. Default to `stderr`.
- `sep::AbstractString`: Separator for the labels to print in the message prefix.
- `date_format::Union{AbstractString, Nothing}`: Format for the timestamp.
    to print in the message prefix. If nothing, no timestamp will be printed.
- `kwargs...`: Labels to be printed as `key=value` in the message prefix.

# Returns
- `Logging.ConsoleLogger`: Logger formatted with [`custom_logger_meta_formatter()`](@ref).

# Throws
- `ErrorException`: In case the log level is not supported, or if some
    error occurs during the logger obtention.

```julia-repl
julia> using Logging

julia> Logging.with_logger(get_formatted_logger(scope="repl", tag="test")) do
            @info "Hello world!"
        end
[ 2022-05-18 17:27:01 | scope=repl | tag=test | INFO: Hello world!

julia> Logging.with_logger(get_formatted_logger(:Debug, "tag1", level="1")) do
            @debug "Logging in this level"
            Logging.with_logger(get_formatted_logger(:Debug, "tag2", level="2")) do
                @debug "Logging in another level"
            end
        end
[ 2022-05-18 17:27:16 | tag1 | level=1 | DEBUG: Logging in this level
[ 2022-05-18 17:27:16 | tag2 | level=2 | DEBUG: Logging in another level
```
"""
function get_formatted_logger(
    min_level::Symbol = :Debug,
    args...;
    stream::Base.IO = stderr,
    sep::String = " | ",
    date_format::AbstractString = "yyyy-mm-dd HH:MM:SS",
    colors_config::ColorsConfig = ColorsConfig(),
    kwargs...,
)
    min_level_ =
        min_level ∈ keys(LOG_LEVELS) ? LOG_LEVELS[min_level] :
        throw(ErrorException("""
        Logging level '$min_level' not recognized. Must be in $(collect(keys(LOG_LEVELS)))
        """))

    labels = vcat(args..., ["$(k)=$(v)" for (k, v) in kwargs])
    meta_formatter(log_level, args...) = custom_logger_meta_formatter(
        labels,
        log_level,
        sep = sep,
        date_format = date_format,
        color = colors_config[Symbol(log_level)],
    )
    return Logging.ConsoleLogger(stream, min_level_, meta_formatter = meta_formatter)
end
