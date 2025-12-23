local Replacement = {}

function Replacement.CreateFunctionPatch(Quartz)
	-- Bypass upvalue issues by wrapping the function
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
