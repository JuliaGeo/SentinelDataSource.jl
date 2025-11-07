module SentinelDataSource
using DimensionalData: DimTree
using Zarr: zopen
using ZarrDatasets: ZarrDataset
using CommonDataModel: CommonDataModel as CDM
using Rasters:Raster

export open_tree

open_tree(path::AbstractString;kwargs...) = open_tree(ZarrDataset(path);kwargs...)

function open_tree(dataset; prefer_datetime=true)
    stem = DimTree()
    groupnames = CDM.groupnames(dataset)
    varnames = CDM.varnames(dataset)
    alldimnames = nesteddimnames(dataset)
    @show varnames
    for v in setdiff(varnames, alldimnames)
        r = Raster(CDM.variable(dataset, v); lazy=true, prefer_datetime)
        setindex!(stem, r,Symbol(v))
    end
    for g in groupnames
        setindex!(stem,  open_tree(CDM.group(dataset, g);prefer_datetime),Symbol(g))
    end
    stem
end


function nesteddimnames(zarrdataset)
    alldims = []
    for v in CDM.varnames(zarrdataset)
        append!(alldims, CDM.dimnames(CDM.variable(zarrdataset, v)))
    end
    unique(alldims)
end

end