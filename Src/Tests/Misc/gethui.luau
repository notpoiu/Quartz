local Test = {}

function Test.Run()
	assert(typeof(gethui) == "function", "gethui is not a function")

	local hui = gethui()
	assert(typeof(hui) == "Instance", "Hidden UI did not return an Instance")
	assert(hui ~= game:GetService("CoreGui"), "Hidden UI is CoreGui")

	local gui = Instance.new("ScreenGui")
	task.delay(1, gui.Destroy, gui)
	gui.Parent = hui
end

return Test
