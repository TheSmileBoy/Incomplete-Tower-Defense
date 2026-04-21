--!strict
type CircleConfig = {
	Radius: number,
	BlockSize: number,
	Spacing: number,
	Height: number,
	Parent: Instance,
	OutlineColor: Color3?,
	FillColor: Color3?,
	FillTransparency: number?,
}

return function(Config: CircleConfig): {Model: Model, ChangeColor :(Color3) -> (), Destroy: () -> ()}
	local Model = Instance.new("Model")
	Model.Name = "Circle"
	Model.Parent = Config.Parent

	local Fill = Instance.new("Part")
	Fill.Name = "Fill"
	Fill.Shape = Enum.PartType.Cylinder
	Fill.Size = Vector3.new(Config.Height, Config.Radius * 2, Config.Radius * 2)
	Fill.CFrame = CFrame.new(Vector3.zero) * CFrame.Angles(0, 0, math.rad(90))
	Fill.Anchored = true
	Fill.CanCollide = false
	Fill.CastShadow = false
	Fill.Color = Config.FillColor or Color3.fromRGB(0, 162, 255)
	Fill.Transparency = Config.FillTransparency or 0.7
	Fill.Material = Enum.Material.Neon
	Fill.Parent = Model

	local Circumference = 2 * math.pi * Config.Radius
	local BlockCount = math.floor(Circumference / (Config.BlockSize + Config.Spacing))
	local AngleStep = (2 * math.pi) / BlockCount

	for i = 0, BlockCount - 1 do
		local Angle = i * AngleStep
		local X = math.cos(Angle) * Config.Radius
		local Z = math.sin(Angle) * Config.Radius

		local Block = Instance.new("Part")
		Block.Name = "OutlineBlock"
		Block.Size = Vector3.new(Config.BlockSize, Config.Height, Config.BlockSize)
		Block.CFrame = CFrame.new(Vector3.new(X, 0, Z)) * CFrame.Angles(0, Angle, 0)
		Block.Anchored = true
		Block.CanCollide = false
		Block.CastShadow = false
		Block.Color = Config.OutlineColor or Color3.fromRGB(255, 255, 255)
		Block.Material = Enum.Material.Neon
		Block.Transparency = 0
		Block.Parent = Model
	end

	return {
		Model = Model,
		
		ChangeColor = function(Color)
			Model:SetAttribute("Color", Color)
			
			for _, Part :BasePart in (Model:GetDescendants()) do
				Part.Color = Color
			end
		end,
		
		Destroy = function()
			Model:Destroy()
		end,
	}
end