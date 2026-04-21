return {
	TowerFrame = {
		Activated = {
			Size = UDim2.fromScale(0.083, 0.033),
			Position = UDim2.fromScale(0.008, 0.458),
			
			CornerRadius = UDim.new(0.2),
			
			TweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.In)
		},
		Deactivated = {
			Size = UDim2.fromScale(0.083, 0.117),
			Position = UDim2.fromScale(0.0083, 0.5),
			
			CornerRadius = UDim.new(0.05),

			TweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.In)
		},
	},
}