--// Modules \\--
local ReplacementOrchestrator = require(script.Replacements.Orchestrator)
local TestOrchestrator = require(script.Tests.Orchestrator)

local PathResolver = require(script.Utils.PathResolver)
local Levenshtein = require(script.Utils.Levenshtein)
local SafeLoader = require(script.Utils.SafeLoader)
local Validate = require(script.Utils.Validator)

local Requirer = SafeLoader.new()

--// Constants \\--
local ExecutorName, ExecutorVersion
do
    local Success, _ = pcall(function()
        local identifyexec = typeof(identifyexecutor) == "function" and identifyexecutor or function() return "Unknown", "0.0.0.0" end
        ExecutorName, ExecutorVersion = identifyexec()
    end)

    if not Success then
        ExecutorName, ExecutorVersion = "Unknown", "0.0.0.0"
    end
end

--// Module \\--
local Quartz = {}
Quartz.__index = Quartz

--// Types \\--
type Options = {
	Timeout: number?
}

type CustomResultProcessor = (
	testIdx: number,
	name: string,
	passed: boolean,
	message: string
) -> ()

--// Validator Templates \\--
local Template = {
	Timeout = 15
}

function Quartz.new(options: Options)
	options = Validate(options, Template)

    return setmetatable({
        TestResultCache = {},
        TestErrorMessageCache = {},
        TestSuccessMessageCache = {},
        Timeout = options.Timeout
    }, Quartz)
end

--// Testing \\--
function Quartz:_InternalTest(func: string)
	if self.TestResultCache[func] ~= nil then
		return self.TestResultCache[func]
	end

	--// Get Module \\--
	local TestModuleInst = TestOrchestrator.Tests[func]
	do
		if not TestModuleInst then
			local ClosestMatch = Levenshtein.GetClosestMatch(func, TestOrchestrator.Tests, 3)
			if ClosestMatch then error(`The test for the function {func} does not exist. Did you mean '{ClosestMatch}'?`, 2) end
	
			error(`The test for the function {func} does not exist.`, 2)
		end
	end

	local ModuleSuccess, TestModule = Requirer:SafeRequire(TestModuleInst)
	assert(ModuleSuccess, `Had issue while loading test {TestModuleInst.Name} ({TestModule})`)
	assert(typeof(TestModule) == "table", `Expected the return of {TestModuleInst:GetFullName()} to be a table, got {typeof(TestModule)}`)
	assert(typeof(TestModule.Run) == "function", `Expected the table returned by {TestModuleInst:GetFullName()} to have a 'Run' function, got {typeof(TestModule.Run)}`)

	--// Collect all names for this test (primary + aliases) \\--
	local AllNames = { func }
    do
		if not table.find(AllNames, TestModuleInst.Name) then
			table.insert(AllNames, TestModuleInst.Name)
		end

        for _, alias in next, TestModule.Aliases or {} do
            if table.find(AllNames, alias) then
                continue
            end

            table.insert(AllNames, alias)
        end
    end

	--// Test Hard Coded Conditions \\--
	if (
		typeof(TestModule.UnsupportedExecutors) == "table" and
		table.find(TestModule.UnsupportedExecutors, ExecutorName)
	) then
        for _, name in next, AllNames do
			self.TestErrorMessageCache[name] = "This function doesn't work on this executor."
			self.TestResultCache[name] = false
		end

		return false
	end

	--// Dynamically Test \\--
	local Success, Result = false, nil
	local DidTestFinish = false

	local TestThread = task.spawn(function()
		Success, Result = pcall(TestModule.Run)
		DidTestFinish = true
	end)

	--// Test Timeout \\--
	local start = tick()
	repeat task.wait() until DidTestFinish or tick() - start > self.Timeout

	if not DidTestFinish then
		pcall(task.cancel, TestThread)
		Result = "Test timed out."
	end

	--// Register Results under all aliases \\--
	if Success then
		for _, name in AllNames do
			self.TestResultCache[name] = true

			if typeof(Result) ~= "string" then
                continue
			end
            
            self.TestSuccessMessageCache[name] = Result
		end
	else
		for _, name in AllNames do
			self.TestResultCache[name] = false
			self.TestErrorMessageCache[name] = Result
		end
	end

	return self.TestResultCache[func]
