local Test = {
    UnsupportedExecutors = { "SirHurt" }
}

function Test.Run()
    assert(typeof(replicatesignal) == "function", "replicatesignal is not a function")

    if firesignal then
        assert(
            replicatesignal ~= firesignal,
            "replicatesignal and firesignal are the same function"
        )
    end
end

return Test
