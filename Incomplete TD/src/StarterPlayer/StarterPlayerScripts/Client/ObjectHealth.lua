--!strict
--[[
 Create a connection/health gui for each object with the tag "HasHealth", e.g: Map Base
]]
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

local Base = {}

local HealthTween: Tween? = nil
local TweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Cubic, Enum.EasingDirection.In)

local HealthGUI = script.HealthGUI

local HealthFrame = HealthGUI.HealthGui
local HealthBarFrame = HealthFrame.HealthFrame
local HealthBarImage = HealthBarFrame.HealthBar
local HealthLabel = HealthBarFrame.HealthLabel

local TAG = "HasHealth" 

local function UpdateHealth(Object: Instance, Gui: Instance & typeof(script.HealthGUI))
	local Health = Object:GetAttribute("Health") :: number? or 0
	local MaxHealth = Object:GetAttribute("MaxHealth") :: number? or 1
	local Percent = math.clamp(Health / MaxHealth, 0, 1)

	local HealthBar = Gui.HealthGui.HealthFrame.HealthBar

	if HealthTween then
		HealthTween:Cancel()
		HealthTween = nil
	end

	HealthTween = TweenService:Create(HealthBar, TweenInfo, {
		Size = UDim2.fromScale(Percent, 1)
	})

	HealthTween:Play()
	Gui.HealthGui.HealthFrame.HealthLabel.Text = math.floor(Percent * 100) .. "% Health"
end

local function Setup(Object)
	local Clone = HealthGUI:Clone()
	Clone.Parent = Object

	UpdateHealth(Object, Clone)

	Object:GetAttributeChangedSignal("Health"):Connect(function()
		UpdateHealth(Object, Clone)
	end)

	Object:GetAttributeChangedSignal("MaxHealth"):Connect(function()
		UpdateHealth(Object, Clone)
	end)
end

CollectionService:GetInstanceAddedSignal(TAG):Connect(function(Object)
	Setup(Object)
end)

for _, Object in CollectionService:GetTagged(TAG) do
	Setup(Object)
end

return Base