local Test = {}

function Test.Run()
	local function upvalue()
		return "fail"
	end
	
	local function testFunc()
		return upvalue()
	end
	
	debug.setupvalue(testFunc, 1, function()
		return "success"
	end)
	
	assert(testFunc() == "success", "debug.setupvalue did not set the first upvalue")
end

return Test
