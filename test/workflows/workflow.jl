using TOML

run_jobs = DataWorkstation.Workflows.run_jobs
run_job_steps = DataWorkstation.Workflows.run_job_steps
namedtuple_to_dict = DataWorkstation.Workflows.namedtuple_to_dict # Used as a util

function test_run_job_steps()
    cfg = ConfigObject((; result_step_a = "res_step_a", result_step_b = "res_step_b"))
    workflow_name = "test_workflow"
    job_name = "test_job"

    # Define and register dummy step functions for workflow
    result = []  # Just a collector of results from runned steps
    eval(quote
        step_a_test_run_job_steps(c::ConfigObject) = push!($result, c.result_step_a)
    end)
    eval(quote
        step_b_test_run_job_steps(c::ConfigObject) = push!($result, c.result_step_b)
    end)
    register_step_function(step_a_test_run_job_steps)
    register_step_function(step_b_test_run_job_steps)
    steps = [:step_a_test_run_job_steps, :step_b_test_run_job_steps]

    duration = run_job_steps(cfg, workflow_name, job_name, steps)

    @test duration isa Real
    @test result == [cfg.result_step_a, cfg.result_step_b]

    @test_throws ErrorException run_job_steps(
        cfg,
        workflow_name,
        job_name,
        [:not_existing_function_step],
    )
end

function test_run_jobs()
    cfg = ConfigObject((;
        result_job_a_step_1 = "res_job_a_step_1",
        result_job_a_step_2 = "res_job_a_step_2",
        result_job_b_step_1 = "res_job_b_step_1",
        result_job_b_step_2 = "res_job_b_step_2",
    ))
    workflow_spec = WorkflowSpec((;
        name = "test_workflow",
        jobs = (;
            job_a_test_run_jobs = (; steps = [:job_a_step_1, :job_a_step_2]),
            job_b_test_run_jobs = (; steps = [:job_b_step_1, :job_b_step_2]),
        ),
    ))
    jobs = [:job_a_test_run_jobs, :job_b_test_run_jobs]

    # Define and register step functions for jobs in workflow
    result = []  # Just a collector of results from runned steps
    eval(quote
        job_a_step_1(c::ConfigObject) = push!($result, c.result_job_a_step_1)
    end)
    eval(quote
        job_a_step_2(c::ConfigObject) = push!($result, c.result_job_a_step_2)
    end)
    eval(quote
        job_b_step_1(c::ConfigObject) = push!($result, c.result_job_b_step_1)
    end)
    eval(quote
        job_b_step_2(c::ConfigObject) = push!($result, c.result_job_b_step_2)
    end)
    register_step_function(job_a_step_1)
    register_step_function(job_a_step_2)
    register_step_function(job_b_step_1)
    register_step_function(job_b_step_2)

    duration = run_jobs(cfg, workflow_spec, jobs)

    @test duration isa Real
    @test result == [
        cfg.result_job_a_step_1,
        cfg.result_job_a_step_2,
        cfg.result_job_b_step_1,
        cfg.result_job_b_step_2,
    ]

    @test_throws ErrorException run_jobs(
        cfg, WorkflowSpec((;
            jobs = (; job_a = (; steps = [:job_a_step_1, :job_a_step_2]))
        )), [:not_valid_job_key])

    @test_throws ErrorException run_jobs(
        cfg, WorkflowSpec((;
            jobs = (; job_a = (; not_valid_steps = []))
        )), [:job_a])

end

function test_run_workflow()
    cfg = ConfigObject((;
        result_job_a_step_1 = "res_job_a_step_1",
        result_job_a_step_2 = "res_job_a_step_2",
        result_job_b_step_1 = "res_job_b_step_1",
        result_job_b_step_2 = "res_job_b_step_2",
    ))
    workflow_spec = WorkflowSpec((;
        name = "test_workflow",
        conf = tempdir() * "/config.toml",
        jobs = (;
            job_a_test_run_jobs = (; steps = ["job_a_step_1", "job_a_step_2"]),
            job_b_test_run_jobs = (; steps = ["job_b_step_1", "job_b_step_2"],
                                   needs = "job_a_test_run_jobs"),
        ),
    ))
    jobs = [:job_a_test_run_jobs, :job_b_test_run_jobs]
    expected_result = [
        cfg.result_job_a_step_1,
        cfg.result_job_a_step_2,
        cfg.result_job_b_step_1,
        cfg.result_job_b_step_2,
    ]

    # Define and register step functions for jobs in workflow
    result = []  # Just a collector of results from runned steps
    eval(quote
        job_a_step_1(c::ConfigObject) = push!($result, c.result_job_a_step_1)
    end)
    eval(quote
        job_a_step_2(c::ConfigObject) = push!($result, c.result_job_a_step_2)
    end)
    eval(quote
        job_b_step_1(c::ConfigObject) = push!($result, c.result_job_b_step_1)
    end)
    eval(quote
        job_b_step_2(c::ConfigObject) = push!($result, c.result_job_b_step_2)
    end)
    register_step_function(job_a_step_1)
    register_step_function(job_a_step_2)
    register_step_function(job_b_step_1)
    register_step_function(job_b_step_2)

    duration = run_workflow(cfg, workflow_spec, jobs_keys=jobs)
    @test duration isa Real
    @test result == expected_result

    # Test other APIs and get the same results (concatenated in result list)

    open(workflow_spec.conf, "w") do io
        TOML.print(io, namedtuple_to_dict(collect(cfg)))
    end

    workflow_spec_fname = tempdir() * "/workflow.toml"
    open(workflow_spec_fname, "w") do io
        TOML.print(io, namedtuple_to_dict(collect(workflow_spec)))
    end

    run_workflow(
        workflow_spec_fname
    )
    @test result == vcat(expected_result, expected_result)  # execution x2

    run_workflow(
        cfg,
        workflow_spec_fname;
        jobs_keys=:job_a_test_run_jobs,
    )
    @test result == vcat(expected_result, expected_result,
    [cfg.result_job_a_step_1, cfg.result_job_a_step_2,])  # execution x2 + job A

    workflow_spec_not_valid_needs = WorkflowSpec((;
        name = "test_workflow_not_valid_needs",
        jobs = (;
            job_a = (; steps = ["job_a_step_1", "job_a_step_2"], needs = 1),
        ),
    ))
    @test_throws ErrorException run_workflow(cfg, workflow_spec_not_valid_needs)

    workflow_spec_needs_not_existing_job = WorkflowSpec((;
        name = "test_workflow_needs_not_existing_job",
        jobs = (;
            job_a = (; steps = ["job_a_step_1", "job_a_step_2"], needs = ["job_X"]),
        ),
    ))
    @test_throws ErrorException run_workflow(cfg, workflow_spec_needs_not_existing_job)

    workflow_spec_no_conf = WorkflowSpec((;
        name = "test_workflow_no_conf",
        jobs = (;
            job_a = (; steps = ["job_a_step_1", "job_a_step_2"]),
        ),
    ))
    bad_workflow_spec_fname = tempdir() * "/bad_workflow.toml"
    open(bad_workflow_spec_fname, "w") do io
        TOML.print(io, namedtuple_to_dict(collect(workflow_spec_no_conf)))
    end

    @test_throws ErrorException run_workflow(bad_workflow_spec_fname)
end

@testset "workflow.jl" begin
    @testset "unit" begin
        test_run_job_steps()
        test_run_jobs()
        test_run_workflow()
    end
end
