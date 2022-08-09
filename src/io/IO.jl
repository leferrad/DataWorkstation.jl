module IO

include("file_handler.jl")
export FileHandler,
    load_file,
    save_file,
    methods_load_file,
    methods_save_file,
    register_file_handler,
    unregister_file_handler

include("file_handlers_default.jl")
export register_default_bson_file_handler,
    register_default_csv_file_handler,
    register_default_jdf_file_handler,
    register_default_serialization_file_handler

include("logging.jl")
export ColorsConfig, custom_logger_meta_formatter, get_formatted_logger, LOG_LEVELS

end
