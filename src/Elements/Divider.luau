--!strict
-- Fluent Divider Element (Horizontal separator with optional centered text)

local Creator = require(script.Parent.Parent.Core.Creator)
local Janitor = require(script.Parent.Parent.Core.Janitor)
local Types = require(script.Parent.Parent.Types)

type DividerOptions = Types.DividerOptions

local Divider = {}

function Divider.new(
	parent: Instance,
	themeReg: Creator.ThemeRegistry,
	options: DividerOptions?
)
	local opts = options or ({} :: DividerOptions)
	local janitor = Janitor.new()

	local container = Creator.Create("Frame", {
		Name = "Divider",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, if opts.Text and opts.Text ~= "" then 20 else 10),
		Visible = if opts.Visible == nil then true else opts.Visible,
		Parent = parent,
	}) :: Frame
	janitor:Add(container)

	local hasText = opts.Text ~= nil and opts.Text ~= ""
	if hasText then
		local leftLine = Creator.Create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(0.5, -45, 0, 1),
			BackgroundTransparency = 0.35,
			Parent = container,
		}) :: Frame
		local rightLine = Creator.Create("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.new(0.5, -45, 0, 1),
			BackgroundTransparency = 0.35,
			Parent = container,
		}) :: Frame
		local label = Creator.Create("TextLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 82, 1, 0),
			Text = opts.Text :: string,
			TextSize = 11,
			FontFace = Creator.BoldFont,
			Parent = container,
		}) :: TextLabel

		themeReg:Bind(leftLine, "BackgroundColor3", "Border")
		themeReg:Bind(rightLine, "BackgroundColor3", "Border")
		themeReg:Bind(label, "TextColor3", "MutedText")
	else
		local line = Creator.Create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundTransparency = 0.35,
			Parent = container,
		}) :: Frame
		themeReg:Bind(line, "BackgroundColor3", "Border")
	end

	return {
		Id = "Divider",
		Type = "Divider",
		Frame = container,
		SetVisible = function(_, visible: boolean)
			container.Visible = visible
		end,
		SetDisabled = function() end,
		SetTitle = function() end,
		SetDescription = function() end,
		MatchesSearch = function(_, query: string): boolean
			return query == ""
		end,
		Destroy = function()
			janitor:Destroy()
		end,
	}
end

return Divider
