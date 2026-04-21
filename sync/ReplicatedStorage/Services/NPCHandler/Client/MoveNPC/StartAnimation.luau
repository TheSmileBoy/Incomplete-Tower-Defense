--!strict
local Animation = script.Animation :: Animation

return function(Model: Model): AnimationTrack?
	local AnimationController = Model:FindFirstChildWhichIsA("AnimationController")
	if not AnimationController then
		warn("AnimationController doesn't exist!", Model)
		return nil
	end

	local Track = AnimationController:LoadAnimation(Animation)
	Track:Play()

	return Track
end