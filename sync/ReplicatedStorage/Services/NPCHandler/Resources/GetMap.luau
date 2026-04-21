--!strict
return function(NPCTable): Model?
	local Map = game.Workspace:FindFirstChild(NPCTable.Map)

	if not Map then
		warn("Map doesn't exist!", NPCTable.Map)
		return nil
	end

	return Map :: Model
end
