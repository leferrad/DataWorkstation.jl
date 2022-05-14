@doc raw"""
    FileHandler{E,V}
    FileHandler(extension::AbstractString, version::Union{AbstractString,Nothing} = nothing)

Abstraction to handle file operations. It is internally managed by [`load_file()`](@ref)
and [`save_file()`](@ref) methods, so it should not be necessary to instantiate it directly.

# Examples
```jldoctest
julia> fh = FileHandler("csv", "dataframe")
FileHandler{:csv, :dataframe}()

julia> FileHandler{:csv, :dataframe} == typeof(fh)
true

julia> FileHandler("csv")
FileHandler{:csv, :nothing}()
```
"""
struct FileHandler{E,V} end

FileHandler(extension::AbstractString, version::Union{AbstractString,Nothing} = nothing) =
    FileHandler{Symbol(extension),Symbol(version)}()

"""
Get a list of the available methods of a function `func` that have an argument of type `t`.
For example, `_methodswith(BigInt, iszero)` returns a list with `iszero(x::BigInt)`.

Method developed for internal usage, not intended to be exported.
"""
_methodswith(t, func) = filter(
    m -> hasproperty(m.sig, :body) ? t in m.sig.body.parameters : t in m.sig.parameters,
    Base.methods(func).ms,
)

@doc raw"""
    methods_load_file(
        extension::AbstractString,
        version::Union{AbstractString,Nothing} = nothing
    ) -> Vector{Method}

Get the available methods for [`load_file()`](@ref) that are compatible with the
arguments `extension` and `version`. This is useful to check if there are methods
already registered with [`register_file_handler!()`](@ref) that support the arguments.

# Arguments
- `extension::AbstractString`: extension of a file path to support in the registered method
- `version::Union{AbstractString,Nothing}`: version of the registered methods

# Returns
- `Vector{Method}`: available methods that are compatible with the given arguments

# Examples
```jldoctest
julia> using CSV, DataFrames

julia> length(methods_load_file("csv", nothing))
0

julia> register_file_handler!(
            "csv",
            load_file_function = path -> CSV.read(path, DataFrame),
            save_file_function = (path, obj) -> CSV.write(path, obj),
        );

julia> length(methods_load_file("csv", nothing))
1

julia> unregister_file_handler!("csv", version=nothing);

julia> length(methods_load_file("csv", nothing))
0
```
"""
methods_load_file(
    extension::AbstractString,
    version::Union{AbstractString,Nothing} = nothing,
) = begin
    fh = FileHandler(extension, version)
    return _methodswith(typeof(fh), load_file)
end

@doc raw"""
    methods_save_file(
        extension::AbstractString,
        version::Union{AbstractString,Nothing} = nothing
    ) -> Vector{Method}

Get the available methods for [`save_file()`](@ref) that are compatible with the
arguments `extension` and `version`. This is useful to check if there are methods
already registered with [`register_file_handler!()`](@ref) that support the arguments.

# Arguments
- `extension::AbstractString`: extension of a file path to support in the registered method
- `version::Union{AbstractString,Nothing}`: version of the registered methods

# Returns
- `Vector{Method}`: available methods that are compatible with the given arguments

# Examples
```jldoctest
julia> using CSV, DataFrames

julia> length(methods_save_file("csv", nothing))
0

julia> register_file_handler!(
            "csv",
            load_file_function = path -> CSV.read(path, DataFrame),
            save_file_function = (path, obj) -> CSV.write(path, obj),
        );

julia> length(methods_save_file("csv", nothing))
1

julia> unregister_file_handler!("csv", version=nothing);

julia> length(methods_save_file("csv", nothing))
0
```
"""
methods_save_file(
    extension::AbstractString,
    version::Union{AbstractString,Nothing} = nothing,
) = begin
    fh = FileHandler(extension, version)
    return _methodswith(typeof(fh), load_file)
end

