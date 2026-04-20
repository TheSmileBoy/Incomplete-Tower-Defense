--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GetTableByName = require(ReplicatedStorage.Shared.Utils.GetTableByName)

local SteppedRegister = require(ReplicatedStorage.Shared.Utils.SteppedRegister)

local BulkMoveTo = require(ReplicatedStorage.Shared.Utils.BulkMoveTo)
local NPCTypes = require(ReplicatedStorage.Shared.Types.NPCTypes)
local NewUID = require(ReplicatedStorage.Shared.Utils.NewUID)

local GetHeightFromNPC = require(script.Resources.GetHeightFromNPC)
local GetNPC = require(script.Resources.GetNPC)

local NPC = require(script.NPC)

local IsClient = RunService:IsClient()
local IsServer = RunService:IsServer()

local PositionCache: {[string]: Vector3} = {}

local CreateNPC = {}
local Data :NPCTypes.RenderData = {}

function CreateNPC.CreateNewNPC(Table :NPCTypes.NPCInfo)
	local Index :number = #Data[Table.DefenseUID]
	
	local NPCTable = NPC.new(Table)
	NPCTable:SetupHealth()
	
	Data[Table.DefenseUID][Index + 1] = NPCTable
end

function CreateNPC.HandleInfo(SendTable :NPCTypes.SendTableType)
	if not Data[SendTable.DefenseUID] then
		Data[SendTable.DefenseUID] = {}
	end
	
	for Name: string, Data: NPCTypes.NPCSendData in (SendTable.NPCS) do
		for i = 1, Data.Quantity do
			CreateNPC.CreateNewNPC({
				Index = i,
				Name = Name,
				Attributes = Data.Attributes[tostring(i)],
				Map = SendTable.Base,
				TickStart = SendTable.TickStart + SendTable.TimeBetween*i,
				DefenseUID = SendTable.DefenseUID,
			})
		end
	end
end

function CreateNPC.GetNearestNPCFromPosition(Position: Vector3, Range: number, DefenseUID: string?): (NPCTypes.RenderNPC?, Vector3?)
	local Nearest: NPCTypes.RenderNPC
	local NearestDistance = math.huge
	local NearestPosition: Vector3
	
	local function CheckArray(NPCArray: {NPCTypes.RenderNPC})
		for _, NPCTable in ipairs(NPCArray) do
			if not NPCTable or NPCTable.PreviewHealth <= 0 then continue end
			local NPCPosition = PositionCache[NPCTable.UID]
			if not NPCPosition then continue end

			local Distance = (Position - NPCPosition).Magnitude
			if Distance < NearestDistance and Distance <= Range then
				NearestDistance = Distance
				NearestPosition = NPCPosition
				Nearest = NPCTable
			end
		end
	end

	if DefenseUID then
		local NPCArray = Data[DefenseUID]
	
		if not NPCArray then 
			return nil, nil
		end
		
		CheckArray(NPCArray)
	else
		for _, NPCArray in pairs(Data) do
			CheckArray(NPCArray)
		end
	end

	return Nearest, NearestPosition
end

SteppedRegister.Register("NPCMove", function(time, dt)
	table.clear(PositionCache)
	
	for DefenseUID: string, NPCArray in (Data) do
		for Order, NPCTable in (NPCArray) do
			if not NPCTable or NPCTable.Died then
				table.remove(NPCArray, Order)
				continue
			end
			
			PositionCache[NPCTable.UID] = NPCTable:Move(dt)
		end
	end
end, 1)

return CreateNPC
