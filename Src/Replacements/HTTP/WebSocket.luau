local Replacement = {}

function Replacement.CreateFunctionPatch(Quartz)
	if not Quartz:Test("setfflag") then
		return nil
	end

	local Success, _ = pcall(setfflag, "FFlagWebSocketServiceEnableClientCreation", "true")
	if not Success then
		return nil
	end

	--// Can get detected via game:FindService("WebSocketService") hence the GetService call INSIDE the WebSocket.connect function. \\--
	local Websocket = {}
	function Websocket.connect(Url: string)
		local WebSocketService = cloneref(game:GetService("WebSocketService"))

		local Client = WebSocketService:CreateClient(Url)
		local CloseEvent = Instance.new("BindableEvent")
		local MessageEvent = Instance.new("BindableEvent")

		local WS = {}

		function WS:Send(Data: string)
			Client:Send(Data)
		end

		function WS:Close()
			Client:Close()
		end

		Client.Closed:Connect(function()
			CloseEvent:Fire()
		end)
		
		Client.MessageReceived:Connect(function(...)
			MessageEvent:Fire(...)
		end)

		setmetatable(WS, {
			__index = function(_, Key)
				if Key == "OnMessage" then
					return MessageEvent.Event
				elseif Key == "OnClose" then
					return CloseEvent.Event
				end

				return rawget(WS, Key)
			end,
		})

		return WS
	end

	return Websocket
end

return Replacement
