function test_custom_logger_meta_formatter()
    format_func = DataWorkstation.IO.custom_logger_meta_formatter
    result = format_func(["some_label"], Logging.Info)
    @test result isa Tuple{Symbol,String,String}

    result = format_func([], Logging.Info)
    @test result isa Tuple{Symbol,String,String}

    result = format_func(nothing, Logging.Info)
    @test result isa Tuple{Symbol,String,String}

    result = format_func(nothing, Logging.Info, date_format = nothing)
    @test result isa Tuple{Symbol,String,String}
end

function test_get_formatted_logger()
    logger_noargs = get_formatted_logger()
    @test logger_noargs isa Logging.ConsoleLogger

    logger_withargs = get_formatted_logger(:Debug, "level", stream = stderr, sublevel = "x")
    @test logger_noargs isa Logging.ConsoleLogger
    @test logger_withargs.stream == stderr
    @test logger_withargs.min_level == Logging.Debug
end

@testset "logging.jl" begin
    @testset "unit" begin
        test_custom_logger_meta_formatter()
        test_get_formatted_logger()
    end
end
