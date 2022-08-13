WorkflowStep = DataWorkstation.Workflows.WorkflowStep

function test_register_and_run_step_function()
    step_sym = :TestRegisterAndRun
    cfg = ConfigObject((; result = "result"))
    func = cfg -> cfg.result
    # Register function to allow validation of run_step_function
    register_step_function(step_sym, func)
    # Run step function to validate
    result = run_step_function(step_sym, cfg)
    @test result == "result"
end

function test_register_step_function_overwrite()
    step_sym = :TestRegisterNoOverwrite
    cfg = ConfigObject((; result = "result"))
    func = cfg -> cfg.result

    # First call OK
    register_step_function(step_sym, func, overwrite = false)
    # Second call throws error when overwrite = false
    @test_throws ErrorException register_step_function(step_sym, func, overwrite = false)
    # Third call OK when overwrite = true
    register_step_function(step_sym, func, overwrite = true)
end

function test_register_step_function_not_valid_function()
    not_valid_function(x::Int) = println(x)
    @test_throws ErrorException register_step_function(
        :TestNotValidFunction,
        not_valid_function,
    )
end

function test_register_step_function_no_name()
    this_is_a_test_function(x) = println(x)
    register_step_function(this_is_a_test_function)

    expected_sig = Tuple{
        typeof(run_step_function),
        Type{WorkflowStep{:this_is_a_test_function}},  # use Symbol to identify method
        ConfigObject,
    }
    func_methods = collect(methods(run_step_function))

    @test length(filter(m -> m.sig == expected_sig, func_methods)) > 0
end

@testset "step.jl" begin
    @testset "unit" begin
        test_register_and_run_step_function()
        test_register_step_function_overwrite()
        test_register_step_function_not_valid_function()
        test_register_step_function_no_name()
    end
end
