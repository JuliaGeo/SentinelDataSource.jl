module SentinelDataSource
using DimensionalData: DimTree, DimArray, DimensionalData
using Zarr: zopen
using ZarrDatasets: ZarrDataset
using CommonDataModel: CommonDataModel as CDM
using Rasters: Rasters
using TimerOutputs
export open_tree

open_tree(path::AbstractString) = open_tree(ZarrDataset(path))

function open_tree(dataset::ZarrDataset)
    @timeit_debug "stem" stem = DimTree()
    @timeit_debug "groups" groupnames = CDM.groupnames(dataset)
    @timeit_debug "vars" varnames = CDM.varnames(dataset)
    @timeit_debug "dims" alldimnames = nesteddimnames(dataset)
    diffnames = setdiff(varnames, alldimnames)
    for v in diffnames
        @timeit_debug "var $v" begin
        var = CDM.variable(dataset, v)
        vardims = Rasters._dims(var)
        metadata_out = Rasters._metadata(var)
        missingval_out = Rasters._read_missingval_pair(var, metadata_out, Rasters.nokw)
        mod = Rasters._mod(eltype(var), metadata_out, missingval_out;scaled=true, coerce=true)
        #=
        Rasters.FileArray{ZarrDataset}(var, filename;
                name=v, Rasters.nokw, mod, write=false
            )
                =#
        vardata = Rasters._maybe_modify(var, mod)
        setindex!(stem, DimArray(vardata, vardims),Symbol(v))
        end
    end
    for g in groupnames
        @timeit_debug "forg $g"    setindex!(stem,  open_tree(CDM.group(dataset, g)),Symbol(g))
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