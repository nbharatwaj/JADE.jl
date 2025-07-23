#  This file is part of JADE source code and is added as part of the
# SSAD review work done in 2025 by RBP
#  
struct WindStation
    node::Symbol
    capacity::Float64
    omcost::Float64
end

function getwinds(filename::String, nodes::Vector{Symbol})
    winds = Dict{Symbol,WindStation}()
    for row in CSV.Rows(
        filename;
        missingstring = ["NA", "na", "default"],
        stripwhitespace = true,
        comment = "%",
    )
        row = _validate_and_strip_trailing_comment(
            row,
            [
                :GENERATOR,
                :NODE,
                :CAPACITY,
                :OMCOST,
            ],
        )
        generator = str2sym(row.GENERATOR)
        if haskey(winds, generator)
            error("Generator $(generator) given twice.")
        end

        node = str2sym(row.NODE)
        if !(node in nodes)
            error("Node $node for generator $generator not found")
        end
        winds[generator] = WindStation(
            node,
            parse(Float64, row.CAPACITY),
            parse(Float64, get(row, :OMCOST, "0.0")),
        )
    end
    return winds
end