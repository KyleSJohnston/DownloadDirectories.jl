module DownloadDirectories

using Downloads: Downloads
using URIs: URI

export DownloadDirectory, retrieve

struct DownloadDirectory
    baseuri::URI
    basepath::String
    headers::Dict{String,String}

    function DownloadDirectory(baseuri::URI, basepath::String, headers::Dict{String,String})
        new(baseuri, abspath(basepath), headers)
    end
end

DownloadDirectory(baseuri::URI, basepath::String) = DownloadDirectory(baseuri, basepath, Dict{String,String}())

function localpath(dir::DownloadDirectory, parts::AbstractString...)
    p = abspath(dir.basepath, parts...)
    if !startswith(p, dir.basepath)
        throw(ArgumentError("resulting path is not allowed $(parts...)"))
    end
    return p
end

remoteuri(dir::DownloadDirectory, parts::AbstractString...) = joinpath(dir.baseuri, parts...)

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
