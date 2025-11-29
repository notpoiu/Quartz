local Orchestrator = {
    Replacements = {}
}

--// Map all replacements into Orchestrator.Replacements \\--
for _, Replacement in next, script.Parent:GetDescendants() do
    if Replacement.ClassName ~= "ModuleScript" or Replacement == script then
        continue
    end

    Orchestrator.Replacements[Replacement.Name] = Replacement
    
    --// Support Aliases \\--
    local success, ReplacementModule = pcall(require, Replacement)
    if success and typeof(ReplacementModule) == "table" and typeof(ReplacementModule.Aliases) == "table" then
        for _, alias in next, ReplacementModule.Aliases do
            Orchestrator.Replacements[alias] = Replacement
        end
    end
end

return Orchestrator