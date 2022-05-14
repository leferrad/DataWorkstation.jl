import BSON
import CSV
import JDF
import Serialization
using DataFrames: DataFrame

@doc raw"""
    register_default_bson_file_handler!(; extension = "bson", version = nothing) -> Nothing

Function to register methods for [`load_file()`](@ref) and [`save_file()`](@ref)
with a default implementation based on the [`BSON`](https://github.com/JuliaIO/BSON.jl)
library, to be compatible with file paths having an `extension` value and some `version`.
This internall calls [`register_file_handler!()`](@ref).

Useful to save objects like machine learning models or just
Julia objects to be retrieved in a Julia session, using a BSON format.

# Arguments
- `extension::AbstractString`: extension of a file path to support in the registered method
- `version::Union{AbstractString,Nothing}`: version of the registered methods

# Examples
```jldoctest
julia> extension = "bson";

julia> version = nothing;

julia> obj = (;a=1, b=2);

julia> filepath = joinpath(tempdir(), "file.$extension");

julia> register_default_bson_file_handler!(
            extension = extension;
            version = version,
        );

julia> save_file(filepath, obj, version=version);

julia> loaded_obj = load_file(filepath, version=version);

julia> loaded_obj == obj
true
```
"""
register_default_bson_file_handler!(; extension = "bson", version = nothing) =
    register_file_handler!(
        extension,
        version = version,
        load_file_function = path -> begin
            BSON.@load path obj
            return obj
        end,
        save_file_function = (path, obj) -> begin
            BSON.@save path obj
        end,
    )

@doc raw"""
    register_default_csv_file_handler!(; extension = "csv", version = nothing) -> Nothing

Function to register methods for [`load_file()`](@ref) and [`save_file()`](@ref)
with a default implementation based on the [`CSV`](https://csv.juliadata.org/stable/)
library, to be compatible with file paths having an `extension` value and some `version`.
This internall calls [`register_file_handler!()`](@ref).

Useful to save tabular data in plain-text format. Make sure the object is in a compatible
format before saving it (e.g. `Array`, `DataFrame`, `Dict`).

# Arguments
- `extension::AbstractString`: extension of a file path to support in the registered method
- `version::Union{AbstractString,Nothing}`: version of the registered methods

# Examples
```jldoctest
julia> using DataFrames

julia> extension = "csv";

julia> version = "v1";

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

julia> filepath = joinpath(tempdir(), "file.$extension");

julia> register_default_csv_file_handler!(
            extension = extension;
            version = version,
        );

julia> save_file(filepath, df, version=version);

julia> loaded_df = load_file(filepath, version=version);

julia> loaded_df == df
true
```
"""
register_default_csv_file_handler!(; extension = "csv", version = nothing) =
    register_file_handler!(
        extension,
        version = version,
        load_file_function = path -> CSV.read(path, DataFrame),
        save_file_function = (path, obj) -> CSV.write(path, obj),
    )

@doc raw"""
    register_default_jdf_file_handler!(; extension = "jdf", version = nothing) -> Nothing

Function to register methods for [`load_file()`](@ref) and [`save_file()`](@ref)
with a default implementation based on the [`JDF`](https://github.com/xiaodaigh/JDF.jl)
library, to be compatible with file paths having an `extension` value and some `version`.
This internall calls [`register_file_handler!()`](@ref).

Useful to save tabular data in binary format. Make sure the object is in `DataFrame` format.

# Arguments
- `extension::AbstractString`: extension of a file path to support in the registered method
- `version::Union{AbstractString,Nothing}`: version of the registered methods

# Examples
```jldoctest
julia> using DataFrames

julia> extension = "jdf";

julia> version = nothing;

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

julia> filepath = joinpath(tempdir(), "file.$extension");

julia> register_default_jdf_file_handler!(
            extension = extension;
            version = version,
        );

julia> save_file(filepath, df, version=version);

julia> loaded_df = load_file(filepath, version=version);

julia> loaded_df == df
true
```
"""
register_default_jdf_file_handler!(; extension = "jdf", version = nothing) =
    register_file_handler!(
        extension,
        version = version,
        load_file_function = path -> DataFrame(JDF.load(path)),
        save_file_function = (path, obj) -> JDF.save(path, obj),
    )

@doc raw"""
    register_default_serialization_file_handler!(
        ; extension = "slz", version = nothing) -> Nothing

Function to register methods for [`load_file()`](@ref) and [`save_file()`](@ref)
with a default implementation based on the
[`Serialization`](https://docs.julialang.org/en/v1/stdlib/Serialization/)
library, to be compatible with file paths having an `extension` value and some `version`.
This internall calls [`register_file_handler!()`](@ref).

Useful to save objects like machine learning models or just
Julia objects to be retrieved in a Julia session, by using a native Julia implementation.

# Arguments
- `extension::AbstractString`: extension of a file path to support in the registered method
- `version::Union{AbstractString,Nothing}`: version of the registered methods

# Examples
```jldoctest
julia> extension = "slz";

julia> version = nothing;

julia> obj = (;a=1, b=2);

julia> filepath = joinpath(tempdir(), "file.$extension");

julia> register_default_serialization_file_handler!(
            extension = extension;
            version = version,
        );

julia> save_file(filepath, obj, version=version);

julia> loaded_obj = load_file(filepath, version=version);

julia> loaded_obj == obj
true
```
"""
register_default_serialization_file_handler!(; extension = "slz", version = nothing) =
    register_file_handler!(
        extension,
        version = version,
        load_file_function = path -> Serialization.deserialize(path),
        save_file_function = (path, obj) -> Serialization.serialize(path, obj),
    )
