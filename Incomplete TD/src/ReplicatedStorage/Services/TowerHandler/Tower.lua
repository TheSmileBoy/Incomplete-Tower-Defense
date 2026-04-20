local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GetTableByName = require(ReplicatedStorage.Shared.Utils.GetTableByName)

local NPCTypes = require(ReplicatedStorage.Shared.Types.NPCTypes)
local TowersTypes = require(ReplicatedStorage.Shared.Types.TowersTypes)

local Objects = require(ReplicatedStorage.Shared.Utils.Objects)

local BulkMoveTo = require(ReplicatedStorage.Shared.Utils.BulkMoveTo)

local Tower = {}
Tower.__index = Tower

export type TowerObject = {
	-- Shared
	TowerName: string,
	TowerPosition: Vector3,
	StartTick: number,
	ObjectConfig: TowersTypes.ObjectConfig,
	LastFireIndex: number,

	-- Client only
	TrackObject: BasePart?,
	TowerFire: BasePart?,
	TowerProjectile: string?,
	Object: Model?,
}

export type Projectile = {
	Object: Model,
	TargetNPC: NPCTypes.RenderNPC,
	Speed: number,
	TowerName: string,
	Damage: number,
}


type TowerObj = setmetatable<TowerObject, typeof(Tower)>

local function CreateHitboxForModel(Model :Model)
	local Clone = script.Hitbox:Clone() :: BasePart	
	Clone.Size = Model:GetExtentsSize()
	Clone:PivotTo(Model:GetPivot())
	Clone.Parent = Model
end

-- Shared
function Tower.new(TowerName: string, TowerPosition: Vector3, StartTick: number, ObjectConfig: TowersTypes.ObjectConfig): TowerObj
	assert(typeof(TowerName) == "string", "Tower.new: TowerName must be a string")
	assert(typeof(TowerPosition) == "Vector3", "Tower.new: TowerPosition must be a Vector3")
	assert(typeof(StartTick) == "number", "Tower.new: StartTick must be a number")
	assert(typeof(ObjectConfig) == "table", "Tower.new: ObjectConfig must be a table")

	return setmetatable({
		TowerName = TowerName,
		TowerPosition = TowerPosition,
		StartTick = StartTick,
		ObjectConfig = ObjectConfig,
		LastFireIndex = -1,

		TrackObject = nil,
		TowerFire = nil,
		TowerProjectile = nil,
		Object = nil,
	}, Tower)
end

function Tower:GetFireIndex(Tick: number): number
	local Elapsed = Tick - self.StartTick
	return math.floor(Elapsed / self.ObjectConfig.Cooldown)
end

function Tower:ShouldFire(Tick: number): boolean
	return self:GetFireIndex(Tick) > self.LastFireIndex
end

function Tower:MarkFired(Tick: number)
	self.LastFireIndex = self:GetFireIndex(Tick)
end

function Tower:GetActualFlightTime(Distance: number): number
	local FlightTime = self.ObjectConfig.FlightTime or 0.5
	return FlightTime + (FlightTime * Distance / 10)
end

-- Server
function Tower:ComputeHit(NearestPosition: Vector3, Tick: number): (number, number)
	local FireIndex = self:GetFireIndex(Tick)
	local FireTick = self.StartTick + FireIndex * self.ObjectConfig.Cooldown
	local FireDistance = (self.TowerPosition - NearestPosition).Magnitude
	local ActualFlightTime = self:GetActualFlightTime(FireDistance)
	local HitTick = FireTick + ActualFlightTime
	local Delay = HitTick - Tick
	return Delay, FireDistance
end

-- Client
function Tower:SetupClient(Object: Model, TrackerObject: BasePart, Fire: BasePart?, ProjectileObject: string?)
	self.Object = Object
	self.TrackObject = TrackerObject
	self.TowerFire = Fire
	self.TowerProjectile = ProjectileObject
	
	self.Object:AddTag("TowerModel")
	self.Object:AddTag("ObjectView")
	
	CreateHitboxForModel(self.Object)
end

function Tower:SpawnProjectile(TargetNPC: NPCTypes.RenderNPC, NearestPosition: Vector3): Projectile?
	local FirePart = self.TowerFire
	local ProjectileName = self.TowerProjectile
	if not FirePart or not ProjectileName then return nil end

	local Projectile = Objects[ProjectileName]:Clone() :: Model?
	if not Projectile then return nil end

	local TargetPart = TargetNPC.Model and TargetNPC.Model.PrimaryPart
	if not TargetPart then return nil end

	local FireDistance = (self.TowerPosition - NearestPosition).Magnitude
	local ActualFlightTime = self:GetActualFlightTime(FireDistance)
	local Speed = FireDistance / ActualFlightTime

	Projectile:PivotTo(CFrame.new(FirePart.Position))
	Projectile.Parent = workspace

	return {
		Object = Projectile,
		TargetNPC = TargetNPC,
		Speed = Speed,
		TowerName = self.TowerName,
		Damage = self.ObjectConfig.Damage,
	}
end

function Tower:UpdateTracker(NearestPosition: Vector3)
	local TrackerObject = self.TrackObject
	if not TrackerObject then return end

	local TrackerPosition = TrackerObject.Position
	local LookAt = Vector3.new(NearestPosition.X, TrackerPosition.Y, NearestPosition.Z)
	BulkMoveTo.Insert(TrackerObject, CFrame.new(TrackerPosition, LookAt))
end

return Tower