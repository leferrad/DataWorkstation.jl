function test_file_handler_constructor()
    @test FileHandler("a", "b") == FileHandler{:a,:b}()
    @test FileHandler("a") == FileHandler{:a,:nothing}()
end

function test_get_extension()
    @test DataWorkstation.IO._get_extension("path/to/file.csv") == "csv"
    @test DataWorkstation.IO._get_extension("file.csv.zip") == "zip"
    @test_throws ArgumentError DataWorkstation.IO._get_extension("not_valid_path")
end

function test_methodswith_no_function()
    some_new_function() = nothing
    @test length(DataWorkstation.IO._methodswith(Int, some_new_function)) == 0
end

function test_methodswith_existing_function()
    some_new_function(x::Int) = x
    @test length(DataWorkstation.IO._methodswith(Int, some_new_function)) == 1
end

function test_methods_load_file_and_save_file()
    extension = "test_methods_load_file_and_save_file"
    version = nothing
    @test length(methods_load_file(extension, version)) == 0
    @test length(methods_save_file(extension, version)) == 0

    register_file_handler(
        extension;
        version = version,
        load_file_function = x -> x,
        save_file_function = (x, y) -> x,
    )

    @test length(methods_load_file(extension, version)) == 1
    @test length(methods_save_file(extension, version)) == 1
end

function test_register_file_handler()
    let catched_call_load_file = Ref(""), catched_call_save_file = Ref("")
        register_test_func() = register_file_handler(
            "test_register_file_handler";
            version = nothing,
            load_file_function = x -> catched_call_load_file[] = x,
            save_file_function = (x, y) -> catched_call_save_file[] = x,
        )
        register_test_func()
        fh = FileHandler("test_register_file_handler", nothing)
        Base.invokelatest(load_file, fh, "load")
        @test catched_call_load_file[] == "load"
        Base.invokelatest(save_file, fh, "save", nothing)
        @test catched_call_save_file[] == "save"

        @test_throws ErrorException register_test_func()
    end
end

function test_unregister_file_handler_nofunction()
    extension = "test_unregister_file_handler_nofunction"
    version = nothing
    @test_throws ErrorException unregister_file_handler(extension, version = version)
end

function test_unregister_file_handler_happy_path()
    extension = "test_unregister_file_handler_happy_path"
    version = nothing
    fh = FileHandler(extension, version)
    t = typeof(fh)
    register_test_func() = register_file_handler(
        extension;
        version = version,
        load_file_function = x -> x,
        save_file_function = (x, y) -> x,
    )
    register_test_func()
    @test length(DataWorkstation.IO._methodswith(t, load_file)) == 1
    @test length(DataWorkstation.IO._methodswith(t, save_file)) == 1
    unregister_file_handler(extension, version = version)
    @test length(DataWorkstation.IO._methodswith(t, load_file)) == 0
    @test length(DataWorkstation.IO._methodswith(t, save_file)) == 0

end

function test_load_file()
    extension = "test_load_file"
    version = nothing
    path = "path/to/file.$extension"

    @test_throws ErrorException load_file(path, version = version)
    @test_throws ArgumentError load_file("not_valid_path")

    register_file_handler(
        extension;
        version = version,
        load_file_function = p -> p,      # just return the path
        save_file_function = (p, o) -> o,  # just return the object
    )

    result = load_file(path, version = version)
    @test result == path
end

function test_save_file()
    extension = "test_save_file"
    version = nothing
    path = "path/to/file.$extension"
    obj = "object"

    @test_throws ErrorException save_file(path, obj, version = version)
    @test_throws ArgumentError save_file("not_valid_path", obj)

    let catched_call_save_file = Ref("")
        register_file_handler(
            extension;
            version = version,
            load_file_function = p -> p,
            save_file_function = (p, o) -> catched_call_save_file[] = o,
        )
        save_file(path, obj, version = version)
        @test catched_call_save_file[] == obj
    end

end

@testset "file_handler.jl" begin
    @testset "unit" begin
        @testset "basics" begin
            test_file_handler_constructor()
            test_register_file_handler()
            test_unregister_file_handler_nofunction()
            test_unregister_file_handler_happy_path()
            test_load_file()
            test_save_file()
        end
        @testset "utils" begin
            test_methodswith_no_function()
            test_methodswith_existing_function()
            test_methods_load_file_and_save_file()
        end
    end
end
