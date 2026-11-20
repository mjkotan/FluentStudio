--!strict
-- Shared Fluent Element Card Container (supports Thai text, AutomaticSize, Disabled/Locked overlay, Search)

local Creator = require(script.Parent.Parent.Core.Creator)
local Janitor = require(script.Parent.Parent.Core.Janitor)
local Icons = require(script.Parent.Parent.Icons)
local Types = require(script.Parent.Parent.Types)

type BaseElementOptions = Types.BaseElementOptions

local BaseElement = {}

export type CardResult = {
	Id: string,
	Frame: Frame,
	TextArea: Frame,
	TitleLabel: TextLabel,
	DescLabel: TextLabel,
	ControlHolder: Frame,
	Stroke: UIStroke,
	Janitor: Janitor.JanitorType,
	Disabled: boolean,
	SetVisible: (self: any, visible: boolean) -> (),
	SetDisabled: (self: any, disabled: boolean, lockedText: string?) -> (),
	SetTitle: (self: any, title: string) -> (),
	SetDescription: (self: any, desc: string?) -> (),
	MatchesSearch: (self: any, query: string) -> boolean,
	Destroy: (self: any) -> (),
}

local idCounter = 0

function BaseElement.CreateCard(
	parent: Instance,
	themeReg: Creator.ThemeRegistry,
	options: BaseElementOptions,
	rightWidth: number?
): CardResult
	idCounter += 1
	local elemId = options.Id or (options.Title .. "_" .. tostring(idCounter))
	local janitor = Janitor.new()

	local card = Creator.Create("Frame", {
		Name = "Element_" .. elemId,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Visible = if options.Visible == nil then true else options.Visible,
		Parent = parent,
	}, {
		Creator.Corner(8),
		Creator.Padding(10, 12, 10, 12),
	}) :: Frame

	local stroke = Creator.Stroke(themeReg.Theme.ElementBorder, 1, 0.25)
	stroke.Parent = card

	themeReg:Bind(card, "BackgroundColor3", "Element")
	themeReg:Bind(stroke, "Color", "ElementBorder")

	local rWidth = rightWidth or 120

	local textArea = Creator.Create("Frame", {
		Name = "TextArea",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -(rWidth + 12), 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = card,
	}, {
		Creator.Create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 3),
		}),
	}) :: Frame

	local titleLabel = Creator.Create("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = options.Title,
		TextSize = 14,
		FontFace = Creator.BoldFont,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		LineHeight = 1.15, -- Prevents Thai upper/lower vowels from clipping
		LayoutOrder = 1,
		Parent = textArea,
	}) :: TextLabel
	themeReg:Bind(titleLabel, "TextColor3", "Text")

	local hasDesc = options.Description ~= nil and options.Description ~= ""
	local descLabel = Creator.Create("TextLabel", {
		Name = "Description",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = options.Description or "",
		TextSize = 12,
		FontFace = Creator.RegularFont,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		LineHeight = 1.15,
		Visible = hasDesc,
		LayoutOrder = 2,
		Parent = textArea,
	}) :: TextLabel
	themeReg:Bind(descLabel, "TextColor3", "SubText")

	local controlHolder = Creator.Create("Frame", {
		Name = "ControlHolder",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, rWidth, 0, 30),
		Parent = card,
	}) :: Frame

	-- Disabled / Role-Lock Overlay
	local lockOverlay = Creator.Create("TextButton", {
		Name = "LockOverlay",
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 0.35,
		Position = UDim2.new(0, -12, 0, -10),
		Size = UDim2.new(1, 24, 1, 20),
		ZIndex = 10,
		Visible = false,
		Active = true,
		Parent = card,
	}, {
		Creator.Corner(8),
	}) :: TextButton
	themeReg:Bind(lockOverlay, "BackgroundColor3", "Background")

	local lockBadge = Creator.Create("Frame", {
		Name = "LockBadge",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 0, 0, 24),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 0.1,
		ZIndex = 11,
		Parent = lockOverlay,
	}, {
		Creator.Corner(6),
		Creator.Padding(0, 8, 0, 8),
		Creator.Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 5),
		}),
	}) :: Frame
	themeReg:Bind(lockBadge, "BackgroundColor3", "Surface")

	local lockIcon = Creator.Create("ImageLabel", {
		Name = "Icon",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 13, 0, 13),
		Image = Icons.Resolve("lock"),
		ZIndex = 12,
		Parent = lockBadge,
	}) :: ImageLabel
	themeReg:Bind(lockIcon, "ImageColor3", "MutedText")

	local lockTextLabel = Creator.Create("TextLabel", {
		Name = "LockText",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Text = options.LockedText or "Locked",
		TextSize = 11,
		FontFace = Creator.BoldFont,
		ZIndex = 12,
		Parent = lockBadge,
	}) :: TextLabel
	themeReg:Bind(lockTextLabel, "TextColor3", "MutedText")

	janitor:Add(card)

	local result: CardResult = {
		Id = elemId,
		Frame = card,
		TextArea = textArea,
		TitleLabel = titleLabel,
		DescLabel = descLabel,
		ControlHolder = controlHolder,
		Stroke = stroke,
		Janitor = janitor,
		Disabled = false,
		SetVisible = function(self, visible: boolean)
			self.Frame.Visible = visible
		end,
		SetDisabled = function(self, disabled: boolean, lockedText: string?)
			self.Disabled = disabled
			lockOverlay.Visible = disabled
			if lockedText then
				lockTextLabel.Text = lockedText
			end
		end,
		SetTitle = function(self, title: string)
			self.TitleLabel.Text = title
		end,
		SetDescription = function(self, desc: string?)
			if desc and desc ~= "" then
				self.DescLabel.Text = desc
				self.DescLabel.Visible = true
			else
				self.DescLabel.Text = ""
				self.DescLabel.Visible = false
			end
		end,
		MatchesSearch = function(self, query: string): boolean
			if query == "" then
				return true
			end
			local q = string.lower(query)
			if string.find(string.lower(self.TitleLabel.Text), q, 1, true) then
				return true
			end
			if string.find(string.lower(self.DescLabel.Text), q, 1, true) then
				return true
			end
			return false
		end,
		Destroy = function(self)
			self.Janitor:Destroy()
		end,
	}

	if options.Disabled then
		result:SetDisabled(true, options.LockedText)
	end

	return result
end

return BaseElement
