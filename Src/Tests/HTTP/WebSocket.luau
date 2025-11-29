local Test = {}

local ExpectedKeys = {
	"Send",
	"Close",
	"OnMessage",
	"OnClose",
}

local HttpService = cloneref(game:GetService("HttpService")) :: HttpService

function Test.Run()
	assert(typeof(WebSocket) == "table", "WebSocket is not a table")
	assert(typeof(WebSocket.connect) == "function", "WebSocket.connect is not a function")

	--// Pasted from UNC \\--
	local ws = WebSocket.connect("wss://echo.websocket.org")
	assert(typeof(ws) ~= "nil", "WebSocket.connect returned nil")
	
	for _, k in next, ExpectedKeys do
		assert(typeof(ws[k]) ~= "nil", `WebSocket.{k} is missing`)
	end

	--// Real testing \\--
	local ExpectedMessage = HttpService:GenerateGUID(false)
	local ReceivedMessage = nil
	ws.OnMessage:Connect(function(message) ReceivedMessage = message end)

	repeat task.wait(0.1)
		ws:Send(ExpectedMessage)
	until ReceivedMessage ~= nil and not ReceivedMessage:match("Request served by")

	ws:Close()
	assert(ReceivedMessage == ExpectedMessage, `Did not receive the expected message, expected "{ExpectedMessage}" but received "{ReceivedMessage}"`)
end

return Test
