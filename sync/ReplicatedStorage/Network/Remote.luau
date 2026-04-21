--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local RemoteEvent = ReplicatedStorage.RemoteEvent
local MaxQueue = 10

local PendingQueue :{[number | string] :{any}} = {}

local Actions :{[any] :{unknown}} = {}
local Module = {}

type args = {[any] :any}

function Module:Fire(Callback :any)
	assert(typeof(Callback) == "table", "Fire: Callback must be a table, got " .. typeof(Callback))
	assert(RunService:IsClient(), "Fire: must be called on the client")
	
	RemoteEvent:FireServer(Callback)	
end

function Module:FireClient(Player :Player, Callback :any)
	assert(typeof(Player) == "Instance" and Player:IsA("Player"), "FireClient: Player must be a Player instance, got " .. typeof(Player))
	assert(typeof(Callback) == "table", "FireClient: Callback must be a table, got " .. typeof(Callback))
	assert(RunService:IsServer(), "FireClient: must be called on the server")
	
	RemoteEvent:FireClient(Player, Callback)
end

function Module:FirePlayersExcept(ExcludedPlayers: {[number]: Player}, Callback: any)
	assert(typeof(ExcludedPlayers) == "table", "FirePlayersExcept: ExcludedPlayers must be a table, got " .. typeof(ExcludedPlayers))
	assert(typeof(Callback) == "table", "FirePlayersExcept: Callback must be a table, got " .. typeof(Callback))
	assert(RunService:IsServer(), "FirePlayersExcept: must be called on the server")

	local AllPlayers = Players:GetPlayers() :: {[number]: Player}
	
	for _, Player: Player in AllPlayers do
		assert(Player:IsA("Player"), "FirePlayersExcept: ExcludedPlayers contains a non-Player instance")
		
		if not table.find(ExcludedPlayers, Player) then
			RemoteEvent:FireClient(Player, Callback)
		end
	end
end

function Module:FireAll(Callback)
	assert(typeof(Callback) == "table", "FireAll: Callback must be a table, got " .. typeof(Callback))
	assert(RunService:IsServer(), "FireAll: must be called on the server")
	
	RemoteEvent:FireAllClients(Callback)
end

function Module:OnAction(ActionName, callback)
	if not Actions[ActionName] then
		Actions[ActionName] = {}
	end

	table.insert(Actions[ActionName], callback)

	if not RunService:IsServer() then
		local Queue = PendingQueue[ActionName]
		if Queue then
			for _, data in (Queue) do
				callback(table.unpack(data))
			end
			PendingQueue[ActionName] = nil
		end
	end
end

function Module.GetExpectPlayersByDefenseUID(DefenseUID)
	local Players = Players:GetChildren()
	local ExcludedPlayers = {}
	
	for Order :number, Player :Player in (Players) do
		if Player:GetAttribute("DefenseUID") ~= DefenseUID then
			ExcludedPlayers[#ExcludedPlayers + 1] = Player
		end
	end
	
	return ExcludedPlayers :: {[number] :Player}
end

local function ValidateCallback(Callback) :boolean
	if not Callback or typeof(Callback) ~= "table" then
		warn("Callback is invalid!", Callback)
		return false
	end
	
	if not Callback.RemoteType or typeof(Callback.RemoteType) ~= "string" then
		warn("RemoteType is invalid!", Callback)
		return false
	end
	
	return true
end

local function Handle(Action, ...)
	local List = Actions[Action] :: {() -> ()}

	if List then
		for _, callback in (List) do
			callback(...)
		end
	else
		if not RunService:IsServer() then
			PendingQueue[Action] = PendingQueue[Action] or {}

			if #PendingQueue[Action] < MaxQueue then
				table.insert(PendingQueue[Action], {...})
			end
		end
	end
end

if RunService:IsServer() then
	RemoteEvent.OnServerEvent:Connect(function(Player :Player, Callback :{RemoteType :string})
		if not ValidateCallback(Callback) then
			return
		end
		
		Handle(Callback.RemoteType, Player, Callback)
	end)
else
	RemoteEvent.OnClientEvent:Connect(function(Callback :{RemoteType :string})
		if not ValidateCallback(Callback) then
			return
		end
		
		Handle(Callback.RemoteType, Callback)
	end)
end

return Module