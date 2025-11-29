local Test = {}

function Test.Run()
	assert(typeof(hookfunction) == "function", "This test requires hookfunction")
	assert(typeof(isfunctionhooked) == "function", "isfunctionhooked is not a function")

	local function testFunc()
		return true
	end

	assert(testFunc() == true, "Function should return true; not hooked")
	assert(isfunctionhooked(testFunc) == false, "isfunctionhooked should return false; the function is not hooked")

	local ref = hookfunction(testFunc, function()
		return false
	end)

	assert(testFunc() == false, "Function should return false; is hooked")
	assert(ref() == true, "Original function should return true")
	assert(testFunc ~= ref, "Original function should not be same as the reference")
	assert(isfunctionhooked(testFunc) == true, "isfunctionhooked should return true; the function is hooked")
end

return Test
