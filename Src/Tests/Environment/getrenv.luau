local Test = {
	UnsupportedExecutors = { "Solara" }
}

function Test.Run()
	assert(typeof(getrenv) == "function", "getrenv is not a function")
	assert(typeof(getrenv()._G) == "table", "Failed to get roblox environment")
	assert(getrenv()._G ~= _G, "Executor and Roblox environment are the same")
end

return Test
