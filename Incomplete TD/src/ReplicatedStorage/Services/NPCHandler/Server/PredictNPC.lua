--!strict
--[[
    PredictNPC is used to calculate the NPC's position on the server.
    No movement or data is sent to the client.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NPCTypes = require(ReplicatedStorage.Shared.Types.NPCTypes)

local GetPathPart = require(script.Parent.Parent.Resources.GetPathPart)
local OnBaseHit = require(script.Parent.Parent.Resources.OnBaseHit)
local GetMap = require(script.Parent.Parent.Resources.GetMap)

return function(NPCTable: NPCTypes.RenderNPC): Vector3?
	local Tick = workspace:GetServerTimeNow()

	if not NPCTable.TickSegment then
		NPCTable.TickSegment = NPCTable.TickStart
	end

	local Map = GetMap(NPCTable)
	if not Map then 
		return nil 
	end
	
	if not NPCTable.NPCConfig or not NPCTable.Path then
		return nil
	end
	
	local PathPart = GetPathPart(Map, NPCTable.Path)
	local NextPath = GetPathPart(Map, NPCTable.Path + 1)
	
	if not PathPart or not NextPath then
		print("Delete")
		OnBaseHit(NPCTable)
		
		return nil 
	end

	local From = PathPart.Position
	local To = NextPath.Position
	local SegmentLength = (To - From).Magnitude
	if SegmentLength == 0 then 
		return nil 
	end

	local Speed = NPCTable.NPCConfig.Speed
	local Elapsed = NPCTable.TickSegment and Tick - NPCTable.TickSegment
	
	if not Elapsed or not Speed then
		return nil
	end
	
	local TraveledInSegment = Elapsed * Speed

	if TraveledInSegment >= SegmentLength then
		local TimeToComplete = SegmentLength / Speed
		
		if NPCTable.TickSegment then
			NPCTable.TickSegment += TimeToComplete	
		end

		NPCTable.Path += 1
		return nil
	end

	local Alpha = math.clamp(TraveledInSegment / SegmentLength, 0, 1)
	local Position = From:Lerp(To, Alpha)

	return Position
end