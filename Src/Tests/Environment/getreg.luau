local Test = {}

function Test.Run()
	assert(typeof(getreg) == "function", "getreg is not a function")
end

return Test
