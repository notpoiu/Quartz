local Replacement = {}

function Replacement.CreateFunctionPatch(Quartz)
	if not Quartz:Test("getconnections") then
		return nil
	end

	return function(event, ...)
		assert(typeof(event) == "RBXScriptSignal", "Invalid argument #1 to 'firesignal' (RBXScriptSignal expected)")
		
		for _, connection in next, getconnections(event) do
			connection:Fire(...)
		end
	end
end

return Replacement
