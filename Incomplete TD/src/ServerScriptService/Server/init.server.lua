--!strict
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Maps = ServerStorage.Objects.Map

local GetTableByName = require(ReplicatedStorage.Shared.Utils.GetTableByName)
local NPCTypes = require(ReplicatedStorage.Shared.Types.NPCTypes)

local NPCHandler = require(ReplicatedStorage.Services.NPCHandler)
local Remote = require(ReplicatedStorage.Network.Remote)

local Profile = require(ServerScriptService.Server.Profile)

local WaveSequence = require(script.Resources.WaveSequence)
local GridManager = require(script.Resources.GridManager)

local ActiveMaps = {}
local SpawnOrder = 0

local function CreateMap(Player :Player, MapTemplate :Model?) :Model?
	if not MapTemplate then
		warn("MapTemplate is invalid!", Player)
		return nil
	end
	
	local slot = GridManager.GetFreeSlot()
	GridManager.Occupy(slot)

	local MapClone = MapTemplate:Clone()
	
	local Pivot = MapClone:GetPivot()
	MapClone:AddTag("MapModel")
	MapClone:PivotTo(CFrame.new(GridManager.GetPosition(slot)) + Vector3.new(0, Pivot.Position.Y, 0))
	MapClone.Parent = workspace

	ActiveMaps[Player] = {
		Model = MapClone,
		Slot = slot
	}
	
	return MapClone
end

local function RemoveMap(Player)
	local data = ActiveMaps[Player]
	if not data then return end

	if data.Model then
		data.Model:Destroy()
	end

	GridManager.Release(data.Slot)
	ActiveMaps[Player] = nil
end

Players.PlayerAdded:Connect(function(Player :Player)
	SpawnOrder += 1
	
	local MapName = "Map1"
	local UID = "MapTest"..SpawnOrder
	
	local MapConfig = GetTableByName.GetMapConfig(MapName)
	
	if not MapConfig then
		warn(MapName,"don't have a config!")
		return
	end
	
	Player:SetAttribute("DefenseUID", UID)

	local Map = CreateMap(Player, Maps:FindFirstChild(MapName))
	
	if not Map then
		warn("Map is invalid!", Map)
		return
	end
	
	local Base = Map:FindFirstChild("Base",true) :: BasePart
	
	if not Base then
		warn("Where is the spawnpoint?", Map)
		return
	end
	
	local Spawnpoint = Map:FindFirstChild("Spawnpoint") :: BasePart
	
	if not Spawnpoint then
		warn("Where is the spawnpoint?", Map)
		return
	end
	
	Map.Name = UID
	
	Base:SetAttribute("Health",MapConfig.Health)
	Base:SetAttribute("MaxHealth", MapConfig.Health)
	
	Base:AddTag("HasHealth")
	
	Player.CharacterAdded:Connect(function(Character :Model)
		local PrimaryPart = Character.PrimaryPart :: BasePart
		PrimaryPart:PivotTo(Spawnpoint.CFrame)

		WaveSequence(MapConfig, UID)
	end)
end)

GridManager.Init(Maps.Map1, 5, 10)