local Test = {
    UnsupportedExecutors = { "Xeno" }
}

local CoreGui = cloneref(game:GetService("CoreGui"))
local CorePackages = cloneref(game:GetService("CorePackages"))
local Players = cloneref(game:GetService("Players"))
local LocalPlayer = cloneref(Players.LocalPlayer)

function Test.Run()
    --// Module Filtering \\--
    local GameModuleScripts = {}
    do
        local ModuleScripts = game:QueryDescendants("ModuleScript")
        for _, ModuleScript in next, ModuleScripts do
            if (
                ModuleScript:IsDescendantOf(CoreGui) or
                ModuleScript:IsDescendantOf(CorePackages) or
                ModuleScript.RobloxLocked
            ) then
                continue
            end
    
            table.insert(GameModuleScripts, ModuleScript)
        end

        ModuleScripts = nil

        --// No Compatible Modulescripts Found, we are probably not loaded yet. \\-- 
        if #GameModuleScripts == 0 then
            local PlayerScripts = LocalPlayer:FindFirstChildOfClass("PlayerScripts")
            do
                if not PlayerScripts then
                    repeat task.wait()
                        PlayerScripts = LocalPlayer:FindFirstChildOfClass("PlayerScripts")
                    until PlayerScripts
                end
            end

            table.insert(GameModuleScripts, PlayerScripts:WaitForChild("PlayerModule", 5))
        end
    end

    assert(#GameModuleScripts > 0, "No require-able modulescripts found.")
    local ModuleScript = GameModuleScripts[math.random(1, #GameModuleScripts)]
    
    --// Cleanup \\--
    table.clear(GameModuleScripts)
    GameModuleScripts = nil :: any

    --// Testing \\--
    local Success, Error = xpcall(function()
        require(ModuleScript)
    end, function(err)
        local Lines = string.split(err, "\n")
        local Error = Lines[1] or ": "
        local Tracebacks = string.split(Error, ": ")
        
        return ModuleScript:GetFullName() .. ": " .. Tracebacks[#Tracebacks]
    end)

    assert(Success, Error)
    return ModuleScript:GetFullName()
end

return Test
