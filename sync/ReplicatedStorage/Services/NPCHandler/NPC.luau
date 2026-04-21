--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GetTableByName = require(ReplicatedStorage.Shared.Utils.GetTableByName)

local NPCTypes = require(ReplicatedStorage.Shared.Types.NPCTypes)
local TowersTypes = require(ReplicatedStorage.Shared.Types.TowersTypes)

local BulkMoveTo = require(ReplicatedStorage.Shared.Utils.BulkMoveTo)
local Objects = require(ReplicatedStorage.Shared.Utils.Objects)

local NewUID = require(ReplicatedStorage.Shared.Utils.NewUID)

local GetHeightFromNPC = require(script.Parent.Resources.GetHeightFromNPC)
local GetNPC = require(script.Parent.Resources.GetNPC)

local PredictNPC = require(script.Parent.Server.PredictNPC)
local MoveNPC = require(script.Parent.Client.MoveNPC)

local IsClient = RunService:IsClient()
local IsServer = RunService:IsServer()

export type NPCObject = {
	Attributes: {[string]: any},
	TickStart: number,
	NPCIndex: number,
	Name: string,
	Map: string,

	UID: string,
	NPCConfig: NPCTypes.NPCInfo,

	Died: boolean,
	Started: boolean,

	Path: number,
	Health: number,
	MaxHealth: number,
	PreviewHealth: number,

	-- Client only
	Model: Model?,
	Height: number?,
	TickSegment: number?,
}

local NPC = {}
NPC.__index = NPC

type OOPNPC = setmetatable<NPCObject, typeof(NPC)>

function NPC.new(Table :NPCTypes.NPCInfo) :OOPNPC
	assert(Table.Index and typeof(Table.Index) == "number", "NPC.new: NPCIndex must be a number!")
	assert(Table.Name and typeof(Table.Name) == "string", "NPC.new: Name must be a string!")
	assert(Table.Map and typeof(Table.Map) == "string", "NPC.new: Map must be a string!")
	
	local NPCConfig = GetTableByName.GetNPCConfig(Table.Name)
	assert(NPCConfig ~= nil, "NPC.new: Invalid NPCConfig")
	
	return setmetatable({
		Attributes = Table.Attributes,
		TickStart = Table.TickStart,
		NPCIndex = Table.Index,
		Name = Table.Name,
		Map = Table.Map,
		
		UID = NewUID(),
		NPCConfig = NPCConfig,
		
		Died = false,
		Started = false,
		
		Path = 0,
		Health = 0,
		MaxHealth = 0,
		PreviewHealth = 0,
	}, NPC)
end

function NPC:Move(dt) :Vector3?
	if IsServer then
		return PredictNPC(self)
	else 
		return MoveNPC(self, dt)
	end
end

--Client
function NPC:CreateModel() :boolean
	self.Model = GetNPC(self.Name)

	if not self.Model then
		return false
	end
	
	self.Model:AddTag("ObjectView")
	self.Model:AddTag("NPCModel")
	
	return true
end

function NPC:GetHeight() :boolean
	self.Height = GetHeightFromNPC(self.Model)

	if not self.Model then
		return false
	end

	return true
end

--Server and Client
function NPC:SetupHealth()
	if IsServer then
		self.PreviewHealth = self.NPCConfig.Health
		self.MaxHealth = self.NPCConfig.Health
		self.Health = self.NPCConfig.Health
	elseif IsClient then
		if self:CreateModel() then
			if self:GetHeight() then
				self.PreviewHealth = self.NPCConfig.Health
				
				self.Model:SetAttribute("MaxHealth", self.NPCConfig.Health)
				self.Model:SetAttribute("Health", self.NPCConfig.Health)
			end
		end
	end
end

return NPC
