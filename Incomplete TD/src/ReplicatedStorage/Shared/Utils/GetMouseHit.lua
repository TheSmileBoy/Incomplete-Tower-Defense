--!strict
local Players = game:GetService("Players")
local Player : Player? = Players.LocalPlayer

local Mouse = Player and Player:GetMouse()
local Camera = workspace.CurrentCamera

return function(Params: RaycastParams?): RaycastResult?
	if not Mouse then
		warn("Mouse is invalid!", Mouse)
		return nil
	end
	
	local UnitRay = Camera and Camera:ScreenPointToRay(Mouse.X, Mouse.Y)
	
	if not UnitRay then
		warn("UnitRay is invalid!", Camera, Mouse)
		return nil
	end
	
	if Params then
		return workspace:Raycast(UnitRay.Origin, UnitRay.Direction * 1000, Params)
	end
	
	local Params = RaycastParams.new()
	Params.FilterType = Enum.RaycastFilterType.Include
	Params.FilterDescendantsInstances = {game.Workspace[Player:GetAttribute("DefenseUID")]}

	return workspace:Raycast(UnitRay.Origin, UnitRay.Direction * 1000, Params)
end