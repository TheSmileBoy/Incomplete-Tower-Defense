--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ObjectView = require(ReplicatedStorage.Client.ObjectView)

local ObjectName = script.Parent.ObjectName
local CanvasHealth = script.Parent.CanvasHealth
local HealthText = CanvasHealth.HealthText

local CurrentModel: Model? = nil
local HealthConnection: RBXScriptConnection? = nil
local MaxHealthConnection: RBXScriptConnection? = nil

ObjectName.Visible = false
CanvasHealth.Visible = false

local function UpdateHealth(Model: Model)
	local Health = Model:GetAttribute("Health") :: number?
	local MaxHealth = Model:GetAttribute("MaxHealth") :: number?

	if not Health or not MaxHealth or MaxHealth == 0 then return end

	local Percent = math.clamp(Health / MaxHealth, 0, 1)
	HealthText.Text = string.format("%d/%d (%.0f%%)", Health, MaxHealth, Percent * 100)
end

local function DisconnectHealth()
	if HealthConnection then
		HealthConnection:Disconnect()
		HealthConnection = nil
	end
	if MaxHealthConnection then
		MaxHealthConnection:Disconnect()
		MaxHealthConnection = nil
	end
end

local function ShowHealth(Model: Model)
	CurrentModel = Model
	ObjectName.Text = Model.Name

	UpdateHealth(Model)

	HealthConnection = Model:GetAttributeChangedSignal("Health"):Connect(function()
		if CurrentModel == Model then
			UpdateHealth(Model)
		end
	end)

	MaxHealthConnection = Model:GetAttributeChangedSignal("MaxHealth"):Connect(function()
		if CurrentModel == Model then
			UpdateHealth(Model)
		end
	end)

	CanvasHealth.Visible = true
end

local function UnshowHealth(Model: Model)
	DisconnectHealth()
	CurrentModel = nil
	CanvasHealth.Visible = false
	ObjectName.Text = ""
end

ObjectView.OnNPCHighlight("HealthNPC", ShowHealth, UnshowHealth, 1)