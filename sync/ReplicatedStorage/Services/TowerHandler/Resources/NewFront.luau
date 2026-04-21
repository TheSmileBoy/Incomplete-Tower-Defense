--[[
    Some towers may not have their front orientation correctly set.
    This function creates a new part aligned using the "LookDirection" attachment,
    and repositions the remaining objects relative to it.
]]
local function CreateController(SwordMesh: BasePart) :BasePart
	local LookAttachment = SwordMesh:FindFirstChild("LookDirection")
	if not LookAttachment then return SwordMesh end

	local Controller = Instance.new("Part")
	Controller.Size = Vector3.one
	Controller.Transparency = 1
	Controller.Anchored = true
	Controller.CanCollide = false
	Controller.CanQuery = false
	Controller.CanTouch = false
	Controller:SetAttribute("Controller",true)
	Controller.Name = SwordMesh.Name
	Controller.Parent = SwordMesh.Parent
	Controller.CFrame = CFrame.new(SwordMesh.Position, LookAttachment.WorldPosition)

	local Weld = Instance.new("WeldConstraint")
	Weld.Part0 = Controller
	Weld.Part1 = SwordMesh
	Weld.Parent = Controller

	SwordMesh.Anchored = false
	SwordMesh.Name = "Object"
	SwordMesh.Parent = Controller	

	return Controller
end

return CreateController