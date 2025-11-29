local Test = {}

function Test.Run()
	assert(typeof(readfile) == "function", "readfile is not a function")
end

return Test
