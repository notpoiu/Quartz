local Orchestrator = {
    Tests = {}
}

--// Modules \\--
local SafeLoader = require(script.Parent.Parent.Utils.SafeLoader)
local Requirer = SafeLoader.new()


--// Map all tests into Orchestrator.Tests \\--
for _, Test in next, script.Parent:GetDescendants() do
    if Test.ClassName ~= "ModuleScript" or Test == script then
        continue
    end

    Orchestrator.Tests[Test.Name] = Test
    
    --// Support Aliases \\--
    local success, TestModule = Requirer:SafeRequire(Test)
    if success and typeof(TestModule) == "table" and typeof(TestModule.Aliases) == "table" then
        for _, alias in next, TestModule.Aliases do
            Orchestrator.Tests[alias] = Test
        end
    end
end

return Orchestrator