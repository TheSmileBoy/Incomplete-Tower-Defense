local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local ProfileStore = require(ServerStorage.Modules.ProfileStore)

local Template = require(ReplicatedStorage.Network.Manager.Template)
local Manager = require(ReplicatedStorage.Network.Manager)

local PlayerStore = ProfileStore.New("PlayerStore2", Template)
local Profile = {}

function Profile.ProfileEnd(Player :Player)
	local profile = Manager[Player]
	if profile ~= nil then
		profile:EndSession()
	end
end

function Profile.ProfileStart(Player :Player)
	-- Start a profile session for this Player's data:

	local profile = PlayerStore:StartSessionAsync(`{Player.UserId}`, {
		Cancel = function()
			return Player.Parent ~= Players
		end,
	})

	-- Handling new profile session or failure to start it:

	if profile ~= nil then

		profile:AddUserId(Player.UserId) -- GDPR compliance
		profile:Reconcile() -- Fill in missing variables from PROFILE_TEMPLATE (optional)

		profile.OnSessionEnd:Connect(function()
			Manager[Player] = nil
			Player:Kick(`Profile session end - Please rejoin`)
		end)

		if Player.Parent == Players then
			Manager[Player] = profile

			for CurrencyName, CurrencyCount in (profile.Data.Currency) do
				print(CurrencyName, CurrencyCount)
				Player:SetAttribute(CurrencyName, CurrencyCount)
			end
		else
			profile:EndSession()
		end

	else
		-- This condition should only happen when the Roblox server is shutting down
		Player:Kick(`Profile load fail - Please rejoin`)
	end
end

local function OnPlayerRemoved(Player :Player)
	Profile.ProfileEnd(Player)
end

local function OnPlayerAdded(Player :Player)
	task.spawn(Profile.ProfileStart, Player)
end

for _, Player :Player in (Players:GetPlayers()) do
	OnPlayerAdded(Player)
end

Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoved)

return Profile
