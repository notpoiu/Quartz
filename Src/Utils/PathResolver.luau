local PathResolver = {}

function PathResolver.ResolvePath(base, path)
    for _, Segment in path:split(".") do
        assert(base[Segment] ~= nil, `Failed to resolve path {path} at segment {Segment}`)
        
        base = base[Segment]
    end

    return base
end

function PathResolver.InsertDataInPath(options: {
    BaseTable: any,
    OverrideTable: any,
    Data: any,
    Path: string
})
    local BasePointer = options.BaseTable
    local OverridePointer = options.OverrideTable

    local Segments = options.Path:split(".")
    for Idx, Segment in Segments do
        --// Insert Data if last element. \\--
        if Idx == #Segments then
            OverridePointer[Segment] = options.Data
            break
        end

        --// Create Table Proxy if it doesn't exist \--
        if not OverridePointer[Segment] then
            if BasePointer[Segment] then
                --// Create Table Proxy \\--
                OverridePointer[Segment] = setmetatable({}, {
                    __index = BasePointer[Segment]
                })
            else
                --// Create Empty Table \\--
                OverridePointer[Segment] = {}
            end
        end

        BasePointer = BasePointer[Segment]
        OverridePointer = OverridePointer[Segment]
    end
end


return PathResolver