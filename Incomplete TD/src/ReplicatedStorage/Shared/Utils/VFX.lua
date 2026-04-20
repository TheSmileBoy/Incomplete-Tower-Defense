--!nocheck
local VFX = {}

local function ShiftSequenceHue(sequence, newColor : Color3)
	local h = newColor:ToHSV()

	local newKeypoints = {}

	for i, kp in (sequence.Keypoints) do
		local _, s, v = kp.Value:ToHSV()

		local newColor = Color3.fromHSV(h, s, v)
		newKeypoints[i] = ColorSequenceKeypoint.new(kp.Time, newColor)
	end

	return ColorSequence.new(newKeypoints)
end

function VFX.Spawn(Name : string, Position : Vector3, Color : Color3?)
	local Object : BasePart = script[Name]:Clone()
	Object.CFrame = CFrame.new(Position)
	Object.Parent = workspace.Visual

	for _, ParticleEmitter in (Object:QueryDescendants("ParticleEmitter")) do
		if Color then
			local current = ParticleEmitter.Color

			if typeof(current) == "ColorSequence" then
				ParticleEmitter.Color = ShiftSequenceHue(current, Color)

			elseif typeof(current) == "Color3" then
				local h = Color:ToHSV()
				local _, s, v = current:ToHSV()

				ParticleEmitter.Color = Color3.fromHSV(h, s, v)
			end
		end

		ParticleEmitter:Emit(ParticleEmitter:GetAttribute("EmitCount"))
	end
end

for _, Part in (script:GetChildren()) do
	Part.Anchored = true
end

return VFX
