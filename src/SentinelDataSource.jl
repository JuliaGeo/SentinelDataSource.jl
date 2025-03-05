module SentinelDataSource
using DimensionalData
using Zarr: zopen

function open_eopf(path)
    z = zopen(path)
end
#zopen()
# Write your package code here.

end
