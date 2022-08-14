import Logging

@doc raw"""
    run_job_steps(
        cfg::ConfigObject,
        workflow_name::String,
        job_name::String,
        steps::Vector{Symbol};
        logging_config::LoggingConfig = LoggingConfig(),
    ) -> Float

Run a list of step functions previously registered through calls of
[`register_step_function()`](@ref), using the configuration specified in a `ConfigObject`.

This is an internal method which is convenient for the execution of a workflow through
[`run_workflow()`](@ref), so it should be used directly only for testing purposes.

# Arguments
- `cfg::ConfigObject`: Configuration to use during steps running.
- `workflow_name::String`: Name of workflow to print on logging.
- `job_name::String`: Name of job to print on logging.
- `steps::Vector{Symbol}`: Identifiers of step functions to run.
- `logging_config::LoggingConfig`: Configuration for logging operations (optional).

# Returns
- `Float`: duration of the execution.

# Throws
- `ErrorException`: If some step function does not exist, or some error occurs
    during the step functions execution.
"""
run_job_steps(
    cfg::ConfigObject,
    workflow_name::String,
    job_name::String,
    steps::Vector{Symbol};
    logging_config::LoggingConfig = LoggingConfig(),
) = begin
    duration = @elapsed begin
        for step_sym in steps
            if !check_step_function_existence(step_sym)
                throw(
                    ErrorException(
                        "Step '$(step_sym)' does not have a registered step function",
                    ),
                )
            end
            @debug "Running step '$(step_sym)'"
            Logging.with_logger(
                get_formatted_logger(
                    logging_config,
                    workflow = workflow_name,
                    job = job_name,
                    step = string(step_sym),
                ),
            ) do
                t = @elapsed run_step_function(step_sym, cfg)
                sec = round(t, digits = 3)
                @debug """Completed execution of step '$(step_sym)' in $(sec) seconds"""
            end
        end
    end
    return duration
end

@doc raw"""
    run_jobs(
        cfg::ConfigObject,
        workflow_spec::WorkflowSpec,
        jobs_keys::Vector{Symbol};
        logging_config::LoggingConfig = LoggingConfig(),
    ) -> Float

Run a list of jobs for a given Workflow, each of them having step functions
previously registered through calls of [`register_step_function()`](@ref),
using the configuration specified in a `ConfigObject`.

This is an internal method which is convenient for the execution of a workflow through
[`run_workflow()`](@ref), so it should be used directly only for testing purposes.

# Arguments
- `cfg::ConfigObject`: Configuration to use during steps running.
- `workflow_spec::WorkflowSpec`: Specification for the given workflow.
- `jobs_keys::Vector{Symbol}`: Selection of jobs to run from the given workflow.
- `logging_config::LoggingConfig`: Configuration for logging operations (optional).

# Returns
- `Float`: duration of the execution.

# Throws
- `ErrorException`: If some WorkflowSpec entry needed does not exist, or some error occurs
    during the jobs execution.
"""
run_jobs(
    cfg::ConfigObject,
    workflow_spec::WorkflowSpec,
    jobs_keys::Vector{Symbol};
    logging_config::LoggingConfig = LoggingConfig(),
) = begin
    workflow_name = workflow_spec.name

    total_duration = 0.0
    for job_key in jobs_keys
        !hasproperty(workflow_spec.jobs, job_key) && throw(
            ErrorException("Job $(job_key) not valid for jobs on the WorkflowSpec: " *
            "$(keys(workflow_spec.jobs))"))

        job_name = string(job_key)
        Logging.with_logger(
            get_formatted_logger(logging_config, workflow = workflow_name, job = job_name),
        ) do
            job_spec = workflow_spec.jobs[job_key]

            !hasproperty(job_spec, :steps) && throw(
                ErrorException("Job '$(job_name)' must have a list of steps to run " *
                "configured on the WorkflowSpec"))

            steps = job_spec.steps
            cfg_job = hasproperty(cfg, :with) ? update_config(cfg, job_spec.with) : cfg
            @debug "Starting execution of job '$(job_name)'"
            duration = run_job_steps(
                cfg_job,
                workflow_name,
                job_name,
                Symbol.(steps);
                logging_config = logging_config,
            )
            @debug """
            Completed execution of job '$(job_name)' in $(round(duration, digits=3)) seconds
            """
            total_duration += duration
        end
    end
    return total_duration
end

