local Replacement = {
	Aliases = { "firetouchtransmitter" }
}

function Replacement.CreateFunctionPatch(Quartz)
	local InteractingCoroutine = {}
	
	return function(initialPart, toTouch, state)
		for idx, part in {initialPart, toTouch} do
			assert(typeof(part) == "Instance", "Invalid argument #" .. idx .. " to 'firetouchinterest' (Instance expected)")
			assert(part:IsA("BasePart"), "Invalid argument #" .. idx .. " to 'firetouchinterest' (BasePart expected)")
			assert(part:IsDescendantOf(workspace), "Invalid argument #" .. idx .. " to 'firetouchinterest' (Descendant of workspace expected)")
		end

		assert(typeof(state) == "number" or typeof(state) == "boolean", "Invalid argument #3 to 'firetouchinterest' (number or boolean expected)")

		local ShouldTriggerTouchState = (state == 0 or state == true)
		local SuccessfullyTriggeredEvent = false
		do
			local Connection
			if ShouldTriggerTouchState then
				Connection = initialPart.Touched
			else
				Connection = initialPart.TouchEnded
			end

			Connection:Once(function()
				SuccessfullyTriggeredEvent = true
			end)
		end

		if ShouldTriggerTouchState then
			local DataIdx = #InteractingCoroutine + 1

			local oldPosition = initialPart.CFrame
			local oldCanCollide = initialPart.CanCollide

			local touchThread = coroutine.create(function()
				initialPart.CFrame = toTouch.CFrame
				initialPart.CanCollide = false

				task.wait()
				local posConnection = initialPart:GetPropertyChangedSignal("CFrame"):Connect(function()
					if initialPart.CFrame ~= toTouch.CFrame then
						InteractingCoroutine[DataIdx]["initial"]["pos"] = oldPosition
					end

					initialPart.CFrame = toTouch.CFrame
				end)

				local collideConnection = initialPart:GetPropertyChangedSignal("CanCollide"):Connect(function()
					InteractingCoroutine[DataIdx]["initial"]["collide"] = oldCanCollide

					initialPart.CanCollide = false
				end)

				table.insert(InteractingCoroutine[DataIdx]["cleanup"], posConnection)
				table.insert(InteractingCoroutine[DataIdx]["cleanup"], collideConnection)
				
				repeat
					task.wait()
				until SuccessfullyTriggeredEvent or not initialPart:IsDescendantOf(workspace)

				if collideConnection then
					collideConnection:Disconnect()
				end
				if posConnection then
					posConnection:Disconnect()
				end

				initialPart.CFrame = InteractingCoroutine[DataIdx]["initial"]["pos"]
				initialPart.CanCollide = InteractingCoroutine[DataIdx]["initial"]["collide"]
				InteractingCoroutine[DataIdx] = nil
			end)

			InteractingCoroutine[DataIdx] = {
				["initialPart"] = initialPart,
				["toTouch"] = toTouch,
				["initial"] = {
					["pos"] = oldPosition,
					["collide"] = oldCanCollide,
				},
				["cleanup"] = {},
				["thread"] = touchThread,
			}

			coroutine.resume(touchThread)
		else
			local targetCoroutineData = nil
			for _, coroutineData in InteractingCoroutine do
				if
					coroutineData.initialPart == initialPart
					and coroutineData.toTouch == toTouch
					and coroutine.status(coroutineData.thread) ~= "dead"
				then
					targetCoroutineData = coroutineData
					break
				end
			end

			if targetCoroutineData then
				coroutine.close(targetCoroutineData.thread)

				for _, connection in targetCoroutineData.cleanup do
					if not connection.Connected then
						continue
					end

					connection:Disconnect()
				end

				initialPart.CFrame = targetCoroutineData["initial"]["pos"]
				initialPart.CanCollide = targetCoroutineData["initial"]["collide"]
			end
		end
	end
end

return Replacement
