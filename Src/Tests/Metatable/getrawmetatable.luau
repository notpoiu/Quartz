local Test = {
    Aliases = { "debug.setmetatable" }
}

function Test.Run()
	assert(typeof(getrawmetatable) == "function", "getrawmetatable is not a function")

    local mtfunc = function() return false end
    local mt = {
		__index = mtfunc,
		__metatable = "Locked!"
	}

	local object = setmetatable({}, mt)
	local ref = getrawmetatable(object)

    assert(ref == mt, "Failed to get the rawmetatable (table does not match)")
	assert(ref.__index == mtfunc, "Failed to get the rawmetatable (function does not match)")
    assert(ref.__metatable == "Locked!", "Failed to get the rawmetatable (metatable metafield does not match)")
end

return Test
