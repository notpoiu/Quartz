local Test = {
	Aliases = { "firetouchtransmitter" },
	UnsupportedExecutors = { "Xeno" }
}

function Test.Run()
	assert(typeof(firetouchinterest) == "function" or typeof(firetouchtransmitter) == "function", "firetouchinterest/firetouchtransmitter is not a function")
end

return Test
