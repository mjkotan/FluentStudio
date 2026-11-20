--!strict
-- Fluent Tab Component (Supports 1-column or 2-column layout, Sections, and Global Search filtering)

local Creator = require(script.Parent.Parent.Core.Creator)
local Janitor = require(script.Parent.Parent.Core.Janitor)
local Sound = require(script.Parent.Parent.Core.Sound)
local Icons = require(script.Parent.Parent.Icons)
local ConfigManager = require(script.Parent.Parent.Managers.ConfigManager)
local ElementFactory = require(script.Parent.ElementFactory)
local Section = require(script.Parent.Section)
local Types = require(script.Parent.Parent.Types)

type TabOptions = Types.TabOptions
type SectionOptions = Types.SectionOptions

local Tab = {}

function Tab.new(
	sidebarList: Instance,
	pagesHolder: Instance,
	themeReg: Creator.ThemeRegistry,
	sound: Sound.SoundControllerType,
	config: ConfigManager.ConfigManagerType,
	options: TabOptions,
	onSelect: (tabObj: any) -> ()
)
	local janitor = Janitor.new()
	local columnsCount = if options.Columns == 2 then 2 else 1
	local elements: { any } = {}
	local sections: { any } = {}
	local isSelected = false

	-- Sidebar Tab Button
	local tabBtn = Creator.Create("TextButton", {
		Name = "TabBtn_" .. options.Title,
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Selectable = true,
		Parent = sidebarList,
	}, {
		Creator.Corner(7),
		Creator.Padding(0, 10, 0, 10),
	}) :: TextButton
	janitor:Add(tabBtn)

	-- Windows 11 Fluent left accent pill indicator
	local indicator = Creator.Create("Frame", {
		Name = "Indicator",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, -10, 0.5, 0),
		Size = UDim2.new(0, 3, 0, 0),
		BackgroundTransparency = 0,
		Parent = tabBtn,
	}, {
		Creator.Corner(2),
	}) :: Frame
	themeReg:Bind(indicator, "BackgroundColor3", "Accent")

	local iconAsset = Icons.Resolve(options.Icon)
	local hasIcon = iconAsset ~= ""
	local iconLabel: ImageLabel? = nil
	if hasIcon then
		iconLabel = Creator.Create("ImageLabel", {
			Name = "Icon",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 2, 0.5, 0),
			Size = UDim2.new(0, 16, 0, 16),
			Image = iconAsset,
			Parent = tabBtn,
		}) :: ImageLabel
		themeReg:Bind(iconLabel :: ImageLabel, "ImageColor3", "SubText")
	end

	local tabTitle = Creator.Create("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, if hasIcon then 26 else 4, 0, 0),
		Size = UDim2.new(1, if hasIcon then -28 else -6, 1, 0),
		Text = options.Title,
		TextSize = 13,
		FontFace = Creator.DefaultFont,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = tabBtn,
	}) :: TextLabel
	themeReg:Bind(tabTitle, "TextColor3", "SubText")

	-- Page Scroll Container
	local page = Creator.Create("ScrollingFrame", {
		Name = "Page_" .. options.Title,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 4,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Visible = false,
		Parent = pagesHolder,
	}, {
		Creator.Padding(6, 10, 12, 6),
	}) :: ScrollingFrame
	themeReg:Bind(page, "ScrollBarImageColor3", "MutedText")
	janitor:Add(page)

	-- Columns setup
	local leftCol: Frame
	local rightCol: Frame? = nil

	if columnsCount == 2 then
		local colWrapper = Creator.Create("Frame", {
			Name = "ColumnsWrapper",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = page,
		}) :: Frame

		leftCol = Creator.Create("Frame", {
			Name = "LeftColumn",
			BackgroundTransparency = 1,
			Size = UDim2.new(0.5, -5, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = colWrapper,
		}, {
			Creator.Create("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 7),
			}),
		}) :: Frame

		rightCol = Creator.Create("Frame", {
			Name = "RightColumn",
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 5, 0, 0),
			Size = UDim2.new(0.5, -5, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = colWrapper,
		}, {
			Creator.Create("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 7),
			}),
		}) :: Frame
	else
		leftCol = Creator.Create("Frame", {
			Name = "SingleColumn",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = page,
		}, {
			Creator.Create("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 7),
			}),
		}) :: Frame
	end

	local function getColumnFrame(col: number?): Frame
		if columnsCount == 2 and col == 2 and rightCol then
			return rightCol
		end
		return leftCol
	end

	local function renderSelectedState(animate: boolean)
		local theme = themeReg.Theme
		local targetBgTrans = if isSelected then 0 else 1
		local targetBg = if isSelected then theme.Surface else theme.Sidebar
		local targetText = if isSelected then theme.Text else theme.SubText
		local targetIcon = if isSelected then theme.Accent else theme.SubText
		local targetIndSize = if isSelected then UDim2.new(0, 3, 0, 16) else UDim2.new(0, 3, 0, 0)

		if animate then
			Creator.Tween(tabBtn, 0.16, { BackgroundTransparency = targetBgTrans, BackgroundColor3 = targetBg })
			Creator.Tween(tabTitle, 0.16, { TextColor3 = targetText })
			Creator.Tween(indicator, 0.18, { Size = targetIndSize })
			if iconLabel then
				Creator.Tween(iconLabel, 0.16, { ImageColor3 = targetIcon })
			end
		else
			tabBtn.BackgroundTransparency = targetBgTrans
			tabBtn.BackgroundColor3 = targetBg
			tabTitle.TextColor3 = targetText
			indicator.Size = targetIndSize
			if iconLabel then
				iconLabel.ImageColor3 = targetIcon
			end
		end
	end

	themeReg:OnThemeChanged(function()
		renderSelectedState(true)
	end)

	janitor:Add(tabBtn.MouseEnter:Connect(function()
		if isSelected then
			return
		end
		sound:Play("Hover")
		Creator.Tween(tabBtn, 0.12, { BackgroundTransparency = 0.45, BackgroundColor3 = themeReg.Theme.SurfaceHover })
	end))

	janitor:Add(tabBtn.MouseLeave:Connect(function()
		if isSelected then
			return
		end
		Creator.Tween(tabBtn, 0.12, { BackgroundTransparency = 1 })
	end))

	local tabObj: any = {
		Title = options.Title,
		Button = tabBtn,
		Page = page,
		SetSelected = function(_, selected: boolean)
			isSelected = selected
			page.Visible = selected
			renderSelectedState(true)
		end,
		AddSection = function(_, secOpts: SectionOptions)
			local sec = Section.new(getColumnFrame(secOpts.Column), themeReg, sound, config, secOpts)
			table.insert(sections, sec)
			return sec
		end,
		FilterElements = function(_, query: string): boolean
			local anyVisible = false
			for _, elem in ipairs(elements) do
				local matched = elem:MatchesSearch(query)
				elem:SetVisible(matched)
				if matched then
					anyVisible = true
				end
			end
			for _, sec in ipairs(sections) do
				if sec:FilterElements(query) then
					anyVisible = true
				end
			end
			return anyVisible
		end,
		Destroy = function()
			for _, elem in ipairs(elements) do
				elem:Destroy()
			end
			for _, sec in ipairs(sections) do
				sec:Destroy()
			end
			table.clear(elements)
			table.clear(sections)
			janitor:Destroy()
		end,
	}

	janitor:Add(tabBtn.Activated:Connect(function()
		sound:Play("Click")
		onSelect(tabObj)
	end))

	ElementFactory.Attach(tabObj, {
		GetContainer = function(col: number?)
			return getColumnFrame(col)
		end,
		ThemeReg = themeReg,
		Sound = sound,
		Config = config,
		RegisterElement = function(elem: any)
			table.insert(elements, elem)
		end,
	})

	return tabObj
end

return Tab
