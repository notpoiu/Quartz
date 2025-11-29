local Test = {}

function Test.Run()
	assert(typeof(getrunningscripts) == "function", "getrunningscripts is not a function")
	assert(typeof(getrunningscripts()) == "table", "getrunningscripts does not return a table")
end

return Test
