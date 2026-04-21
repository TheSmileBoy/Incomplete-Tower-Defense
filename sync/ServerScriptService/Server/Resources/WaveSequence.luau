--!strict
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Maps = ServerStorage.Objects.Map

local GetTableByName = require(ReplicatedStorage.Shared.Utils.GetTableByName)
local MapTypes = require(ReplicatedStorage.Shared.Types.MapTypes)
local NPCTypes = require(ReplicatedStorage.Shared.Types.NPCTypes)

local NPCHandler = require(ReplicatedStorage.Services.NPCHandler)
local Remote = require(ReplicatedStorage.Network.Remote)

local function BuildSendTable(Entry: MapTypes.NPCEntry, Wave: number, UID: string): NPCTypes.SendTableType
	local Quantity = Entry.BaseQuantity + Entry.QuantityGrowth * Wave

	return {
		NPCS = {
			[Entry.Name] = {
				Quantity = Quantity,
				Attributes = Entry.Attributes,
			},
		},
		DefenseUID = UID,
		Base = UID,
		TimeBetween = Entry.TimeBetween,
		TickStart = workspace:GetServerTimeNow(),
	}
end

local function DispatchSendTable(SendTable: NPCTypes.SendTableType, UID: string)
	NPCHandler.HandleInfo(SendTable)
	Remote:FirePlayersExcept(Remote.GetExpectPlayersByDefenseUID(UID), {
		RemoteType = "NPCCreate",
		SendTable = SendTable,
	})
end

local function StartWaveSequence(WaveConfig :MapTypes.MapConfig, UID: string)
	for Wave = 1, WaveConfig.WaveCount do
		-- Normal NPC
		for _, Entry in ipairs(WaveConfig.NPCs) do
			local SendTable = BuildSendTable(Entry, Wave, UID)
			DispatchSendTable(SendTable, UID)
		end

		-- For each X waves create a BOSS
		if WaveConfig.BossEvery and Wave % WaveConfig.BossEvery == 0 and WaveConfig.BossNPCs then
			task.delay(5, function()
				for _, Entry in ipairs(WaveConfig.BossNPCs) do
					local SendTable = BuildSendTable(Entry, Wave, UID)
					DispatchSendTable(SendTable, UID)
				end
			end)
		end

		task.wait(WaveConfig.TimeBetweenWaves)
	end
end

return StartWaveSequence