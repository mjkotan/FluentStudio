--!strict
-- Fluent Slider Element (Mouse + Touch friendly, Rounding, Suffix, Silent SetValue)

local UserInputService = game:GetService("UserInputService")
local Creator = require(script.Parent.Parent.Core.Creator)
local Signal = require(script.Parent.Parent.Core.Signal)
local Sound = require(script.Parent.Parent.Core.Sound)
local BaseElement = require(script.Parent.BaseElement)
local Types = require(script.Parent.Parent.Types)

type SliderOptions = Types.SliderOptions

local Slider = {}

local function roundNumber(val: number, decimals: number): number
	local mult = 10 ^ decimals
	return math.floor(val * mult + 0.5) / mult
end

function Slider.new(
	parent: Instance,
	themeReg: Creator.ThemeRegistry,
	sound: Sound.SoundControllerType,
	options: SliderOptions
)
	local card = BaseElement.CreateCard(parent, themeReg, options, 175)
	local minVal = options.Min
	local maxVal = math.max(options.Max, minVal + 0.001)
	local rounding = options.Rounding or 0
	local suffix = options.Suffix or ""
	local value = roundNumber(math.clamp(options.Default or minVal, minVal, maxVal), rounding)

	local changedSignal = Signal.new()
	card.Janitor:Add(changedSignal)

	local valueLabel = Creator.Create("TextLabel", {
		Name = "ValueLabel",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 46, 0, 20),
		Text = tostring(value) .. suffix,
		TextSize = 12,
		FontFace = Creator.BoldFont,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = card.ControlHolder,
	}) :: TextLabel
	themeReg:Bind(valueLabel, "TextColor3", "SubText")

	-- Larger invisible hitbox for easier Touch / Mobile dragging
	local hitArea = Creator.Create("TextButton", {
		Name = "SliderHitArea",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, -52, 0, 26),
		Text = "",
		AutoButtonColor = false,
		Selectable = true,
		Parent = card.ControlHolder,
	}) :: TextButton

	local rail = Creator.Create("Frame", {
		Name = "Rail",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0, 5),
		Parent = hitArea,
	}, {
		Creator.Corner(3),
	}) :: Frame
	themeReg:Bind(rail, "BackgroundColor3", "InputBackground")

	local fill = Creator.Create("Frame", {
		Name = "Fill",
		Size = UDim2.new(0, 0, 1, 0),
		Parent = rail,
	}, {
		Creator.Corner(3),
	}) :: Frame
	themeReg:Bind(fill, "BackgroundColor3", "Accent")

	local thumb = Creator.Create("Frame", {
		Name = "Thumb",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 14, 0, 14),
		ZIndex = 3,
		Parent = rail,
	}, {
		Creator.Corner(7),
	}) :: Frame
	themeReg:Bind(thumb, "BackgroundColor3", "Text")

	local thumbStroke = Creator.Stroke(themeReg.Theme.Accent, 2, 0)
	thumbStroke.Parent = thumb
	themeReg:Bind(thumbStroke, "Color", "Accent")

	local function updateVisuals(animate: boolean)
		local alpha = math.clamp((value - minVal) / (maxVal - minVal), 0, 1)
		valueLabel.Text = tostring(value) .. suffix
		if animate then
			Creator.Tween(fill, 0.08, { Size = UDim2.new(alpha, 0, 1, 0) })
			Creator.Tween(thumb, 0.08, { Position = UDim2.new(alpha, 0, 0.5, 0) })
		else
			fill.Size = UDim2.new(alpha, 0, 1, 0)
			thumb.Position = UDim2.new(alpha, 0, 0.5, 0)
		end
	end

	updateVisuals(false)

	local handle: any
	local function setValue(newVal: number, silent: boolean?)
		local clamped = roundNumber(math.clamp(newVal, minVal, maxVal), rounding)
		if clamped == value then
			updateVisuals(true)
			return
		end
		value = clamped
		handle.Value = value
		updateVisuals(true)

		if not silent then
			if options.Callback then
				task.spawn(options.Callback, value)
			end
			changedSignal:Fire(value)
		end
	end

	local dragging = false
	local function updateFromX(inputX: number)
		local absPos = rail.AbsolutePosition.X
		local absSize = rail.AbsoluteSize.X
		if absSize <= 0 then
			return
		end
		local alpha = math.clamp((inputX - absPos) / absSize, 0, 1)
		local raw = minVal + (maxVal - minVal) * alpha
		setValue(raw, false)
	end

	card.Janitor:Add(hitArea.InputBegan:Connect(function(input: InputObject)
		if card.Disabled then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			sound:Play("Click")
			updateFromX(input.Position.X)
		end
	end))

	card.Janitor:Add(UserInputService.InputChanged:Connect(function(input: InputObject)
		if not dragging then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			updateFromX(input.Position.X)
		end
	end))

	card.Janitor:Add(UserInputService.InputEnded:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end))

	handle = setmetatable({
		Type = "Slider",
		Value = value,
		Default = value,
		Saveable = if options.Saveable == nil then true else options.Saveable,
		OnChanged = function(_, fn: (val: number) -> ())
			return changedSignal:Connect(fn)
		end,
		SetValue = function(_, newVal: number, silent: boolean?)
			setValue(newVal, silent)
		end,
		GetValue = function(): number
			return value
		end,
	}, { __index = card })

	return handle
end

return Slider
