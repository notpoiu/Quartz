local Test = {}

function Test.Run()
	assert(typeof(getgc) == "function", "getgc is not a function")
end

return Test
