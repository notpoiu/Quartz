local Test = {}

function Test.Run()
	assert(typeof(isfolder) == "function", "isfolder is not a function")
end

return Test