@doc raw"""
    run_workflow(cfg, workflow_spec; jobs_keys) -> Float
    run_workflow(cfg, filename; jobs_keys) -> Float
    run_workflow(filename; jobs_keys, config_root) -> Float

Run a selection of jobs from a workflow specified, each of them having step functions
previously registered through calls of [`register_step_function()`](@ref),
using the configuration specified in a `ConfigObject`.

# Arguments
- `cfg::ConfigObject`: Configuration to use during steps running.
- `workflow_spec::WorkflowSpec`: Specification for the given workflow.
- `filename::String`: File to load workflow (and configuration) specification.
- `jobs_keys::Vector{Symbol}`: Selection of jobs to run from the given workflow.
- `config_root::Union{AbstractString,Nothing}`: Root for the configuration
    file to load (optional)

# Returns
- `Float`: duration of the execution.

# Throws
- `ErrorException`: If some WorkflowSpec entry needed does not exist, or some error occurs
    during the jobs execution.

# Examples
```jldoctest
julia> cfg = ConfigObject((;
           result_job_a_step_1 = "res_job_a_step_1",
           result_job_a_step_2 = "res_job_a_step_2",
           result_job_b_step_1 = "res_job_b_step_1",
           result_job_b_step_2 = "res_job_b_step_2",
       ))
ConfigObject((result_job_a_step_1 = "res_job_a_step_1",
    result_job_a_step_2 = "res_job_a_step_2", result_job_b_step_1 = "res_job_b_step_1",
    result_job_b_step_2 = "res_job_b_step_2"))

julia> workflow_spec = WorkflowSpec((;
        name = "test_workflow",
        jobs = (;
            job_a_test_run_jobs = (; steps = ["job_a_step_1", "job_a_step_2"]),
            job_b_test_run_jobs = (; steps = ["job_b_step_1", "job_b_step_2"],
                                    needs = "job_a_test_run_jobs"),
        ),
        ))
WorkflowSpec((name = "test_workflow", jobs = (job_a_test_run_jobs =
    (steps = ["job_a_step_1", "job_a_step_2"],), job_b_test_run_jobs =
    (steps = ["job_b_step_1", "job_b_step_2"], needs = "job_a_test_run_jobs"))))

julia> result = []  # Just a collector of results from runned steps
Any[]

julia> job_a_step_1(c::ConfigObject) = push!(result, c.result_job_a_step_1)
job_a_step_1 (generic function with 1 method)

julia> job_a_step_2(c::ConfigObject) = push!(result, c.result_job_a_step_2)
job_a_step_2 (generic function with 1 method)

julia> job_b_step_1(c::ConfigObject) = push!(result, c.result_job_b_step_1)
job_b_step_1 (generic function with 1 method)

julia> job_b_step_2(c::ConfigObject) = push!(result, c.result_job_b_step_2)
job_b_step_2 (generic function with 1 method)

julia> register_step_function(job_a_step_1)
run_step_function (generic function with 2 methods)

julia> register_step_function(job_a_step_2)
run_step_function (generic function with 3 methods)

julia> register_step_function(job_b_step_1)
run_step_function (generic function with 4 methods)

julia> register_step_function(job_b_step_2)
run_step_function (generic function with 5 methods)

julia> run_workflow(cfg, workflow_spec);

julia> result
4-element Vector{Any}:
 "res_job_a_step_1"
 "res_job_a_step_2"
 "res_job_b_step_1"
 "res_job_b_step_2"
```
"""
run_workflow(
    cfg::ConfigObject,
    workflow_spec::WorkflowSpec;
    jobs_keys::Union{Symbol,Vector{Symbol},Nothing} = nothing
) = begin
    workflow_name = workflow_spec.name

    # Get configuration for logging operations from workflow specification
    logging_config = LoggingConfig(workflow_spec)

    # Get keys of jobs to be executed
    jobs_keys = isnothing(jobs_keys) ?
        collect(keys(workflow_spec.jobs)) :
        jobs_keys isa Symbol ?
            [jobs_keys] :  # Symbol to list of Symbols
            jobs_keys

    # Sort jobs to be executed sorted by their dependencies
    jobs_and_deps::Vector{Tuple{Symbol, NTuple{N, Symbol} where N}} = []
    for job in jobs_keys
        deps = ()
        if hasproperty(workflow_spec.jobs[job], :needs)
            deps = workflow_spec.jobs[job][:needs]
            !(deps isa Union{String, Vector{String}, Symbol, Vector{Symbol}}) && throw(
                ErrorException("Job dependencies specified in parameter 'needs' must be " *
                "a Symbol / String or a list of Symbol / String. Got $(deps).")
            )
            if !(deps isa Vector)
                deps = [deps]
            end
            deps = Tuple(Symbol.(deps))

            any([!(d in jobs_keys) for d in deps]) && throw(ErrorException(
                "Dependencies for job '$(job)' must belong to selected jobs $(jobs_keys) " *
                "Got: $(deps)."
            ))

        end
        push!(jobs_and_deps, (job, deps))
    end
    sorted_jobs = get_sorted_jobs_based_on_dependencies(jobs_and_deps)

    # Run jobs with configured logging
    Logging.with_logger(get_formatted_logger(logging_config, workflow = workflow_name)) do
        @debug "Starting execution of workflow"
        duration = run_jobs(
            cfg,
            workflow_spec,
            Symbol.(sorted_jobs),
            logging_config = logging_config,
        )
        @debug "Completed execution of workflow '$workflow_name' in " *
               "$(round(duration, digits=3)) seconds"
        return duration
    end
end
run_workflow(
    cfg::ConfigObject,
    filename::AbstractString;
    jobs_keys::Union{Symbol,Vector{Symbol},Nothing} = nothing,
) = run_workflow(cfg, WorkflowSpec(filename), jobs_keys = jobs_keys)

run_workflow(
    filename::AbstractString;
    jobs_keys::Union{Symbol,Vector{Symbol},Nothing} = nothing,
    config_root::Union{AbstractString,Nothing} = nothing,
) = begin
    workflow_spec = WorkflowSpec(filename)

    !hasproperty(workflow_spec, :conf) && throw(ErrorException(
        "Workflow specification must have an entry 'conf' with a path " *
        "to the configuration file to load."
    ))
    # Load configuration from file
    config_filename = joinpath(dirname(filename), workflow_spec.conf)
    cfg = load_config(config_filename, config_root)

    return run_workflow(cfg, workflow_spec, jobs_keys=jobs_keys)
end
