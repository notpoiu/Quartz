local Test = {}

function Test.Run()
	assert(typeof(isexecutorclosure) == "function", "isexecutorclosure is not a function")

	local executorFunc = function()
		return true
	end

	assert(isexecutorclosure(executorFunc), "Executor created function should return true")
	assert(not isexecutorclosure(wait), "Roblox Luau function should return false; its not an executor function")
end

return Test
