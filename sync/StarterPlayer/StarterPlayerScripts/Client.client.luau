--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Manager = require(ReplicatedStorage.Network.Manager)

local ObjectView = require(ReplicatedStorage.Client.ObjectView)

local TowerHandler = require(ReplicatedStorage.Services.TowerHandler)
local NPCHandler = require(ReplicatedStorage.Services.NPCHandler)
local Remote = require(ReplicatedStorage.Network.Remote)

local ObjectHealth = require(script.ObjectHealth)

Remote:OnAction("NPCCreate", function(Callback)
	NPCHandler.HandleInfo(Callback.SendTable)
end)

Remote:OnAction("CreateTower", function(Callback)
	TowerHandler.CreateNewTower(Callback.TowerName, Callback.MousePosition, Callback.StartTick)
end)