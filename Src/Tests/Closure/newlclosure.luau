local Test = {}

function Test.Run()
	assert(typeof(newlclosure) == "function", "newlclosure is not a function")
	
	local func = function() end
	local src = debug.info(func, "s")
	assert(src == debug.info(1, "s"), "Lua closure source does not match expected value.")

	local cfunc = newlclosure(func)
	local csrc = debug.info(cfunc, "s")
	assert(csrc ~= "[C]", "newlclosure source is not supposed to be [C]")
end

return Test
