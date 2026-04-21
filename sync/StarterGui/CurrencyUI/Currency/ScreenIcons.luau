--[[
 Isn't made by Smile
]]
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGUI = Player.PlayerGui

local Camera = workspace.CurrentCamera
local Viewport = Camera.ViewportSize

local ScreenEffects = PlayerGUI:WaitForChild("ScreenEffects")
local Clone = script:WaitForChild("CloneLabel")

export type Icons = {
	StartPos : Vector2?,
	RandomStart : boolean?,

	TargetFrame : GuiObject,
	UseBezierChance : number?,

	Speed : number?,
	ImageID :string,
}

local QueuStarted = false

local Module = {}

local ActiveTextAnimations = {}
local ActiveBezier = {}

local function QuadraticBezier(p0, p1, p2, t)
	return (1 - t)^2 * p0 + 2 * (1 - t) * t * p1 + t^2 * p2
end

local function StartQueue()
	if QueuStarted then return end
	QueuStarted = true
	
	local Connection
	Connection = RunService.RenderStepped:Connect(function(dt)
		if #ActiveBezier == 0 and #ActiveTextAnimations == 0 then
			Connection:Disconnect()
			QueuStarted = false
			return
		end
		
		for i = #ActiveTextAnimations, 1, -1 do
			local data = ActiveTextAnimations[i]
			
			if not data then
				continue
			end
			data.Time += dt
			local alpha = data.Time / data.Duration

			if alpha >= 1 then
				data.Icon.TextLabel.TextSize = data.Icon.TextLabel.AbsoluteSize.Y
				data.Icon.TextLabel.Text = "+" .. math.floor(data.Increment)
				table.remove(ActiveTextAnimations, i)
			else
				local value = data.Increment * alpha
				data.Icon.TextLabel.Text = "+" .. math.floor(value)
			end
		end
		
		for i = #ActiveBezier, 1, -1 do
			local data = ActiveBezier[i]
			
			if not data then
				continue
			end
			
			data.Time += dt
			local t = data.Time / data.Duration

			t = math.clamp(t, 0, 1)
			t = t * t

			if t >= 1 then
				data.OnTarget()
				data.Icon.Position = UDim2.new(0, data.Target.X, 0, data.Target.Y)
				data.Icon:Destroy()
				table.remove(ActiveBezier, i)
				continue
			end

			local pos = QuadraticBezier(data.Start, data.Control, data.Target, t)
			data.Icon.Position = UDim2.new(0, pos.X, 0, pos.Y)
		end
	end)
end

local function CreateIcon(Params)
	local Icon = Clone:Clone()
	Icon.Image = Params.ImageID
	Icon.Visible = true
	Icon.TextLabel.Text = "+0"
	
	Icon.TextLabel.TextSize = Icon.TextLabel.AbsoluteSize.Y
	Icon.TextLabel.UIGradient.Color = Params.Color
	Icon.ImageTransparency = 1
	Icon.TextLabel.TextTransparency = 1
	Icon.TextLabel.UIStroke.Transparency = 1

	Icon.Parent = ScreenEffects.Frame
	
	return Icon
end

local function FadeInIcon(Icon)
	local TweenInfoIn = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	TweenService:Create(Icon, TweenInfoIn, {
		ImageTransparency = 0
	}):Play()

	TweenService:Create(Icon.TextLabel, TweenInfoIn, {
		TextTransparency = 0
	}):Play()

	if Icon.TextLabel.UIStroke then
		TweenService:Create(Icon.TextLabel.UIStroke, TweenInfoIn, {
			Transparency = 0
		}):Play()
	end
end

local function GetStartPos(Params, TargetPos)
	local zone = math.random(1, 3)

	if zone == 1 then
		return Vector2.new(
			math.random(0, Viewport.X),
			math.random(Viewport.Y * 0.7, Viewport.Y)
		)

	elseif zone == 2 then
		return Vector2.new(
			math.random(Viewport.X * 0.5, Viewport.X),
			math.random(0, Viewport.Y)
		)

	else
		return Vector2.new(
			math.random(Viewport.X * 0.5, Viewport.X),
			math.random(Viewport.Y * 0.3, Viewport.Y)
		)
	end
end

local function AnimateText(Icon, Increment)
	StartQueue()
	table.insert(ActiveTextAnimations, {
		Icon = Icon,
		Increment = Increment,
		Time = 0,
		Duration = 0.2
	})
end

local function MoveIcon(Icon, StartPos, TargetPos, Duration, UseBezier, Params)
	if UseBezier then
		local ControlPoint = (StartPos + TargetPos) / 2 + Vector2.new(
			math.random(-100, 100),
			math.random(-100, 100)
		)

		table.insert(ActiveBezier, {
			Icon = Icon,
			Start = StartPos,
			Control = ControlPoint,
			Target = TargetPos,
			OnTarget = Params.OnTarget,
			Time = 0,
			Duration = Duration,
		})
		
		StartQueue()
	else
		local tween = TweenService:Create(Icon, TweenInfo.new(
			Duration,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
			), {
				Position = UDim2.new(0, TargetPos.X, 0, TargetPos.Y)
			})

		tween:Play()
		tween.Completed:Connect(function()
			Params.OnTarget()
			Icon:Destroy()
		end)
	end
end

function Module.SpawnIcons(Amount : number, Params : Icons)
	for i = 1, Amount do
		local Icon = CreateIcon(Params)

		local TargetPos = Params.TargetFrame.AbsolutePosition + Vector2.new(0, GuiService:GetGuiInset().Y)
		local StartPos = GetStartPos(Params, TargetPos)

		Icon.Position = UDim2.new(0, StartPos.X, 0, StartPos.Y)

		local distance = (TargetPos - StartPos).Magnitude
		local speed = Params.Speed * 1000
		local duration = distance / speed + 0.25

		local UseBezier = math.random() < (Params.UseBezierChance or 0.5)

		FadeInIcon(Icon)
		AnimateText(Icon, Params.IncrementPerIcon)

		task.delay(0.25, function()
			MoveIcon(Icon, StartPos, TargetPos, duration, UseBezier, Params)
		end)
	end
end

return Module