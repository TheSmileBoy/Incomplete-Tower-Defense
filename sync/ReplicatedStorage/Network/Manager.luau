local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Remote = require(ReplicatedStorage.Network.Remote)

local Profiles = {}

export type ProfileData = {
	Currency :{
		Cash :number,
		Gem :number,
		Diamond :number,
	}
}


function Profiles.GetPlayerProfile(Player :Player) :ProfileData
	if RunService:IsClient() then
		return Profiles[Players.LocalPlayer]
	end
	
	if not Profiles[Player] then
		repeat
			task.wait()
		until Profiles[Player]
	end
	
	return Profiles[Player].Data
end

function Profiles.GetCurrency(Player :Player, CurrencyName :string) :number
	if not CurrencyName or typeof(CurrencyName) ~= "string" then
		warn("CurrencyName is invalid!", CurrencyName, Player)
		return 0
	end

	local Profile = Profiles.GetPlayerProfile(Player)

	if Profile and Profile.Currency and Profile.Currency[CurrencyName] then
		return Profile.Currency[CurrencyName]
	end

	return 0
end

function Profiles.CurrencyChange(Player :Player, CurrencyName :string, CurrencyChange :number) :ProfileData?
	if not CurrencyChange or typeof(CurrencyChange) ~= "number" then
		return 
	end
	
	if not CurrencyName or typeof(CurrencyName) ~= "string" then
		return 
	end

	local Profile = Profiles.GetPlayerProfile(Player)
	
	if Profile and Profile.Currency and Profile.Currency[CurrencyName] then
		Profile.Currency[CurrencyName] += CurrencyChange
		Player:SetAttribute(CurrencyName, Profile.Currency[CurrencyName])
		
		Remote:FireClient(Player, {
			RemoteType = "UpdateProfile",
			Type = "Currency",
			CurrencyName = "Cash",
			NewValue = Profile.Currency[CurrencyName]
		})
	end

	return
end

if RunService:IsServer() then
	Remote:OnAction("ClientOrder", function(Player, Callback)
		local Profile = Profiles.GetPlayerProfile(Player)
		
		Remote:FireClient(Player, {
			RemoteType = "GetProfile",
			Profile = Profile
		})
	end)
elseif RunService:IsClient() then
	Remote:OnAction("UpdateProfile", function(Callback)
		
	end)
	
	Remote:OnAction("GetProfile", function(Callback)
		Profiles[Players.LocalPlayer] = Callback.Profile
	end)
	
	Remote:Fire({RemoteType = "ClientOrder"})
end

return Profiles
