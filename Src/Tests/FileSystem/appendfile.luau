local Test = {}

function Test.Run()
	assert(typeof(appendfile) == "function", "appendfile is not a function")
end

return Test
