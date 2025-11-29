local Test = {}

function Test.Run()
	local upvalue1 = function() end
	local upvalue2 = function() end
	local function testFunc()
		print(upvalue1, upvalue2)
	end
	
	local upvalues = debug.getupvalues(testFunc)
	assert(#upvalues == 2, "Unexpected amount of upvalues returned from debug.getupvalues")
end

return Test
