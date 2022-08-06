function test_loggingconfig_constructor_default_when_no_logging_config()
    logging_config = LoggingConfig(
        WorkflowSpec((;no_logging_config=true))
    )

    @test logging_config isa LoggingConfig
end

function test_loggingconfig_constructor_with_logging_parameters()
    logging_config = LoggingConfig(
        WorkflowSpec((;logging=(;
            min_level=:Debug,
            color=(;Info="yellow", Debug="green"),
            workflow=true, jobs=true, steps=false)
        ))
    )
    @test logging_config isa LoggingConfig
    @test logging_config.min_level == :Debug
    expected_colors_config = Dict(:Info => :yellow, :Debug => :green)
    @test logging_config.colors_config isa DataWorkstation.IO.ColorsConfig
    @test all(
        [logging_config.colors_config[k] == expected_colors_config[k]
        for k in keys(expected_colors_config)])
    @test logging_config.workflow === true
    @test logging_config.jobs === true
    @test logging_config.steps === false
end

function test_loggingconfig_constructor_bad_path()

    @test_throws ErrorException LoggingConfig(
        WorkflowSpec((;logging=(;
            min_level=:not_valid_level,
        )))
    )

    @test_throws ErrorException LoggingConfig(
        WorkflowSpec((;logging=(;
            color=(;Info="not valid color"),
        )))
    )

    @test_throws ErrorException LoggingConfig(
        WorkflowSpec((;logging=(;
            workflow="not valid flag",
        )))
    )

end


function test_get_formatted_logger()
    logger_noargs = get_formatted_logger()
    @test logger_noargs isa Logging.ConsoleLogger

    logger_withargs = get_formatted_logger(
        LoggingConfig(min_level = :Debug),
        "level",
        stream = stderr,
        sublevel = "x",
    )
    @test logger_noargs isa Logging.ConsoleLogger
    @test logger_withargs.stream == stderr
    @test logger_withargs.min_level == Logging.Debug
end

@testset "logging_config.jl" begin
    @testset "unit" begin
        test_loggingconfig_constructor_default_when_no_logging_config()
        test_loggingconfig_constructor_with_logging_parameters()
        test_loggingconfig_constructor_bad_path()
        test_get_formatted_logger()
    end
end
