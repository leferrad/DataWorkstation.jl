dict_to_namedtuple = DataWorkstation.Workflows.dict_to_namedtuple
check_step_function_existence = DataWorkstation.Workflows.check_step_function_existence
get_sorted_jobs_based_on_dependencies =
    DataWorkstation.Workflows.get_sorted_jobs_based_on_dependencies

function test_dict_to_namedtuple()
    @test dict_to_namedtuple(Dict(:a => 1, "b" => Dict("c" => 2))) == (;a=1, b=(;c=2))
end

function test_is_valid_step_function()
    @test is_valid_step_function((x1, x2) -> x1 + x2) == false
    @test is_valid_step_function(a::Int -> a + 1) == false
    @test is_valid_step_function(cfg::ConfigObject -> cfg.x) == true
    @test is_valid_step_function(cfg -> cfg.x) == true
end

function test_check_step_function_existence()
    @test check_step_function_existence(:StepFunctionA) == false
    register_step_function(:StepFunctionA, x -> x.a)
    @test check_step_function_existence(:StepFunctionA) == true
end

function test_get_sorted_jobs_based_on_dependencies()
    jobs_and_deps = [("job1", ()), ("job2", ("job1",)),
                     ("job3", ("job4",)), ("job4", ("job1", "job2"))]
    @test get_sorted_jobs_based_on_dependencies(jobs_and_deps) == [
        "job1", "job2", "job4", "job3"]

    # Detect cyclic dependencies and throw error
    @test_throws ErrorException get_sorted_jobs_based_on_dependencies(
        [("job1", ("job2",)), ("job2", ("job1",))]
    )
end

@testset "utils.jl" begin
    @testset "unit" begin
        test_dict_to_namedtuple()
        test_is_valid_step_function()
        test_check_step_function_existence()
        test_get_sorted_jobs_based_on_dependencies()
    end
end
