local Test = {}

function Test.Run()
	assert(typeof(fireclickdetector) == "function", "fireclickdetector is not a function")
	
	local part = Instance.new("Part", workspace)
	local click = Instance.new("ClickDetector", part)
	local triggered = false

	click.MouseClick:Once(function()
		triggered = true

		part:Destroy()
		part = nil
	end)

	task.delay(0.11, function()
		if not part then return end
		part:Destroy()
	end)

	fireclickdetector(click)
	task.wait(0.1)

	assert(triggered, "Failed to fire click detector")
end

return Test
