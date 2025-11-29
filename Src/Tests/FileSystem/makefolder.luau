local Test = {}

function Test.Run()
	assert(typeof(makefolder) == "function", "makefolder is not a function")
end

return Test
