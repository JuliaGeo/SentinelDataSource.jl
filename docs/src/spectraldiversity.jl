using SentinelDataSource
using YAXArrays
using Distances
using DimensionalData
using AWS

struct AnonymousGCS <:AbstractAWSConfig end
struct NoCredentials end
AWS.region(aws::AnonymousGCS) = "" # No region
AWS.credentials(aws::AnonymousGCS) = NoCredentials() # No credentials
AWS.check_credentials(c::NoCredentials) = c # Skip credentials check
AWS.sign!(aws::AnonymousGCS, ::AWS.Request) = nothing # Don't sign request
function AWS.generate_service_url(aws::AnonymousGCS, service::String, resource::String)
    service == "s3" || throw(ArgumentError("Can only handle s3 requests to GCS"))
    awsurl =  string("https://objects.eodc.eu:2222", resource)
    return awsurl
end
AWS.global_aws_config(AnonymousGCS())
path = "s3://e05ab01a9d56408d82ac32d69a5aae2a:sample-data/tutorial_data/cpm_v253/S2A_MSIL2A_20180601T102021_N0500_R065_T32UPC_20230902T045008.zarr/measurements/reflectance/r20m"

pathbase = "s3://e05ab01a9d56408d82ac32d69a5aae2a:sample-data/eopf-sample-output/"
zopen(path)
c = Cube(open_dataset(zopen(path)))
yax = YAXArray((Dim{:x}(1:500), Dim{:y}(500:-1:1), Dim{:Variables}(1:10)), rand(500,500,10))
c = yax
function spectraldiversity(c)
    dlat = dims(c, :x)
    dlon = dims(c, :y)
    dband = dims(c, :Variables)
    # This needs a better interface for within index space
    latinterval = MovingIntervals(center=dlat.val, width=3*step(dlat), n=length(dlat)-1, step=step(dlat))
    loninterval = MovingIntervals(center=dlon.val, width=-3*step(dlon), n=length(dlon)-1, step=-step(dlon))
    bandinterval = MovingIntervals(:closed, :closed, left=first(dband.val), right=last(dband.val), n=1)
    meanwindows = windows(c, :y=>loninterval, :Variables => Whole())
    @show meanwindows[10,10,1]
    @time xmap(innerdiversity, meanwindows)
end
spectraldiversity(c)
function innerdiversity(xout, arr)
    winsize =  prod(size(arr)) ÷ size(arr,3)
    arrreshaped = reshape(arr, (winsize, size(arr,3)))
    tslist = eachrow(arrreshaped)
    dists = pairwise(Euclidean(), tslist) .* 2 ./ winsize .^ 4
    xout .= sum(dists) ./ 2 
end

spectraldiversity(c)