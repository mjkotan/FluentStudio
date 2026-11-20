--!strict
-- Fluent Modal Dialog Overlay (Confirm / Cancel / Custom Buttons)

local Creator = require(script.Parent.Parent.Core.Creator)
local Sound = require(script.Parent.Parent.Core.Sound)
local Types = require(script.Parent.Parent.Types)

type DialogOptions = Types.DialogOptions

local Dialog = {}

function Dialog.Show(
	rootContainer: Instance,
	themeReg: Creator.ThemeRegistry,
	sound: Sound.SoundControllerType,
	options: DialogOptions
)
	local closed = false

	local backdrop = Creator.Create("TextButton", {
		Name = "DialogBackdrop",
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 80,
		Active = true,
		Parent = rootContainer,
	}) :: TextButton

	local modal = Creator.Create("Frame", {
		Name = "DialogModal",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 16),
		Size = UDim2.new(0, 340, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 81,
		Parent = backdrop,
	}, {
		Creator.Corner(10),
		Creator.Padding(16, 18, 16, 18),
		Creator.Create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 10),
		}),
	}) :: Frame

	local stroke = Creator.Stroke(themeReg.Theme.Border, 1, 0.15)
	stroke.Parent = modal
	themeReg:Bind(modal, "BackgroundColor3", "Background")
	themeReg:Bind(stroke, "Color", "Border")

	local titleLabel = Creator.Create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = options.Title,
		TextSize = 16,
		FontFace = Creator.BoldFont,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		LayoutOrder = 1,
		ZIndex = 82,
		Parent = modal,
	}) :: TextLabel
	themeReg:Bind(titleLabel, "TextColor3", "Text")

	local contentLabel = Creator.Create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = options.Content,
		TextSize = 13,
		FontFace = Creator.RegularFont,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		LineHeight = 1.15,
		LayoutOrder = 2,
		ZIndex = 82,
		Parent = modal,
	}) :: TextLabel
	themeReg:Bind(contentLabel, "TextColor3", "SubText")

	local btnRow = Creator.Create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 32),
		LayoutOrder = 3,
		ZIndex = 82,
		Parent = modal,
	}, {
		Creator.Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = UDim.new(0, 8),
		}),
	}) :: Frame

	local function close()
		if closed then
			return
		end
		closed = true
		Creator.Tween(backdrop, 0.16, { BackgroundTransparency = 1 })
		local tw = Creator.Tween(modal, 0.16, { Position = UDim2.new(0.5, 0, 0.5, 16) })
		tw.Completed:Once(function()
			if backdrop.Parent then
				backdrop:Destroy()
			end
		end)
	end

	local buttons = options.Buttons or {
		{ Title = "OK", Primary = true },
	}

	for _, b in ipairs(buttons) do
		local btn = Creator.Create("TextButton", {
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = b.Title,
			TextSize = 13,
			FontFace = Creator.BoldFont,
			AutoButtonColor = false,
			Selectable = true,
			ZIndex = 83,
			Parent = btnRow,
		}, {
			Creator.Corner(6),
			Creator.Padding(0, 16, 0, 16),
		}) :: TextButton

		if b.Primary then
			themeReg:Bind(btn, "BackgroundColor3", "Accent")
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			themeReg:Bind(btn, "BackgroundColor3", "Surface")
			themeReg:Bind(btn, "TextColor3", "Text")
		end

		btn.Activated:Connect(function()
			sound:Play("Click")
			if b.Callback then
				task.spawn(b.Callback)
			end
			close()
		end)
	end

	Creator.Tween(backdrop, 0.18, { BackgroundTransparency = 0.45 })
	Creator.Tween(modal, 0.22, { Position = UDim2.new(0.5, 0, 0.5, 0) })

	return { Close = close }
end

return Dialog
