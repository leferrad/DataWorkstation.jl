var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = DataWorkstation","category":"page"},{"location":"#DataWorkstation","page":"Home","title":"DataWorkstation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for DataWorkstation.","category":"page"},{"location":"#API-Reference","page":"Home","title":"API Reference","text":"","category":"section"},{"location":"#Index","page":"Home","title":"Index","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [DataWorkstation]\nPrivate = false\nOrder = [:type, :function]","category":"page"},{"location":"#Config-module","page":"Home","title":"Config module","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"DataWorkstation.Config.ConfigObject\nDataWorkstation.Config.load_config\nDataWorkstation.Config.parse_config\nDataWorkstation.Config.update_config","category":"page"},{"location":"#DataWorkstation.Config.ConfigObject","page":"Home","title":"DataWorkstation.Config.ConfigObject","text":"ConfigObject(nt::NamedTuple)\nConfigObject(cfg::ConfigObject)\n\nAbstraction to manage configuration values in a program. Elements in the object being NamedTuple are converted to ConfigObject instances.\n\nFields\n\n_nt::NamedTuple: stores the keys and values for the configuration\n\nExamples\n\njulia> raw = (;a=1, b=(;c=3, d=4))\n(a = 1, b = (c = 3, d = 4))\n\njulia> cfg = ConfigObject(raw)\nConfigObject((a = 1, b = ConfigObject((c = 3, d = 4))))\n\njulia> cfg.b\nConfigObject((c = 3, d = 4))\n\njulia> cfg.b.d\n4\n\njulia> length(cfg)\n2\n\njulia> keys(cfg), values(cfg)\n((:a, :b), (1, ConfigObject((c = 3, d = 4))))\n\njulia> merge(cfg, ConfigObject((;e=5, f=6)))\nConfigObject((a = 1, b = ConfigObject((c = 3, d = 4)), e = 5, f = 6))\n\njulia> cfg == ConfigObject(raw)\ntrue\n\njulia> collect(cfg)\n(a = 1, b = (c = 3, d = 4))\n\n\n\n\n\n","category":"type"},{"location":"#DataWorkstation.Config.load_config","page":"Home","title":"DataWorkstation.Config.load_config","text":"load_config(filename, root) -> ConfigObject\n\nLoad a file as a ConfigObject instance.\n\nArguments\n\nfilename::AbstractString: the path to load to get the configuration content\nroot::AbstractString: root for the path to load (optional)\n\nReturns\n\nConfigObject: having the content loaded from the file\n\nExamples\n\njulia> config_dict = Dict(\"a\" => 1, \"b\" => Dict(\"c\" => 2, \"d\" => 3))\nDict{String, Any} with 2 entries:\n  \"b\" => Dict(\"c\"=>2, \"d\"=>3)\n  \"a\" => 1\n\njulia> using TOML\n\njulia> filename = tempdir() * \"/cfg.toml\"\n\"/tmp/cfg.toml\"\n\njulia> open(filename, \"w\") do io\n       TOML.print(io, config_dict)\n       end;\n\njulia> load_config(filename)\nConfigObject((b = ConfigObject((c = 2, d = 3)), a = 1))\n\n\n\n\n\n","category":"function"},{"location":"#DataWorkstation.Config.parse_config","page":"Home","title":"DataWorkstation.Config.parse_config","text":"parse_config(d::Dict, root::AbstractString = \"\") -> ConfigObject\nparse_config(s::AbstractString, root) -> Union{ConfigObject, String}\n\nParse an input to build a ConfigObject instance. If the input is a Dict, the content will be converted into entries for a ConfigObject. If some entry contains a string of the kind \"filename.toml\", it is taken as a file to load as a ConfigObject.\n\nArguments\n\nd::Dict: the dict to convert to a ConfigObject instance\ns::AbstractString: when a value is a string with a format like \"filename.toml\",   the file is loaded from that path as a ConfigObject\nroot::AbstractString=\"\": in case of loading a file,   this is the root for the path to load (optional)\n\nReturns\n\nConfigObject: having the content parsed from the input\n\nExamples\n\njulia> config_dict = Dict(\"a\" => 1, \"b\" => Dict(\"c\" => 2, \"d\" => 3))\nDict{String, Any} with 2 entries:\n  \"b\" => Dict(\"c\"=>2, \"d\"=>3)\n  \"a\" => 1\n\njulia> parse_config(config_dict)\nConfigObject((b = ConfigObject((c = 2, d = 3)), a = 1))\n\njulia> using TOML\n\njulia> filename = tempdir() * \"/cfg.toml\"\n\"/tmp/cfg.toml\"\n\njulia> open(filename, \"w\") do io\n       TOML.print(io, config_dict)\n       end;\n\njulia> parse_config(Dict(\"cfg\" => \"\\$($(filename))\"))\nConfigObject((cfg = ConfigObject((b = ConfigObject((c = 2, d = 3)), a = 1)),))\n\n\n\n\n\n","category":"function"},{"location":"#DataWorkstation.Config.update_config","page":"Home","title":"DataWorkstation.Config.update_config","text":"update_config(cfg::ConfigObject, entries::NamedTuple) -> ConfigObject\n\nGet a new ConfigObject by updating the content with new entries\n\nArguments\n\ncfg::ConfigObject: configuration instance to updated\nentries::NamedTuple: new entries to put into the configuration instance\n\nReturns\n\nConfigObject: having updated entries\n\nExamples\n\njulia> raw = (;a=1, b=(;c=3, d=4))\n(a = 1, b = (c = 3, d = 4))\n\njulia> cfg = ConfigObject(raw)\nConfigObject((a = 1, b = ConfigObject((c = 3, d = 4))))\n\njulia> update_config(cfg, (;e=5, f=6))\nConfigObject((a = 1, b = ConfigObject((c = 3, d = 4)), e = 5, f = 6))\n\n\n\n\n\n","category":"function"},{"location":"#IO-module","page":"Home","title":"IO module","text":"","category":"section"},{"location":"#File-operations","page":"Home","title":"File operations","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"DataWorkstation.IO.FileHandler\nDataWorkstation.IO.load_file\nDataWorkstation.IO.save_file\nDataWorkstation.IO.methods_load_file\nDataWorkstation.IO.methods_save_file\nDataWorkstation.IO.register_file_handler!\nDataWorkstation.IO.unregister_file_handler!","category":"page"},{"location":"#DataWorkstation.IO.FileHandler","page":"Home","title":"DataWorkstation.IO.FileHandler","text":"FileHandler{E,V}\nFileHandler(extension::AbstractString, version::Union{AbstractString,Nothing} = nothing)\n\nAbstraction to handle file operations. It is internally managed by load_file() and save_file() methods, so it should not be necessary to instantiate it directly.\n\nExamples\n\njulia> fh = FileHandler(\"csv\", \"dataframe\")\nFileHandler{:csv, :dataframe}()\n\njulia> FileHandler{:csv, :dataframe} == typeof(fh)\ntrue\n\njulia> FileHandler(\"csv\")\nFileHandler{:csv, :nothing}()\n\n\n\n\n\n","category":"type"},{"location":"#DataWorkstation.IO.load_file","page":"Home","title":"DataWorkstation.IO.load_file","text":"load_file(\n    path::AbstractString,\n    args...;\n    version::Union{AbstractString,Nothing} = nothing,\n    kwargs...,\n) -> Any\n\nFunction to load the content of file in path, using a method already registered with a call of register_file_handler!() with version and the file extension given in path.\n\nArguments\n\npath::AbstractString: path to the file to load, which should have an extension   compatible with a load_file() method already registered\nargs...: Arguments passed to the registered load_file() method\n\nKeywords\n\nversion::Union{AbstractString,Nothing}: tag to identify the particular method to use\nkwargs...: Keyword arguments passed to the registered load_file() method\n\nReturns\n\nAny: object loaded from the file, and the type will depend on the method implemented\n\nThrows\n\nErrorException: In case there is no load_file() method compatible with version and   the extension given in path, or if some error occurs during the load operation.\n\nExamples\n\njulia> using CSV, DataFrames\n\njulia> register_file_handler!(\n            \"csv\",\n            load_file_function = path -> CSV.read(path, DataFrame),\n            save_file_function = (path, obj) -> CSV.write(path, obj),\n        );\n\njulia> df = DataFrame(Dict(\"a\" => 1:5, \"b\" => 6:10))\n5×2 DataFrame\n Row │ a      b\n     │ Int64  Int64\n─────┼──────────────\n   1 │     1      6\n   2 │     2      7\n   3 │     3      8\n   4 │     4      9\n   5 │     5     10\n\njulia> save_file(\"dataset.csv\", df);\n\njulia> isfile(\"dataset.csv\")\ntrue\n\njulia> run(`head -2 dataset.csv`)\na,b\n1,6\nProcess(`head -2 dataset.csv`, ProcessExited(0))\n\njulia> load_file(\"dataset.csv\")\n5×2 DataFrame\n Row │ a      b\n     │ Int64  Int64\n─────┼──────────────\n   1 │     1      6\n   2 │     2      7\n   3 │     3      8\n   4 │     4      9\n   5 │     5     10\n\njulia> register_file_handler!(\n            \"csv\",\n            version = \"pipe_delim\",\n            load_file_function = path -> CSV.read(path, DataFrame, delim=\"|\"),\n            save_file_function = (path, obj) -> CSV.write(path, obj, delim=\"|\"),\n        );\n\njulia> save_file(\"dataset_pipe.csv\", df, version=\"pipe_delim\");\n\njulia> run(`head -2 dataset_pipe.csv`)\na|b\n1|6\nProcess(`head -2 dataset_pipe.csv`, ProcessExited(0))\n\njulia> load_file(\"dataset_pipe.csv\", version=\"pipe_delim\")\n5×2 DataFrame\n Row │ a      b\n     │ Int64  Int64\n─────┼──────────────\n   1 │     1      6\n   2 │     2      7\n   3 │     3      8\n   4 │     4      9\n   5 │     5     10\n\njulia> register_file_handler!(\n            \"csv\",\n            version = \"verbose\",\n            load_file_function = (path; verbose=false) -> begin\n                verbose ? println(\"Loading dataset from $path...\") : nothing\n                CSV.read(path, DataFrame)\n            end,\n            save_file_function = (path, obj; verbose=false) -> begin\n                verbose ? println(\"Saving dataset to $path...\") : nothing\n                CSV.write(path, obj)\n            end\n        );\n\njulia> save_file(\"dataset.csv\", df, version=\"verbose\", verbose=true);\nSaving dataset to dataset.csv...\n\njulia> load_file(\"dataset.csv\", version=\"verbose\", verbose=true)\nLoading dataset from dataset.csv...\n5×2 DataFrame\n Row │ a      b\n     │ Int64  Int64\n─────┼──────────────\n   1 │     1      6\n   2 │     2      7\n   3 │     3      8\n   4 │     4      9\n   5 │     5     10\n\njulia> length(methods_load_file(\"csv\", nothing))\n1\n\njulia> unregister_file_handler!(\"csv\", version=nothing);\n\njulia> length(methods_load_file(\"csv\", nothing))\n0\n\n\n\n\n\n","category":"function"},{"location":"#DataWorkstation.IO.save_file","page":"Home","title":"DataWorkstation.IO.save_file","text":"save_file(\n    path::AbstractString,\n    obj::Any,\n    args...;\n    version::Union{AbstractString,Nothing} = nothing,\n    kwargs...,\n) -> Nothing\n\nFunction to save the content of obj as a file in path, using a method already registered with a call of register_file_handler!() with version and the file extension given in path.\n\nFor examples of usage, look at the documentation of load_file().\n\nArguments\n\npath::AbstractString: path to the file to save, which should have an extension   compatible with a save_file() method already registered\nobj::Any: object to be saved as a file in the given path\nargs...: Arguments passed to the registered save_file() method\n\nKeywords\n\nversion::Union{AbstractString,Nothing}: tag to identify the particular method to use\nkwargs...: Keyword arguments passed to the registered save_file() method\n\nThrows\n\nErrorException: In case there is no save_file() method compatible with version and   the extension given in path, or if some error occurs during the save operation.\n\n\n\n\n\n","category":"function"},{"location":"#DataWorkstation.IO.methods_load_file","page":"Home","title":"DataWorkstation.IO.methods_load_file","text":"methods_load_file(\n    extension::AbstractString,\n    version::Union{AbstractString,Nothing} = nothing\n) -> Vector{Method}\n\nGet the available methods for load_file() that are compatible with the arguments extension and version. This is useful to check if there are methods already registered with register_file_handler!() that support the arguments.\n\nArguments\n\nextension::AbstractString: extension of a file path to support in the registered method\nversion::Union{AbstractString,Nothing}: version of the registered methods\n\nReturns\n\nVector{Method}: available methods that are compatible with the given arguments\n\nExamples\n\njulia> using CSV, DataFrames\n\njulia> length(methods_load_file(\"csv\", nothing))\n0\n\njulia> register_file_handler!(\n            \"csv\",\n            load_file_function = path -> CSV.read(path, DataFrame),\n            save_file_function = (path, obj) -> CSV.write(path, obj),\n        );\n\njulia> length(methods_load_file(\"csv\", nothing))\n1\n\njulia> unregister_file_handler!(\"csv\", version=nothing);\n\njulia> length(methods_load_file(\"csv\", nothing))\n0\n\n\n\n\n\n","category":"function"},{"location":"#DataWorkstation.IO.methods_save_file","page":"Home","title":"DataWorkstation.IO.methods_save_file","text":"methods_save_file(\n    extension::AbstractString,\n    version::Union{AbstractString,Nothing} = nothing\n) -> Vector{Method}\n\nGet the available methods for save_file() that are compatible with the arguments extension and version. This is useful to check if there are methods already registered with register_file_handler!() that support the arguments.\n\nArguments\n\nextension::AbstractString: extension of a file path to support in the registered method\nversion::Union{AbstractString,Nothing}: version of the registered methods\n\nReturns\n\nVector{Method}: available methods that are compatible with the given arguments\n\nExamples\n\njulia> using CSV, DataFrames\n\njulia> length(methods_save_file(\"csv\", nothing))\n0\n\njulia> register_file_handler!(\n            \"csv\",\n            load_file_function = path -> CSV.read(path, DataFrame),\n            save_file_function = (path, obj) -> CSV.write(path, obj),\n        );\n\njulia> length(methods_save_file(\"csv\", nothing))\n1\n\njulia> unregister_file_handler!(\"csv\", version=nothing);\n\njulia> length(methods_save_file(\"csv\", nothing))\n0\n\n\n\n\n\n","category":"function"},{"location":"#DataWorkstation.IO.register_file_handler!","page":"Home","title":"DataWorkstation.IO.register_file_handler!","text":"register_file_handler!(\n    extension::AbstractString;\n    version::Union{AbstractString,Nothing} = nothing,\n    load_file_function::Function,\n    save_file_function::Function,\n) -> Nothing\n\nFunction to register methods for load_file() and save_file() that are compatible with file paths having an extension value and some version.\n\nThis way allows to use a single function to save any object with a proper method just based on the extension of the given filename, which is useful to avoid hard-coded file operations in your program.\n\nYou can handle multiple methods for a given extension, using the argument version to specify which method to use for a given file.\n\nFor examples of usage, look at the documentation of load_file().\n\nArguments\n\nextension::AbstractString: extension to extract from a file path to recognize that the   methods registered should be used\n\nKeywords\n\nversion::Union{AbstractString,Nothing}: tag to identify the type of methods to register\nload_file_function::Function: function to use in the call of load_file()\nsave_file_function::Function: function to use in the call of save_file()\n\nThrows\n\nErrorException: In case there are already load_file() and/or save_file() methods   compatible with version and the given extension\n\n\n\n\n\n","category":"function"},{"location":"#DataWorkstation.IO.unregister_file_handler!","page":"Home","title":"DataWorkstation.IO.unregister_file_handler!","text":"unregister_file_handler!(\n    extension::String;\n    version::Union{AbstractString,Nothing} = nothing\n) -> Nothing\n\nFunction to unregister available methods for load_file() and save_file() that were already registered with a call of register_file_handler!() having an extension value and some version.\n\nFor examples of usage, look at the documentation of load_file().\n\nArguments\n\nextension::AbstractString: extension to extract from a file path to recognize the   methods to unregister\n\nKeywords\n\nversion::Union{AbstractString,Nothing}: tag for the type of methods to unregister\n\nThrows\n\nErrorException: In case there are no load_file() or save_file() methods   compatible with version and the given extension to unregister\n\n\n\n\n\n","category":"function"},{"location":"#Util-file-handlers","page":"Home","title":"Util file handlers","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"DataWorkstation.IO.register_default_bson_file_handler!\nDataWorkstation.IO.register_default_csv_file_handler!\nDataWorkstation.IO.register_default_jdf_file_handler!\nDataWorkstation.IO.register_default_serialization_file_handler!","category":"page"},{"location":"#DataWorkstation.IO.register_default_bson_file_handler!","page":"Home","title":"DataWorkstation.IO.register_default_bson_file_handler!","text":"register_default_bson_file_handler!(; extension = \"bson\", version = nothing) -> Nothing\n\nFunction to register methods for load_file() and save_file() with a default implementation based on the BSON library, to be compatible with file paths having an extension value and some version. This internall calls register_file_handler!().\n\nUseful to save objects like machine learning models or just Julia objects to be retrieved in a Julia session, using a BSON format.\n\nArguments\n\nextension::AbstractString: extension of a file path to support in the registered method\nversion::Union{AbstractString,Nothing}: version of the registered methods\n\nExamples\n\njulia> extension = \"bson\";\n\njulia> version = nothing;\n\njulia> obj = (;a=1, b=2);\n\njulia> filepath = joinpath(tempdir(), \"file.$extension\");\n\njulia> register_default_bson_file_handler!(\n            extension = extension;\n            version = version,\n        );\n\njulia> save_file(filepath, obj, version=version);\n\njulia> loaded_obj = load_file(filepath, version=version);\n\njulia> loaded_obj == obj\ntrue\n\n\n\n\n\n","category":"function"},{"location":"#DataWorkstation.IO.register_default_csv_file_handler!","page":"Home","title":"DataWorkstation.IO.register_default_csv_file_handler!","text":"register_default_csv_file_handler!(; extension = \"csv\", version = nothing) -> Nothing\n\nFunction to register methods for load_file() and save_file() with a default implementation based on the CSV library, to be compatible with file paths having an extension value and some version. This internall calls register_file_handler!().\n\nUseful to save tabular data in plain-text format. Make sure the object is in a compatible format before saving it (e.g. Array, DataFrame, Dict).\n\nArguments\n\nextension::AbstractString: extension of a file path to support in the registered method\nversion::Union{AbstractString,Nothing}: version of the registered methods\n\nExamples\n\njulia> using DataFrames\n\njulia> extension = \"csv\";\n\njulia> version = \"v1\";\n\njulia> df = DataFrame(Dict(\"a\" => 1:5, \"b\" => 6:10))\n5×2 DataFrame\n Row │ a      b\n     │ Int64  Int64\n─────┼──────────────\n   1 │     1      6\n   2 │     2      7\n   3 │     3      8\n   4 │     4      9\n   5 │     5     10\n\njulia> filepath = joinpath(tempdir(), \"file.$extension\");\n\njulia> register_default_csv_file_handler!(\n            extension = extension;\n            version = version,\n        );\n\njulia> save_file(filepath, df, version=version);\n\njulia> loaded_df = load_file(filepath, version=version);\n\njulia> loaded_df == df\ntrue\n\n\n\n\n\n","category":"function"},{"location":"#DataWorkstation.IO.register_default_jdf_file_handler!","page":"Home","title":"DataWorkstation.IO.register_default_jdf_file_handler!","text":"register_default_jdf_file_handler!(; extension = \"jdf\", version = nothing) -> Nothing\n\nFunction to register methods for load_file() and save_file() with a default implementation based on the JDF library, to be compatible with file paths having an extension value and some version. This internall calls register_file_handler!().\n\nUseful to save tabular data in binary format. Make sure the object is in DataFrame format.\n\nArguments\n\nextension::AbstractString: extension of a file path to support in the registered method\nversion::Union{AbstractString,Nothing}: version of the registered methods\n\nExamples\n\njulia> using DataFrames\n\njulia> extension = \"jdf\";\n\njulia> version = nothing;\n\njulia> df = DataFrame(Dict(\"a\" => 1:5, \"b\" => 6:10))\n5×2 DataFrame\n Row │ a      b\n     │ Int64  Int64\n─────┼──────────────\n   1 │     1      6\n   2 │     2      7\n   3 │     3      8\n   4 │     4      9\n   5 │     5     10\n\njulia> filepath = joinpath(tempdir(), \"file.$extension\");\n\njulia> register_default_jdf_file_handler!(\n            extension = extension;\n            version = version,\n        );\n\njulia> save_file(filepath, df, version=version);\n\njulia> loaded_df = load_file(filepath, version=version);\n\njulia> loaded_df == df\ntrue\n\n\n\n\n\n","category":"function"},{"location":"#DataWorkstation.IO.register_default_serialization_file_handler!","page":"Home","title":"DataWorkstation.IO.register_default_serialization_file_handler!","text":"register_default_serialization_file_handler!(\n    ; extension = \"slz\", version = nothing) -> Nothing\n\nFunction to register methods for load_file() and save_file() with a default implementation based on the Serialization library, to be compatible with file paths having an extension value and some version. This internall calls register_file_handler!().\n\nUseful to save objects like machine learning models or just Julia objects to be retrieved in a Julia session, by using a native Julia implementation.\n\nArguments\n\nextension::AbstractString: extension of a file path to support in the registered method\nversion::Union{AbstractString,Nothing}: version of the registered methods\n\nExamples\n\njulia> extension = \"slz\";\n\njulia> version = nothing;\n\njulia> obj = (;a=1, b=2);\n\njulia> filepath = joinpath(tempdir(), \"file.$extension\");\n\njulia> register_default_serialization_file_handler!(\n            extension = extension;\n            version = version,\n        );\n\njulia> save_file(filepath, obj, version=version);\n\njulia> loaded_obj = load_file(filepath, version=version);\n\njulia> loaded_obj == obj\ntrue\n\n\n\n\n\n","category":"function"},{"location":"#Logging-utils","page":"Home","title":"Logging utils","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"DataWorkstation.IO.custom_logger_meta_formatter\nDataWorkstation.IO.get_formatted_logger","category":"page"},{"location":"#DataWorkstation.IO.custom_logger_meta_formatter","page":"Home","title":"DataWorkstation.IO.custom_logger_meta_formatter","text":"custom_logger_meta_formatter(\n    labels::Union{Vector{T}, Nothing} = nothing,\n    log_level::Logging.LogLevel = Logging.Debug;\n    sep::AbstractString = \" | \",\n    date_format::Union{AbstractString, Nothing} = \"yyyy-mm-dd HH:MM:SS\",\n) where {T <: Union{Any, String}} -> Tuple{Symbol, String, String}\n\nFunction to allow a custom format for the logging messages to generate with a Logging.ConsoleLogger instance. The format is the following one:     [ (date) (sep) (labels separated by 'sep') (log level): (message) For example:     [ 2022-01-01 00:00:00 | tag=test | INFO: Happy new year!\n\nArguments\n\nlabels::Union{Vector{T}, Nothing}: labels to be used in the prefix of the logging   messages. If nothing or an empty Array, no labels will be added to the message.\nlog_level::Logging.LogLevel: Level for the log message to print.\n\nKeywords\n\nsep::AbstractString: Separator for the labels to print in the message prefix\ndate_format::Union{AbstractString, Nothing}: Format for the timestamp   to print in the message prefix. If nothing, no timestamp will be printed.\n\nReturns\n\nTuple{Symbol, String, String}: A tuple of log level, prefix of message, and suffix of   message to be used by a Logger instance when printing a logging message.\n\nExamples\n\njulia> using Logging\n\njulia> DataWorkstation.IO.custom_logger_meta_formatter()\n(:blue, \"DEBUG:\", \"\")\n\njulia> DataWorkstation.IO.custom_logger_meta_formatter([\"level\", \"sublevel\"],\n       Logging.Info, date_format=\"\", sep=\" - \")\n(:blue, \" - level - sublevel - INFO:\", \"\")\n\n\n\n\n\n","category":"function"},{"location":"#DataWorkstation.IO.get_formatted_logger","page":"Home","title":"DataWorkstation.IO.get_formatted_logger","text":"get_formatted_logger(\n    min_level::Symbol=:Debug,\n    args...;\n    stream::Base.IO=stderr,\n    sep::String=\" | \",\n    date_format::AbstractString = \"yyyy-mm-dd HH:MM:SS\",\n    kwargs...) -> Logging.ConsoleLogger\n\nGet an instance of Logging.ConsoleLogger, having a format for the messages based on the given arguments.\n\nThis is useful for the package to log the operations on a workflow with details about in which level they occur, which is important during debugging.\n\nArguments\n\nmin_level::Symbol: Minimum level of log to print, represented as as symbol (e.g.   :Debug, :Info, :Error, :Warn).\nargs...: Labels to be printed as in the message prefix.\n\nKeywords\n\nstream::Base.IO: Stream for the messages to print. Default to stderr.\nsep::AbstractString: Separator for the labels to print in the message prefix.\ndate_format::Union{AbstractString, Nothing}: Format for the timestamp.   to print in the message prefix. If nothing, no timestamp will be printed.\nkwargs...: Labels to be printed as key=value in the message prefix.\n\nReturns\n\nLogging.ConsoleLogger: Logger formatted with custom_logger_meta_formatter().\n\nThrows\n\nErrorException: In case the log level is not supported, or if some   error occurs during the logger obtention.\n\njulia> using Logging\n\njulia> Logging.with_logger(get_formatted_logger(scope=\"repl\", tag=\"test\")) do\n            @info \"Hello world!\"\n        end\n[ 2022-05-18 17:27:01 | scope=repl | tag=test | INFO: Hello world!\n\njulia> Logging.with_logger(get_formatted_logger(:Debug, \"tag1\", level=\"1\")) do\n            @debug \"Logging in this level\"\n            Logging.with_logger(get_formatted_logger(:Debug, \"tag2\", level=\"2\")) do\n                @debug \"Logging in another level\"\n            end\n        end\n[ 2022-05-18 17:27:16 | tag1 | level=1 | DEBUG: Logging in this level\n[ 2022-05-18 17:27:16 | tag2 | level=2 | DEBUG: Logging in another level\n\n\n\n\n\n","category":"function"}]
}
