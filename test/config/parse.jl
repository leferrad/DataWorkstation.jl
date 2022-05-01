using TOML


create_temp_config_file(cfg::Dict) = begin
    fname = tempname() * ".toml"
    open(fname, "w") do io
        TOML.print(io, cfg)
    end
    return fname
end


function test_parse_config()
    config_dict = Dict("a" => 1, "b" => Dict("c" => 2, "d" => 3))
    config_nt = (; a = 1, b = (; c = 2, d = 3))
    cfg = ConfigObject(config_nt)
    @test parse_config(config_dict, "") == cfg
    @test parse_config("not_valid", "") == "not_valid"

    filename = create_temp_config_file(config_dict)
    root, fname = dirname(filename), basename(filename)
    escaped_fname = "\$($(fname))"
    @test parse_config(escaped_fname, root) == cfg
end

function test_load_config()
    config_dict = Dict("a" => 1, "b" => Dict("c" => 2, "d" => 3))
    config_nt = (; a = 1, b = (; c = 2, d = 3))
    cfg = ConfigObject(config_nt)

    filename = create_temp_config_file(config_dict)
    root, fname = dirname(filename), basename(filename)
    @test load_config(joinpath(root, fname), root) == cfg
    @test load_config(joinpath(root, fname)) == cfg
end

function test_update_config()
    config_nt = (; a = 1, b = (; c = 2, d = 3))
    new_entries = (; a = 2, e = (f = 3, g = 4))
    cfg = ConfigObject(config_nt)

    @test update_config(cfg, new_entries) == ConfigObject((; config_nt..., new_entries...))
end

@testset "parse.jl" begin
    @testset "unit" begin
        @testset "basics" begin
            test_parse_config()
            test_load_config()
            test_update_config()
        end
    end
end
