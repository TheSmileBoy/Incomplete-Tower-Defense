--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Storage = require(ReplicatedStorage.Shared.Utils.Storage)

return function(): nil
	local AnimateOut = Storage:Get("AnimateOut") :: () -> ()
	if AnimateOut then
		AnimateOut()
	end
	
	local Cancel = Storage:Get("TowerConnection") :: () -> ()
	if Cancel then
		Cancel()
	end
	
	return nil
end