module SentinelDataSource
using DimensionalData: DimTree, DimArray
using Zarr: zopen
using ZarrDatasets: ZarrDataset
using CommonDataModel: CommonDataModel as CDM
using Rasters: Rasters

export open_tree

open_tree(path::AbstractString) = open_tree(ZarrDataset(path))

function open_tree(dataset::ZarrDataset)
    @time "stem" stem = DimTree()
    @time "groups" groupnames = CDM.groupnames(dataset)
    @time "vars" varnames = CDM.varnames(dataset)
    @time "dims" alldimnames = nesteddimnames(dataset)
    @time "forvar" for v in setdiff(varnames, alldimnames)
        @time "var" var = CDM.variable(dataset, v)
        @time "vardims" vardims = Rasters._dims(var)
        @time "meta" metadata_out = Rasters._metadata(var)
        @time "missing" missingval_out = Rasters._read_missingval_pair(var, metadata_out, Rasters.nokw)
        @time "mod" mod = Rasters._mod(eltype(var), metadata_out, missingval_out;scaled=true, coerce=true)
        @time "vardata" vardata = Rasters._maybe_modify(var, mod)
        @time "set" setindex!(stem, DimArray(vardata, vardims),Symbol(v))
    end
    @time "forg" for g in groupnames
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