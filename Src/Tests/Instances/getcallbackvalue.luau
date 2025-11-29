local Test = {}

function Test.Run()
	assert(typeof(getcallbackvalue) == "function", "getcallbackvalue is not a function")

	local bindable = Instance.new("BindableFunction")
	local InvokeFunction = function(value)
		return value * 2
	end
	bindable.OnInvoke = InvokeFunction

	local FetchedInvoke = getcallbackvalue(bindable, "OnInvoke")
	bindable:Destroy()

	assert(typeof(FetchedInvoke) == "function", "getcallbackvalue did not return a function")
	assert(FetchedInvoke == InvokeFunction, "getcallbackvalue did not return the original function")

	assert(FetchedInvoke(5) == 10, "getcallbackvalue's function return did not match expected value")

	local remoteFunction = Instance.new("RemoteFunction")
	local success, didNoValueReturnNil = pcall(function()
		return getcallbackvalue(remoteFunction, "OnClientInvoke") == nil
	end)

	remoteFunction:Destroy()
	assert(success == true and didNoValueReturnNil == true, "getcallbackvalue raised an error instead of returning nil, the function is not supposed to raise an error when there is no callback")
end

return Test
