module SentinelDataSource
using DimensionalData: DimTree
using Zarr: zopen
using ZarrDatasets: ZarrDataset
using CommonDataModel: CommonDataModel as CDM
using Rasters:Raster

function open_eopf(path)
    zd = ZarrDataset(path)
    eopfstem = DimTree()
    eopfstem.measurements = DimTree()
end

function open_tree(dataset)
    stem = DimTree()
    groupnames = CDM.groupnames(dataset)
    varnames = CDM.varnames(dataset)
    alldimnames = nesteddimnames(dataset)
    for v in setdiff(varnames, alldimnames)
        setindex!(stem, Raster(CDM.variable(dataset, v), lazy=true),Symbol(v))
    end
    for g in groupnames
        setindex!(stem,  open_tree(CDM.group(dataset, g)),Symbol(g))
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