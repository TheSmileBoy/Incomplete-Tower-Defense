local Weld = {}
Weld.Objects = {}

function Weld.DestroyWeld(WeldName :string)
	if Weld.Objects[WeldName] then
		Weld.Objects[WeldName]:Destroy()
	end
end

function Weld.Motor6DWeld(WeldName :string, ObjectToWeld :BasePart, Hand :BasePart, CFrame :CFrame)
	local Motor6D = Instance.new("Motor6D")
	Motor6D.Name = WeldName
	Motor6D.Part0 = ObjectToWeld
	Motor6D.Part1 = Hand
	Motor6D.C0 = CFrame
	Motor6D.Parent = Hand
end

return Weld
