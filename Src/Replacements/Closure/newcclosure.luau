local Replacement = {}

function Replacement.CreateFunctionPatch(Quartz)
	-- Can't do anything much except wrap the function to remove upvalues.
	-- Doing coroutine.wrap, while it shows up as a C function, can break the functionality.
	return function(f)
		local env = getfenv(f)
		local x = setmetatable({
			__F = f,
		}, {
			__index = env,
			__newindex = env,
		})

		local nf = function(...)
			return __F(...)
		end

		setfenv(nf, x) -- set func env (env of nf gets deoptimized)
		return nf
	end
end

return Replacement
