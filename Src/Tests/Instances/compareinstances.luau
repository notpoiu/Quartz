local Test = {}

function Test.Run()
	assert(typeof(compareinstances) == "function", "compareinstances is not a function")
	assert(typeof(cloneref) == "function", "could not test reliability of compareinstances due to missing cloneref")

	assert(not compareinstances(game, workspace), "compareinstances should return false when comparing different instances")
	assert(compareinstances(game, game), "compareinstances should return true when comparing the same instance")
	
	assert(compareinstances(game, cloneref(game)), "compareinstances should return true when comparing the same instance")
end

return Test
