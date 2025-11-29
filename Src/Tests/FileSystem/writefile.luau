local Test = {}

function Test.Run()
	assert(typeof(writefile) == "function", "writefile is not a function")
end

return Test