end

function Quartz:Test(funcs: { string } | string)
    if typeof(funcs) == "string" then
        return self:_InternalTest(funcs)
    end

    local Results = {}
    for _, func in next, funcs do
        Results[func] = self:_InternalTest(func)
    end

    return Results
end

function Quartz:TestAll()
	local Results = {}
	local TestedModules = {}
	
	for func, testModule in next, TestOrchestrator.Tests do
		if TestedModules[testModule] then
			Results[func] = self.TestResultCache[func]
			continue
		end
		
		TestedModules[testModule] = true
		Results[func] = self:_InternalTest(func)
	end

	return Results
end

function Quartz:TestAllExcluding(excluded: { string } | string)
    if typeof(excluded) == "string" then
        excluded = { excluded }
    end

	local Results = {}
	local TestedModules = {}
	local ExcludedModules = {}

	--// Resolve Excluded Modules \\--
	for _, name in next, excluded do
		local testModule = TestOrchestrator.Tests[name]
		if testModule then
			ExcludedModules[testModule] = true
		end
	end
	
	for func, testModule in next, TestOrchestrator.Tests do
		if ExcludedModules[testModule] then
			continue
		end

		if TestedModules[testModule] then
			Results[func] = self.TestResultCache[func]
			continue
		end
		
		TestedModules[testModule] = true
		Results[func] = self:_InternalTest(func)
	end

	return Results
end

--// Getters & Setters \\--
function Quartz:ClearCache()
    self.TestResultCache = {}
	self.TestErrorMessageCache = {}
	self.TestSuccessMessageCache = {}
end

function Quartz:GetResults()
    return self.TestResultCache
end

function Quartz:GetErrors()
    return self.TestErrorMessageCache
end

function Quartz:GetSuccesses()
    return self.TestSuccessMessageCache
end

--// Output \\--
function Quartz.FormatResult(func: string, success: boolean, errorMessage: any)
    return string.format(
        "%s [%s]%s",
        success and "✅" or "❌",
        func,
        errorMessage and (": " .. tostring(errorMessage)) or ""
	)
end

function Quartz:PrintResults(callback: CustomResultProcessor?)
	local SuccessCount, TotalCount = 0, 0
	local PrintedModules = {}
	
	for func, result in next, self.TestResultCache do
		local testModule = TestOrchestrator.Tests[func]
		
		if PrintedModules[testModule] then
			continue
		end
		PrintedModules[testModule] = true
		
		local displayName = testModule.Name
		local message = self.TestSuccessMessageCache[displayName] or self.TestErrorMessageCache[displayName]
		if callback then
			callback(TotalCount, displayName, result, message)
		else
			print(Quartz.FormatResult(displayName, result, message))
		end

		TotalCount += 1
		if result then
			SuccessCount += 1
		end
	end

	if not callback then
		print("🛠️ Total working:", tostring(SuccessCount) .. "/" .. tostring(TotalCount))
	end
end

--// Replacement \\--
function Quartz:GetAvailablePatches()
    local Replacements = {}
    for func, _ in next, ReplacementOrchestrator.Replacements do
        table.insert(Replacements, func)
    end

    return Replacements
end

