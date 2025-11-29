local Test = {}

function Test.Run()
	assert(typeof(checkcaller) == "function", "checkcaller is not a function")
	assert(checkcaller(), "checkcaller did not return true when it was invoked from an executor thread.")
end

return Test
