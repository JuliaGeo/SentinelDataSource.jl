using SentinelDataSource
using Test
using Aqua
using Zarr
using ZarrDatasets

@testset "SentinelDataSource.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(SentinelDataSource)
    end
    # Write your tests here.

    @testset "S1 L1 GRD" begin
        s1grdpath = "https://objectstore.eodc.eu:2222/e05ab01a9d56408d82ac32d69a5aae2a:sample-data/tutorial_data/cpm_v253/S1A_IW_GRDH_1SDV_20240201T164915_20240201T164940_052368_065517_750E.zarr"
        s1grd = ZarrDataset(s1grdpath)
        s1grdtree = SentinelDataSource.open_tree(s1grd)
    end
    @testset "S1 L1 SLC" begin
        s1slcpath = "https://objectstore.eodc.eu:2222/e05ab01a9d56408d82ac32d69a5aae2a:sample-data/tutorial_data/cpm_v253/S1A_IW_SLC__1SDV_20231119T170635_20231119T170702_051289_063021_178F.zarr"
        s1slc = zopen(s1slcpath)
        @test s1slc isa ZGroup
    end
    @testset "S1 L1 NRB" begin
        s1nrbpath = "https://objectstore.eodc.eu:2222/e05ab01a9d56408d82ac32d69a5aae2a:sample-data/tutorial_data/cpm_v253/S1A_IW_SLC__1SDV_20240106T170607_20240106T170635_051989_064848_04A6.zarr"
        s1nrb = zopen(s1nrbpath)
        @test s1nrb isa ZGroup
    end
    @testset "S1 L2 OCN" begin
        s1ocnpath = "https://objectstore.eodc.eu:2222/e05ab01a9d56408d82ac32d69a5aae2a:sample-data/tutorial_data/cpm_v253/S1A_IW_OCN__2SDV_20250224T054940_20250224T055005_058034_072A26_160E.zarr"
        s1ocn = zopen(s1ocnpath)
        @test s1ocn isa ZGroup
    end
    @testset "S2 L1C MSI" begin
        s2l1cpath = "https://objectstore.eodc.eu:2222/e05ab01a9d56408d82ac32d69a5aae2a:sample-data/tutorial_data/cpm_v253/S2B_MSIL1C_20250113T103309_N0511_R108_T32TLQ_20250113T122458.zarr"
        s2l1c = zopen(s2l1cpath)
        @test s2l1c isa ZGroup
    end
    @testset "S2 L2A MSI" begin
        s2l2apath = "https://objectstore.eodc.eu:2222/e05ab01a9d56408d82ac32d69a5aae2a:sample-data/tutorial_data/cpm_v253/S2A_MSIL2A_20240101T102431_N0510_R065_T32TNT_20240101T144052.zarr"
        s2l2a = zopen(s2l2apath)
        @test s2l2a isa ZGroup
    end
    
end
    
