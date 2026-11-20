--!strict
-- Fluent Text Input Element (Numeric, Finished-only, MaxLength, Silent SetValue)

local Creator = require(script.Parent.Parent.Core.Creator)
local Signal = require(script.Parent.Parent.Core.Signal)
local Sound = require(script.Parent.Parent.Core.Sound)
local BaseElement = require(script.Parent.BaseElement)
local Types = require(script.Parent.Parent.Types)

type InputOptions = Types.InputOptions

local Input = {}

function Input.new(
	parent: Instance,
	themeReg: Creator.ThemeRegistry,
	sound: Sound.SoundControllerType,
	options: InputOptions
)
	local card = BaseElement.CreateCard(parent, themeReg, options, 160)
	local value = options.Default or ""
	local numeric = options.Numeric == true
	local finishedOnly = options.Finished == true
	local maxLength = options.MaxLength

	local changedSignal = Signal.new()
	card.Janitor:Add(changedSignal)

	local boxWrap = Creator.Create("Frame", {
		Name = "InputWrap",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0, 28),
		Parent = card.ControlHolder,
	}, {
		Creator.Corner(6),
		Creator.Padding(0, 8, 0, 8),
	}) :: Frame

	local boxStroke = Creator.Stroke(themeReg.Theme.ElementBorder, 1, 0.2)
	boxStroke.Parent = boxWrap
	themeReg:Bind(boxWrap, "BackgroundColor3", "InputBackground")
	themeReg:Bind(boxStroke, "Color", "ElementBorder")

	local textBox = Creator.Create("TextBox", {
		Name = "TextBox",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Text = value,
		PlaceholderText = options.Placeholder or "Type here...",
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		ClipsDescendants = true,
		Selectable = true,
		Parent = boxWrap,
	}) :: TextBox
	themeReg:Bind(textBox, "TextColor3", "Text")
	themeReg:Bind(textBox, "PlaceholderColor3", "MutedText")

	local handle: any
	local isSettingInternally = false

	local function sanitize(raw: string): string
		local out = raw
		if numeric then
			out = string.gsub(out, "[^%d%.%-]", "")
		end
		if maxLength and #out > maxLength then
			out = string.sub(out, 1, maxLength)
		end
		return out
	end

	local function applyValue(newVal: string, silent: boolean?)
		local clean = sanitize(newVal)
		if textBox.Text ~= clean then
			isSettingInternally = true
			textBox.Text = clean
			isSettingInternally = false
		end
		if clean == value then
			return
		end
		value = clean
		handle.Value = value
		if not silent then
			if options.Callback then
				task.spawn(options.Callback, value)
			end
			changedSignal:Fire(value)
		end
	end

	card.Janitor:Add(textBox.Focused:Connect(function()
		if card.Disabled then
			textBox:ReleaseFocus()
			return
		end
		sound:Play("Click")
		Creator.Tween(boxStroke, 0.14, { Color = themeReg.Theme.Accent })
	end))

	card.Janitor:Add(textBox.FocusLost:Connect(function()
		Creator.Tween(boxStroke, 0.14, { Color = themeReg.Theme.ElementBorder })
		applyValue(textBox.Text, false)
	end))

	card.Janitor:Add(textBox:GetPropertyChangedSignal("Text"):Connect(function()
		if isSettingInternally then
			return
		end
		local clean = sanitize(textBox.Text)
		if clean ~= textBox.Text then
			isSettingInternally = true
			textBox.Text = clean
			isSettingInternally = false
		end
		if not finishedOnly then
			applyValue(clean, false)
		end
	end))

	handle = setmetatable({
		Type = "Input",
		Value = value,
		Default = value,
		Saveable = if options.Saveable == nil then true else options.Saveable,
		OnChanged = function(_, fn: (val: string) -> ())
			return changedSignal:Connect(fn)
		end,
		SetValue = function(_, newVal: string, silent: boolean?)
			applyValue(tostring(newVal or ""), silent)
		end,
		GetValue = function(): string
			return value
		end,
	}, { __index = card })

	return handle
end

return Input
