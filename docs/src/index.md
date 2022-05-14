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

#### Basic functions
```@docs
DataWorkstation.IO.FileHandler
DataWorkstation.IO.load_file
DataWorkstation.IO.save_file
DataWorkstation.IO.methods_load_file
DataWorkstation.IO.methods_save_file
DataWorkstation.IO.register_file_handler!
DataWorkstation.IO.unregister_file_handler!
```

#### Util functions
```@docs
DataWorkstation.IO.register_default_bson_file_handler!
DataWorkstation.IO.register_default_csv_file_handler!
DataWorkstation.IO.register_default_jdf_file_handler!
DataWorkstation.IO.register_default_serialization_file_handler!
```