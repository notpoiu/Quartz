local Replacement = {}

function Replacement.CreateFunctionPatch(Quartz)
    if not Quartz:Test("getscriptbytecode") then
        return nil
    end

    --// Loadstring method \\--
    local LoadstringRequire
    do
        local decompile = Quartz:GetFunction("decompile")

        local CreateSafeEnvironement
        do
            local SafeEnvironement = {}
            local ExecutorSpecificKeys = {}

            --// Get Executor Environement \\--
            local getrawmetatable = Quartz:GetFunction("getrawmetatable") or getmetatable
            local getgenv = Quartz:GetFunction("getgenv") or getfenv
            local getrenv = Quartz:GetFunction("getrenv") or getfenv
    
            local ExecutorEnvironement = (
                getrawmetatable(getgenv()) and
                getrawmetatable(getgenv()).__index or
                getgenv()
            )
            local RobloxEnvironement = (
                getrawmetatable(getrenv()) and
                getrawmetatable(getrenv()).__index or
                getrenv()
            )
            
            for key in next, ExecutorEnvironement do
                local ExistsInRobloxEnv = RobloxEnvironement[key]
                if ExistsInRobloxEnv then
                    continue
                end
                
                ExecutorSpecificKeys[key] = true
            end

            --// Create Safe Environement \\--
            SafeEnvironement = {
                require = function(module) return LoadstringRequire(module) end,
            }
            
            for key in next, ExecutorSpecificKeys do
                SafeEnvironement[key] = nil
            end

            CreateSafeEnvironement = function(module, callback)
                local NewEnvironement = {}
                for key, value in next, SafeEnvironement do
                    NewEnvironement[key] = value
                end

                --// Add module specific values \\--
                NewEnvironement.script = module

                --// Sanitize Old Environement \\--
                local OldEnvironement = getfenv(callback)
                local RawOldEnvironement = (
                    getrawmetatable(OldEnvironement) and
                    getrawmetatable(OldEnvironement).__index or
                    OldEnvironement
                )

                local SanitizedOldEnvironement = {}
                for key in next, RawOldEnvironement do
                    if ExecutorSpecificKeys[key] then
                        continue
                    end
                    
                    SanitizedOldEnvironement[key] = RawOldEnvironement[key]
                end
                
                return setmetatable(NewEnvironement, { __index = SanitizedOldEnvironement }) :: any
            end
        end

        LoadstringRequire = function(module)
            local Source = decompile(module)

            local Callback = loadstring(Source)
            assert(typeof(Callback) == "function", "Failed to load module, decompiled source was invalid.")
            
            --// Create proxy to require \\--
            setfenv(Callback, CreateSafeEnvironement(module, Callback))
            
            --// Get Output \\--
            return Callback()
        end
    end

    --// debug.loadmodule method \\--
    if Quartz:Test("setfflag") then
		local Success = false
        for _, value in { "true", true, 1 } do
		    Success, _ = pcall(setfflag, "WebSocketServiceEnableClientCreation", value)
		
		    if Success then
		        break
		    end
		end
		
        if not Success then
            return LoadstringRequire
        end

        local debug = getrenv and getrenv().debug or debug
        return function(module)
            local Result = table.pack(pcall(debug.loadmodule(module)))
            
            if not Result[1] then
                return LoadstringRequire(module)
            end
            
            return table.unpack(Result, 2, Result.n)
        end
	end

    return LoadstringRequire
end

return Replacement
