local Replacement = {}

function Replacement.CreateFunctionPatch(Quartz)
    if not Quartz:Test("getscriptbytecode") then
        return nil
    end

    --// Loadstring method \\--
    local LoadstringRequire
    do
        local decompile = Quartz:GetFunction("decompile")

        LoadstringRequire = function(module)
            local Source = decompile(module)

            local Callback = loadstring(Source)
            assert(typeof(Callback) == "function", "Failed to load module, decompiled source was invalid.")
            
            --// Create proxy to require \\--
            setfenv(Callback, setmetatable({
                require = function(module) return LoadstringRequire(module) end,
            }, { __index = getfenv(Callback) }) :: any)
            
            --// Get Output \\--
            return Callback()
        end
    end

    --// debug.loadmodule method \\--
    if Quartz:Test("setfflag") then
		local Success, _ = pcall(setfflag, "EnableLoadModule", "true")
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
