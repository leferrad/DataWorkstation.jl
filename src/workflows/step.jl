"""Struct to represent Steps in a Workflow"""
struct WorkflowStep{S} end

@doc raw"""
    run_step_function(s::Symbol, cfg::ConfigObject) -> Any

Run a step function previously registered through a call of
[`register_step_function()`](@ref). The return type will depend on the
design of the involved step function, but in general it is expected to be `Nothing`.

This is an internal method which is convenient for the execution of a workflow through
[`run_workflow()`](@ref), so it should be used directly only for testing purposes.

For examples of usage, look at the documentation of [`register_step_function()`](@ref).

# Arguments
- `s::Symbol`: Identifier for the step function.
- `cfg::ConfigObject`: Argument for the step function to run.

# Throws
- `ErrorException`: If some error occurs during the step function execution.
"""
function run_step_function end
run_step_function(s::Symbol, cfg::ConfigObject) =
# NOTE: doing a invokelatest call to get the latest version of the step function to run
    Base.invokelatest(run_step_function, WorkflowStep{s}, cfg)

@doc raw"""
    register_step_function(step_sym::Symbol, func::Function; overwrite::Bool = true)
    register_step_function(func::Function; overwrite::Bool = true)

Register a step function which is expected to be runned as part of some workflow specified
through a [`WorkflowSpec`](@ref).

A step function is just a simple `Function` that can only take a [`ConfigObject`](@ref)
instance as unique argument to operate, which makes simpler
to build workflows that chain step-by-step operations with some configured behavior.
This kind of function can be identified through a `step_sym` symbol, or with a function
that will be identified with its name. To be a valid function, it should meet the
following aspects:
- It must be available for calls done outside its origin module (so make sure it can be
imported, or just use `eval` when declaring the function).
- It must have one argument of the type [`ConfigObject`](@ref) or `Any`. This object
should contain all the necessary configuration to allow the step work correctly.
- Its return type will depend on the design of the involved step function,
but in general it is expected to be `Nothing`.

# Arguments
- `step_sym::Symbol`: Identifier for the step function to register.
- `func::Function`: Function to register.
- `overwrite::Bool = true`: In case the step function was already registered, decide if
it should be overwriten.

# Throws
- `ErrorException`: In case the step function is not valid, or it already exists
(and `overwrite = false`).

```julia-repl
julia> function print_config(cfg) println("Config: $cfg") end
print_config (generic function with 1 method)

julia> register_step_function(:PrintConfig, print_config)
run_step_function (generic function with 2 methods)

julia> run_step_function(:PrintConfig, ConfigObject((;a=1)))
# prints: "Config: ConfigObject((a = 1,))"

julia> register_step_function(:GetConfiguredName, cfg -> cfg.name)
run_step_function (generic function with 3 methods)

julia> run_step_function(:GetConfiguredName, ConfigObject((;name="pepe")))
"pepe"

julia> multiply_x_and_y(cfg) = cfg.x * cfg.y
multiply_x_and_y (generic function with 1 method)

julia> register_step_function(multiply_x_and_y)
run_step_function (generic function with 4 methods)

julia> run_step_function(:multiply_x_and_y, ConfigObject((;x=5, y=4)))
20
```
"""
function register_step_function(step_sym::Symbol, func::Function; overwrite::Bool = true)
    !is_valid_step_function(func) && throw(
        ErrorException(
            "Function $(func) is not valid to register a step function for $(step_sym). " *
            "Please read the documentation to know how to define it correctly.",
        ),
    )

    if !overwrite && check_step_function_existence(step_sym)
        throw(
            ErrorException(
                "Step $(step_sym) already has a registered function and parameter " *
                "overwrite=false. Remove the registered function or set overwrite=true.",
            ),
        )
    end

    step = WorkflowStep{step_sym}
    eval(quote
        run_step_function(::Type{$step}, cfg::ConfigObject) = $func(cfg)
    end)
end
register_step_function(func::Function; overwrite::Bool = true) =
# If regex matches, then it is an anonymous function that doesn't have a actual name
    match(r"#\d+", string(nameof(func))) !== nothing ?
    throw(
        ErrorException(
            "Method register_step_function() must be called with a step type for " *
            "anonymous function like $func",
        ),
    ) : register_step_function(nameof(func), func; overwrite = overwrite)
