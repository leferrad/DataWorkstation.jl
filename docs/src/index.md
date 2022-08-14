```@meta
CurrentModule = DataWorkstation
```

# DataWorkstation

Documentation for [DataWorkstation](https://github.com/leferrad/DataWorkstation.jl).

## API Reference

### Index
```@index
```

```@autodocs
Modules = [DataWorkstation]
Private = false
Order = [:type, :function]
```

### Config module
```@docs
DataWorkstation.Config.ConfigObject
DataWorkstation.Config.load_config
DataWorkstation.Config.parse_config
DataWorkstation.Config.update_config 
```

### IO module

#### File operations
```@docs
DataWorkstation.IO.FileHandler
DataWorkstation.IO.load_file
DataWorkstation.IO.save_file
DataWorkstation.IO.methods_load_file
DataWorkstation.IO.methods_save_file
DataWorkstation.IO.register_file_handler
DataWorkstation.IO.unregister_file_handler
```

#### Util file handlers
```@docs
DataWorkstation.IO.register_default_bson_file_handler
DataWorkstation.IO.register_default_csv_file_handler
DataWorkstation.IO.register_default_jdf_file_handler
DataWorkstation.IO.register_default_serialization_file_handler
```

#### Logging utils
```@docs
DataWorkstation.IO.custom_logger_meta_formatter
DataWorkstation.IO.get_formatted_logger
```

### Workflows module

#### Logging utils

```@docs
DataWorkstation.Workflows.LoggingConfig
DataWorkstation.Workflows.get_formatted_logger
```

#### Step functions

```@docs
DataWorkstation.Workflows.register_step_function
DataWorkstation.Workflows.run_step_function
DataWorkstation.Workflows.is_valid_step_function
```

#### Workflow specification and running

```@docs
DataWorkstation.Workflows.WorkflowSpec
DataWorkstation.Workflows.run_workflow
```