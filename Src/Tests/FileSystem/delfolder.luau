local Test = {}

function Test.Run()
	assert(typeof(delfolder) == "function", "delfolder is not a function")
end

return Test
