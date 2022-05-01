@doc raw"""
    ConfigObject(nt::NamedTuple)
    ConfigObject(cfg::ConfigObject)

Abstraction to manage configuration values in a program.
Elements in the object being NamedTuple are converted to ConfigObject instances.

# Fields
- `_nt::NamedTuple`: stores the keys and values for the configuration

# Examples
```jldoctest
julia> raw = (;a=1, b=(;c=3, d=4))
(a = 1, b = (c = 3, d = 4))

julia> cfg = ConfigObject(raw)
ConfigObject((a = 1, b = ConfigObject((c = 3, d = 4))))

julia> cfg.b
ConfigObject((c = 3, d = 4))

julia> cfg.b.d
4

julia> length(cfg)
2

julia> keys(cfg), values(cfg)
((:a, :b), (1, ConfigObject((c = 3, d = 4))))

julia> merge(cfg, (;e=5, f=6))
ConfigObject((a = 1, b = ConfigObject((c = 3, d = 4)), e = 5, f = 6))

julia> cfg == ConfigObject(raw)
true

julia> collect(cfg)
(a = 1, b = (c = 3, d = 4))
```
"""
struct ConfigObject
    _nt::NamedTuple
    ConfigObject(x) = x
    ConfigObject(nt::NamedTuple) =
        :_nt in keys(nt) ?
            throw(KeyError(
                "Keys of a ConfigObject cannot have a '_nt' entry. Got $(keys(nt))")) :
            new((; (Symbol(k) => ConfigObject(v) for (k, v) in zip(keys(nt), nt))...))
    ConfigObject(cfg::ConfigObject) = cfg
end

# Methods to treat a ConfigObject just like a NamedTuple
Base.getproperty(cfg::ConfigObject, s::Symbol) = begin
    s == :_nt ? getfield(cfg, s) :
    hasproperty(cfg._nt, s) ? getfield(cfg._nt, s) :
    throw(ErrorException("ConfigObject has no value $(s)"))
end
Base.getindex(cfg::ConfigObject, s::Symbol) = getindex(cfg._nt, s)
Base.hasproperty(cfg::ConfigObject, k::Symbol) = hasproperty(cfg._nt, k)
Base.propertynames(cfg::ConfigObject) = keys(cfg)
Base.keys(cfg::ConfigObject) = keys(cfg._nt)
Base.values(cfg::ConfigObject) = values(cfg._nt)
Base.iterate(cfg::ConfigObject) = iterate(cfg._nt)
Base.iterate(cfg::ConfigObject, i) = iterate(cfg._nt, i)
Base.merge(cfg::ConfigObject, a::NamedTuple) = ConfigObject(merge(cfg._nt, a))
Base.merge(a::NamedTuple, cfg::ConfigObject) = ConfigObject(merge(a, cfg._nt))
Base.merge(cfg1::ConfigObject, cfg2::ConfigObject) = ConfigObject(merge(cfg1._nt, cfg2._nt))
Base.length(cfg::ConfigObject) = length(cfg._nt)
Base.:(==)(a::ConfigObject, b::ConfigObject) =
    length(a) == length(b) &&
    all(p1.first == p2.first && p1.second == p2.second
        for (p1, p2) in zip(
            sort(collect(pairs(a._nt)), by=x->x.first),
            sort(collect(pairs(b._nt)), by=x->x.first)))
Base.collect(cfg::ConfigObject) = (
    ; (Symbol(k) => (
        typeof(v) == ConfigObject ? collect(v) : v
    )
    for (k, v) in zip(keys(cfg), values(cfg)))...)
