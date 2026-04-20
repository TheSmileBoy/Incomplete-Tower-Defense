--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Manager = require(ReplicatedStorage.Network.Manager)

local Collection = require(ReplicatedStorage.Shared.Utils.Collection)

local TowerHandler = require(ReplicatedStorage.Services.TowerHandler)

local GetTableByName = require(ReplicatedStorage.Shared.Utils.GetTableByName)
local NPCTypes = require(ReplicatedStorage.Shared.Types.NPCTypes)

local NPCHandler = require(ReplicatedStorage.Services.NPCHandler)
local Remote = require(ReplicatedStorage.Network.Remote)

type TowerSend = {
	RemoteType :string,
	TowerName :string,
	
	MousePosition :Vector3,
}

local function ValidateCharacter(Player :Player) :boolean
	local Character = Player.Character
	
	if not Character or not Character.PrimaryPart then
		return false
	end
	
	return true
end

Remote:OnAction("CreateTower", function(Player :Player, Callback :TowerSend) :boolean
	if not ValidateCharacter(Player) then
		return false
	end
	
	if not Callback.TowerName or typeof(Callback.TowerName) ~= "string" then
		return false
	end
	
	if not Callback.MousePosition or typeof(Callback.MousePosition) ~= "Vector3" then
		return false
	end
	
	for IndexName, Value in Callback do
		if not IndexName or typeof(IndexName) ~= "string" then
			return false
		end
		
		if not table.find({"TowerName", "MousePosition", "RemoteType"}, IndexName) then
			return false
		end
	end
	
	local ObjectConfig = GetTableByName.GetObjectConfig(Callback.TowerName)
	
	if not ObjectConfig then
		warn("ObjectConfig is invalid!", Callback.RemoteType)
		return false
	end
	
	local Raycast = workspace:Raycast(Callback.MousePosition + Vector3.new(0,ObjectConfig.Height,0), Vector3.new(0,-ObjectConfig.Height*3,0))
	
	if not Raycast or not Raycast.Instance:HasTag("CanTower") then
		warn("Invalid raycast!", Raycast.Instance)
		return false
	end
	
	local Cash = Manager.GetCurrency(Player, "Cash")
	local Price = ObjectConfig.Price
	
	if Cash < Price then
		warn("Player don't have enough cash!", Cash, Price)
		return false
	end
		
	local DefenseUID = Player:GetAttribute("DefenseUID")
	local ExceptPlayers = Remote.GetExpectPlayersByDefenseUID(DefenseUID)
	
	Callback.StartTick = game.Workspace:GetServerTimeNow()
	
	Manager.CurrencyChange(Player, "Cash", -Price)
	Remote:FirePlayersExcept(ExceptPlayers, Callback)
	
	TowerHandler.CreateNewTower(Callback.TowerName, Callback.MousePosition, Callback.StartTick)
	
	return true
end)