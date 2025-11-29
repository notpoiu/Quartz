local Test = {}

function Test.Run()
	assert(typeof(fireproximityprompt) == "function", "fireproximityprompt is not a function")

	local part = Instance.new("Part", workspace)
	local prompt = Instance.new("ProximityPrompt", part)
	local triggered = false

	prompt.Triggered:Once(function()
		triggered = true

		part:Destroy()
		part = nil
	end)
	
	task.delay(0.11, function()
		if not part then return end

		prompt.Enabled = false
		prompt.MaxActivationDistance = 0

		part:Destroy()
	end)

	fireproximityprompt(prompt)
	task.wait(0.1)

	assert(triggered, "Failed to fire proximity prompt")
end

return Test
