--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local BulkMoveTo = require(ReplicatedStorage.Shared.Utils.BulkMoveTo)

type SteppedCallback = (time: number, dt: number) -> ()

type CallbackEntry = {
	Callback: SteppedCallback,
	Priority: number,
}

local Callbacks: {[string]: CallbackEntry} = {}
local SortedCallbacks: {CallbackEntry} = {}
local Dirty = false

local Stepped = {}

function Stepped.Register(ID: string, Callback: SteppedCallback, Priority: number?)
	assert(typeof(ID) == "string", "Stepped.Register: ID must be a string")
	assert(typeof(Callback) == "function", "Stepped.Register: Callback must be a function")

	Callbacks[ID] = {
		Callback = Callback,
		Priority = Priority or 0,
	}
	Dirty = true
end

function Stepped.Unregister(ID: string)
	assert(typeof(ID) == "string", "Stepped.Unregister: ID must be a string")
	Callbacks[ID] = nil
	Dirty = true
end

local function RebuildSorted()
	table.clear(SortedCallbacks)
	
	for _, Entry in pairs(Callbacks) do
		SortedCallbacks[#SortedCallbacks + 1] = Entry
	end
	
	table.sort(SortedCallbacks, function(A, B)
		return A.Priority > B.Priority
	end)
	
	Dirty = false
end

RunService.Stepped:Connect(function(time: number, dt: number)
	if Dirty then
		RebuildSorted()
	end

	for _, Entry in ipairs(SortedCallbacks) do
		Entry.Callback(time, dt)
	end

	BulkMoveTo.Execute()
end)

return Stepped