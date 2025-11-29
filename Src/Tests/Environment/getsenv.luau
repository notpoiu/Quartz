local Test = {}

local LocalPlayer = cloneref(game:GetService("Players").LocalPlayer)

local getrunningscripts = getrunningscripts or function()
	local scripts = {}

	for _, scriptInstance in LocalPlayer:QueryDescendants("Script, LocalScript") do
		if not scriptInstance.Enabled then continue end
		
		if scriptInstance:IsA("Script") and scriptInstance.RunContext ~= Enum.RunContext.Client or false then
			continue
		end
		
		table.insert(scripts, scriptInstance)
	end

	return scripts
end

function Test.Run()
	assert(typeof(getsenv) == "function", "getsenv is not a function")

	local tries = 0
	local env = nil

	for _, targetScript in getrunningscripts() do
		task.wait()
		if tries > 4 then break end

		local success, _env = pcall(getsenv, targetScript)
		
		if success and typeof(_env) == "table" and rawequal(rawget(_env, "script"), targetScript) then
			env = _env
			break
		end

		tries += 1
	end

	assert(typeof(env) == "table", "Failed to get script environment")
	assert(env ~= _G, "Executor and Roblox environment are the same")
	assert(env ~= shared, "Executor and shared environment are the same")
	assert(env ~= getgenv(), "Executor and global environment are the same")
end

return Test
