--!nocheck
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local NPCTypes = require(ReplicatedStorage.Shared.Types.NPCTypes)

local IsServer = RunService:IsServer()
local IsClient = RunService:IsClient()

return function(NPCTable :NPCTypes.RenderNPC)
	if not NPCTable or NPCTable.Died then
		return
	end
	
	if IsServer then
		local Map = game.Workspace:FindFirstChild(NPCTable.Map)
		
		if Map then
			local Base = Map:FindFirstChild("Base",true)
			
			if Base then
				local BaseHealth = Base:GetAttribute("Health")
				Base:SetAttribute("Health", BaseHealth - NPCTable.NPCConfig.Damage)
			end
		end
		NPCTable.Died = true
		NPCTable = nil
	elseif IsClient then
		local Model = NPCTable.Model
		
		if Model then
			Model.Parent = nil

			task.delay(1, function()
				if Model then
					Model:Destroy()
				end
			end)
		end

		NPCTable.Died = true
		NPCTable = nil
	end
end