module SentinelDataSource
using DimensionalData: DimTree
using Zarr: zopen
using ZarrDatasets: ZarrDataset
using CommonDataModel: CommonDataModel as CDM

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
        @show v
        setproperty!(stem, Symbol(v), Raster(CDM.variable(dataset, v), lazy=true))
    end
    for g in groupnames
        setproperty!(stem, Symbol(g), open_tree(CDM.group(dataset, g)))
    end
    stem
end
#zopen()
# Write your package code here.

end

function nesteddimnames(zarrdataset)
    alldims = []
    for v in CDM.varnames(zarrdataset)
        append!(alldims, CDM.dimnames(CDM.variable(zarrdataset, v)))
    end
    unique(alldims)
end