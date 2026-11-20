--!strict
-- Rich Notification Stack (Countdown Progress Bar + Optional Action Buttons)

local Creator = require(script.Parent.Parent.Core.Creator)
local Sound = require(script.Parent.Parent.Core.Sound)
local Icons = require(script.Parent.Parent.Icons)
local Types = require(script.Parent.Parent.Types)

type NotifyOptions = Types.NotifyOptions

local Notification = {}

function Notification.CreateStack(screenGui: ScreenGui): Frame
	local holder = Creator.Create("Frame", {
		Name = "NotificationStack",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -18, 1, -18),
		Size = UDim2.new(0, 310, 1, -36),
		ZIndex = 50,
		Parent = screenGui,
	}, {
		Creator.Create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = UDim.new(0, 8),
		}),
	}) :: Frame
	return holder
end

function Notification.Show(
	stackHolder: Frame,
	themeReg: Creator.ThemeRegistry,
	sound: Sound.SoundControllerType,
	options: NotifyOptions
)
	sound:Play("Notify")
	local duration = options.Duration or 4.5
	local dismissed = false

	local card = Creator.Create("Frame", {
		Name = "NotifyCard",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = 51,
		Parent = stackHolder,
	}, {
		Creator.Corner(9),
	}) :: Frame

	local inner = Creator.Create("Frame", {
		Name = "Inner",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.new(1, 30, 0, 0),
		ZIndex = 52,
		Parent = card,
	}, {
		Creator.Corner(9),
		Creator.Padding(11, 12, 14, 12),
		Creator.Create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 4),
		}),
	}) :: Frame

	local stroke = Creator.Stroke(themeReg.Theme.Border, 1, 0.2)
	stroke.Parent = inner
	themeReg:Bind(inner, "BackgroundColor3", "Background")
	themeReg:Bind(inner, "BackgroundTransparency", "BackgroundTransparency")
	themeReg:Bind(stroke, "Color", "Border")

	-- Header Row
	local header = Creator.Create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		LayoutOrder = 1,
		ZIndex = 53,
		Parent = inner,
	}) :: Frame

	local iconAsset = Icons.Resolve(options.Icon or "bell")
	if iconAsset ~= "" then
		local iconImg = Creator.Create("ImageLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 16, 0, 16),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Image = iconAsset,
			ZIndex = 54,
			Parent = header,
		}) :: ImageLabel
		themeReg:Bind(iconImg, "ImageColor3", "Accent")
	end

	local titleLabel = Creator.Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, if iconAsset ~= "" then 22 else 0, 0, 0),
		Size = UDim2.new(1, -44, 1, 0),
		Text = options.Title,
		TextSize = 14,
		FontFace = Creator.BoldFont,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 54,
		Parent = header,
	}) :: TextLabel
	themeReg:Bind(titleLabel, "TextColor3", "Text")

	local closeBtn = Creator.Create("ImageButton", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 14, 0, 14),
		Image = Icons.Resolve("x"),
		ZIndex = 54,
		Parent = header,
	}) :: ImageButton
	themeReg:Bind(closeBtn, "ImageColor3", "MutedText")

	-- Body Content
	local bodyLabel = Creator.Create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = options.Content,
		TextSize = 12,
		FontFace = Creator.RegularFont,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		LineHeight = 1.15,
		LayoutOrder = 2,
		ZIndex = 53,
		Parent = inner,
	}) :: TextLabel
	themeReg:Bind(bodyLabel, "TextColor3", "SubText")

	if options.SubContent and options.SubContent ~= "" then
		local subLabel = Creator.Create("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Text = options.SubContent,
			TextSize = 11,
			FontFace = Creator.RegularFont,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			LayoutOrder = 3,
			ZIndex = 53,
			Parent = inner,
		}) :: TextLabel
		themeReg:Bind(subLabel, "TextColor3", "MutedText")
	end

	local function dismiss()
		if dismissed then
			return
		end
		dismissed = true
		local tw = Creator.Tween(inner, 0.22, { Position = UDim2.new(1, 40, 0, 0) })
		tw.Completed:Once(function()
			if card.Parent then
				card:Destroy()
			end
		end)
	end

	-- Optional Action Buttons
	if options.Actions and #options.Actions > 0 then
		local actionRow = Creator.Create("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 26),
			LayoutOrder = 4,
			ZIndex = 53,
			Parent = inner,
		}, {
			Creator.Create("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				Padding = UDim.new(0, 6),
			}),
		}) :: Frame

		for _, act in ipairs(options.Actions) do
			local btn = Creator.Create("TextButton", {
				Size = UDim2.new(0, 0, 1, 0),
				AutomaticSize = Enum.AutomaticSize.X,
				Text = act.Title,
				TextSize = 12,
				FontFace = Creator.BoldFont,
				AutoButtonColor = false,
				ZIndex = 54,
				Parent = actionRow,
			}, {
				Creator.Corner(5),
				Creator.Padding(0, 10, 0, 10),
			}) :: TextButton

			if act.Primary then
				themeReg:Bind(btn, "BackgroundColor3", "Accent")
				btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			else
				themeReg:Bind(btn, "BackgroundColor3", "Surface")
				themeReg:Bind(btn, "TextColor3", "Text")
			end

			btn.Activated:Connect(function()
				sound:Play("Click")
				if act.Callback then
					task.spawn(act.Callback)
				end
				dismiss()
			end)
		end
	end

	-- Countdown Progress Bar
	local progressBar = Creator.Create("Frame", {
		Name = "CountdownBar",
		Size = UDim2.new(1, 0, 0, 3),
		LayoutOrder = 5,
		ZIndex = 54,
		Parent = inner,
	}, {
		Creator.Corner(2),
	}) :: Frame
	themeReg:Bind(progressBar, "BackgroundColor3", "Accent")

	closeBtn.Activated:Connect(function()
		sound:Play("Click")
		dismiss()
	end)

	-- Slide in
	Creator.Tween(inner, 0.25, { Position = UDim2.new(0, 0, 0, 0) })
	if duration > 0 then
		Creator.Tween(progressBar, duration, { Size = UDim2.new(0, 0, 0, 3) }, Enum.EasingStyle.Linear)
		task.delay(duration, dismiss)
	end

	return { Dismiss = dismiss }
end

return Notification
