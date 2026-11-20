--!strict
-- Fluent Button Element

local Creator = require(script.Parent.Parent.Core.Creator)
local Sound = require(script.Parent.Parent.Core.Sound)
local BaseElement = require(script.Parent.BaseElement)
local Types = require(script.Parent.Parent.Types)

type ButtonOptions = Types.ButtonOptions

local Button = {}

function Button.new(
	parent: Instance,
	themeReg: Creator.ThemeRegistry,
	sound: Sound.SoundControllerType,
	options: ButtonOptions
)
	local card = BaseElement.CreateCard(parent, themeReg, options, 110)

	local btn = Creator.Create("TextButton", {
		Name = "ActionButton",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 100, 0, 28),
		Text = options.ButtonText or "Run",
		TextSize = 13,
		FontFace = Creator.BoldFont,
		AutoButtonColor = false,
		Selectable = true,
		Parent = card.ControlHolder,
	}, {
		Creator.Corner(6),
	}) :: TextButton

	local btnStroke = Creator.Stroke(themeReg.Theme.ElementBorder, 1, 0.2)
	btnStroke.Parent = btn

	themeReg:Bind(btn, "BackgroundColor3", "Surface")
	themeReg:Bind(btn, "TextColor3", "Text")
	themeReg:Bind(btnStroke, "Color", "ElementBorder")

	card.Janitor:Add(btn.MouseEnter:Connect(function()
		if card.Disabled then
			return
		end
		sound:Play("Hover")
		Creator.Tween(btn, 0.14, { BackgroundColor3 = themeReg.Theme.SurfaceHover })
	end))

	card.Janitor:Add(btn.MouseLeave:Connect(function()
		Creator.Tween(btn, 0.14, { BackgroundColor3 = themeReg.Theme.Surface })
	end))

	card.Janitor:Add(btn.MouseButton1Down:Connect(function()
		if card.Disabled then
			return
		end
		Creator.Tween(btn, 0.08, { BackgroundColor3 = themeReg.Theme.SurfaceActive })
	end))

	card.Janitor:Add(btn.MouseButton1Up:Connect(function()
		if card.Disabled then
			return
		end
		Creator.Tween(btn, 0.12, { BackgroundColor3 = themeReg.Theme.SurfaceHover })
	end))

	card.Janitor:Add(btn.Activated:Connect(function()
		if card.Disabled then
			return
		end
		sound:Play("Click")
		if options.Callback then
			task.spawn(options.Callback)
		end
	end))

	local handle = setmetatable({
		Type = "Button",
		SetButtonText = function(_, text: string)
			btn.Text = text
		end,
	}, { __index = card })

	return handle
end

return Button
