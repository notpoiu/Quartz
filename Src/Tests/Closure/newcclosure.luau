local Test = {}

function Test.Run()
	assert(typeof(newcclosure) == "function", "newcclosure is not a function")
	
	local func = function() end
	local src = debug.info(func, "s")
	assert(src == debug.info(1, "s"), "Lua closure source does not match expected value.")

	local cfunc = newcclosure(func)
	local csrc = debug.info(cfunc, "s")
	assert(csrc == "[C]", "C closure source is supposed to be [C]")

	local cfuncname = newcclosure(func, "tuff")
	assert(debug.info(cfuncname, "n") == "tuff", "C closure name is supposed to be 'tuff'")
	assert(debug.info(cfuncname, "s") == "[C]", "C closure source is supposed to be [C] (#2)")
end

return Test
