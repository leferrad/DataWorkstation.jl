import TOML

@doc raw"""
    WorkflowSpec(nt::NamedTuple)
    WorkflowSpec(filename::String)

Abstraction to specify the properties of a Workflow to be executed.
The specification can be done either through a `NamedTuple` or a `TOML` file. It can be
used just like a `NamedTuple` to access to its properties.

# Fields
- `_spec::NamedTuple`: stores the keys and values for the specification.

# Examples
```jldoctest
julia> raw_nt = (;a=1, b=(;c=3, d=4))
(a = 1, b = (c = 3, d = 4))

julia> spec = WorkflowSpec(raw_nt)
WorkflowSpec((a = 1, b = (c = 3, d = 4)))

julia> spec.b
(c = 3, d = 4)

julia> spec.b.d
4

julia> length(spec)
2

julia> keys(spec), values(spec)
((:a, :b), (1, (c = 3, d = 4)))

julia> collect(spec)
(a = 1, b = (c = 3, d = 4))

julia> using TOML

julia> raw_dict = Dict("a" => 1, "b" => Dict("c" => 3, "d" => 4))

julia> filename = tempdir() * "/workflow.toml";

julia> open(filename, "w") do io
       TOML.print(io, raw_dict)
       end;

julia> spec == WorkflowSpec(filename)
true
```
"""
struct WorkflowSpec
    _spec::NamedTuple
    WorkflowSpec(nt::NamedTuple) = new(nt)
    WorkflowSpec(filename::String) = new(dict_to_namedtuple(TOML.parsefile(filename)))
end

# Methods to treat a WorkflowSpec a little bit like a NamedTuple
Base.getproperty(w::WorkflowSpec, s::Symbol) = begin
    s == :_spec ? getfield(w, s) :
    hasproperty(w._spec, s) ? getfield(w._spec, s) :
    throw(ErrorException("WorkflowSpec has no entry $(s). Check the corresponding file."))
end
Base.hasproperty(w::WorkflowSpec, k::Symbol) = hasproperty(w._spec, k)
Base.getindex(w::WorkflowSpec, s::Symbol) = getindex(w._spec, s)
Base.propertynames(w::WorkflowSpec) = keys(w)
Base.keys(w::WorkflowSpec) = keys(w._spec)
Base.values(w::WorkflowSpec) = values(w._spec)
Base.iterate(w::WorkflowSpec) = iterate(w._spec)
Base.iterate(w::WorkflowSpec, i) = iterate(w._spec, i)
Base.length(w::WorkflowSpec) = length(w._spec)
Base.:(==)(a::WorkflowSpec, b::WorkflowSpec) =
    length(a) == length(b) && all(
        p1.first == p2.first && p1.second == p2.second for (p1, p2) in zip(
            sort(collect(pairs(a._spec)), by = x -> x.first),
            sort(collect(pairs(b._spec)), by = x -> x.first),
        )
    )
Base.collect(w::WorkflowSpec) = (;
    (
        Symbol(k) => (typeof(v) == WorkflowSpec ? collect(v) : v) for
        (k, v) in zip(keys(w), values(w))
    )...,
)
