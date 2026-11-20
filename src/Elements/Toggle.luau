--!strict
-- Fluent Toggle Switch Element (supports Silent SetValue for DataStore sync)

local Creator = require(script.Parent.Parent.Core.Creator)
local Signal = require(script.Parent.Parent.Core.Signal)
local Sound = require(script.Parent.Parent.Core.Sound)
local BaseElement = require(script.Parent.BaseElement)
local Types = require(script.Parent.Parent.Types)

type ToggleOptions = Types.ToggleOptions

local Toggle = {}

function Toggle.new(
	parent: Instance,
	themeReg: Creator.ThemeRegistry,
	sound: Sound.SoundControllerType,
	options: ToggleOptions
)
	local card = BaseElement.CreateCard(parent, themeReg, options, 52)
	local value = options.Default == true
	local changedSignal = Signal.new()
	card.Janitor:Add(changedSignal)

	local track = Creator.Create("TextButton", {
		Name = "ToggleTrack",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 44, 0, 22),
		Text = "",
		AutoButtonColor = false,
		Selectable = true,
		Parent = card.ControlHolder,
	}, {
		Creator.Corner(11),
	}) :: TextButton

	local trackStroke = Creator.Stroke(themeReg.Theme.ElementBorder, 1, 0.2)
	trackStroke.Parent = track

	local knob = Creator.Create("Frame", {
		Name = "Knob",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.new(0, 16, 0, 16),
		Parent = track,
	}, {
		Creator.Corner(8),
	}) :: Frame

	local function render(animate: boolean)
		local theme = themeReg.Theme
		local targetBg = if value then theme.Accent else theme.InputBackground
		local targetKnobColor = if value then Color3.fromRGB(255, 255, 255) else theme.SubText
		local targetPos = if value then UDim2.new(1, -19, 0.5, 0) else UDim2.new(0, 3, 0.5, 0)
		local targetStroke = if value then theme.Accent else theme.ElementBorder

		if animate then
			Creator.Tween(track, 0.16, { BackgroundColor3 = targetBg })
			Creator.Tween(trackStroke, 0.16, { Color = targetStroke })
			Creator.Tween(knob, 0.16, { Position = targetPos, BackgroundColor3 = targetKnobColor })
		else
			track.BackgroundColor3 = targetBg
			trackStroke.Color = targetStroke
			knob.Position = targetPos
			knob.BackgroundColor3 = targetKnobColor
		end
	end

	render(false)
	themeReg:OnThemeChanged(function()
		render(true)
	end)

	local handle: any
	local function setValue(newVal: boolean, silent: boolean?)
		local boolVal = newVal == true
		if boolVal == value then
			return
		end
		value = boolVal
		handle.Value = value
		render(true)

		if not silent then
			sound:Play(if value then "ToggleOn" else "ToggleOff")
			if options.Callback then
				task.spawn(options.Callback, value)
			end
			changedSignal:Fire(value)
		end
	end

	card.Janitor:Add(track.Activated:Connect(function()
		if card.Disabled then
			return
		end
		setValue(not value, false)
	end))

	handle = setmetatable({
		Type = "Toggle",
		Value = value,
		Default = options.Default == true,
		Saveable = if options.Saveable == nil then true else options.Saveable,
		OnChanged = function(_, fn: (val: boolean) -> ())
			return changedSignal:Connect(fn)
		end,
		SetValue = function(_, newVal: boolean, silent: boolean?)
			setValue(newVal, silent)
		end,
		GetValue = function(): boolean
			return value
		end,
	}, { __index = card })

	return handle
end

return Toggle
