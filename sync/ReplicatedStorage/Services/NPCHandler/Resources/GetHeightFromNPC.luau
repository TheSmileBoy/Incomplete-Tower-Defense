--!strict
return function(Model: Model): number?
	local HRP = Model:FindFirstChild("HumanoidRootPart") :: BasePart?
	
	local LeftLeg = Model:FindFirstChild("Left Leg") :: BasePart?
	local LeftFoot = Model:FindFirstChild("LeftFoot") :: BasePart?

	if not HRP then 
		return nil 
	end

	if LeftLeg then
		return (HRP.Size.Y / 2) + LeftLeg.Size.Y*1.15
	elseif LeftFoot then
		return (HRP.Position - LeftFoot.Position).Magnitude
	end

	return nil
end