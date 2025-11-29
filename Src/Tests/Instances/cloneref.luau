local Test = {
	Aliases = { "clonereference" },
}

function Test.Run()
	local cloneref = cloneref or clonereference
	
	assert(typeof(cloneref) == "function", "cloneref/clonereference is not a function")
	assert(cloneref(game) ~= game, "cloneref/clonereference returns the same instance")
end

return Test
