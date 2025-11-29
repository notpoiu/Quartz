local Test = {}

function Test.Run()
	assert(typeof(getcallingscript) == "function", "getcallingscript is not a function")
end

return Test
