local Test = {}

function Test.Run()
	assert(typeof(filtergc) == "function", "filtergc is not a function")

    --// Test Function Filtering \\--
    local function QuartzFilterTest(data)
        return data * 2
    end

    local Candidates = filtergc("function", {
        Name = "QuartzFilterTest",
        IgnoreExecutor = false
    })

    assert(typeof(Candidates) == "table", "filtergc did not return a table when returnOne is not set.")
    assert(table.find(Candidates, QuartzFilterTest) ~= nil, "filtergc did not find the QuartzFilterTest function.")

    --// Test Table Filtering \\--
    local Key = math.random(1, 100_000_000)
    local TableToFilter = {
        [`QuartzFilter{Key}`] = Key,
        ["QuartzOrigin"] = true
    }

    local FilteredTable = filtergc("table", {
        Keys = { `QuartzFilter{Key}` },
        Values = { Key },
    }, true)

    assert(typeof(FilteredTable) == "table", "filtergc did not return a table when returnOne is set.")
    assert(FilteredTable == TableToFilter, "filtergc did not return the correct table when returnOne is set.")
end

return Test
