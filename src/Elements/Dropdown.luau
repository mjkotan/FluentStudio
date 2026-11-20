--!strict
-- Fluent Dropdown Element (Single & Multi-select, Searchable list, Chip summary, Silent SetValue)

local Creator = require(script.Parent.Parent.Core.Creator)
local Signal = require(script.Parent.Parent.Core.Signal)
local Sound = require(script.Parent.Parent.Core.Sound)
local Icons = require(script.Parent.Parent.Icons)
local BaseElement = require(script.Parent.BaseElement)
local Types = require(script.Parent.Parent.Types)

type DropdownOptions = Types.DropdownOptions

local Dropdown = {}

function Dropdown.new(
	parent: Instance,
	themeReg: Creator.ThemeRegistry,
	sound: Sound.SoundControllerType,
	options: DropdownOptions
)
	local card = BaseElement.CreateCard(parent, themeReg, options, 150)
	local isMulti = options.Multi == true
	local searchable = if options.Searchable == nil then true else options.Searchable
	local allowNull = options.AllowNull == true
	local values: { string } = table.clone(options.Values or {})

	local selectedSingle: string? = nil
	local selectedMulti: { [string]: boolean } = {}

	if isMulti then
		if type(options.Default) == "table" then
			for _, v in ipairs(options.Default :: { string }) do
				selectedMulti[v] = true
			end
		end
	else
		if type(options.Default) == "string" then
			selectedSingle = options.Default
		elseif not allowNull and #values > 0 then
			selectedSingle = values[1]
		end
	end

	local changedSignal = Signal.new()
	card.Janitor:Add(changedSignal)

	local isOpen = false

	-- Trigger Button
	local trigger = Creator.Create("TextButton", {
		Name = "DropdownTrigger",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0, 28),
		Text = "",
		AutoButtonColor = false,
		Selectable = true,
		Parent = card.ControlHolder,
	}, {
		Creator.Corner(6),
		Creator.Padding(0, 8, 0, 10),
	}) :: TextButton

	local trigStroke = Creator.Stroke(themeReg.Theme.ElementBorder, 1, 0.2)
	trigStroke.Parent = trigger
	themeReg:Bind(trigger, "BackgroundColor3", "InputBackground")
	themeReg:Bind(trigStroke, "Color", "ElementBorder")

	local selectedLabel = Creator.Create("TextLabel", {
		Name = "SelectedText",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -20, 1, 0),
		Text = "--",
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = trigger,
	}) :: TextLabel
	themeReg:Bind(selectedLabel, "TextColor3", "Text")

	local chevron = Creator.Create("ImageLabel", {
		Name = "Chevron",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 14, 0, 14),
		Image = Icons.Resolve("chevron-down"),
		Parent = trigger,
	}) :: ImageLabel
	themeReg:Bind(chevron, "ImageColor3", "SubText")

	-- Expandable Drawer inside Card (so it naturally pushes layout cleanly without clipping issues)
	local drawer = Creator.Create("Frame", {
		Name = "DropdownDrawer",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		Position = UDim2.new(0, 0, 0, 0),
		ClipsDescendants = true,
		Visible = false,
		Parent = card.TextArea,
		LayoutOrder = 3,
	}) :: Frame

	-- Make TextArea span full width when drawer is open? Better: attach drawer directly to card below top row.
	-- Let's restructure drawer cleanly as a sibling in a vertical wrapper or place a full-width drawer container.
	drawer.Parent = nil
	drawer:Destroy()

	-- Re-layout: create an inline expandable container right below card's content using UIListLayout on a wrapper
	-- Keep card.Frame intact, append a drawer below it via a dedicated DrawerFrame child that expands card height!
	local drawerContainer = Creator.Create("Frame", {
		Name = "DrawerContainer",
		BackgroundTransparency = 0,
		Position = UDim2.new(0, 0, 0, 40),
		Size = UDim2.new(1, 0, 0, 0),
		ClipsDescendants = true,
		Visible = false,
		Parent = card.Frame,
	}, {
		Creator.Corner(6),
		Creator.Padding(6, 6, 6, 6),
	}) :: Frame
	local drawerStroke = Creator.Stroke(themeReg.Theme.ElementBorder, 1, 0.3)
	drawerStroke.Parent = drawerContainer
	themeReg:Bind(drawerContainer, "BackgroundColor3", "InputBackground")
	themeReg:Bind(drawerStroke, "Color", "ElementBorder")

	local drawerLayout = Creator.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4),
		Parent = drawerContainer,
	}) :: UIListLayout

	local searchBox: TextBox? = nil
	if searchable then
		local searchWrap = Creator.Create("Frame", {
			Name = "SearchWrap",
			Size = UDim2.new(1, 0, 0, 26),
			LayoutOrder = 1,
			Parent = drawerContainer,
		}, {
			Creator.Corner(5),
			Creator.Padding(0, 8, 0, 8),
		}) :: Frame
		themeReg:Bind(searchWrap, "BackgroundColor3", "Surface")

		searchBox = Creator.Create("TextBox", {
			Name = "SearchBox",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Text = "",
			PlaceholderText = "Search...",
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			Parent = searchWrap,
		}) :: TextBox
		themeReg:Bind(searchBox :: TextBox, "TextColor3", "Text")
		themeReg:Bind(searchBox :: TextBox, "PlaceholderColor3", "MutedText")
	end

	local scroll = Creator.Create("ScrollingFrame", {
		Name = "OptionList",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 120),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		LayoutOrder = 2,
		Parent = drawerContainer,
	}, {
		Creator.Create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 3),
		}),
	}) :: ScrollingFrame
	themeReg:Bind(scroll, "ScrollBarImageColor3", "MutedText")

	local function getCurrentValue(): any
		if isMulti then
			local list = {}
			for _, v in ipairs(values) do
				if selectedMulti[v] then
					table.insert(list, v)
				end
			end
			return list
		else
			return selectedSingle
		end
	end

	local function updateTriggerText()
		if isMulti then
			local picked = getCurrentValue() :: { string }
			if #picked == 0 then
				selectedLabel.Text = "None"
			elseif #picked <= 2 then
				selectedLabel.Text = table.concat(picked, ", ")
			else
				selectedLabel.Text = string.format("%s, %s (+%d)", picked[1], picked[2], #picked - 2)
			end
		else
			selectedLabel.Text = selectedSingle or "None"
		end
	end

	local optionButtons: { { Value: string, Button: TextButton, Check: ImageLabel } } = {}

	local function refreshOptionStates()
		local theme = themeReg.Theme
		for _, item in ipairs(optionButtons) do
			local active = if isMulti then (selectedMulti[item.Value] == true) else (selectedSingle == item.Value)
			item.Check.Visible = active
			item.Button.BackgroundColor3 = if active then theme.SurfaceActive else theme.Surface
			item.Button.TextColor3 = if active then theme.Accent else theme.Text
		end
		updateTriggerText()
	end

	local handle: any
	local function emitChange(silent: boolean?)
		local current = getCurrentValue()
		handle.Value = current
		if not silent then
			if options.Callback then
				task.spawn(options.Callback, current)
			end
			changedSignal:Fire(current)
		end
	end

	local function rebuildOptions()
		for _, item in ipairs(optionButtons) do
			item.Button:Destroy()
		end
		table.clear(optionButtons)

		local query = if searchBox then string.lower(searchBox.Text) else ""
		for idx, val in ipairs(values) do
			if query == "" or string.find(string.lower(val), query, 1, true) then
				local optBtn = Creator.Create("TextButton", {
					Name = "Opt_" .. val,
					Size = UDim2.new(1, -4, 0, 26),
					Text = val,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					AutoButtonColor = false,
					LayoutOrder = idx,
					Selectable = true,
					Parent = scroll,
				}, {
					Creator.Corner(5),
					Creator.Padding(0, 24, 0, 8),
				}) :: TextButton

				local check = Creator.Create("ImageLabel", {
					Name = "Check",
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 18, 0.5, 0),
					Size = UDim2.new(0, 14, 0, 14),
					Image = Icons.Resolve("check"),
					Visible = false,
					Parent = optBtn,
				}) :: ImageLabel
				themeReg:Bind(check, "ImageColor3", "Accent")

				optBtn.Activated:Connect(function()
					if card.Disabled then
						return
					end
					sound:Play("Click")
					if isMulti then
						selectedMulti[val] = not selectedMulti[val]
					else
						if selectedSingle == val and allowNull then
							selectedSingle = nil
						else
							selectedSingle = val
						end
					end
					refreshOptionStates()
					emitChange(false)
				end)

				table.insert(optionButtons, { Value = val, Button = optBtn, Check = check })
			end
		end
		refreshOptionStates()
	end

	if searchBox then
		card.Janitor:Add((searchBox :: TextBox):GetPropertyChangedSignal("Text"):Connect(function()
			rebuildOptions()
		end))
	end

	local function setOpen(open: boolean)
		isOpen = open
		Creator.Tween(chevron, 0.16, { Rotation = if isOpen then 180 else 0 })
		if isOpen then
			local topOffset = math.max(card.TextArea.AbsoluteSize.Y + 8, 36)
			drawerContainer.Position = UDim2.new(0, 0, 0, topOffset)
			drawerContainer.Visible = true
			local targetHeight = (if searchable then 32 else 0) + math.min(#values * 29 + 14, 134) + 12
			Creator.Tween(drawerContainer, 0.18, { Size = UDim2.new(1, 0, 0, targetHeight) })
			-- Keep ControlHolder aligned to top row while drawer expands
			card.ControlHolder.AnchorPoint = Vector2.new(1, 0)
			card.ControlHolder.Position = UDim2.new(1, 0, 0, 2)
		else
			local tw = Creator.Tween(drawerContainer, 0.14, { Size = UDim2.new(1, 0, 0, 0) })
			tw.Completed:Once(function()
				if not isOpen then
					drawerContainer.Visible = false
					card.ControlHolder.AnchorPoint = Vector2.new(1, 0.5)
					card.ControlHolder.Position = UDim2.new(1, 0, 0.5, 0)
				end
			end)
		end
	end

	card.Janitor:Add(trigger.Activated:Connect(function()
		if card.Disabled then
			return
		end
		sound:Play("Click")
		setOpen(not isOpen)
	end))

	-- Ensure drawerLayout is referenced
	local _ = drawerLayout

	themeReg:OnThemeChanged(function()
		refreshOptionStates()
	end)

	rebuildOptions()

	handle = setmetatable({
		Type = "Dropdown",
		Value = getCurrentValue(),
		Default = getCurrentValue(),
		Saveable = if options.Saveable == nil then true else options.Saveable,
		OnChanged = function(_, fn: (val: any) -> ())
			return changedSignal:Connect(fn)
		end,
		SetValues = function(_, newValues: { string })
			values = table.clone(newValues)
			rebuildOptions()
		end,
		SetValue = function(_, newVal: any, silent: boolean?)
			if isMulti then
				table.clear(selectedMulti)
				if type(newVal) == "table" then
					for k, v in pairs(newVal) do
						if type(k) == "number" and type(v) == "string" then
							selectedMulti[v] = true
						elseif type(k) == "string" and v == true then
							selectedMulti[k] = true
						end
					end
				end
			else
				selectedSingle = if type(newVal) == "string" then newVal else nil
			end
			refreshOptionStates()
			emitChange(silent)
		end,
		GetValue = function(): any
			return getCurrentValue()
		end,
	}, { __index = card })

	return handle
end

return Dropdown
