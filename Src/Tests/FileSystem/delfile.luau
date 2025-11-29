local Test = {}

function Test.Run()
	assert(typeof(delfile) == "function", "delfile is not a function")
end

return Test
