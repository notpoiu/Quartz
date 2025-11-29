# Quartz

Quartz is a comprehensive testing and polyfill framework designed for Roblox Executors. It acts as a compatibility layer for different executors, ensuring your scripts can run smoothly across different executors.

> [!IMPORTANT]
> Some tests may not fully test the functionality due to limitations of being compatible in all games and the need to not be performance heavy.

## Features

- **Testing**: Validates the functionality of executor specific functions as well as some non-executor functions (e.g. `require`).
- **Environment Patching**: Can create polyfills for missing functions or aliases, ensuring your scripts run smoothly across different executors.
- **Detailed Reporting**: Can print a summary of the results of the tests.

### Usage

To check which functions are supported by your current executor:

```lua
-- https://discord.gg/FJcJMuze7S
local Quartz = loadstring(game:HttpGetAsync("https://github.com/notpoiu/Quartz/releases/latest/download/Quartz.luau"))()

local Tester = Quartz.new({
    Timeout = 5
})

-- Run specific tests
-- local RequireResult = Tester:Test("require") -- boolean
-- local Results = Tester:Test({ "require", "cloneref", "getrawmetatable" }) -- { [string]: boolean }
local Results = Tester:TestAll()

-- Print a summary of results
Tester:PrintResults()

-- Example use case
local PlayerModule
if Results["require"] then
    PlayerModule = require(game:GetService("Players").LocalPlayer.PlayerScripts.PlayerModule)
end
```

### Polyfilling the Environment

To automatically fix missing or broken functions in your environment:

```lua
-- https://discord.gg/FJcJMuze7S
local Quartz = loadstring(game:HttpGetAsync("https://github.com/notpoiu/Quartz/releases/latest/download/Quartz.luau"))()

-- Default timeout is 15 seconds
local Tester = Quartz.new()

-- Run tests to see what's missing
Tester:TestAll()

-- Print a summary of results with a custom callback
Tester:PrintResults(function(testIdx: number, name: string, passed: boolean, message: string)
    print(testIdx, name, passed, message)
end)

-- Patch the current environment with available replacements
Tester:PatchEnvironment()

-- Alternatively:
-- Use Tester:GetFunction. It will return the existing function if it works, or a replacement if it doesn't.
local require = Tester:GetFunction("require")
```

### Misc

```lua
print(Tester:GetExecutorName(), Tester:SupportsFileSystem() and "Supports FileSystem" or "Doesn't support FileSystem")

-- Get all available patches
local Pollyfills = Tester:GetAvailablePatches()

for _, name in next, Pollyfills do
    print("Replacement for " .. name .. " is available")
end

-- Clear the cache
Tester:ClearCache()

-- Get results
local Results = Tester:GetResults()

for func, result in next, Results do
    print(func, result)
end

-- Get errors messages
local Errors = Tester:GetErrors()

for func, error in next, Errors do
    print(func, error)
end

-- Get successes messages
local Successes = Tester:GetSuccesses()

for func, success in next, Successes do
    print(func, success)
end

-- patch environement of specific callback
local env = getfenv()
local test = function()
    print(getfenv() == env and "i am not in a patched environement" or "i am in a patched environement")
end

test()

-- Only patch "fireproximityprompt" if broken in test or add fireproximityprompt aliases
Tester:PatchEnvironment(test, { "fireproximityprompt" })

test()

```

## Prerequisites

To enhance your work environment, I recommend installing all the recommended [extensions](.vscode/extensions.json).

## Bundling

To bundle all the scripts, you have to follow these steps:

1. Install [rokit](https://github.com/rojo-rbx/rokit) if you haven't already
2. Open Powershell or the command-line shell of your liking and [cd to this repository](https://www.quora.com/What-does-it-mean-to-CD-into-a-directory-and-how-can-I-do-that-Can-someone-explain-it-in-a-laymans-term)
3. Run `rokit install` and wait for it to install all the dependencies
4. In VSCode, press CTRL + SHIFT + B to build or run this command `lune run Build bundle header=Build/Header.luau`

You can find the bundled script in `/Distribution/Script.luau`.
