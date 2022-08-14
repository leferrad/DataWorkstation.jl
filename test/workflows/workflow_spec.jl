using TOML

function test_workflowspec_constructor_nt()
    nt = (; a = 1, b = (; c = 2, d = 3))
    spec = WorkflowSpec(nt)

    @test spec._spec == nt
    @test spec.a == nt.a
    @test spec.b isa NamedTuple
    @test spec.b.c == nt.b.c
end

function test_workflowspec_constructor_file()
    spec_dict = Dict("a" => 1, "b" => Dict("c" => 2, "d" => 3))
    filename = tempdir() * "/workflow.toml"
    open(filename, "w") do io
        TOML.print(io, spec_dict)
    end
    spec = WorkflowSpec(filename)

    @test spec.a == spec_dict["a"]
    @test spec.b isa NamedTuple
    @test spec.b.c == spec_dict["b"]["c"]
end

function test_workflowspec_properties()
    nt = (; a = 1, b = (; c = 2, d = 3))
    spec = WorkflowSpec(nt)

    @test propertynames(spec) == keys(nt)
    @test hasproperty(spec, :a) === true
    @test getproperty(spec, :_spec) == (; a = 1, b = (; c = 2, d = 3))
    @test getindex(spec, :a) == getindex(nt, :a)
    @test_throws ErrorException getproperty(spec, :not_valid_property)
end

function test_workflowspec_equals()
    nt1 = (; a = 1, b = (; c = 2, d = 3))
    nt2 = (; b = (; c = 2, d = 3), a = 1)
    @test WorkflowSpec(nt1) == WorkflowSpec(nt2)
    @test WorkflowSpec(nt1) != WorkflowSpec(nt2.b)
end

function test_workflowspec_iterable()
    nt = (; a = 1, b = (; c = 2, d = 3))
    spec = WorkflowSpec(nt)

    @test keys(spec) == (:a, :b)
    @test values(spec) == (1, (; c = 2, d = 3))
    @test iterate(spec) == (1, 2)
    @test iterate(spec, 2) == ((; c = 2, d = 3), 3)
    @test collect(spec) == nt
end

@testset "workflow_spec.jl" begin
    @testset "unit" begin
        test_workflowspec_constructor_nt()
        test_workflowspec_constructor_file()
        test_workflowspec_properties()
        test_workflowspec_equals()
        test_workflowspec_iterable()
    end
end
