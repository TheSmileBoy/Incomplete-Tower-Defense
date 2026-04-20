local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Highlight = script.Highlight

export type Type = {
	FillTransparency :number,
	FillColor :Color3,
	
	OutlineColor :Color3,
	OutlineTransparency :number,
	
	TweenIn :number,
	DelayBetween :number,
	TweenOut :number,
	
	Model :Model | BasePart,
}

local Module = {}

function Module.HighlightPulse(Params :Type)
	local Clone = Highlight:Clone()
	
	Clone.FillColor = Params.FillColor
	Clone.FillTransparency = 1
	Clone.OutlineColor = Params.OutlineColor	
	Clone.OutlineTransparency = 1
	
	Clone.Parent = Params.Model
	
	local TweenIn = TweenService:Create(Clone, TweenInfo.new(Params.TweenIn), {
		FillTransparency = Params.FillTransparency,
		OutlineTransparency = Params.OutlineTransparency,
	})
	
	TweenIn.Completed:Once(function()
		if Params.DelayBetween then
			task.wait(Params.DelayBetween)
		end
		
		local TweenOut = TweenService:Create(Clone, TweenInfo.new(Params.TweenOut), {
			FillTransparency = 1,
			OutlineTransparency = 1,
		})
		
		TweenOut.Completed:Once(function()
			Clone:Destroy()
		end)
		
		TweenOut:Play()
	end)
	
	TweenIn:Play()
end

return Module
