using Dates

function hfun_bar(vname)
    val = Meta.parse(vname[1])
    return round(sqrt(val), digits=2)
end

function hfun_m1fill(vname)
    var = vname[1]
    return pagevar("index", var)
end

function lx_baz(com, _)
    # keep this first line
    brace_content = Franklin.content(com.braces[1]) # input string
    # do whatever you want here
    return uppercase(brace_content)
end

function hfun_posts()
    post_records = Vector{Any}()
    for path in readdir("posts")
        if !endswith(path, ".md") || path == "index.md"
            continue
        end
        title = pagevar(joinpath("posts", path), :title)
        date = pagevar(joinpath("posts", path), :date)
        if !isnothing(date)
            push!(post_records, (; path, date, title))
        end
    end
    io = IOBuffer()
    for rec in post_records
        write(io, string(rec.date), " <a href='", replace(rec.path, ".md" => ""), "'>", rec.title, "</a>\n")
    end
    return String(take!(io))
end