@doc raw"""
    load_file(
        path::AbstractString,
        args...;
        version::Union{AbstractString,Nothing} = nothing,
        kwargs...,
    ) -> Any

Function to load the content of file in `path`, using a
method already registered with a call of [`register_file_handler!()`](@ref) with
`version` and the file extension given in `path`.

# Arguments
- `path::AbstractString`: path to the file to load, which should have an extension
    compatible with a `load_file()` method already registered
- `args...`: Arguments passed to the registered `load_file()` method

# Keywords
- `version::Union{AbstractString,Nothing}`: tag to identify the particular method to use
- `kwargs...`: Keyword arguments passed to the registered `load_file()` method

# Returns
- `Any`: object loaded from the file, and the type will depend on the method implemented

# Throws
- `ErrorException`: In case there is no `load_file()` method compatible with `version` and
    the extension given in `path`, or if some error occurs during the load operation.

# Examples
```jldoctest
julia> using CSV, DataFrames

julia> register_file_handler!(
            "csv",
            load_file_function = path -> CSV.read(path, DataFrame),
            save_file_function = (path, obj) -> CSV.write(path, obj),
        );

julia> df = DataFrame(Dict("a" => 1:5, "b" => 6:10))
5×2 DataFrame
 Row │ a      b
     │ Int64  Int64
─────┼──────────────
   1 │     1      6
   2 │     2      7
   3 │     3      8
   4 │     4      9
   5 │     5     10

julia> save_file("dataset.csv", df);

julia> isfile("dataset.csv")
true

julia> run(`head -2 dataset.csv`)
a,b
1,6
Process(`head -2 dataset.csv`, ProcessExited(0))

julia> load_file("dataset.csv")
5×2 DataFrame
 Row │ a      b
     │ Int64  Int64
─────┼──────────────
   1 │     1      6
   2 │     2      7
   3 │     3      8
   4 │     4      9
   5 │     5     10

julia> register_file_handler!(
            "csv",
            version = "pipe_delim",
            load_file_function = path -> CSV.read(path, DataFrame, delim="|"),
            save_file_function = (path, obj) -> CSV.write(path, obj, delim="|"),
        );

julia> save_file("dataset_pipe.csv", df, version="pipe_delim");

julia> run(`head -2 dataset_pipe.csv`)
a|b
1|6
Process(`head -2 dataset_pipe.csv`, ProcessExited(0))

julia> load_file("dataset_pipe.csv", version="pipe_delim")
5×2 DataFrame
 Row │ a      b
     │ Int64  Int64
─────┼──────────────
   1 │     1      6
   2 │     2      7
   3 │     3      8
   4 │     4      9
   5 │     5     10

julia> register_file_handler!(
            "csv",
            version = "verbose",
            load_file_function = (path; verbose=false) -> begin
                verbose ? println("Loading dataset from $path...") : nothing
                CSV.read(path, DataFrame)
            end,
            save_file_function = (path, obj; verbose=false) -> begin
                verbose ? println("Saving dataset to $path...") : nothing
                CSV.write(path, obj)
            end
        );

julia> save_file("dataset.csv", df, version="verbose", verbose=true);
Saving dataset to dataset.csv...

julia> load_file("dataset.csv", , version="verbose", verbose=true)
Loading dataset from dataset.csv...
5×2 DataFrame
 Row │ a      b
     │ Int64  Int64
─────┼──────────────
   1 │     1      6
   2 │     2      7
   3 │     3      8
   4 │     4      9
   5 │     5     10

julia> length(methods_load_file("csv", nothing))
1

julia> unregister_file_handler!("csv", version=nothing);

julia> length(methods_load_file("csv", nothing))
0
```
"""
load_file(
    path::AbstractString,
    args...;
    version::Union{AbstractString,Nothing} = nothing,
    kwargs...,
) = begin
    _, extension = splitext(path)
    extension == "" && throw(ArgumentError("""
        Argument 'path' must be a valid file path with a extension (e.g. "path/to/file.csv")
        """))
    fh = FileHandler(replace(extension, "." => ""), version)
    t = typeof(fh)
    length(_methodswith(t, load_file)) > 0 ? load_file(fh, path, args...; kwargs...) :
    throw(ErrorException("""
        No method for load_file() compatible with path='$path' and version=$version.
        Available methods: $(Base.methods(load_file))
        """))
end

