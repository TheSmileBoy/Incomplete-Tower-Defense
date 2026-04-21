--!strict
--[[
   Author: Smile
   
   Description: Tower Defense tower system. Handles tower creation, 
   detects targets within range, and executes attacks. 
   Fully synchronized between server and client.
]]

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local GetTableByName = require(ReplicatedStorage.Shared.Utils.GetTableByName)
local SteppedRegister = require(ReplicatedStorage.Shared.Utils.SteppedRegister)

local NPCTypes = require(ReplicatedStorage.Shared.Types.NPCTypes)
local TowersTypes = require(ReplicatedStorage.Shared.Types.TowersTypes)

local BulkMoveTo = require(ReplicatedStorage.Shared.Utils.BulkMoveTo)

local NPCHandler = require(ReplicatedStorage.Services.NPCHandler)
local Objects = require(ReplicatedStorage.Shared.Utils.Objects)

local NewFront = require(script.Resources.NewFront)
local OnHit = require(script.Resources.OnHit)

local Tower = require(script.Tower)

local IsServer = RunService:IsServer()
local IsClient = RunService:IsClient()

local TowerTrackers :{[number] :any} = {}
local TowerHandler = {}

function TowerHandler.CreateNewTower(TowerName: string, TowerPosition: Vector3, StartTick: number)
	local Tick = workspace:GetServerTimeNow()

	task.delay(StartTick - Tick, function()
		local ObjectConfig = GetTableByName.GetObjectConfig(TowerName)
		if not ObjectConfig then
			warn("Tower config is invalid!", TowerName)
			return
		end

		local TowerInstance = Tower.new(TowerName, TowerPosition, StartTick, ObjectConfig)

		if IsClient then
			local Object = Objects[TowerName]:Clone() :: Model
			if not Object then return end

			Object:PivotTo(CFrame.new(TowerPosition) + Vector3.new(0, ObjectConfig.Height, 0))

			local TrackerObject = Object:FindFirstChild(ObjectConfig.TrackerObject, true) :: BasePart
			if not TrackerObject then return end

			local Fire = ObjectConfig.ProjectileObject and Object:FindFirstChild("Fire", true) :: BasePart?
		
			TowerInstance:SetupClient(Object, NewFront(TrackerObject), Fire, ObjectConfig.ProjectileObject)

			Object.Parent = workspace

		elseif IsServer then
			TowerInstance.TowerPosition = TowerPosition + Vector3.new(0, ObjectConfig.Height, 0)
		end

		TowerTrackers[#TowerTrackers + 1] = TowerInstance
	end)
end

if IsServer then
	--[[
    NPCHandler Module:
    Manages the .Stepped:Connect loop for all towers and NPCs in the TD system.
    
    .Register:
    Allows registering functions that will be executed every Stepped cycle.
]]
	SteppedRegister.Register("Towers_Server", function(time, dt)
		local Tick = workspace:GetServerTimeNow()

		for _, TowerInstance: Tower.TowerObject in ipairs(TowerTrackers) do
			local NearestNPC, NearestPosition = NPCHandler.GetNearestNPCFromPosition(
				TowerInstance.TowerPosition,
				TowerInstance.ObjectConfig.Range
			)

			if not NearestNPC or NearestNPC.Died then continue end
			if not TowerInstance:ShouldFire(Tick) then continue end

			local Delay = TowerInstance:ComputeHit(NearestPosition, Tick)
			TowerInstance:MarkFired(Tick)
			
			NearestNPC.PreviewHealth -= TowerInstance.ObjectConfig.Damage
			
			if Delay < 0 then
				OnHit(NearestNPC, TowerInstance.ObjectConfig.Damage)
			else
				task.delay(Delay, function()
					if NearestNPC.Died then return end
					OnHit(NearestNPC, TowerInstance.ObjectConfig.Damage)
				end)
			end
		end
	end, 2)
elseif IsClient then
	local LocalPlayer = Players.LocalPlayer
	
	local Projectiles: {[string]: Tower.Projectile} = {}
	
	SteppedRegister.Register("Towers_Client", function(time, dt)
		local DefenseUID = LocalPlayer and LocalPlayer:GetAttribute("DefenseUID")
		local Tick = workspace:GetServerTimeNow()

		for _, TowerInstance: Tower.TowerObject in ipairs(TowerTrackers) do
			local NearestNPC, NearestPosition = NPCHandler.GetNearestNPCFromPosition(
				TowerInstance.TowerPosition,
				TowerInstance.ObjectConfig.Range,
				DefenseUID
			)

			if not NearestNPC or not NearestPosition then continue end

			local PrimaryPart = NearestNPC.Model and NearestNPC.Model.PrimaryPart
			if not PrimaryPart then continue end

			TowerInstance:UpdateTracker(NearestPosition)

			if TowerInstance:ShouldFire(Tick) then
				TowerInstance:MarkFired(Tick)
				
				NearestNPC.PreviewHealth -= TowerInstance.ObjectConfig.Damage
				
				local Projectile = TowerInstance:SpawnProjectile(NearestNPC, NearestPosition)
				if Projectile then
					Projectiles[tostring(Projectile.Object) .. tostring(os.clock())] = Projectile
				end
			end
		end

		for UID, ProjectileTable in pairs(Projectiles) do
			local Projectile = ProjectileTable.Object
			if not Projectile or not Projectile.Parent then
				Projectiles[UID] = nil
				continue
			end

			local TargetPart = ProjectileTable.TargetNPC.Model and ProjectileTable.TargetNPC.Model.PrimaryPart
			if not TargetPart then
				Projectile:Destroy()
				Projectiles[UID] = nil
				continue
			end

			local CurrentPos = Projectile:GetPivot().Position
			local TargetPos = TargetPart.Position
			local Distance = (TargetPos - CurrentPos).Magnitude
			local Step = ProjectileTable.Speed * dt

			if Distance <= Step then
				Projectile:Destroy()
				Projectiles[UID] = nil
				OnHit(ProjectileTable.TargetNPC, ProjectileTable.Damage)
				continue
			end

			local Alpha = Step / Distance
			BulkMoveTo.Insert(Projectile, CFrame.new(CurrentPos:Lerp(TargetPos, Alpha), TargetPos))
		end
	end, 2)
end

return TowerHandler
