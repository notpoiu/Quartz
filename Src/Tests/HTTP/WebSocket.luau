local Test = {}

local ExpectedTypes = {
	Send = "function",
	Close = "function",
	OnMessage = {"table", "userdata", "RBXScriptSignal"},
	OnClose = {"table", "userdata", "RBXScriptSignal"},
}

local HttpService = cloneref(game:GetService("HttpService")) :: HttpService

function Test.Run()
	assert(typeof(WebSocket) == "table", "WebSocket is not a table")
	assert(typeof(WebSocket.connect) == "function", "WebSocket.connect is not a function")

	--// Pasted from UNC \\--
	local ws = WebSocket.connect("wss://echo.websocket.org")
	assert(typeof(ws) ~= "nil", "WebSocket.connect returned nil")
	
	for k, v in next, ExpectedTypes do
		if typeof(v) == "table" then
			assert(table.find(v, typeof(ws[k])), `WebSocket.{k} is not a {table.concat(v, ", ")} (a {typeof(ws[k])})`)
			continue
		end

		assert(typeof(ws[k]) == v, `WebSocket.{k} is not a {v} (a {typeof(ws[k])})`)
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
