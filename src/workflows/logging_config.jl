import ..IO: get_formatted_logger

@doc raw"""
    LoggingConfig(;
        min_level::Symbol=:Info,
        colors_config::ColorsConfig=ColorsConfig(),
        workflow::Bool=true, jobs::Bool=true, steps::Bool=true,
    )
    LoggingConfig(workflow_spec::WorkflowSpec)

Abstraction to manage configuration relevant for the logging of a workflow to execute.

# Fields
- `min_level::Symbol`: Minimum level of log to print, represented as as symbol (e.g.
    `:Debug`, `:Info`, `:Error`, `:Warn`).
- `colors_config::ColorsConfig`: Configuration of colors to use in console logging, through
    an instance of a [`ColorsConfig`](@ref).
- `workflow::Bool`: Flag to indicate that logging at workflow level should be printed.
- `jobs::Bool`: Flag to indicate that logging at job level should be printed.
- `steps::Bool`: Flag to indicate that logging at step level should be printed.

# Arguments
- `workflow_spec::WorkflowSpec`: Specification of the workflow, so the logging configuration
     can be extracted from this [`WorkflowSpec`](@ref) instance.
```
"""
struct LoggingConfig
    min_level::Symbol
    colors_config::ColorsConfig
    workflow::Bool
    jobs::Bool
    steps::Bool

    LoggingConfig(;
        min_level::Symbol = :Info,
        colors_config::ColorsConfig = ColorsConfig(),
        workflow::Bool = true,
        jobs::Bool = true,
        steps::Bool = true,
    ) = new(min_level, colors_config, workflow, jobs, steps)

    LoggingConfig(workflow_spec::WorkflowSpec) = begin
        # Default configuration in case the workflow specification doesn't have an entry
        if !hasproperty(workflow_spec, :logging)
            config = LoggingConfig()
            @debug "Logging not configured. Setting default: $(config)"
            return config
        end

        # Configuration of minimum level of logging
        log_min_level =
            hasproperty(workflow_spec.logging, :min_level) ?
            Symbol(workflow_spec.logging.min_level) : :Info  # Info level by default
        if log_min_level ∉ keys(LOG_LEVELS)
            throw(
                ErrorException(
                    "Logging min_level $(log_min_level) not recognized. " *
                    "Check your workflow specification file",
                ),
            )
        end

        # Configuration of colors for logging by level
        colors_config = ColorsConfig().colors_by_level
        if hasproperty(workflow_spec.logging, :color)
            # TODO: validate entries?
            for level in keys(workflow_spec.logging.color)
                if level in keys(colors_config)
                    color = Symbol(workflow_spec.logging.color[level])
                    if color ∉ keys(Base.text_colors)
                        throw(
                            ErrorException(
                                "Color $(color) not recognized for logging level. " *
                                "Check your workflow specification file",
                            ),
                        )
                    else
                        colors_config[level] = color
                    end
                end
            end
        end

        # Configuration for flags of logging during a workflow execution
        flags = Dict()
        for k in [:workflow, :jobs, :steps]
            flags[k] =
                hasproperty(workflow_spec.logging, k) ?
                getproperty(workflow_spec.logging, k) : true  # Flag in true by default
            if typeof(flags[k]) != Bool
                throw(
                    ErrorException(
                        "Value for logging.$(String(k)) in your workflow specification " *
                        "file must be a bool. Got $(flags[k])",
                    ),
                )
            end
        end

        return new(
            log_min_level,
            ColorsConfig(colors_config),
            flags[:workflow],
            flags[:jobs],
            flags[:steps],
        )
    end
end

@doc raw"""
    get_formatted_logger(
        logging_config::LoggingConfig,
        args...;
        stream::Base.IO=stderr,
        sep::String=" | ",
        date_format::AbstractString = "yyyy-mm-dd HH:MM:SS",
        kwargs...) -> Logging.ConsoleLogger

Get an instance of [`Logging.ConsoleLogger`]
(https://docs.julialang.org/en/v1/stdlib/Logging/#Logging.ConsoleLogger), having a format
for the messages based on the given arguments.

    
This is a version of [`get_formatted_logger()`](@ref), allowing to
configure some parameters with `logging_config`.

# Arguments
- `logging_config::LoggingConfig`: Configuration of logging to implement, in particular the
    minimum level of log to print and the colors to use by logging level.
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

julia> Logging.with_logger(get_formatted_logger(LoggingConfig(), scope="a", tag="b")) do
            @info "Hello world!"
        end
[ 2022-07-17 23:36:20 | scope=a | tag=b | INFO: Hello world!

julia> Logging.with_logger(
        get_formatted_logger(LoggingConfig(min_level=:Debug), "tag1", level="1")) do
            @debug "Logging in this level"
            Logging.with_logger(get_formatted_logger(:Debug, "tag2", level="2")) do
                @debug "Logging in another level"
            end
        end
[ 2022-07-17 23:37:38 | tag1 | level=1 | DEBUG: Logging in this level
[ 2022-07-17 23:37:38 | tag2 | level=2 | DEBUG: Logging in another level
```
"""
get_formatted_logger(
    logging_config::LoggingConfig,
    args...;
    stream::Base.IO = stderr,
    sep::String = " | ",
    date_format::AbstractString = "yyyy-mm-dd HH:MM:SS",
    kwargs...,
) = get_formatted_logger(
    logging_config.min_level,
    args...;
    stream = stream,
    sep = sep,
    date_format = date_format,
    colors_config = logging_config.colors_config,
    kwargs...,
)
