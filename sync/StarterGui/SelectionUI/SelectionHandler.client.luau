--!strict
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local TowersTypes = require(ReplicatedStorage.Shared.Types.TowersTypes)
local Storage = require(ReplicatedStorage.Shared.Utils.Storage)

local Player = Players.LocalPlayer :: Player?

if not Player then
	return
end

local PlayerGui = Player:WaitForChild("PlayerGui") :: typeof(script.Parent.Parent)

local SelectionUI = PlayerGui:WaitForChild("SelectionUI")
local Towers = PlayerGui:WaitForChild("Towers")

local OpenFrame = SelectionUI.CanvasName

local TowersFrame = Towers.OpenFrame
local TowersCanva = Towers.TowersCanva
local TowersOpen = TowersFrame.OpenButton

local TowerLabel = OpenFrame.TowerName

local StrokeFrame = SelectionUI.CanvasInfo

local OptionsFrame = StrokeFrame.OptionsFrame
local OptionsStack = OptionsFrame.OptionName

local StatsFrame = StrokeFrame.StatsFrame
local StatsStack = StatsFrame.TowerStats

local TowerIcon :ImageLabel = StrokeFrame.TowerIcon

--[[
Stores stack entries for tower creation requests and manages the BindableEvent used to handle them
]]
local OnTowerSelected = require(Towers.TowersUI) :: {TowersStack :{[number] :Frame}, OnTowerSelected :BindableEvent}

local TweenValues = require(script.TweenValues)

local CreateOptions = require(script.CreateOptions)
local CreateStats = require(script.CreateStats)

local TowersStack :{[number] :Frame} = OnTowerSelected.TowersStack

--[[Store functions for each option, e.g: Buy tower, Cancel tower purchase]]
local OptionsModule :{[string] :(TowerName :string, TowerConfig :TowersTypes.ObjectConfig) -> ()} = {}

local TweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local OffscreenX = UDim2.new(1.5, 0, StrokeFrame.Position.Y.Scale, StrokeFrame.Position.Y.Offset)

local StrokeFrameOriginPos = StrokeFrame.Position
local OpenFrameOriginPos = OpenFrame.Position

StrokeFrame.Visible = false
OpenFrame.Visible = false

TowersCanva.UIGradient.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(1, 1),
})

TowersCanva.UIGradient.Rotation = 90
TowersCanva.Visible = false

local function ChangeGradients(NewRotation :number?, NewSequence :NumberSequence)
	for _, Frame in ipairs({StrokeFrame, OpenFrame}) do
		local UIGradient = Frame:FindFirstChildWhichIsA("UIGradient") :: UIGradient
		local UIStroke = Frame:FindFirstChildWhichIsA("UIStroke") :: UIStroke

		if UIStroke then
			local StrokeGradient = UIStroke:FindFirstChildWhichIsA("UIGradient")
			if StrokeGradient then
				StrokeGradient.Rotation = NewRotation or StrokeGradient.Rotation
				StrokeGradient.Transparency = NewSequence
			end
		end

		if UIGradient then
			UIGradient.Rotation = NewRotation or UIGradient.Rotation
			UIGradient.Transparency = NewSequence
		end
	end
end

local function SetOffscreen()
	StrokeFrame.Position = UDim2.new(1.5, 0, StrokeFrameOriginPos.Y.Scale, StrokeFrameOriginPos.Y.Offset)
	OpenFrame.Position = UDim2.new(1.5, 0, OpenFrameOriginPos.Y.Scale, OpenFrameOriginPos.Y.Offset)
	StrokeFrame.Visible = false
	OpenFrame.Visible = false
end

local function AnimateOut()
	OpenFrame.TowerName.Text = ""
	
	local Duration = TweenInfo.Time
	local Elapsed = 0
	
	ChangeGradients(180, NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 0),
	}))
	
	TweenService:Create(StrokeFrame, TweenInfo, {
		Position = UDim2.new(1.3, 0, StrokeFrameOriginPos.Y.Scale, StrokeFrameOriginPos.Y.Offset)
	}):Play()
	TweenService:Create(OpenFrame, TweenInfo, {
		Position = UDim2.new(1.3, 0, OpenFrameOriginPos.Y.Scale, OpenFrameOriginPos.Y.Offset)
	}):Play()
	
	local Connection :RBXScriptConnection
	Connection = RunService.RenderStepped:Connect(function(dt)
		Elapsed = math.min(Elapsed + dt, Duration)
		local Alpha = Elapsed / Duration
		
		ChangeGradients(nil, NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(math.clamp(Alpha, 0.01, 0.98), 1),
			NumberSequenceKeypoint.new(math.clamp(Alpha + 0.01, 0.02, 0.99), 0),
			NumberSequenceKeypoint.new(1, 0),
		}))

		if Elapsed >= Duration then
			OpenFrame.TowerName.Text = ""
			
			StrokeFrame.Visible = false
			OpenFrame.Visible = false
			SetOffscreen()
			Connection:Disconnect()
			
			print("Out")
		end
	end)
end