@doc raw"""
    save_file(
        path::AbstractString,
        obj::Any,
        args...;
        version::Union{AbstractString,Nothing} = nothing,
        kwargs...,
    ) -> Nothing

Function to save the content of `obj` as a file in `path`, using a
method already registered with a call of [`register_file_handler!()`](@ref) with
`version` and the file extension given in `path`.

For examples of usage, look at the documentation of [`load_file()`](@ref).

# Arguments
- `path::AbstractString`: path to the file to save, which should have an extension
    compatible with a `save_file()` method already registered
- `obj::Any`: object to be saved as a file in the given `path`
- `args...`: Arguments passed to the registered `save_file()` method

# Keywords
- `version::Union{AbstractString,Nothing}`: tag to identify the particular method to use
- `kwargs...`: Keyword arguments passed to the registered `save_file()` method

# Throws
- `ErrorException`: In case there is no `save_file()` method compatible with `version` and
    the extension given in `path`, or if some error occurs during the save operation.
"""
save_file(
    path::AbstractString,
    obj::Any,
    args...;
    version::Union{AbstractString,Nothing} = nothing,
    kwargs...,
) = begin
    _, extension = splitext(path)
    extension == "" && throw(ArgumentError("""
        Argument 'path' must be a valid file path with a extension (e.g. "path/to/file.csv")
        """))
    fh = FileHandler(replace(extension, "." => ""), version)
    t = typeof(fh)
    length(_methodswith(t, save_file)) > 0 ?
    save_file(fh, path, obj, args...; kwargs...) :
    throw(ErrorException("""
        No method for save_file() compatible with path='$path' and version=$version.
        Available methods: $(Base.methods(save_file))
        """))
    return
end

@doc raw"""
    register_file_handler!(
        extension::AbstractString;
        version::Union{AbstractString,Nothing} = nothing,
        load_file_function::Function,
        save_file_function::Function,
    ) -> Nothing

Function to register methods for [`load_file()`](@ref) and [`save_file()`](@ref)
that are compatible with file paths having an `extension` value and some `version`.

This way allows to use a single function to save any object with a proper method
just based on the extension of the given filename, which is useful to
avoid hard-coded file operations in your program.

You can handle multiple methods for a given extension, using the argument `version` to
specify which method to use for a given file.

For examples of usage, look at the documentation of [`load_file()`](@ref).

# Arguments
- `extension::AbstractString`: extension to extract from a file path to recognize that the
    methods registered should be used

# Keywords
- `version::Union{AbstractString,Nothing}`: tag to identify the type of methods to register
- `load_file_function::Function`: function to use in the call of [`load_file()`](@ref)
- `save_file_function::Function`: function to use in the call of [`save_file()`](@ref)

# Throws
- `ErrorException`: In case there are already `load_file()` and/or `save_file()` methods
    compatible with `version` and the given `extension`
"""
function register_file_handler!(
    extension::AbstractString;
    version::Union{AbstractString,Nothing} = nothing,
    load_file_function::Function,
    save_file_function::Function,
)
    fh = FileHandler(extension, version)
    t = typeof(fh)
    if length(_methodswith(t, load_file)) > 0 || length(_methodswith(t, save_file)) > 0
        throw(
            ErrorException(
                "Methods load_file() and/or save_file() " *
                "are already registered for extension=$extension and version=$version",
            ),
        )
    end
    eval(
        quote
            load_file(::$t, path::AbstractString, args...; kwargs...) =
                $load_file_function(path, args...; kwargs...)
            save_file(::$t, path::AbstractString, obj, args...; kwargs...) =
                $save_file_function(path, obj, args...; kwargs...)
        end,
    )
    return
end

@doc raw"""
    unregister_file_handler!(
        extension::String;
        version::Union{AbstractString,Nothing} = nothing
    ) -> Nothing

Function to unregister available methods for [`load_file()`](@ref) and [`save_file()`](@ref)
that were already registered with a call of [`register_file_handler!()`](@ref)
having an `extension` value and some `version`.

For examples of usage, look at the documentation of [`load_file()`](@ref).

# Arguments
- `extension::AbstractString`: extension to extract from a file path to recognize the
    methods to unregister

# Keywords
- `version::Union{AbstractString,Nothing}`: tag for the type of methods to unregister

# Throws
- `ErrorException`: In case there are no `load_file()` or `save_file()` methods
    compatible with `version` and the given `extension` to unregister
"""
function unregister_file_handler!(
    extension::String;
    version::Union{AbstractString,Nothing} = nothing,
)
    fh = FileHandler(extension, version)
    t = typeof(fh)
    load_methods = _methodswith(t, load_file)
    length(load_methods) != 1 && throw(
        ErrorException(
            "No existing load_file() method for extension=$extension and version=$version",
        ),
    )
    save_methods = _methodswith(t, save_file)
    length(save_methods) != 1 && throw(
        ErrorException(
            "No existing save_file() method for extension=$extension and version=$version",
        ),
    )
    Base.delete_method(load_methods[end])
    Base.delete_method(save_methods[end])
    return
end
