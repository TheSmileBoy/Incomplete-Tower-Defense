return function(NPCTable) :Folder?
	local Map = game.Workspace:FindFirstChild(NPCTable.Map)
	if not Map then 
		warn("Map doesn't exist!", NPCTable.Map) 
		return 
	end
	
	return Map
end