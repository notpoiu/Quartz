local Test = {}

function Test.Run()
	assert(typeof(firesignal) == "function", "firesignal is not a function")

	local event = Instance.new("BindableEvent")
	local fired = false

	event.Event:Once(function(value)
		fired = value

		event:Destroy()
		event = nil
	end)
	
	task.delay(0.11, function()
		if not event then return end
		event:Destroy()
	end)

	firesignal(event.Event, true)
	task.wait(0.1)

	assert(fired, "Failed to fire a BindableEvent")
end

return Test
