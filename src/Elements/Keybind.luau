--!strict
-- Fluent Keybind Element (Toggle / Hold / Always modes + Interactive Recorder)

local UserInputService = game:GetService("UserInputService")
local Creator = require(script.Parent.Parent.Core.Creator)
local Signal = require(script.Parent.Parent.Core.Signal)
local Sound = require(script.Parent.Parent.Core.Sound)
local BaseElement = require(script.Parent.BaseElement)
local Types = require(script.Parent.Parent.Types)

type KeybindOptions = Types.KeybindOptions
type KeybindMode = Types.KeybindMode

local Keybind = {}

local function resolveKeyCode(key: (Enum.KeyCode | string)?): Enum.KeyCode
	if typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode then
		return key :: Enum.KeyCode
	elseif type(key) == "string" then
		local found = (Enum.KeyCode :: any)[key]
		if found then
			return found
		end
	end
	return Enum.KeyCode.Unknown
end

function Keybind.new(
	parent: Instance,
	themeReg: Creator.ThemeRegistry,
	sound: Sound.SoundControllerType,
	options: KeybindOptions
)
	local card = BaseElement.CreateCard(parent, themeReg, options, 96)
	local currentKey: Enum.KeyCode = resolveKeyCode(options.Default)
	local mode: KeybindMode = options.Mode or "Toggle"
	local active = (mode == "Always")
	local listening = false

	local stateSignal = Signal.new()
	local keyChangedSignal = Signal.new()
	card.Janitor:Add(stateSignal)
	card.Janitor:Add(keyChangedSignal)

	local bindBtn = Creator.Create("TextButton", {
		Name = "KeybindButton",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 88, 0, 26),
		Text = if currentKey == Enum.KeyCode.Unknown then "None" else currentKey.Name,
		TextSize = 12,
		FontFace = Creator.BoldFont,
		AutoButtonColor = false,
		Selectable = true,
		Parent = card.ControlHolder,
	}, {
		Creator.Corner(6),
	}) :: TextButton

	local bindStroke = Creator.Stroke(themeReg.Theme.ElementBorder, 1, 0.2)
	bindStroke.Parent = bindBtn
	themeReg:Bind(bindBtn, "BackgroundColor3", "InputBackground")
	themeReg:Bind(bindBtn, "TextColor3", "Text")
	themeReg:Bind(bindStroke, "Color", "ElementBorder")

	local handle: any

	local function setKey(newKey: Enum.KeyCode, silent: boolean?)
		currentKey = newKey
		handle.Value = currentKey
		bindBtn.Text = if currentKey == Enum.KeyCode.Unknown then "None" else currentKey.Name
		if not silent then
			if options.ChangedCallback then
				task.spawn(options.ChangedCallback, currentKey)
			end
			keyChangedSignal:Fire(currentKey)
		end
	end

	local function setActive(newActive: boolean)
		if active == newActive then
			return
		end
		active = newActive
		if options.Callback then
			task.spawn(options.Callback, active)
		end
		stateSignal:Fire(active)
	end

	card.Janitor:Add(bindBtn.Activated:Connect(function()
		if card.Disabled or listening then
			return
		end
		sound:Play("Click")
		listening = true
		bindBtn.Text = "..."
		Creator.Tween(bindStroke, 0.12, { Color = themeReg.Theme.Accent })
	end))

	card.Janitor:Add(UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
		if listening then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				listening = false
				Creator.Tween(bindStroke, 0.12, { Color = themeReg.Theme.ElementBorder })
				if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
					setKey(Enum.KeyCode.Unknown, false)
				else
					setKey(input.KeyCode, false)
				end
			end
			return
		end

		if gameProcessed or card.Disabled or currentKey == Enum.KeyCode.Unknown then
			return
		end

		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
			if mode == "Toggle" then
				setActive(not active)
			elseif mode == "Hold" then
				setActive(true)
			end
		end
	end))

	card.Janitor:Add(UserInputService.InputEnded:Connect(function(input: InputObject)
		if mode == "Hold" and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
			setActive(false)
		end
	end))

	handle = setmetatable({
		Type = "Keybind",
		Value = currentKey,
		Default = currentKey,
		Mode = mode,
		Saveable = if options.Saveable == nil then true else options.Saveable,
		GetState = function(): boolean
			if mode == "Always" then
				return true
			end
			return active
		end,
		OnChanged = function(_, fn: (newKey: Enum.KeyCode) -> ())
			return keyChangedSignal:Connect(fn)
		end,
		OnStateChanged = function(_, fn: (isActive: boolean) -> ())
			return stateSignal:Connect(fn)
		end,
		SetValue = function(_, newKey: Enum.KeyCode | string, silent: boolean?)
			setKey(resolveKeyCode(newKey), silent)
		end,
		GetValue = function(): Enum.KeyCode
			return currentKey
		end,
	}, { __index = card })

	return handle
end

return Keybind
