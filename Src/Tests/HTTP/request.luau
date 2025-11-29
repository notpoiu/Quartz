local Test = {
	Aliases = { "http_request", "syn.request", "http.request", "fluxus.request", "krnl.request" },
}

local RequestURLPool = {
	"https://httpbingo.org/user-agent",
	"https://httpbin.org/user-agent"
}

local HttpService = cloneref(game:GetService("HttpService")) :: HttpService

function Test.Run()
	assert(typeof(request) == "function", "request is not a function")

	--// get response data \\--
	local response = nil
	for _, url in RequestURLPool do
		response = request({
			Url = url,
			Method = "GET",
		})

		assert(typeof(response) == "table", "invalid response data")
		if response.StatusCode == 200 then break end
	end
	
	assert(response.StatusCode == 200, "failed with status code: " .. tostring(response.StatusCode))

	--// decode data \\--
	local data = HttpService:JSONDecode(response.Body)
	assert(typeof(data) == "table", "error")

	--// useragent \\--
	local userAgent = data["User-Agent"] or data["user-agent"]
	return typeof(userAgent) == "string" and "User-Agent: " .. userAgent or "User-Agent: ???"
end

return Test
