local Test = {}

function Test.Run()
	assert(typeof(clonefunction) == "function", "clonefunction is not a function")

	local function testFunc()
		return true
	end

	local cloned = clonefunction(testFunc)
	assert(cloned ~= testFunc, "clonefunction should not return the same function")
	assert(cloned() == true, "clonefunction did not return the same result as the original function")
end

return Test
