function test_register_default_bson_file_handler()
    extension = "test_register_default_bson_file_handler"
    version = nothing
    obj = (; a = 1, b = 2)
    filepath = joinpath(tempdir(), "file.$extension")
    register_test_func() =
        register_default_bson_file_handler(extension = extension; version = version)
    register_test_func()
    save_file(filepath, obj)
    loaded_obj = load_file(filepath)
    @test loaded_obj == obj
end

function test_register_default_csv_file_handler()
    extension = "test_register_default_csv_file_handler"
    version = nothing
    obj = DataFrame(Dict("a" => 1:3, "b" => 4:6))
    filepath = joinpath(tempdir(), "file.$extension")
    register_test_func() =
        register_default_csv_file_handler(extension = extension; version = version)
    register_test_func()
    save_file(filepath, obj)
    loaded_obj = load_file(filepath)
    @test loaded_obj == obj
end

function test_register_default_jdf_file_handler()
    extension = "test_register_default_jdf_file_handler"
    version = nothing
    obj = DataFrame(Dict("a" => 1:3, "b" => 4:6))
    filepath = joinpath(tempdir(), "file.$extension")
    register_test_func() =
        register_default_jdf_file_handler(extension = extension; version = version)
    register_test_func()
    save_file(filepath, obj)
    loaded_obj = load_file(filepath)
    @test loaded_obj == obj
end

function test_register_default_serialization_file_handler()
    extension = "test_register_default_serialization_file_handler"
    version = nothing
    obj = (; a = 1, b = 2)
    filepath = joinpath(tempdir(), "file.$extension")
    register_test_func() = register_default_serialization_file_handler(
        extension = extension;
        version = version,
    )
    register_test_func()
    save_file(filepath, obj)
    loaded_obj = load_file(filepath)
    @test loaded_obj == obj
end


@testset "file_handlers_default.jl" begin
    @testset "unit" begin
        test_register_default_bson_file_handler()
        test_register_default_csv_file_handler()
        test_register_default_jdf_file_handler()
        test_register_default_serialization_file_handler()
    end
end
