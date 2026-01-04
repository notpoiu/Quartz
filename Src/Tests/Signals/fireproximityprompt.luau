local Test = {}

function Test.Run()
	assert(typeof(fireproximityprompt) == "function", "fireproximityprompt is not a function")

	local part = Instance.new("Part", workspace)
	local prompt = Instance.new("ProximityPrompt", part)
	local triggered = false

	prompt.Triggered:Once(function()
		triggered = true

		part:Destroy()
		prompt:Destroy()
		part = nil
		prompt = nil
	end)
	
	task.delay(0.11, function()
		if prompt then
			prompt.Enabled = false
			prompt.MaxActivationDistance = 0
			prompt:Destroy()
			prompt = nil
		end

		if part then
			part:Destroy()
			part = nil
		end
	end)

	fireproximityprompt(prompt)
	task.wait(0.1)

	assert(triggered, "Failed to fire proximity prompt")
end

return Test
