local Test = {}

function Test.Run()
	assert(typeof(decompile) == "function", "decompile is not a function")
end

return Test
