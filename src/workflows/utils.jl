@doc raw"""
    dict_to_namedtuple(d::Dict) -> NamedTuple

Utility function to convert a `Dict` object into a `NamedTuple`.

Method developed for internal usage, not intended to be exported.

# Arguments
- `d::Dict`: Object to convert. Notice that the function is called recursively
    so it could be also a Dict component.

# Returns
- `NamedTuple`: Converted object.

# Examples
```jldoctest
julia> DataWorkstation.Workflows.dict_to_namedtuple(Dict(:a => 1, "b" => Dict("c" => 2)))
(a = 1, b = (c = 2,))
```
"""
dict_to_namedtuple(d::Dict) =
    (; (Symbol(p.first) => dict_to_namedtuple(p.second) for p in d)...)
dict_to_namedtuple(d) = d

@doc raw"""
    namedtuple_to_dict(nt::NamedTuple) -> Dict

Utility function to convert a `NamedTuple` object into a `Dict`.

Method developed for internal usage, not intended to be exported.

# Arguments
- `nt::NamedTuple`: Object to convert. Notice that the function is called recursively
    so it could be also a NamedTuple component.

# Returns
- `Dict`: Converted object.

# Examples
```jldoctest
julia> DataWorkstation.Workflows.namedtuple_to_dict((;a=1, b=(; c=2, d=(; e=3))))
Dict{Symbol, Any} with 2 entries:
  :a => 1
  :b => Dict{Symbol, Any}(:d=>Dict(:e=>3), :c=>2)
```
"""
namedtuple_to_dict(nt::NamedTuple) =
    Dict(p.first => namedtuple_to_dict(p.second) for p in pairs(nt))
namedtuple_to_dict(nt) = nt

@doc raw"""
    is_valid_step_function(func::Function) -> Bool

Returns `true` if the function is considered a valid step function for a Workflow, so
it can be registered through a call of [`register_step_function()`](@ref).

The function must have only one argument of the type [`ConfigObject`](@ref) or `Any`.
This object should contain all the necessary configuration to allow the step work correctly.

# Arguments
- `func::Function`: Function to be validated.

# Returns
- `Bool`: Returns `true` if the function is considered a valid step function.

# Examples
```jldoctest
julia> is_valid_step_function((x1, x2) -> x1 + x2)
false

julia> is_valid_step_function(a::Int -> a + 1)
false

julia> is_valid_step_function(cfg::ConfigObject -> cfg.x)
true

julia> is_valid_step_function(cfg -> cfg.x)
true
```
"""
function is_valid_step_function(func::Function)
    for m in collect(methods(func))
        if m.sig == Tuple{typeof(func),ConfigObject} || m.sig == Tuple{typeof(func),Any}
            return true
        end
    end
    return false
end

@doc raw"""
    check_step_function_existence(step_type::Symbol) -> Bool

Returns `true` if there is a step function that was registered with
[`register_step_function()`](@ref) having `step_type` as identifier. This is
useful to prevent overwriting step functions with the same identifier.

Method developed for internal usage, not intended to be exported.

# Arguments
- `step_type::Symbol`: Identifier of step function to be checked.

# Returns
- `Bool`: Returns `true` if a step function identified with `step_type` already exists.

# Examples
```jldoctest
julia> DataWorkstation.Workflows.check_step_function_existence(:StepFunctionA)
false

julia> register_step_function(:StepFunctionA, x -> x.a)
run_step_function (generic function with 2 methods)

julia> DataWorkstation.Workflows.check_step_function_existence(:StepFunctionA)
true
```
"""
check_step_function_existence(step_type::Symbol) = begin
    t = Type{WorkflowStep{step_type}}
    return any(
        m ->
            hasproperty(m.sig, :body) ? t in m.sig.body.parameters : t in m.sig.parameters,
        Base.methods(run_step_function).ms,
    )
end

@doc raw"""
    get_sorted_jobs_based_on_dependencies(jobs_and_deps::Vector{Tuple{T, V}}
    ) where V <: Union{Tuple{T}, NTuple{N, T} where N} where T -> Vector{T}

Get a sorted list of generic `T` objects representing the correct order of dependencies
in a sequence of jobs defined for a Workflow. This is very useful
to ensure a correct execution of a Workflow.

The implementation was maded based on this solution: https://stackoverflow.com/a/11564323.

Method developed for internal usage, not intended to be exported.

# Arguments
- `jobs_and_deps::Vector{Tuple{T, V}
where V <: Union{Tuple{T}, NTuple{N, T} where N} where T`: Dependencies to process

# Returns
- `Vector{T}`: Order of dependencies to follow when executing the workflow associated.

# Examples
```julia-repl
julia> jobs_and_deps = [(:job1, ()), (:job2, (:job1,)),
                        (:job3, (:job4,)), (:job4, (:job1, :job2))]
4-element Vector{Tuple{Symbol, Tuple{Vararg{Symbol, N} where N}}}:
 (:job1, ())
 (:job2, (:job1,))
 (:job3, (:job4,))
 (:job4, (:job1, :job2))

julia> DataWorkstation.Workflows.get_sorted_jobs_based_on_dependencies(jobs_and_deps)
4-element Vector{Symbol}:
 :job1
 :job2
 :job4
 :job3
```
"""
function get_sorted_jobs_based_on_dependencies(
    jobs_and_deps::Vector{Tuple{T, V}}
) where V <: Union{Tuple{T}, NTuple{N, T} where N} where T
    pending = [(job, Set(deps)) for (job, deps) in jobs_and_deps]  # To be modified in-place
    emitted = []
    result::Vector{T} = []
    while !isempty(pending)
        next_pending, next_emitted = [], []
        for (name, deps) in pending
            setdiff!(deps, emitted)  # Remove dependencies already emitted
            if !isempty(deps)
                push!(next_pending, (name, deps))  # Add pending dependency for next pass
            else
                push!(result, name)  # No more dependencies, then emit
                push!(emitted, name)  # Just to preserve original ordering
                push!(next_emitted, name)  # Remember what was emitted for next pass
            end
        end
        # Ensure correct dependencies declaration
        isempty(next_emitted) && throw(
            ErrorException(
                "Cyclic or missing dependency found in jobs declaration: $(jobs_and_deps)",
            ),
        )
        pending = next_pending
        emitted = next_emitted
    end
    return result
end
