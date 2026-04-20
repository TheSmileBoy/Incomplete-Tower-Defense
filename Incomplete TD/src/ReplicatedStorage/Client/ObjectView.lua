--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Stepped = require(ReplicatedStorage.Shared.Utils.SteppedRegister)

local GetMouseHit = require(ReplicatedStorage.Shared.Utils.GetMouseHit)
local Collection = require(ReplicatedStorage.Shared.Utils.Collection)


local Objects: {[number]: Model | Instance} = {}

local AncestryConnection: RBXScriptConnection? = nil
local LastHighlighted: Model? = nil

local Highlight = script.Highlight

local View = {
	TowersFunctions = {} :: {[string]: {
		OnEnter: (Model) -> (),
		OnLeave: ((Model) -> ())?,
		Priority: number,
	}},
	NPCFunctions = {} :: {[string]: {
		OnEnter: (Model) -> (),
		OnLeave: ((Model) -> ())?,
		Priority: number,
	}},
}

local SortedTowers: {{OnEnter: (Model) -> (), OnLeave: ((Model) -> ())?, Priority: number}} = {}
local SortedNPCs: {{OnEnter: (Model) -> (), OnLeave: ((Model) -> ())?, Priority: number}} = {}

local DirtyTowers = false
local DirtyNPCs = false

local function FireLeave(Model: Model)
	local SortedList = Model:HasTag("TowerModel") and SortedTowers or SortedNPCs
	for _, Entry in ipairs(SortedList) do
		if Entry.OnLeave then Entry.OnLeave(Model) end
	end
	LastHighlighted = nil
	Highlight.Parent = nil

	if AncestryConnection then
		AncestryConnection:Disconnect()
		AncestryConnection = nil
	end
end

local function RebuildSorted(
	Source: {[string]: {OnEnter: (Model) -> (), OnLeave: ((Model) -> ())?, Priority: number}},
	Target: {{OnEnter: (Model) -> (), OnLeave: ((Model) -> ())?, Priority: number}}
)
	table.clear(Target)
	for _, Entry in pairs(Source) do
		Target[#Target + 1] = Entry
	end
	table.sort(Target, function(A :{Priority :number}, B)
		return A.Priority > B.Priority
	end)
end

function View.OnTowerHighlight(ID: string, OnEnter: (Model) -> (), OnLeave: ((Model) -> ())?, Priority: number?)
	View.TowersFunctions[ID] = {
		OnEnter = OnEnter,
		OnLeave = OnLeave,
		Priority = Priority or 0,
	}
	DirtyTowers = true
end

function View.OnNPCHighlight(ID: string, OnEnter: (Model) -> (), OnLeave: ((Model) -> ())?, Priority: number?)
	View.NPCFunctions[ID] = {
		OnEnter = OnEnter,
		OnLeave = OnLeave,
		Priority = Priority or 0,
	}
	
	DirtyNPCs = true
end

function View.UnregisterTower(ID: string)
	View.TowersFunctions[ID] = nil
	DirtyTowers = true
end

function View.UnregisterNPC(ID: string)
	View.NPCFunctions[ID] = nil
	DirtyNPCs = true
end

Collection("ObjectView", function(Object: Model)
	Objects[#Objects + 1] = Object
end, function(Object: Model)
	local Pos = table.find(Objects, Object)
	if Pos then
		table.remove(Objects, Pos)
	end
end)

Stepped.Register("ObjectView", function(time: number, dt: number)
	if DirtyTowers then
		RebuildSorted(View.TowersFunctions, SortedTowers)
		DirtyTowers = false
	end

	if DirtyNPCs then
		RebuildSorted(View.NPCFunctions, SortedNPCs)
		DirtyNPCs = false
	end
	
	local Params = RaycastParams.new()
	Params.FilterType = Enum.RaycastFilterType.Include
	Params.FilterDescendantsInstances = Objects

	local Result = GetMouseHit(Params)

	if Result and Result.Instance then
		local Parent = Result.Instance:IsA("Model")
			and Result.Instance
			or Result.Instance:FindFirstAncestorOfClass("Model")

		if not Parent then
			if LastHighlighted then
				local SortedList = LastHighlighted:HasTag("TowerModel") and SortedTowers or SortedNPCs
				for _, Entry in ipairs(SortedList) do
					if Entry.OnLeave then Entry.OnLeave(LastHighlighted) end
				end
				
				LastHighlighted = nil
				Highlight.Parent = nil
			end
			return
		end
	
		if LastHighlighted ~= Parent then
			if LastHighlighted then
				FireLeave(LastHighlighted)
			end

			if AncestryConnection then
				AncestryConnection:Disconnect()
			end

			-- Detecta destruição do model
			AncestryConnection = Parent.AncestryChanged:Connect(function()
				if not Parent.Parent then
					FireLeave(Parent)
				end
			end)

			Highlight.Parent = Parent
			LastHighlighted = Parent

			if Parent:HasTag("TowerModel") then
				for _, Entry in ipairs(SortedTowers) do
					Entry.OnEnter(Parent)
				end
			elseif Parent:HasTag("NPCModel") then
				for _, Entry in ipairs(SortedNPCs) do
					Entry.OnEnter(Parent)
				end
			end
		end
	else
		if LastHighlighted then
			local SortedList = LastHighlighted:HasTag("TowerModel") and SortedTowers or SortedNPCs
			for _, Entry in ipairs(SortedList) do
				if Entry.OnLeave then Entry.OnLeave(LastHighlighted) end
			end
			LastHighlighted = nil
			Highlight.Parent = nil
		end
	end
end, 10)

return View