local Replacement = {
    Aliases = { "clonereference" },
}

function Replacement.CreateFunctionPatch(Quartz)
	return function(x) return x end
end

return Replacement
