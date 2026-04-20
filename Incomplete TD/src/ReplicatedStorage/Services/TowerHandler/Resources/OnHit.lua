--!nocheck
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local NPCTypes = require(ReplicatedStorage.Shared.Types.NPCTypes)
local Manager = require(ReplicatedStorage.Network.Manager)

local PlayersTable = Players:GetChildren()

local IsClient = RunService:IsClient()
local IsServer = RunService:IsServer()

Players.PlayerAdded:Connect(function(Player :Player)
	PlayersTable[#PlayersTable + 1] = Player
end)

Players.PlayerRemoving:Connect(function(Player :Player)
	local Pos = table.find(PlayersTable, Player)
	if Pos then
		table.remove(PlayersTable, Pos)
	end
end)

return function(NPCTable :NPCTypes.RenderNPC, Damage)
	if not NPCTable or NPCTable.Died then
		return
	end
	
	if IsClient then
		local Model = NPCTable.Model
		local Health = Model:GetAttribute("Health")
		
		Model:SetAttribute("Health", Health - Damage)
		
		if (Health - Damage) <= 0 then	
			Model.Parent = nil
			
			task.delay(1,  function()
				Model:Destroy()
			end)
			
			NPCTable.Died = true
			NPCTable = nil
		end
	elseif IsServer then
		NPCTable.Health -= Damage

		if NPCTable.Health <= 0 then	
			NPCTable.Died = true
			
			local DropCash = NPCTable.NPCConfig.DropCash
	
			for _, Player in PlayersTable do
				Manager.CurrencyChange(Player, "Cash", DropCash)
			end
			
			NPCTable = nil
		end
	end
end