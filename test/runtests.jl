using SentinelDataSource
using Test
using Aqua

@testset "SentinelDataSource.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(SentinelDataSource)
    end
    # Write your tests here.
end
