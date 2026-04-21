--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NPCsObject :Folder = ReplicatedStorage.Shared.Objects.NPCs

return function(NPCName: string) :Model?
	local Object = NPCsObject:FindFirstChild(NPCName)
	
	if not Object or not Object:IsA("Model") then
		warn("Object must be a model!", NPCName, Object)
		return nil
	end
	
	return Object:Clone()
end