--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TowersFolder = ReplicatedStorage.Shared.Configs.Towers

local TowersGUI = script.Parent

local OpenFrame = TowersGUI.OpenFrame

local OpenButton = OpenFrame.OpenButton
local OpenLabel = OpenFrame.OpenLabel

local TowersFrame = TowersGUI.TowersCanva
local TowersScrolling = TowersFrame.ScrollingFrame
local TowerStack = TowersScrolling.Stack

type TowerConfig = {
	Damage: number,
	Range: number,
	Cooldown: number,
}

local TowersStack = {}

local OnTowerSelected = Instance.new("BindableEvent")
TowersGUI:SetAttribute("OnTowerSelected", true)

TowerStack.Visible = false

local function CreateStack(TowerName: string, Config: TowerConfig)
	local Stack = TowerStack:Clone()

	local Button = Stack.StackButton
	local Label = Stack.StackLabel

	Label.Text = TowerName
	Stack.Name = TowerName
	Stack.Visible = true

	Button.MouseButton1Click:Connect(function()
		OnTowerSelected:Fire(TowerName, Config)
	end)

	Stack.Parent = TowersScrolling
	
	return Stack
end

for Order :number, Module in (TowersFolder:GetChildren()) do
	if not Module:IsA("ModuleScript") then continue end

	local Config = require(Module) :: TowerConfig
	local Stack = CreateStack(Module.Name, Config)
	Stack.LayoutOrder = Order
	
	TowersStack[Order] = Stack
end

return {OnTowerSelected = OnTowerSelected, TowersStack = TowersStack}