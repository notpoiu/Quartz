local Test = {}

function Test.Run()
	assert(typeof(getfflag) == "function", "getfflag is not a function")
end

return Test