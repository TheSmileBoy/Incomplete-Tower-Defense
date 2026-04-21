--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Emotes :{[string] :string} = require(ReplicatedStorage.Shared.Utils.Emotes)

local NPCTypes = require(ReplicatedStorage.Shared.Types.NPCTypes)
local TowersTypes = require(ReplicatedStorage.Shared.Types.TowersTypes)

local StatsAllowed = {
	Damage = true,
	Range = true,
	Cooldown = true,
	Price = true,
}

type StatEntry = {
	Label: string,
	Value: string,
}

--[[Create the Damage, Range, ... labels]]
return function(Template: TextButton, Parent: ScrollingFrame, Stats: TowersTypes.ObjectConfig)
	for _, Child in (Parent:GetChildren()) do
		if Child:IsA("TextButton") and Child ~= Template then
			Child:Destroy()
		end
	end

	for StatName, StatValue in Stats do
		if not StatsAllowed[StatName] then
			continue
		end
		
		local Stack = Template:Clone()
		Stack.Name = StatName
		Stack.Text = `{Emotes[StatName]} {tostring(StatValue)}`
		Stack.Visible = true
		Stack.Parent = Parent
	end

	Template.Visible = false
end