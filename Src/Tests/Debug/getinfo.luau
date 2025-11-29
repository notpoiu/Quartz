local Test = {}

function Test.Run()
	local function testFunc(...)
		print(...)
	end

	local valuesType = {
		["source"] = "string",
		["short_src"] = "string",
		["func"] = "function",
		["name"] = "string",
		["nups"] = "number",
	}

	local info = debug.getinfo(testFunc)
	for k, v in valuesType do
		assert(info[k] ~= nil, "debug.getinfo didn't return " .. k .. " value")

		assert(
			typeof(info[k]) == v,
			"debug.getinfo returned incorrect type for " .. k .. " (expected " .. v .. ", got " .. typeof(info[k]) .. ")"
		)
	end
end

return Test
