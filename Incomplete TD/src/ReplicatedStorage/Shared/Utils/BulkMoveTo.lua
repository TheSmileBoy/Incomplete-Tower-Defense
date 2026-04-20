--!strict
type Entry = {
	Part: BasePart,
	CFrame: CFrame,
}

local Parts: {BasePart} = {}
local CFrames: {CFrame} = {}
local Entries: {Entry} = {}

local BulkMoveTo = {}

function BulkMoveTo.Insert(Part: BasePart, CF: CFrame)
	local Index = #Entries + 1
	Entries[Index] = { Part = Part, CFrame = CF }
	Parts[Index] = Part
	CFrames[Index] = CF
end

function BulkMoveTo.Flush()
	table.clear(Entries)
	table.clear(Parts)
	table.clear(CFrames)
end

function BulkMoveTo.Execute()
	if #Parts == 0 then return end
	workspace:BulkMoveTo(Parts, CFrames, Enum.BulkMoveMode.FireCFrameChanged)
	BulkMoveTo.Flush()
end

return BulkMoveTo