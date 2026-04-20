local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Objects = {}

local function LoopThrough(Object: Instance)
	for _, Model in (Object:GetChildren()) do
		if Model:IsA("Model") or Model.Parent:IsA("Folder") then
			Objects[Model.Name] = Model
		elseif Model:IsA("Folder") then
			LoopThrough(Model)
		end
	end
end

LoopThrough(ReplicatedStorage.Shared.Objects.Towers)
LoopThrough(ReplicatedStorage.Shared.Objects.Projectiles)

return Objects :: {[string] :BasePart | Model}