local function AnimateIn()
	StrokeFrame.Visible = true
	OpenFrame.Visible = true

	ChangeGradients(180, NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.99, 1),
		NumberSequenceKeypoint.new(1, 0),
	}))

	TweenService:Create(StrokeFrame, TweenInfo, { Position = StrokeFrameOriginPos }):Play()
	TweenService:Create(OpenFrame, TweenInfo, { Position = OpenFrameOriginPos }):Play()

	local Duration = TweenInfo.Time/2
	local Elapsed = 0

	local Connection :RBXScriptConnection
	Connection = RunService.RenderStepped:Connect(function(dt)
		Elapsed = math.min(Elapsed + dt, Duration)
		local Alpha = Elapsed / Duration

		ChangeGradients(nil, NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(math.clamp(1 - Alpha - 0.01, 0.01, 0.98), 1),
			NumberSequenceKeypoint.new(math.clamp(1 - Alpha, 0.02, 0.99), 0),
			NumberSequenceKeypoint.new(1, 0),
		}))

		if Elapsed >= Duration then	
			ChangeGradients(nil, NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 0),
			}))
	
			Connection:Disconnect()
		end
	end)
end

SetOffscreen()

for _, Module in script.OptionsModule:GetChildren() do
	if Module:IsA("ModuleScript") then
		OptionsModule[Module.Name] = require(Module)
	end
end

OnTowerSelected.OnTowerSelected.Event:Connect(function(TowerName: string, Config: TowersTypes.ObjectConfig)
	if not TowerName or typeof(TowerName) ~= "string" then
		warn("TowerName is invalid!", TowerName)
		return
	end
	
	--[[If already selected, exit the purchase screen]]
	if OpenFrame.TowerName.Text == TowerName then
		AnimateOut()
		return
	else
		local Cancel = Storage:Get("TowerConnection") :: () -> ()
		if Cancel then
			Cancel()
		end
	end
	
	OpenFrame.TowerName.Text = TowerName
	StrokeFrame.TowerIcon.Image = Config.ImageIcon
	
	AnimateIn()

	local Options = CreateOptions(OptionsStack, OptionsFrame, {
		IsPlaced = false,
		CanUpgrade = false,
	})
	
	Options.Cancel.MouseButton1Click:Connect(function()
		if OptionsModule["Cancel"] then
			OptionsModule["Cancel"](TowerName, Config)
		end
	end)
	
	if Options.Buy then
		Options.Buy.MouseButton1Click:Connect(function()
			print("MouseButton1Click")
			if OptionsModule["Buy"] then
				OptionsModule["Buy"](TowerName, Config)
			end
		end)
	end

	CreateStats(StatsStack, StatsFrame, Config)
end)

TowersOpen.MouseButton1Click:Connect(function()
	local Cancel = Storage:Get("TowerConnection") :: () -> ()
	
	OpenFrame.TowerName.Text = ""
	
	if Cancel then
		Cancel()
	end
	
	if OpenFrame.Visible then
		AnimateOut()
	end
	
	local State: boolean = not TowersOpen:GetAttribute("Enabled")
	TowersOpen:SetAttribute("Enabled", State)

	local Values = State and TweenValues.TowerFrame.Activated 
		or TweenValues.TowerFrame.Deactivated
	
	local Info = Values.TweenInfo

	TweenService:Create(TowersOpen.UICorner, Info, {
		CornerRadius = Values.CornerRadius
	}):Play()
	
	TweenService:Create(TowersFrame, Info, {
		Size = Values.Size, 
		Position = Values.Position 
	}):Play()
	
	local UIGradient = TowersCanva.UIGradient
	if State then
		TowersCanva.Visible = true
		
		UIGradient.Rotation = 90
		UIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.01, 1),
			NumberSequenceKeypoint.new(1, 1),
		})

		local Duration = Info.Time*3
		local Elapsed = 0

		local Connection :RBXScriptConnection
		Connection = RunService.RenderStepped:Connect(function(dt)
			Elapsed = math.min(Elapsed + dt, Duration)
			local Alpha = Elapsed / Duration

			UIGradient.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(math.clamp(Alpha - 0.01, 0.01, 0.99), 0),
				NumberSequenceKeypoint.new(math.min(Alpha, 0.99), 1),
				NumberSequenceKeypoint.new(1, 1),
			})

			if Elapsed >= Duration then
				Connection:Disconnect()
			end
		end)
	else
		local Duration = Info.Time
		local Elapsed = 0

		local Connection :RBXScriptConnection
		Connection = RunService.RenderStepped:Connect(function(dt)
			Elapsed = math.min(Elapsed + dt, Duration)
			local Alpha = 1 - (Elapsed / Duration)

			UIGradient.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(math.clamp(Alpha, 0.01, 0.98), 0),
				NumberSequenceKeypoint.new(math.clamp(Alpha + 0.01, 0.02, 0.99), 1),
				NumberSequenceKeypoint.new(1, 1),
			})

			if Elapsed >= Duration then
				UIGradient.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.01, 1),
					NumberSequenceKeypoint.new(1, 1),
				})
				Connection:Disconnect()
				
				TowersCanva.Visible = false
			end
		end)
	end
end)

Storage:Store("AnimateOut", AnimateOut)