local Test = {}

function Test.Run()
	assert(typeof(isfile) == "function", "isfile is not a function")
end

return Test
