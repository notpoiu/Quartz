local Test = {}

function Test.Run()
	local func = function() end
	local src = debug.info(func, "s")
	assert(src == debug.info(1, "s"), "Lua closure source does not math expected value.")

	local cfunc = newcclosure(func)
	local csrc = debug.info(cfunc, "s")
	assert(csrc == "[C]", "C closure source is supposed to be [C]")
end

return Test