function Quartz:PatchEnvironment(funcOrLevel: number? | ((...any) -> ...any)?, functionsToReplace: { [string]: any }?)
	assert(typeof(funcOrLevel) == "number" or typeof(funcOrLevel) == "function", "Expected funcOrLevel to be a number or function, got " .. typeof(funcOrLevel))
	assert(typeof(functionsToReplace) == "table" or functionsToReplace == nil, "Expected functionsToReplace to be a table, got " .. typeof(functionsToReplace))

	local Level = funcOrLevel or 2
	local Env = getfenv(Level)
	local ReplacementsToUse = {}
	
    --// Auto-create Aliases for Existing Functions \\--
	for funcName, _ in next, (functionsToReplace or TestOrchestrator.Tests) do
        local testModuleInst = TestOrchestrator.Tests[funcName]
        if not testModuleInst then
            continue
        end

		local success, module = Requirer:SafeRequire(testModuleInst)

		if not success or typeof(module) ~= "table" or typeof(module.Aliases) ~= "table" then
            continue
        end
   
        --// Check if the function exists in environment \\--
        local ContendingFunctionNames = { funcName }
        do
            for _, alias in next, module.Aliases do
                table.insert(ContendingFunctionNames, alias)
            end
        end

        local PrimaryFunction
        do
            for _, funcName in next, ContendingFunctionNames do
                if Env[funcName] == nil then
                    continue
                end

                PrimaryFunction = PathResolver.ResolvePath(Env, funcName)
                break
            end
        end

        --// Add to replacements \\--
        if not PrimaryFunction then
            continue
        end

        for _, alias in next, module.Aliases do
			PathResolver.InsertDataInPath({
				BaseTable = Env,
				OverrideTable = ReplacementsToUse,
				Data = PrimaryFunction,
				Path = alias
			})
        end
	end

	--// Add Replacements \\--
	for func, err in next, (functionsToReplace or self.TestErrorMessageCache) do
		if not ReplacementOrchestrator.Replacements[func] then
			continue
		end

		local ReplacementModuleInst = ReplacementOrchestrator.Replacements[func]
		local Success, ReplacementModule = Requirer:SafeRequire(ReplacementModuleInst)

		assert(Success, `Had issue while loading replacement {ReplacementModuleInst.Name} ({ReplacementModule})`)
		assert(typeof(ReplacementModule) == "table", `Expected the return of {ReplacementModuleInst:GetFullName()} to be a table, got {typeof(ReplacementModule)}`)
		assert(typeof(ReplacementModule.CreateFunctionPatch) == "function", `Expected the table returned by {ReplacementModuleInst:GetFullName()} to have a 'Patch' function, got {typeof(ReplacementModule.CreateFunctionPatch)}`)

		local patch = ReplacementModule.CreateFunctionPatch(self)
		PathResolver.InsertDataInPath({
			BaseTable = Env,
			OverrideTable = ReplacementsToUse,
			Data = patch,
			Path = func
		})

		--// Add Aliases \\--
		if typeof(ReplacementModule.Aliases) ~= "table" then
            continue
		end
        
        for _, alias in next, ReplacementModule.Aliases do
            PathResolver.InsertDataInPath({
                BaseTable = Env,
                OverrideTable = ReplacementsToUse,
                Data = patch,
                Path = alias
            })
        end
	end
	
	setfenv(Level, setmetatable(ReplacementsToUse, { __index = Env }) :: any)

	return ReplacementsToUse
end

function Quartz:GetFunction(func: string)
    if not TestOrchestrator.Tests[func] or self:Test(func) then
        return PathResolver.ResolvePath(getfenv(), func)
    end
    
    return self:GetReplacementFunction(func)
end

function Quartz:GetReplacementFunction(func: string)
    local ReplacementInst = ReplacementOrchestrator.Replacements[func]
    if not ReplacementInst then
        return PathResolver.ResolvePath(getfenv(), func)
    end

    local Success, ReplacementModule = Requirer:SafeRequire(ReplacementInst)
	
    assert(Success, `Had issue while loading replacement {ReplacementInst.Name} ({ReplacementModule})`)
    assert(typeof(ReplacementModule) == "table", `Expected the return of {ReplacementInst:GetFullName()} to be a table, got {typeof(ReplacementModule)}`)
    assert(typeof(ReplacementModule.CreateFunctionPatch) == "function", `Expected the table returned by {ReplacementInst:GetFullName()} to have a 'Patch' function, got {typeof(ReplacementModule.CreateFunctionPatch)}`)
    
    return ReplacementModule.CreateFunctionPatch(self)
end

--// Helper Methods \\--
function Quartz:GetExecutorName()
	return ExecutorName
end

function Quartz:GetExecutorVersion()
	return ExecutorVersion
end

function Quartz:SupportsFileSystem()
	for _, func in script.Tests.FileSystem:GetChildren() do
		if (
            self.TestResultCache[func.Name] or
            (self.TestResultCache[func.Name] == nil and self:Test(func.Name))
        ) then
            continue
        end
        
        return false
	end
    
	return true
end

return Quartz