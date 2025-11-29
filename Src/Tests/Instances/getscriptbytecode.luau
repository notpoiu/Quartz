local Test = {}

function Test.Run()
	assert(typeof(getscriptbytecode) == "function", "getscriptbytecode is not a function")
end

return Test
