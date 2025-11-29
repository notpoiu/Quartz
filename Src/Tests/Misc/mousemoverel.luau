local Test = {}

function Test.Run()
	assert(typeof(mousemoverel) == "function", "mousemoverel is not a function")
end

return Test
