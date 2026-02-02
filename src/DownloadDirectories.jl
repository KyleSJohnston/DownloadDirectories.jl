module DownloadDirectories

using Downloads: Downloads
using URIs: URI

export DownloadDirectory, retrieve

"""
    DownloadDirectory(baseuri, basepath, headers=Dict{String,String}())

A local directory to store downloads from a single website

# Arguments
- `baseuri::URI`: the base URI for all downloads
- `basepath::String`: the local directory to store downloaded files
- `headers::Dict{String,String}=Dict{String,String}()`: headers to supply to `Downloads.download`
"""
struct DownloadDirectory
    baseuri::URI
    basepath::String
    headers::Dict{String,String}

    function DownloadDirectory(baseuri::URI, basepath::String, headers::Dict{String,String}=Dict{String,String}())
        new(baseuri, abspath(basepath), headers)
    end
end

function localpath(dir::DownloadDirectory, parts::AbstractString...)
    p = abspath(dir.basepath, parts...)
    if !startswith(p, dir.basepath)
        throw(ArgumentError("resulting path is not allowed $(parts...)"))
    end
    return p
end

remoteuri(dir::DownloadDirectory, parts::AbstractString...) = joinpath(dir.baseuri, parts...)

"""
    retrieve(dir, parts...; refresh=false, verbose=false)

Returns a local path for a downloaded file in `dir`

# Arguments
- `dir::DownloadDirectory`: the URI/directory pairing
- `parts::AbstractString...`: relative path parts
- `refresh::Bool=false`: force the file to be redownloaded even if it exists locally
- `verbose::Bool=false`: see `Downloads.download` for usage
"""
function retrieve(dir::DownloadDirectory, parts::AbstractString...; refresh::Bool=false, verbose::Bool=false)
    path = localpath(dir, parts...)
    if refresh || !isfile(path)
        mkpath(dirname(path))  # make intermediate directories
        uri = remoteuri(dir, parts...)
        Downloads.download(string(uri), path; headers=dir.headers, verbose)
    end
    return path
end

end # module DownloadDirectories
