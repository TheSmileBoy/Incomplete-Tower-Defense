--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Configuration = require(ReplicatedStorage.GameConfig)

local Highlight = require(ReplicatedStorage.Shared.Utils.Highlight)
local Vignette = require(ReplicatedStorage.Shared.Utils.Vignette)
local VFX = require(ReplicatedStorage.Shared.Utils.VFX)

local ScreenIcons = require(script.ScreenIcons)

local Player = Players.LocalPlayer
if not Player then
	return
end

local PlayerGUI = Player:WaitForChild("PlayerGui") :: typeof(script.Parent.Parent)

local MoneyGradient = script.UIGradient

local CurrencyUI = PlayerGUI:WaitForChild("CurrencyUI")

local Scroll = CurrencyUI.ScrollingFrame
local CurrencyStack = Scroll.Stack

local ActiveCurrencies = {}

local function CreateCurrencyStack(CurrencyName :string, Color :ColorSequence, DigitBefore :string, ImageID :string)
	local DelayBetween = .05
	local TweenOut = .1
	local TweenIn = .1

	local NewStack = CurrencyStack:Clone()
	local NewStack = CurrencyStack:Clone()
	local StackLabel = NewStack.TextLabel

	NewStack.Visible = true
	StackLabel.UIGradient.Color = Color
	NewStack.CurrencyUI.Image = ImageID
	NewStack.Parent = Scroll

	local OldQuantity = 0
	local Initialized = false

	local NormalSize = StackLabel.AbsoluteSize.Y
	local BumpSize = NormalSize * 1.1

	local function FormatValue(Value: number): string
		if not Value then
			return ""
		end
		
		return DigitBefore .. string.format("%s", tostring(math.floor(Value)))
	end

	local function OnChange()
		NormalSize = StackLabel.AbsoluteSize.Y
		BumpSize = NormalSize * 1.1

		local NewValue = Player:GetAttribute(CurrencyName) :: number
		local Delta = NewValue - OldQuantity

		if not Initialized then
			Initialized = true
			OldQuantity = NewValue
			StackLabel.TextSize = NormalSize
			StackLabel.Text = FormatValue(NewValue)
			return
		end

		OldQuantity = NewValue

		if Delta <= 0 then
			StackLabel.TextSize = NormalSize
			StackLabel.Text = FormatValue(NewValue)
			return
		end

		StackLabel.TextSize = BumpSize
		StackLabel.Text = FormatValue(NewValue)

		task.delay(0.05, function()
			StackLabel.TextSize = NormalSize
		end)
	end
	
	if not Player:GetAttribute(CurrencyName) then
		Player:SetAttribute(CurrencyName,0)
	end
	
	Player:GetAttributeChangedSignal(CurrencyName):Connect(OnChange)
	OnChange()
end

for CurrecyName, CurrencyTable in (Configuration.Currency) do
	local CurrencyGradient = Configuration.Gradients[CurrecyName.."Gradient"]
	CreateCurrencyStack(CurrecyName, CurrencyGradient.Color, CurrencyTable.DigitBefore or "", CurrencyTable.ImageID)
end