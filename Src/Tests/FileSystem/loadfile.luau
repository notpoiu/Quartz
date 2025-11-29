local Test = {}

function Test.Run()
	assert(typeof(loadfile) == "function", "loadfile is not a function")
end

return Test
