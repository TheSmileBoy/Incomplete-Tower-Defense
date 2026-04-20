return function(Map: Instance, Index: number): BasePart?
	local Path = Map:FindFirstChild("Path")
	if not Path then 
		return nil
	end

	return Path:FindFirstChild(tostring(Index)) :: BasePart?
end
