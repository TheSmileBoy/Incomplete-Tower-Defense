--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TowersTypes = require(ReplicatedStorage.Shared.Types.TowersTypes)
local NPCTypes = require(ReplicatedStorage.Shared.Types.NPCTypes)
local MapTypes = require(ReplicatedStorage.Shared.Types.MapTypes)

local Folder = ReplicatedStorage.Shared.Configs

local Tables : {[string] :any} = {}
local Module = {}

for Order :number, Module :Instance in (Folder:GetDescendants()) do
	if Module and Module:IsA("ModuleScript") then
		Tables[Module.Name] = require(Module) :: {[any] :any}
	end
end

function Module.GetMapConfig(TableName :string) :MapTypes.MapConfig?
	if not TableName then
		warn("TableName is invalid!", TableName)
		return nil
	end

	if typeof(TableName) ~= "string" then
		warn("TableName must be a string!", TableName)
		return nil
	end

	return Tables[TableName]
end


function Module.GetObjectConfig(TableName :string) :TowersTypes.ObjectConfig?
	if not TableName then
		warn("TableName is invalid!", TableName)
		return nil
	end

	if typeof(TableName) ~= "string" then
		warn("TableName must be a string!", TableName)
		return nil
	end

	return Tables[TableName]
end

function Module.GetNPCConfig(TableName :string) :NPCTypes.NPCInfo?
	if not TableName then
		warn("TableName is invalid!", TableName)
		return nil
	end
	
	if typeof(TableName) ~= "string" then
		warn("TableName must be a string!", TableName)
		return nil
	end
	
	return Tables[TableName]
end

return Module