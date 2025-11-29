local Replacement = {}

local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local LocalPlayer = cloneref(Players.LocalPlayer)

function Replacement.CreateFunctionPatch(Quartz)
	return function(prompt, lookToPrompt, doNotDoInstant)
		assert(typeof(prompt) == "Instance", `ProximityPrompt expected, got {typeof(prompt)}`)
		assert(prompt:IsA("ProximityPrompt"), `ProximityPrompt expected, got {prompt.ClassName}`)
		
		local PromptPosition = prompt.Parent and (prompt.Parent :: PVInstance):GetPivot().Position or Vector3.zero
		local PromptTriggered = false
		
		local SetCameraCFrameConnection

		local OriginalData = {
			Enabled = prompt.Enabled,
			HoldDuration = prompt.HoldDuration,
			RequiresLineOfSight = prompt.RequiresLineOfSight,
			CurrentCameraCFrame = workspace.CurrentCamera.CFrame,
		}

		--// Use replicatesignal if available \\--
		if Quartz:Test("replicatesignal") then
			task.spawn(function()
				if doNotDoInstant ~= true then
					prompt.HoldDuration = 0
				end

				replicatesignal(prompt.ButtonHoldBeganActionReplicated, LocalPlayer)
				task.wait(prompt.HoldDuration + 0.05)
				replicatesignal(prompt.ButtonHoldEndedActionReplicated, LocalPlayer)
				replicatesignal(prompt.TriggeredActionReplicated, LocalPlayer)
				replicatesignal(prompt.TriggerEndedActionReplicated, LocalPlayer)

				prompt.HoldDuration = OriginalData.HoldDuration
			end)
			return
		end

		local CurrentCamera = cloneref(workspace.CurrentCamera)

		--// Triggered Connection \\--
		prompt.Triggered:Once(function()
			PromptTriggered = true
		end)

		--// Prompt Setup \\--
		prompt.Enabled = true
		prompt.RequiresLineOfSight = false
		if doNotDoInstant ~= true then
			prompt.HoldDuration = 0
		end

		if lookToPrompt == true then
			SetCameraCFrameConnection = RunService.RenderStepped:Connect(function()
				CurrentCamera.CFrame = CFrame.new(
					CurrentCamera.CFrame.Position,
					PromptPosition
				)
			end)

			task.wait()
		end
		
		--// Input Events \--
		prompt:InputHoldEnd()
		prompt:InputHoldBegin()
		
		task.wait(prompt.HoldDuration + 0.05)

		prompt:InputHoldEnd()

		--// Cleanup \\--
		if SetCameraCFrameConnection then
			repeat
				task.wait()
			until PromptTriggered
			SetCameraCFrameConnection:Disconnect()
		end

		prompt.Enabled = OriginalData.Enabled
		prompt.HoldDuration = OriginalData.HoldDuration
		prompt.RequiresLineOfSight = OriginalData.RequiresLineOfSight
		
		if lookToPrompt == true then
			CurrentCamera.CFrame = OriginalData.CurrentCameraCFrame
		end
	end
end

return Replacement
