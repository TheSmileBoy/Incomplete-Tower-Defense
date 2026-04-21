--!nocheck
--[[
    Moves the NPC on the client autonomously, synchronized using GetServerTimeNow().
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BulkMoveTo = require(ReplicatedStorage.Shared.Utils.BulkMoveTo)
local Collection = require(ReplicatedStorage.Shared.Utils.Collection)
local NPCTypes = require(ReplicatedStorage.Shared.Types.NPCTypes)

local GetPathPart = require(script.Parent.Parent.Resources.GetPathPart)
local OnBaseHit = require(script.Parent.Parent.Resources.OnBaseHit)
local GetMap = require(script.Parent.Parent.Resources.GetMap)

local StartAnimation = require(script.StartAnimation)

local NPCS = game.Workspace.NPCS
local Maps = {}

local function ParentNPC(Model: Model, NPCTable: NPCTypes.RenderNPC)
	if not NPCTable.Path or not NPCTable.Height then
		return 
	end
	
	local Map = GetMap(NPCTable)
	if not Map then
		return
	end
	
	local PathPart = GetPathPart(Map, NPCTable.Path)
	local NextPath = GetPathPart(Map, NPCTable.Path + 1)
	
	if not PathPart or not NextPath then 
		return 
	end

	local Raycast = workspace:Raycast(PathPart.Position, Vector3.new(0, -100, 0))
	local GroundY = if Raycast then Raycast.Position.Y else PathPart.Position.Y
	
	local NewPosition = Vector3.new(PathPart.Position.X, GroundY + NPCTable.Height, PathPart.Position.Z)
	local NextPosition = Vector3.new(NextPath.Position.X, NewPosition.Y, NextPath.Position.Z)

	Model:PivotTo(CFrame.new(NewPosition, NextPosition))
	Model.Parent = NPCS
	
	NPCTable.CanMove = true
	
	StartAnimation(Model)
end

local function GetNextPathPosition(Map: Instance, Index: number, Height: number): Vector3?
	local PathPart = GetPathPart(Map, Index)
	if not PathPart then 
		return nil 
	end

	local Raycast = workspace:Raycast(PathPart.Position, Vector3.new(0, -100, 0))
	local GroundY = if Raycast then Raycast.Position.Y else PathPart.Position.Y

	return Vector3.new(PathPart.Position.X, GroundY + Height, PathPart.Position.Z)
end

Collection("MapModel", function(Map :Model)
	Maps[Map.Name] = Map
end)

return function(NPCTable: NPCTypes.RenderNPC, DeltaTime: number) :Vector3?
	if not NPCTable or NPCTable.Died then
		return nil 
	end
	
	if not NPCTable.TickStart or not NPCTable.Model or not NPCTable.Path then
		return nil 
	end
	
	local Tick = workspace:GetServerTimeNow()

	if not NPCTable.TickSegment then
		NPCTable.TickSegment = NPCTable.TickStart
	end

	if not NPCTable.Started then
		if NPCTable.TickStart > Tick then 
			return nil 
		end

		NPCTable.Started = true
		ParentNPC(NPCTable.Model, NPCTable)
		return nil
	end

	local Model = NPCTable.Model
	if not Model or not Model.Parent then
		return nil 
	end

	local Map = Maps[NPCTable.Map]
	if not Map then 
		return nil 
	end

	local PathPart = GetPathPart(Map, NPCTable.Path)
	local NextPath = GetPathPart(Map, NPCTable.Path + 1)

	if not PathPart or not NextPath then
		OnBaseHit(NPCTable)
		return nil
	end

	local From = PathPart.Position
	local To = NextPath.Position

	local SegmentLength = (To - From).Magnitude
	if SegmentLength == 0 then
		return nil
	end

	local Speed = NPCTable.NPCConfig and NPCTable.NPCConfig.Speed
	local Elapsed = Tick - NPCTable.TickSegment
	local Traveled = Elapsed * Speed

	if Traveled >= SegmentLength then
		local TimeToComplete = SegmentLength / Speed
		NPCTable.TickSegment += TimeToComplete
		NPCTable.Path += 1
		return nil
	end

	local Alpha = math.clamp(Traveled / SegmentLength, 0, 1)
	local Position = From:Lerp(To, Alpha)

	BulkMoveTo.Insert(
		Model.PrimaryPart,
		CFrame.new(Position, To)
	)
	
	return Position
end