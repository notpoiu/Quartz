local Test = {}

function Test.Run()
	local upvalue = function() end
	local function testFunc()
		print(upvalue)
	end

	assert(debug.getupvalue(testFunc, 1) == upvalue, "Unexpected value returned from debug.getupvalue")
end

return Test
