local GridManager = {}

local OccupiedSlots = {}
local GridSize = 5
local Spacing = Vector3.new(100, 0, 100)

function GridManager.Init(mapTemplate: Model, gridSize: number?, extraSpacing: number?)
	GridSize = gridSize or GridSize

	local size = mapTemplate:GetExtentsSize()
	local pivot = mapTemplate:GetPivot()
	local offset = extraSpacing or 10

	Spacing = Vector3.new(
		size.X + offset,
		size.Z + offset
	)
end

function GridManager.GetFreeSlot(): number
	local slot = 1
	while OccupiedSlots[slot] do
		slot += 1
	end
	return slot
end

function GridManager.Occupy(slot: number)
	OccupiedSlots[slot] = true
end

function GridManager.Release(slot: number)
	OccupiedSlots[slot] = nil
end

function GridManager.GetPosition(slot: number): Vector3
	local row = math.floor((slot - 1) / GridSize)
	local col = (slot - 1) % GridSize

	return Vector3.new(
		col * Spacing.X,
		0,
		row * Spacing.Z
	)
end

return GridManager