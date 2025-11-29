local Test = {
	Aliases = { "get_signal_cons" },
	UnsupportedExecutors = { "Solara" }
}

function Test.Run()
	assert(typeof(getconnections) == "function" or typeof(get_signal_cons) == "function", "getconnections/get_signal_cons is not a function")
end

return Test
