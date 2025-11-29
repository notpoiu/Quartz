local Test = {}

function Test.Run()
	assert(typeof(hookfunction) == "function", "hookfunction is not a function")

	local function testFunc()
		return true
	end
	
	local ref = hookfunction(testFunc, function()
		return false
	end)

	assert(testFunc() == false, "Function should return false")
	assert(ref() == true, "Original function should return true")
	assert(testFunc ~= ref, "Original function should not be same as the reference")
end

return Test
