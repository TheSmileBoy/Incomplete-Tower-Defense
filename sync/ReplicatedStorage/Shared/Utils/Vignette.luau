local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGUI = Player.PlayerGui

local ScreenEffects = PlayerGUI:WaitForChild("ScreenEffects")
local VignetteImage = script.Vignette

local VignetteOrder = 0

local Module = {}

function Module.VignettePulse(Color :Color3, NewTransparency :number, TweenIn :number, TweenOut :number, DelayBetween :number)
	VignetteOrder += 1
	
	local NewImage = VignetteImage:Clone()
	NewImage.ImageTransparency	= 1
	NewImage.Visible = true
	NewImage.ImageColor3 = Color
	NewImage.ZIndex = VignetteOrder
	NewImage.Parent = ScreenEffects
	
	local TweenIn = TweenService:Create(NewImage, TweenInfo.new(TweenIn), {ImageTransparency = NewTransparency})
	
	TweenIn.Completed:Once(function()
		if DelayBetween then
			task.wait(DelayBetween)
		end
		
		local TweenOut = TweenService:Create(NewImage, TweenInfo.new(TweenOut), {ImageTransparency = 1})
		TweenOut.Completed:Once(function()
			NewImage:Remove()
		end)
		
		TweenOut:Play()
	end)
	
	TweenIn:Play()
end

return Module
