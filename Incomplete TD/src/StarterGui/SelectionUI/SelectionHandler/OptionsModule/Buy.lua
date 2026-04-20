--!strict
local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Collection = require(ReplicatedStorage.Shared.Utils.Collection)
local GameConfig = require(ReplicatedStorage.GameConfig)

local TowerHandler = require(ReplicatedStorage.Services.TowerHandler)
local CreateCircle = require(ReplicatedStorage.Shared.Utils.CreateCircle)

local GetMouseHit = require(ReplicatedStorage.Shared.Utils.GetMouseHit)
local TowersTypes = require(ReplicatedStorage.Shared.Types.TowersTypes)

local Storage = require(ReplicatedStorage.Shared.Utils.Storage)

local Objects = require(ReplicatedStorage.Shared.Utils.Objects)
local Remote = require(ReplicatedStorage.Network.Remote)

local Towers :{[number] :Model} = {}
local BlockedCases :{[string] :(RaycastResult) -> (boolean)} = {
	RaycastResult = function(Result :RaycastResult) :boolean
		if Result.Instance:HasTag("CanTower") then
			return false
		else
			return true -- [[When true block the tower preview]]
		end
	end,
	
	TowersDistance = function(Result :RaycastResult) :boolean
		for Order :number, TowerObject :Model in Towers do
			local Pivot = TowerObject:GetPivot()
			local Distance = (Pivot.Position - Result.Position).Magnitude
			
			if Distance <= GameConfig.TowerMinDistance then
				return true
			end
		end
		
		return false
	end,
}

Collection("TowerModel", function(Object :Model)
	Towers[#Towers + 1] = Object
end, function(Object)
	local Pos = table.find(Towers, Object)
	if Pos then
		table.remove(Towers, Pos)
	end
end)

local function TowerTransparency(Object :Model)
	for _, Part in (Object:GetDescendants()) do
		if Part:IsA("BasePart") then
			Part.Transparency = 0.5
			Part.CanCollide = false
			Part.CastShadow = false
		end
	end
end

return function(TowerName: string, TurretConfig: TowersTypes.ObjectConfig): nil
	local Template = Objects[TowerName] :: Model?
	if not Template then
		warn("Turret not found:", TowerName)
		return nil
	end
	
	local Circle = CreateCircle({
		Radius = TurretConfig.Range,
		BlockSize = 2,
		Spacing = .5,
		Height = 0.2,
		Parent = workspace,
		OutlineColor = Color3.fromRGB(255, 0, 0),
		FillColor = Color3.fromRGB(255, 0, 0),
		FillTransparency = 0.7,
	})

	local Preview: Model = Template:Clone()
	local Height = TurretConfig.Height or 0
	
	TowerTransparency(Preview)
	Preview.Parent = game.Workspace

	local MousePosition
	local Blocked
	
	local RenderStepped = RunService.RenderStepped:Connect(function()
		local Result = GetMouseHit()
		if not Result then 
			Preview.Parent = nil
			Circle.Model.Parent = nil
			return 
		elseif not Preview.Parent then
			Preview.Parent = game.Workspace
			Circle.Model.Parent = game.Workspace
		end

		Preview:PivotTo(CFrame.new(Result.Position) + Vector3.new(0, Height, 0))
		Circle.Model:PivotTo(CFrame.new(Result.Position) * CFrame.Angles(0, 0, math.rad(90)))
		
		MousePosition = Result.Position
		
		local NewColor
		
		NewColor = Color3.fromRGB(0, 255, 0)
		Blocked = false
		
		for CaseName :string, CaseFunction in BlockedCases do
			if CaseFunction(Result) then
				NewColor = Color3.fromRGB(255, 0, 0)
				Blocked = true
			end
		end

		if Circle.Model:GetAttribute("Color") ~= NewColor then
			Circle.ChangeColor(NewColor)
		end
	end)

	ContextActionService:BindAction("CreateTower", function(ActionName, InputState, InputObject)
		if InputState == Enum.UserInputState.Begin and not Blocked and Preview.Parent then
			Remote:Fire({
				RemoteType = "CreateTower",

				TowerName = TowerName,
				MousePosition = MousePosition,
			})
		end
	end, true, Enum.UserInputType.MouseButton1)

	local function Cancel()
		print("Cancel")
		
		ContextActionService:UnbindAction("CreateTower")
		Circle.Destroy()
		RenderStepped:Disconnect()
		Preview:Destroy()
		
		Storage:Store("TowerConnection", false)
	end
	
	Storage:Store("TowerConnection", Cancel)

	return nil
end