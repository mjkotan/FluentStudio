--!strict
-- Fluent ProgressBar Element (Animated real-time status bar)

local Creator = require(script.Parent.Parent.Core.Creator)
local BaseElement = require(script.Parent.BaseElement)
local Types = require(script.Parent.Parent.Types)

type ProgressBarOptions = Types.ProgressBarOptions

local ProgressBar = {}

function ProgressBar.new(
	parent: Instance,
	themeReg: Creator.ThemeRegistry,
	options: ProgressBarOptions
)
	local card = BaseElement.CreateCard(parent, themeReg, {
		Id = options.Id,
		Title = options.Title,
		Description = options.Description,
		Visible = options.Visible,
		Disabled = options.Disabled,
		Saveable = false,
	}, 60)

	local maxVal = math.max(options.Max or 100, 0.001)
	local curVal = math.clamp(options.Value or 0, 0, maxVal)
	local showPercent = if options.ShowPercent == nil then true else options.ShowPercent

	local statusLabel = Creator.Create("TextLabel", {
		Name = "PercentLabel",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0, 18),
		Text = "",
		TextSize = 12,
		FontFace = Creator.BoldFont,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = card.ControlHolder,
	}) :: TextLabel
	themeReg:Bind(statusLabel, "TextColor3", "Accent")

	local barTrack = Creator.Create("Frame", {
		Name = "BarTrack",
		Size = UDim2.new(1, 0, 0, 7),
		LayoutOrder = 3,
		Parent = card.TextArea,
	}, {
		Creator.Corner(4),
	}) :: Frame
	themeReg:Bind(barTrack, "BackgroundColor3", "InputBackground")

	local barFill = Creator.Create("Frame", {
		Name = "BarFill",
		Size = UDim2.new(0, 0, 1, 0),
		Parent = barTrack,
	}, {
		Creator.Corner(4),
	}) :: Frame
	themeReg:Bind(barFill, "BackgroundColor3", "Accent")

	local function render(animate: boolean)
		local alpha = math.clamp(curVal / maxVal, 0, 1)
		if showPercent then
			statusLabel.Text = string.format("%d%%", math.round(alpha * 100))
		else
			statusLabel.Text = string.format("%s/%s", tostring(curVal), tostring(maxVal))
		end
		if animate then
			Creator.Tween(barFill, 0.22, { Size = UDim2.new(alpha, 0, 1, 0) })
		else
			barFill.Size = UDim2.new(alpha, 0, 1, 0)
		end
	end

	render(false)

	local handle = setmetatable({
		Type = "ProgressBar",
		SetValue = function(_, value: number, newMax: number?)
			if newMax then
				maxVal = math.max(newMax, 0.001)
			end
			curVal = math.clamp(value, 0, maxVal)
			render(true)
		end,
		SetLabel = function(_, text: string)
			statusLabel.Text = text
		end,
	}, { __index = card })

	return handle
end

return ProgressBar
