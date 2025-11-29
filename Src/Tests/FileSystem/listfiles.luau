local Test = {}

function Test.Run()
	assert(typeof(listfiles) == "function", "listfiles is not a function")
end

return Test
