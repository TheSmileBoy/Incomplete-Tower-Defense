--!strict
local OptionsStack: TextButton -- template

type OptionContext = {
	IsPlaced: boolean,
	CanUpgrade: boolean,
}

local AllOptions = {"Buy", "Sell", "Upgrade", "Re-move", "Cancel"}

local OptionRules: {[string]: (Context: OptionContext) -> boolean} = {
	Cancel = function()
		return true
	end,
	
	Buy = function(Context) 
		return not Context.IsPlaced 
	end,
	
	Sell = function(Context) 
		return Context.IsPlaced 
	end,
	
	Upgrade  = function(Context)
		return Context.IsPlaced and Context.CanUpgrade
	end,
	
	["Re-move"] = function(Context) 
		return Context.IsPlaced 
	end,
}

return function(Template: TextButton, Parent: ScrollingFrame, Context: OptionContext): {[string]: TextButton}
	for _, Child in (Parent:GetChildren()) do
		if Child:IsA("TextButton") and Child ~= Template then
			Child:Destroy()
		end
	end

	local Created: {[string]: TextButton} = {}

	for _, OptionName in (AllOptions) do
		local IsActive = OptionRules[OptionName](Context)
		if not IsActive then continue end

		local Stack = Template:Clone()
		Stack.Text = OptionName
		Stack.Name = OptionName
		Stack.Visible = true
		Stack.Parent = Parent

		Created[OptionName] = Stack
	end

	Template.Visible = false
	return Created
end