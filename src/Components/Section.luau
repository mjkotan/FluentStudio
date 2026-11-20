--!strict
-- Collapsible Fluent Section (Accordion Group)

local Creator = require(script.Parent.Parent.Core.Creator)
local Janitor = require(script.Parent.Parent.Core.Janitor)
local Sound = require(script.Parent.Parent.Core.Sound)
local Icons = require(script.Parent.Parent.Icons)
local ConfigManager = require(script.Parent.Parent.Managers.ConfigManager)
local ElementFactory = require(script.Parent.ElementFactory)
local Types = require(script.Parent.Parent.Types)

type SectionOptions = Types.SectionOptions

local Section = {}

function Section.new(
	parent: Instance,
	themeReg: Creator.ThemeRegistry,
	sound: Sound.SoundControllerType,
	config: ConfigManager.ConfigManagerType,
	options: SectionOptions
)
	local janitor = Janitor.new()
	local collapsible = if options.Collapsible == nil then true else options.Collapsible
	local isOpen = if options.DefaultOpen == nil then true else options.DefaultOpen
	local elements: { any } = {}

	local container = Creator.Create("Frame", {
		Name = "Section_" .. options.Title,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 0.25,
		Parent = parent,
	}, {
		Creator.Corner(8),
		Creator.Padding(8, 10, 8, 10),
		Creator.Create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6),
		}),
	}) :: Frame

	local stroke = Creator.Stroke(themeReg.Theme.Border, 1, 0.4)
	stroke.Parent = container
	themeReg:Bind(container, "BackgroundColor3", "Surface")
	themeReg:Bind(stroke, "Color", "Border")
	janitor:Add(container)

	local header = Creator.Create("TextButton", {
		Name = "Header",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 24),
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = 1,
		Selectable = collapsible,
		Parent = container,
	}) :: TextButton

	local titleLabel = Creator.Create("TextLabel", {
		Name = "SectionTitle",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -24, 1, 0),
		Text = options.Title,
		TextSize = 13,
		FontFace = Creator.BoldFont,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header,
	}) :: TextLabel
	themeReg:Bind(titleLabel, "TextColor3", "Accent")

	local chevron: ImageLabel? = nil
	if collapsible then
		chevron = Creator.Create("ImageLabel", {
			Name = "Chevron",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.new(0, 14, 0, 14),
			Image = Icons.Resolve("chevron-down"),
			Rotation = if isOpen then 0 else -90,
			Parent = header,
		}) :: ImageLabel
		themeReg:Bind(chevron :: ImageLabel, "ImageColor3", "SubText")
	end

	local body = Creator.Create("Frame", {
		Name = "Body",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Visible = isOpen,
		LayoutOrder = 2,
		Parent = container,
	}, {
		Creator.Create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6),
		}),
	}) :: Frame

	local function setOpen(open: boolean)
		isOpen = open
		body.Visible = isOpen
		if chevron then
			Creator.Tween(chevron, 0.16, { Rotation = if isOpen then 0 else -90 })
		end
	end

	if collapsible then
		janitor:Add(header.Activated:Connect(function()
			sound:Play("Click")
			setOpen(not isOpen)
		end))
	end

	local secObj: any = {
		Title = options.Title,
		Frame = container,
		Elements = elements,
		SetOpen = function(_, open: boolean)
			setOpen(open)
		end,
		SetVisible = function(_, visible: boolean)
			container.Visible = visible
		end,
		FilterElements = function(_, query: string): boolean
			if query == "" then
				container.Visible = true
				for _, elem in ipairs(elements) do
					elem:SetVisible(true)
				end
				return true
			end
			local sectionMatches = string.find(string.lower(options.Title), string.lower(query), 1, true) ~= nil
			local anyVisible = false
			for _, elem in ipairs(elements) do
				local matched = sectionMatches or elem:MatchesSearch(query)
				elem:SetVisible(matched)
				if matched then
					anyVisible = true
				end
			end
			container.Visible = anyVisible
			if anyVisible and not isOpen then
				setOpen(true)
			end
			return anyVisible
		end,
		Destroy = function()
			for _, elem in ipairs(elements) do
				elem:Destroy()
			end
			table.clear(elements)
			janitor:Destroy()
		end,
	}

	ElementFactory.Attach(secObj, {
		GetContainer = function()
			return body
		end,
		ThemeReg = themeReg,
		Sound = sound,
		Config = config,
		RegisterElement = function(elem: any)
			table.insert(elements, elem)
		end,
	})

	return secObj
end

return Section
