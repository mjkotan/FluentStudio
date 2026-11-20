--!strict
-- Fluent Colorpicker Element (HSV Pad + Hue Slider + Hex Input + Optional Transparency)

local UserInputService = game:GetService("UserInputService")
local Creator = require(script.Parent.Parent.Core.Creator)
local Signal = require(script.Parent.Parent.Core.Signal)
local Sound = require(script.Parent.Parent.Core.Sound)
local BaseElement = require(script.Parent.BaseElement)
local Types = require(script.Parent.Parent.Types)

type ColorpickerOptions = Types.ColorpickerOptions

local Colorpicker = {}

local function colorToHex(c: Color3): string
	return string.format("#%02X%02X%02X", math.round(c.R * 255), math.round(c.G * 255), math.round(c.B * 255))
end

function Colorpicker.new(
	parent: Instance,
	themeReg: Creator.ThemeRegistry,
	sound: Sound.SoundControllerType,
	options: ColorpickerOptions
)
	local card = BaseElement.CreateCard(parent, themeReg, options, 56)
	local value: Color3 = options.Default or Color3.fromRGB(96, 205, 255)
	local transparency: number? = options.Transparency
	local h, s, v = value:ToHSV()
	local isOpen = false

	local changedSignal = Signal.new()
	card.Janitor:Add(changedSignal)

	local swatch = Creator.Create("TextButton", {
		Name = "ColorSwatch",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 44, 0, 24),
		BackgroundColor3 = value,
		Text = "",
		AutoButtonColor = false,
		Selectable = true,
		Parent = card.ControlHolder,
	}, {
		Creator.Corner(6),
	}) :: TextButton
	local swatchStroke = Creator.Stroke(themeReg.Theme.ElementBorder, 1, 0.15)
	swatchStroke.Parent = swatch
	themeReg:Bind(swatchStroke, "Color", "ElementBorder")

	-- Expandable Picker Drawer
	local drawer = Creator.Create("Frame", {
		Name = "ColorDrawer",
		Position = UDim2.new(0, 0, 0, 40),
		Size = UDim2.new(1, 0, 0, 0),
		ClipsDescendants = true,
		Visible = false,
		Parent = card.Frame,
	}, {
		Creator.Corner(6),
		Creator.Padding(8, 8, 8, 8),
	}) :: Frame
	local drawerStroke = Creator.Stroke(themeReg.Theme.ElementBorder, 1, 0.3)
	drawerStroke.Parent = drawer
	themeReg:Bind(drawer, "BackgroundColor3", "InputBackground")
	themeReg:Bind(drawerStroke, "Color", "ElementBorder")

	-- Saturation / Value Box
	local svBox = Creator.Create("TextButton", {
		Name = "SVBox",
		Size = UDim2.new(1, -28, 0, 108),
		BackgroundColor3 = Color3.fromHSV(h, 1, 1),
		Text = "",
		AutoButtonColor = false,
		Parent = drawer,
	}, {
		Creator.Corner(5),
	}) :: TextButton

	-- White horizontal gradient (Saturation)
	local satOverlay = Creator.Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Parent = svBox,
	}, {
		Creator.Corner(5),
		Creator.Create("UIGradient", {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 1),
			}),
		}),
	}) :: Frame
	local _ = satOverlay

	-- Black vertical gradient (Value)
	local valOverlay = Creator.Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		ZIndex = 2,
		Parent = svBox,
	}, {
		Creator.Corner(5),
		Creator.Create("UIGradient", {
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(1, 0),
			}),
		}),
	}) :: Frame
	local _2 = valOverlay

	local svCursor = Creator.Create("Frame", {
		Name = "Cursor",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(s, 0, 1 - v, 0),
		Size = UDim2.new(0, 12, 0, 12),
		BackgroundTransparency = 1,
		ZIndex = 4,
		Parent = svBox,
	}, {
		Creator.Corner(6),
		Creator.Stroke(Color3.fromRGB(255, 255, 255), 2, 0),
	}) :: Frame

	-- Vertical Hue Bar
	local hueBar = Creator.Create("TextButton", {
		Name = "HueBar",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0, 18, 0, 108),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Text = "",
		AutoButtonColor = false,
		Parent = drawer,
	}, {
		Creator.Corner(5),
		Creator.Create("UIGradient", {
			Rotation = 90,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0.00, Color3.fromHSV(0.00, 1, 1)),
				ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
				ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
				ColorSequenceKeypoint.new(0.50, Color3.fromHSV(0.50, 1, 1)),
				ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
				ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
				ColorSequenceKeypoint.new(1.00, Color3.fromHSV(1.00, 1, 1)),
			}),
		}),
	}) :: TextButton

	local hueCursor = Creator.Create("Frame", {
		Name = "HueCursor",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, h, 0),
		Size = UDim2.new(1, 4, 0, 6),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		ZIndex = 3,
		Parent = hueBar,
	}, {
		Creator.Corner(3),
	}) :: Frame

	local hexLabel = Creator.Create("TextLabel", {
		Name = "HexReadout",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 114),
		Size = UDim2.new(1, 0, 0, 18),
		Text = colorToHex(value),
		TextSize = 12,
		FontFace = Creator.BoldFont,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = drawer,
	}) :: TextLabel
	themeReg:Bind(hexLabel, "TextColor3", "SubText")

	local handle: any
	local function updateVisuals()
		swatch.BackgroundColor3 = value
		svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		svCursor.Position = UDim2.new(s, 0, 1 - v, 0)
		hueCursor.Position = UDim2.new(0.5, 0, h, 0)
		hexLabel.Text = colorToHex(value)
	end

	local function applyColor(silent: boolean?)
		value = Color3.fromHSV(h, s, v)
		handle.Value = value
		handle.Transparency = transparency
		updateVisuals()
		if not silent then
			if options.Callback then
				task.spawn(options.Callback, value, transparency)
			end
			changedSignal:Fire(value, transparency)
		end
	end

	local dragMode: ("sv" | "hue")? = nil

	local function handleInputPos(pos: Vector3)
		if dragMode == "sv" then
			local rx = math.clamp((pos.X - svBox.AbsolutePosition.X) / math.max(svBox.AbsoluteSize.X, 1), 0, 1)
			local ry = math.clamp((pos.Y - svBox.AbsolutePosition.Y) / math.max(svBox.AbsoluteSize.Y, 1), 0, 1)
			s = rx
			v = 1 - ry
			applyColor(false)
		elseif dragMode == "hue" then
			local ry = math.clamp((pos.Y - hueBar.AbsolutePosition.Y) / math.max(hueBar.AbsoluteSize.Y, 1), 0, 1)
			h = ry
			applyColor(false)
		end
	end

	card.Janitor:Add(svBox.InputBegan:Connect(function(input: InputObject)
		if card.Disabled then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragMode = "sv"
			handleInputPos(input.Position)
		end
	end))

	card.Janitor:Add(hueBar.InputBegan:Connect(function(input: InputObject)
		if card.Disabled then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragMode = "hue"
			handleInputPos(input.Position)
		end
	end))

	card.Janitor:Add(UserInputService.InputChanged:Connect(function(input: InputObject)
		if not dragMode then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			handleInputPos(input.Position)
		end
	end))

	card.Janitor:Add(UserInputService.InputEnded:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragMode = nil
		end
	end))

	card.Janitor:Add(swatch.Activated:Connect(function()
		if card.Disabled then
			return
		end
		sound:Play("Click")
		isOpen = not isOpen
		if isOpen then
			local topOffset = math.max(card.TextArea.AbsoluteSize.Y + 8, 36)
			drawer.Position = UDim2.new(0, 0, 0, topOffset)
			drawer.Visible = true
			Creator.Tween(drawer, 0.18, { Size = UDim2.new(1, 0, 0, 150) })
			card.ControlHolder.AnchorPoint = Vector2.new(1, 0)
			card.ControlHolder.Position = UDim2.new(1, 0, 0, 2)
		else
			local tw = Creator.Tween(drawer, 0.14, { Size = UDim2.new(1, 0, 0, 0) })
			tw.Completed:Once(function()
				if not isOpen then
					drawer.Visible = false
					card.ControlHolder.AnchorPoint = Vector2.new(1, 0.5)
					card.ControlHolder.Position = UDim2.new(1, 0, 0.5, 0)
				end
			end)
		end
	end))

	handle = setmetatable({
		Type = "Colorpicker",
		Value = value,
		Transparency = transparency,
		Default = value,
		Saveable = if options.Saveable == nil then true else options.Saveable,
		OnChanged = function(_, fn: (col: Color3, trans: number?) -> ())
			return changedSignal:Connect(fn)
		end,
		SetValue = function(_, newColor: Color3, newTrans: number?, silent: boolean?)
			if typeof(newColor) ~= "Color3" then
				return
			end
			h, s, v = newColor:ToHSV()
			if newTrans ~= nil then
				transparency = newTrans
			end
			applyColor(silent)
		end,
		GetValue = function(): Color3
			return value
		end,
	}, { __index = card })

	return handle
end

return Colorpicker
