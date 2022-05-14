
function test_configobject_constructor()
    nt = (; a = 1, b = (; c = 2, d = 3))
    cfg = ConfigObject(nt)

    @test cfg.a == nt.a
    @test cfg.b isa ConfigObject
    @test cfg.b.c == nt.b.c
    @test ConfigObject(cfg) == cfg
    @test_throws KeyError ConfigObject((; _nt = "value_for_not_valid_key"))
end

function test_configobject_iterable()
    nt = (; a = 1, b = (; c = 2, d = 3))
    cfg = ConfigObject(nt)

    @test keys(cfg) == (:a, :b)
    @test values(cfg) == (1, ConfigObject((; c = 2, d = 3)))
    @test iterate(cfg) == (1, 2)
    @test iterate(cfg, 2) == (ConfigObject((; c = 2, d = 3)), 3)
    @test collect(cfg) == nt
end

function test_configobject_properties()
    nt = (; a = 1, b = (; c = 2, d = 3))
    cfg = ConfigObject(nt)

    @test propertynames(cfg) == keys(nt)
    @test hasproperty(cfg, :a) === true
    @test getproperty(cfg, :_nt) == (; a = 1, b = ConfigObject((; c = 2, d = 3)))
    @test getindex(cfg, :a) == getindex(nt, :a)
    @test_throws ErrorException getproperty(cfg, :not_valid_property)
end

function test_configobject_equals()
    nt1 = (; a = 1, b = (; c = 2, d = 3))
    nt2 = (; b = (; d = 3, c = 2), a = 1)
    @test ConfigObject(nt1) == ConfigObject(nt2)
    @test ConfigObject(nt1) != ConfigObject(nt2.b)
end

function test_configobject_merge()
    nt1 = (; a = 1, b = (; c = 2, d = 3))
    nt2 = (; e = 4, f = (; g = 5, h = 6))
    cfg1 = ConfigObject(nt1)
    cfg2 = ConfigObject(nt2)

    @test merge(nt1, cfg2) == ConfigObject((; nt1..., nt2...))
    @test merge(cfg1, nt2) == ConfigObject((; nt1..., nt2...))
    @test merge(cfg1, cfg2) == ConfigObject((; nt1..., nt2...))
end

@testset "config_object.jl" begin
    @testset "unit" begin
        @testset "basics" begin
            test_configobject_constructor()
            test_configobject_iterable()
            test_configobject_properties()
            test_configobject_equals()
            test_configobject_merge()
        end
    end
end
