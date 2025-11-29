local Test = {
	Aliases = { "queueonteleport" }
}

function Test.Run()
	assert(typeof(queue_on_teleport) == "function" or typeof(queueonteleport) == "function", "queue_on_teleport/queueonteleport is not a function")
end

return Test
