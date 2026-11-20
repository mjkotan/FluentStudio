--!strict
-- Fluent Image Preview Card Element

local Creator = require(script.Parent.Parent.Core.Creator)
local Janitor = require(script.Parent.Parent.Core.Janitor)
local Icons = require(script.Parent.Parent.Icons)
local Types = require(script.Parent.Parent.Types)

type ImageOptions = Types.ImageOptions

local ImageElement = {}

function ImageElement.new(
	parent: Instance,
	themeReg: Creator.ThemeRegistry,
	options: ImageOptions
)
	local janitor = Janitor.new()

	local card = Creator.Create("Frame", {
		Name = "ImageCard_" .. (options.Id or "Image"),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Visible = if options.Visible == nil then true else options.Visible,
		Parent = parent,
	}, {
		Creator.Corner(8),
		Creator.Padding(10, 12, 10, 12),
		Creator.Create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6),
		}),
	}) :: Frame

	local stroke = Creator.Stroke(themeReg.Theme.ElementBorder, 1, 0.25)
	stroke.Parent = card
	themeReg:Bind(card, "BackgroundColor3", "Element")
	themeReg:Bind(stroke, "Color", "ElementBorder")
	janitor:Add(card)

	local titleLabel: TextLabel? = nil
	if options.Title and options.Title ~= "" then
		titleLabel = Creator.Create("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Text = options.Title,
			TextSize = 14,
			FontFace = Creator.BoldFont,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			LayoutOrder = 1,
			Parent = card,
		}) :: TextLabel
		themeReg:Bind(titleLabel :: TextLabel, "TextColor3", "Text")
	end

	local img = Creator.Create("ImageLabel", {
		Name = "PreviewImage",
		BackgroundTransparency = 0,
		Size = UDim2.new(1, 0, 0, options.Height or 140),
		Image = Icons.Resolve(options.Image),
		ScaleType = options.ScaleType or Enum.ScaleType.Fit,
		LayoutOrder = 2,
		Parent = card,
	}, {
		Creator.Corner(6),
	}) :: ImageLabel
	themeReg:Bind(img, "BackgroundColor3", "InputBackground")

	local captionLabel = Creator.Create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = options.Caption or "",
		TextSize = 12,
		FontFace = Creator.RegularFont,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Visible = options.Caption ~= nil and options.Caption ~= "",
		LayoutOrder = 3,
		Parent = card,
	}) :: TextLabel
	themeReg:Bind(captionLabel, "TextColor3", "SubText")

	return {
		Id = options.Id or "Image",
		Type = "Image",
		Frame = card,
		SetImage = function(_, assetId: string)
			img.Image = Icons.Resolve(assetId)
		end,
		SetCaption = function(_, caption: string?)
			captionLabel.Text = caption or ""
			captionLabel.Visible = caption ~= nil and caption ~= ""
		end,
		SetVisible = function(_, visible: boolean)
			card.Visible = visible
		end,
		SetDisabled = function() end,
		SetTitle = function(_, title: string)
			if titleLabel then
				titleLabel.Text = title
			end
		end,
		SetDescription = function(_, desc: string?)
			captionLabel.Text = desc or ""
			captionLabel.Visible = desc ~= nil and desc ~= ""
		end,
		MatchesSearch = function(_, query: string): boolean
			if query == "" then
				return true
			end
			local q = string.lower(query)
			if titleLabel and string.find(string.lower(titleLabel.Text), q, 1, true) then
				return true
			end
			if string.find(string.lower(captionLabel.Text), q, 1, true) then
				return true
			end
			return false
		end,
		Destroy = function()
			janitor:Destroy()
		end,
	}
end

return ImageElement
