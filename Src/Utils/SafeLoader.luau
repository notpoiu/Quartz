local SafeLoader = {}
SafeLoader.__index = SafeLoader

local DefaultModuleEnvironement = {
    cloneref = clonereference or cloneref or function(x) return x end,
}

function SafeLoader.new(env)
    return setmetatable({
        Environment = env or DefaultModuleEnvironement
    }, SafeLoader)
end

function SafeLoader:SafeRequire(module: ModuleScript)
    local oldenv = getfenv()
    setfenv(0, setmetatable(self.Environment, { __index = oldenv }) :: any)
    local Result = table.pack(pcall(require, module))
    setfenv(0, oldenv)
    return table.unpack(Result, 1, Result.n)
end

return SafeLoader