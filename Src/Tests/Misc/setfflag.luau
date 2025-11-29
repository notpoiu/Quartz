local Test = {}

function Test.Run()
	assert(typeof(setfflag) == "function", "setfflag is not a function")
end

return Test