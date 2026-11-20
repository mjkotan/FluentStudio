--!nocheck
-- FluentStudio v1.0.0 (Single-File Bundle for Roblox Studio)
-- Generated via: lune run build/bundle.luau
-- Source: https://github.com/mjkotan/FluentStudio

local __MODULES = {}
local __CACHE = {}

local function __makeNode(path)
	return setmetatable({ __path = path }, {
		__index = function(self, key)
			if key == 'Parent' then
				local parts = string.split(self.__path, '/')
				table.remove(parts)
				return __makeNode(table.concat(parts, '/'))
			end
			local childPath = if self.__path == '' then key else self.__path .. '/' .. key
			return __makeNode(childPath)
		end,
	})
end

local function __require(target)
	local path = target.__path
	local resolved = path
	if not __MODULES[resolved] then
		if __MODULES[path .. '/init'] then
			resolved = path .. '/init'
		end
	end
	if __CACHE[resolved] ~= nil then
		return __CACHE[resolved]
	end
	local loader = __MODULES[resolved]
	assert(loader, '[FluentStudio Bundle] Module not found: ' .. tostring(path))
	local result = loader(__makeNode(path), __require)
	__CACHE[resolved] = result
	return result
end

__MODULES["Components/Dialog"] = function(script, require)
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

end

__MODULES["Components/ElementFactory"] = function(script, require)
-- Shared Element Factory Mixin for Tab and Section containers

local Creator = require(script.Parent.Parent.Core.Creator)
local Sound = require(script.Parent.Parent.Core.Sound)
local ConfigManager = require(script.Parent.Parent.Managers.ConfigManager)
local Types = require(script.Parent.Parent.Types)

local ElementsFolder = script.Parent.Parent.Elements
local Button = require(ElementsFolder.Button)
local Toggle = require(ElementsFolder.Toggle)
local Slider = require(ElementsFolder.Slider)
local RangeSlider = require(ElementsFolder.RangeSlider)
local Dropdown = require(ElementsFolder.Dropdown)
local Input = require(ElementsFolder.Input)
local Keybind = require(ElementsFolder.Keybind)
local Colorpicker = require(ElementsFolder.Colorpicker)
local Paragraph = require(ElementsFolder.Paragraph)
local Divider = require(ElementsFolder.Divider)
local ProgressBar = require(ElementsFolder.ProgressBar)
local ImageElement = require(ElementsFolder.Image)

local ElementFactory = {}

export type FactoryContext = {
	GetContainer: (column: number?) -> Instance,
	ThemeReg: Creator.ThemeRegistry,
	Sound: Sound.SoundControllerType,
	Config: ConfigManager.ConfigManagerType,
	RegisterElement: (elem: any) -> (),
}

function ElementFactory.Attach(target: { [string]: any }, ctx: FactoryContext)
	local function track(elem: any)
		ctx.RegisterElement(elem)
		if elem.Saveable and elem.GetValue and elem.SetValue then
			ctx.Config:Register({
				Id = elem.Id,
				Type = elem.Type,
				GetValue = elem.GetValue,
				SetValue = function(val: any, silent: boolean?)
					elem:SetValue(val, silent)
				end,
				Default = elem.Default,
			})
		end
		return elem
	end

	function target:AddButton(options: Types.ButtonOptions)
		return track(Button.new(ctx.GetContainer(), ctx.ThemeReg, ctx.Sound, options))
	end

	function target:AddToggle(options: Types.ToggleOptions)
		return track(Toggle.new(ctx.GetContainer(), ctx.ThemeReg, ctx.Sound, options))
	end

	function target:AddSlider(options: Types.SliderOptions)
		return track(Slider.new(ctx.GetContainer(), ctx.ThemeReg, ctx.Sound, options))
	end

	function target:AddRangeSlider(options: Types.RangeSliderOptions)
		return track(RangeSlider.new(ctx.GetContainer(), ctx.ThemeReg, ctx.Sound, options))
	end

	function target:AddDropdown(options: Types.DropdownOptions)
		return track(Dropdown.new(ctx.GetContainer(), ctx.ThemeReg, ctx.Sound, options))
	end

	function target:AddInput(options: Types.InputOptions)
		return track(Input.new(ctx.GetContainer(), ctx.ThemeReg, ctx.Sound, options))
	end

	function target:AddKeybind(options: Types.KeybindOptions)
		return track(Keybind.new(ctx.GetContainer(), ctx.ThemeReg, ctx.Sound, options))
	end

	function target:AddColorpicker(options: Types.ColorpickerOptions)
		return track(Colorpicker.new(ctx.GetContainer(), ctx.ThemeReg, ctx.Sound, options))
	end

	function target:AddParagraph(options: Types.ParagraphOptions)
		return track(Paragraph.new(ctx.GetContainer(), ctx.ThemeReg, options))
	end

	function target:AddDivider(options: Types.DividerOptions?)
		return track(Divider.new(ctx.GetContainer(), ctx.ThemeReg, options))
	end

	function target:AddProgressBar(options: Types.ProgressBarOptions)
		return track(ProgressBar.new(ctx.GetContainer(), ctx.ThemeReg, options))
	end

	function target:AddImage(options: Types.ImageOptions)
		return track(ImageElement.new(ctx.GetContainer(), ctx.ThemeReg, options))
	end
end

return ElementFactory

end

__MODULES["Components/Notification"] = function(script, require)
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

end

__MODULES["Components/Section"] = function(script, require)
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

end

__MODULES["Components/Tab"] = function(script, require)
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

end

__MODULES["Components/Window"] = function(script, require)
-- FluentStudio Main Window Component (PlayerGui-native, PC/Mobile/Gamepad, Search, Drag/Resize, Config Adapter)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")

local Creator = require(script.Parent.Parent.Core.Creator)
local Janitor = require(script.Parent.Parent.Core.Janitor)
local Sound = require(script.Parent.Parent.Core.Sound)
local Themes = require(script.Parent.Parent.Themes)
local Icons = require(script.Parent.Parent.Icons)
local ConfigManager = require(script.Parent.Parent.Managers.ConfigManager)
local Tab = require(script.Parent.Tab)
local Notification = require(script.Parent.Notification)
local Dialog = require(script.Parent.Dialog)
local Types = require(script.Parent.Parent.Types)

type WindowOptions = Types.WindowOptions
type TabOptions = Types.TabOptions
type NotifyOptions = Types.NotifyOptions
type DialogOptions = Types.DialogOptions
type ConfigData = Types.ConfigData

local Window = {}

function Window.new(options: WindowOptions)
	local janitor = Janitor.new()
	local localPlayer = Players.LocalPlayer
	local parentGui: Instance = options.Parent or (if localPlayer then localPlayer:WaitForChild("PlayerGui") else game:GetService("StarterGui"))

	local initialTheme = Themes.Get(options.Theme or "Dark")
	local themeReg = Creator.CreateThemeRegistry(initialTheme)
	janitor:Add(themeReg)

	local sound = Sound.new(if options.SoundEnabled == nil then true else options.SoundEnabled)
	local config = ConfigManager.new()
	janitor:Add(config)

	local minSize = options.MinSize or Vector2.new(440, 320)
	local tabWidth = options.TabWidth or 165
	local minimizeKey = options.MinimizeKey or Enum.KeyCode.RightControl
	local resizable = if options.Resizable == nil then true else options.Resizable
	local showSearch = if options.SearchBar == nil then true else options.SearchBar
	local showMobileToggle = if options.MobileToggleButton == nil then true else options.MobileToggleButton

	local screenGui = Creator.Create("ScreenGui", {
		Name = "FluentStudio_" .. (options.Title or "Window"),
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
		DisplayOrder = options.DisplayOrder or 10,
		Parent = parentGui,
	}) :: ScreenGui
	janitor:Add(screenGui)

	-- Optional subtle BlurEffect (default OFF to avoid clashing with game Lighting)
	local blurEffect: BlurEffect? = nil
	local function setBlurEnabled(enabled: boolean)
		if enabled then
			if not blurEffect then
				blurEffect = Instance.new("BlurEffect")
				;(blurEffect :: BlurEffect).Name = "FluentStudioBlur"
				;(blurEffect :: BlurEffect).Size = 0
				;(blurEffect :: BlurEffect).Parent = Lighting
				janitor:Add(blurEffect :: BlurEffect)
			end
			Creator.Tween(blurEffect :: BlurEffect, 0.25, { Size = 10 })
		elseif blurEffect then
			Creator.Tween(blurEffect, 0.2, { Size = 0 })
		end
	end

	-- Responsive UIScale for Mobile / Small Viewports
	local uiScale = Creator.Create("UIScale", {
		Scale = 1,
		Parent = screenGui,
	}) :: UIScale

	local function updateResponsiveScale()
		local cam = workspace.CurrentCamera
		if not cam then
			return
		end
		local vp = cam.ViewportSize
		local scale = 1
		if vp.X < 680 or vp.Y < 460 then
			scale = math.clamp(math.min(vp.X / 680, vp.Y / 460), 0.65, 1)
		end
		uiScale.Scale = scale
	end
	updateResponsiveScale()
	if workspace.CurrentCamera then
		janitor:Add(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsiveScale))
	end

	-- Notification Stack
	local notifyStack = Notification.CreateStack(screenGui)

	-- Main Window Frame
	local defaultSize = options.Size or UDim2.fromOffset(620, 440)
	local mainFrame = Creator.Create("Frame", {
		Name = "MainWindow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = defaultSize,
		ClipsDescendants = true,
		Active = true,
		Parent = screenGui,
	}, {
		Creator.Corner(11),
	}) :: Frame

	local mainStroke = Creator.Stroke(initialTheme.Border, 1, 0.15)
	mainStroke.Parent = mainFrame
	themeReg:Bind(mainFrame, "BackgroundColor3", "Background")
	themeReg:Bind(mainFrame, "BackgroundTransparency", "BackgroundTransparency")
	themeReg:Bind(mainStroke, "Color", "Border")

	-- Subtle Fluent Glass Sheen Gradient
	local sheen = Creator.Create("UIGradient", {
		Rotation = 45,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 225, 235)),
		}),
		Parent = mainFrame,
	}) :: UIGradient
	local _ = sheen

	-- Top Title Bar
	local titleBar = Creator.Create("Frame", {
		Name = "TitleBar",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 44),
		ZIndex = 5,
		Parent = mainFrame,
	}, {
		Creator.Padding(0, 12, 0, 14),
	}) :: Frame

	local titleDivider = Creator.Create("Frame", {
		Name = "TitleDivider",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, -14, 1, 0),
		Size = UDim2.new(1, 26, 0, 1),
		BackgroundTransparency = 0.4,
		Parent = titleBar,
	}) :: Frame
	themeReg:Bind(titleDivider, "BackgroundColor3", "Border")

	local titleHolder = Creator.Create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0.5, 0, 1, 0),
		Parent = titleBar,
	}, {
		Creator.Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 8),
		}),
	}) :: Frame

	local titleLabel = Creator.Create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 0, 0, 20),
		AutomaticSize = Enum.AutomaticSize.X,
		Text = options.Title,
		TextSize = 15,
		FontFace = Creator.BoldFont,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = titleHolder,
	}) :: TextLabel
	themeReg:Bind(titleLabel, "TextColor3", "Text")

	if options.SubTitle and options.SubTitle ~= "" then
		local subLabel = Creator.Create("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 0, 18),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = options.SubTitle,
			TextSize = 12,
			FontFace = Creator.RegularFont,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = titleHolder,
		}) :: TextLabel
		themeReg:Bind(subLabel, "TextColor3", "MutedText")
	end

	-- Top-Right Window Controls (Minimize + Close)
	local controlsRow = Creator.Create("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 68, 0, 28),
		Parent = titleBar,
	}, {
		Creator.Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 6),
		}),
	}) :: Frame

	local function createHeaderBtn(iconName: string): TextButton
		local b = Creator.Create("TextButton", {
			Size = UDim2.new(0, 28, 0, 28),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			Selectable = true,
			Parent = controlsRow,
		}, {
			Creator.Corner(6),
		}) :: TextButton
		local img = Creator.Create("ImageLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(0, 14, 0, 14),
			Image = Icons.Resolve(iconName),
			Parent = b,
		}) :: ImageLabel
		themeReg:Bind(img, "ImageColor3", "SubText")
		janitor:Add(b.MouseEnter:Connect(function()
			sound:Play("Hover")
			Creator.Tween(b, 0.12, { BackgroundTransparency = 0.2, BackgroundColor3 = themeReg.Theme.SurfaceHover })
		end))
		janitor:Add(b.MouseLeave:Connect(function()
			Creator.Tween(b, 0.12, { BackgroundTransparency = 1 })
		end))
		return b
	end

	local minBtn = createHeaderBtn("minus")
	local closeBtn = createHeaderBtn("x")

	-- Body Container (Sidebar + Content Area)
	local bodyFrame = Creator.Create("Frame", {
		Name = "Body",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 44),
		Size = UDim2.new(1, 0, 1, -44),
		Parent = mainFrame,
	}) :: Frame

	-- Sidebar
	local sidebar = Creator.Create("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, tabWidth, 1, 0),
		Parent = bodyFrame,
	}, {
		Creator.Padding(10, 8, 10, 8),
	}) :: Frame
	themeReg:Bind(sidebar, "BackgroundColor3", "Sidebar")
	themeReg:Bind(sidebar, "BackgroundTransparency", "SidebarTransparency")

	local sidebarBorder = Creator.Create("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 8, 0, -10),
		Size = UDim2.new(0, 1, 1, 20),
		BackgroundTransparency = 0.4,
		Parent = sidebar,
	}) :: Frame
	themeReg:Bind(sidebarBorder, "BackgroundColor3", "Border")

	-- Global Search Bar in Sidebar
	local searchOffsetY = 0
	local searchBox: TextBox? = nil
	if showSearch then
		searchOffsetY = 38
		local searchFrame = Creator.Create("Frame", {
			Name = "GlobalSearch",
			Size = UDim2.new(1, 0, 0, 30),
			Parent = sidebar,
		}, {
			Creator.Corner(6),
			Creator.Padding(0, 8, 0, 8),
		}) :: Frame
		local sStroke = Creator.Stroke(initialTheme.ElementBorder, 1, 0.3)
		sStroke.Parent = searchFrame
		themeReg:Bind(searchFrame, "BackgroundColor3", "InputBackground")
		themeReg:Bind(sStroke, "Color", "ElementBorder")

		local sIcon = Creator.Create("ImageLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(0, 13, 0, 13),
			Image = Icons.Resolve("search"),
			Parent = searchFrame,
		}) :: ImageLabel
		themeReg:Bind(sIcon, "ImageColor3", "MutedText")

		searchBox = Creator.Create("TextBox", {
			Name = "SearchInput",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 19, 0, 0),
			Size = UDim2.new(1, -19, 1, 0),
			Text = "",
			PlaceholderText = "Search...",
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			Selectable = true,
			Parent = searchFrame,
		}) :: TextBox
		themeReg:Bind(searchBox :: TextBox, "TextColor3", "Text")
		themeReg:Bind(searchBox :: TextBox, "PlaceholderColor3", "MutedText")
	end

	local tabList = Creator.Create("ScrollingFrame", {
		Name = "TabList",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, searchOffsetY),
		Size = UDim2.new(1, 0, 1, -searchOffsetY),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 2,
		Parent = sidebar,
	}, {
		Creator.Create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 4),
		}),
	}) :: ScrollingFrame
	themeReg:Bind(tabList, "ScrollBarImageColor3", "MutedText")

	-- Pages Holder
	local pagesHolder = Creator.Create("Frame", {
		Name = "PagesHolder",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, tabWidth + 4, 0, 4),
		Size = UDim2.new(1, -(tabWidth + 8), 1, -8),
		Parent = bodyFrame,
	}) :: Frame

	-- Floating Mobile / Quick Toggle Button (Draggable)
	local floatingBtn: TextButton? = nil
	if showMobileToggle then
		local fb = Creator.Create("TextButton", {
			Name = "FloatingToggle",
			Position = UDim2.new(0, 18, 0.5, -22),
			Size = UDim2.new(0, 44, 0, 44),
			Text = "",
			AutoButtonColor = false,
			Visible = false,
			ZIndex = 40,
			Parent = screenGui,
		}, {
			Creator.Corner(22),
		}) :: TextButton
		local fbStroke = Creator.Stroke(initialTheme.Accent, 1.5, 0.1)
		fbStroke.Parent = fb
		themeReg:Bind(fb, "BackgroundColor3", "Background")
		themeReg:Bind(fbStroke, "Color", "Accent")

		local fbIcon = Creator.Create("ImageLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(0, 20, 0, 20),
			Image = Icons.Resolve("menu"),
			ZIndex = 41,
			Parent = fb,
		}) :: ImageLabel
		themeReg:Bind(fbIcon, "ImageColor3", "Accent")

		floatingBtn = fb
	end

	-- State & Visibility
	local isVisible = true
	local tabs: { any } = {}
	local activeTab: any = nil

	local function setVisible(visible: boolean)
		isVisible = visible
		mainFrame.Visible = visible
		if floatingBtn then
			floatingBtn.Visible = not visible
		end
		if options.AcrylicBlur then
			setBlurEnabled(visible)
		end
		if visible and UserInputService.GamepadEnabled and activeTab then
			GuiService.SelectedObject = activeTab.Button
		end
	end

	if options.AcrylicBlur then
		setBlurEnabled(true)
	end

	-- Clamped Window Dragging (Mouse + Touch)
	do
		local dragging = false
		local dragStart: Vector3
		local startPos: UDim2

		janitor:Add(titleBar.InputBegan:Connect(function(input: InputObject)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = mainFrame.Position
			end
		end))

		janitor:Add(UserInputService.InputChanged:Connect(function(input: InputObject)
			if not dragging then
				return
			end
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				local delta = (input.Position - dragStart) / uiScale.Scale
				mainFrame.Position = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + delta.X,
					startPos.Y.Scale,
					startPos.Y.Offset + delta.Y
				)
			end
		end))

		janitor:Add(UserInputService.InputEnded:Connect(function(input: InputObject)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end))
	end

	-- Optional Resize Handle (Bottom-Right corner)
	if resizable then
		local resizeHandle = Creator.Create("TextButton", {
			Name = "ResizeHandle",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, 0, 1, 0),
			Size = UDim2.new(0, 16, 0, 16),
			Text = "",
			ZIndex = 20,
			Parent = mainFrame,
		}) :: TextButton

		local resizing = false
		local resizeStart: Vector3
		local startSize: Vector2

		janitor:Add(resizeHandle.InputBegan:Connect(function(input: InputObject)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				resizing = true
				resizeStart = input.Position
				startSize = mainFrame.AbsoluteSize / uiScale.Scale
			end
		end))

		janitor:Add(UserInputService.InputChanged:Connect(function(input: InputObject)
			if not resizing then
				return
			end
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				local delta = (input.Position - resizeStart) / uiScale.Scale
				local newW = math.max(minSize.X, startSize.X + delta.X)
				local newH = math.max(minSize.Y, startSize.Y + delta.Y)
				mainFrame.Size = UDim2.fromOffset(newW, newH)
			end
		end))

		janitor:Add(UserInputService.InputEnded:Connect(function(input: InputObject)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				resizing = false
			end
		end))
	end

	-- Floating Button Drag + Click
	if floatingBtn then
		local fb = floatingBtn
		local fbDragging = false
		local fbMoved = false
		local fbStart: Vector3
		local fbStartPos: UDim2

		janitor:Add(fb.InputBegan:Connect(function(input: InputObject)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				fbDragging = true
				fbMoved = false
				fbStart = input.Position
				fbStartPos = fb.Position
			end
		end))

		janitor:Add(UserInputService.InputChanged:Connect(function(input: InputObject)
			if not fbDragging then
				return
			end
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				local delta = (input.Position - fbStart) / uiScale.Scale
				if delta.Magnitude > 5 then
					fbMoved = true
				end
				fb.Position = UDim2.new(
					fbStartPos.X.Scale,
					fbStartPos.X.Offset + delta.X,
					fbStartPos.Y.Scale,
					fbStartPos.Y.Offset + delta.Y
				)
			end
		end))

		janitor:Add(UserInputService.InputEnded:Connect(function(input: InputObject)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				if fbDragging and not fbMoved then
					sound:Play("Click")
					setVisible(true)
				end
				fbDragging = false
			end
		end))
	end

	-- Header Button Actions
	janitor:Add(minBtn.Activated:Connect(function()
		sound:Play("Click")
		setVisible(false)
	end))

	janitor:Add(closeBtn.Activated:Connect(function()
		sound:Play("Click")
		setVisible(false)
	end))

	-- Minimize Keybind
	janitor:Add(UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
		if gameProcessed then
			return
		end
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == minimizeKey then
			sound:Play("Click")
			setVisible(not isVisible)
		end
	end))

	-- Global Search Filtering across all Tabs
	if searchBox then
		janitor:Add((searchBox :: TextBox):GetPropertyChangedSignal("Text"):Connect(function()
			local query = (searchBox :: TextBox).Text
			local firstMatchedTab: any = nil
			for _, t in ipairs(tabs) do
				local matched = t:FilterElements(query)
				if query ~= "" then
					t.Button.Visible = matched or (string.find(string.lower(t.Title), string.lower(query), 1, true) ~= nil)
					if t.Button.Visible and not firstMatchedTab then
						firstMatchedTab = t
					end
				else
					t.Button.Visible = true
				end
			end
			if query ~= "" and firstMatchedTab and activeTab and not activeTab.Button.Visible then
				activeTab:SetSelected(false)
				activeTab = firstMatchedTab
				activeTab:SetSelected(true)
			end
		end))
	end

	local function selectTab(targetTab: any)
		if activeTab == targetTab then
			return
		end
		if activeTab then
			activeTab:SetSelected(false)
		end
		activeTab = targetTab
		if activeTab then
			activeTab:SetSelected(true)
		end
	end

	local winObj = {
		ScreenGui = screenGui,
		MainFrame = mainFrame,
		Config = config,
		Sound = sound,
		AddTab = function(_, tabOpts: TabOptions)
			local tabObj = Tab.new(tabList, pagesHolder, themeReg, sound, config, tabOpts, selectTab)
			table.insert(tabs, tabObj)
			if #tabs == 1 then
				selectTab(tabObj)
			end
			return tabObj
		end,
		SelectTab = function(_, indexOrTitle: number | string)
			if type(indexOrTitle) == "number" then
				if tabs[indexOrTitle] then
					selectTab(tabs[indexOrTitle])
				end
			elseif type(indexOrTitle) == "string" then
				for _, t in ipairs(tabs) do
					if t.Title == indexOrTitle then
						selectTab(t)
						break
					end
				end
			end
		end,
		SetTheme = function(_, themeName: string)
			themeReg:ApplyTheme(Themes.Get(themeName), true)
		end,
		SetAcrylicBlur = function(_, enabled: boolean)
			options.AcrylicBlur = enabled
			setBlurEnabled(enabled and isVisible)
		end,
		SetSoundEnabled = function(_, enabled: boolean)
			sound:SetEnabled(enabled)
		end,
		SetVisible = function(_, visible: boolean)
			setVisible(visible)
		end,
		Toggle = function()
			setVisible(not isVisible)
		end,
		Notify = function(_, notifyOpts: NotifyOptions)
			return Notification.Show(notifyStack, themeReg, sound, notifyOpts)
		end,
		Dialog = function(_, dialogOpts: DialogOptions)
			return Dialog.Show(mainFrame, themeReg, sound, dialogOpts)
		end,
		ExportConfig = function(): ConfigData
			return config:Export()
		end,
		ImportConfig = function(_, data: ConfigData, silent: boolean?)
			config:Import(data, silent)
		end,
		ExportJSON = function(): string
			return config:ExportJSON()
		end,
		ImportJSON = function(_, jsonStr: string, silent: boolean?): boolean
			return config:ImportJSON(jsonStr, silent)
		end,
		ResetConfig = function(_, silent: boolean?)
			config:ResetDefaults(silent)
		end,
		Destroy = function()
			for _, t in ipairs(tabs) do
				t:Destroy()
			end
			table.clear(tabs)
			janitor:Destroy()
		end,
	}

	return winObj
end

return Window

end

__MODULES["Core/Creator"] = function(script, require)
-- UI Instance builder, Tween helper, and live Theme binding registry

local TweenService = game:GetService("TweenService")
local Types = require(script.Parent.Parent.Types)

type ThemePalette = Types.ThemePalette

local Creator = {}

export type ThemeRegistry = {
	Theme: ThemePalette,
	Bindings: { { Instance: Instance, Property: string, ThemeKey: string } },
	CustomCallbacks: { (theme: ThemePalette) -> () },
	Bind: (self: ThemeRegistry, inst: Instance, prop: string, themeKey: string) -> (),
	OnThemeChanged: (self: ThemeRegistry, fn: (theme: ThemePalette) -> ()) -> (),
	ApplyTheme: (self: ThemeRegistry, theme: ThemePalette, animate: boolean?) -> (),
	Destroy: (self: ThemeRegistry) -> (),
}

Creator.DefaultFont = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
Creator.BoldFont = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
Creator.RegularFont = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)

function Creator.Create(className: string, props: { [string]: any }?, children: { Instance }?): Instance
	local inst = Instance.new(className)

	-- Thai & Localization-friendly defaults for text objects
	if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
		inst.FontFace = Creator.DefaultFont
		inst.AutoLocalize = true
		inst.BorderSizePixel = 0
	elseif inst:IsA("GuiObject") then
		inst.BorderSizePixel = 0
	end

	local parent: Instance? = nil
	if props then
		for k, v in pairs(props) do
			if k == "Parent" then
				parent = v
			else
				(inst :: any)[k] = v
			end
		end
	end

	if children then
		for _, child in ipairs(children) do
			child.Parent = inst
		end
	end

	if parent then
		inst.Parent = parent
	end

	return inst
end

function Creator.Corner(radius: number): UICorner
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	return c
end

function Creator.Stroke(color: Color3, thickness: number?, transparency: number?): UIStroke
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	return s
end

function Creator.Padding(top: number, right: number?, bottom: number?, left: number?): UIPadding
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, top)
	p.PaddingRight = UDim.new(0, right or top)
	p.PaddingBottom = UDim.new(0, bottom or top)
	p.PaddingLeft = UDim.new(0, left or right or top)
	return p
end

function Creator.Tween(
	inst: Instance,
	duration: number,
	props: { [string]: any },
	style: Enum.EasingStyle?,
	direction: Enum.EasingDirection?
): Tween
	local info = TweenInfo.new(
		duration,
		style or Enum.EasingStyle.Quint,
		direction or Enum.EasingDirection.Out
	)
	local tween = TweenService:Create(inst, info, props)
	tween:Play()
	return tween
end

function Creator.CreateThemeRegistry(initialTheme: ThemePalette): ThemeRegistry
	local registry: ThemeRegistry = {
		Theme = initialTheme,
		Bindings = {},
		CustomCallbacks = {},
		Bind = function(self, inst: Instance, prop: string, themeKey: string)
			local val = (self.Theme :: any)[themeKey]
			if val ~= nil then
				(inst :: any)[prop] = val
			end
			table.insert(self.Bindings, {
				Instance = inst,
				Property = prop,
				ThemeKey = themeKey,
			})
		end,
		OnThemeChanged = function(self, fn: (theme: ThemePalette) -> ())
			table.insert(self.CustomCallbacks, fn)
		end,
		ApplyTheme = function(self, theme: ThemePalette, animate: boolean?)
			self.Theme = theme
			local useAnim = if animate == nil then true else animate
			for i = #self.Bindings, 1, -1 do
				local b = self.Bindings[i]
				if b.Instance.Parent == nil then
					table.remove(self.Bindings, i)
				else
					local val = (theme :: any)[b.ThemeKey]
					if val ~= nil then
						if useAnim and (typeof(val) == "Color3" or typeof(val) == "number") then
							Creator.Tween(b.Instance, 0.2, { [b.Property] = val })
						else
							(b.Instance :: any)[b.Property] = val
						end
					end
				end
			end
			for _, fn in ipairs(self.CustomCallbacks) do
				task.spawn(fn, theme)
			end
		end,
		Destroy = function(self)
			table.clear(self.Bindings)
			table.clear(self.CustomCallbacks)
		end,
	}
	return registry
end

return Creator

end

__MODULES["Core/Janitor"] = function(script, require)
-- Lightweight Janitor for deterministic cleanup of Instances, RBXScriptConnections, Tweens, and callbacks

local Janitor = {}
Janitor.__index = Janitor

export type Cleanable = RBXScriptConnection | Instance | Tween | () -> () | { Destroy: (any) -> () } | { Disconnect: (any) -> () }

export type JanitorType = typeof(setmetatable({} :: {
	_tasks: { any },
	_destroyed: boolean,
}, Janitor))

function Janitor.new(): JanitorType
	return setmetatable({
		_tasks = {},
		_destroyed = false,
	}, Janitor)
end

function Janitor:Add<T>(taskObj: T): T
	if self._destroyed then
		self:_cleanupSingle(taskObj)
		return taskObj
	end
	table.insert(self._tasks, taskObj)
	return taskObj
end

function Janitor:_cleanupSingle(taskObj: any)
	local t = typeof(taskObj)
	if t == "RBXScriptConnection" then
		if taskObj.Connected then
			taskObj:Disconnect()
		end
	elseif t == "Instance" then
		if taskObj.Parent ~= nil then
			taskObj:Destroy()
		else
			pcall(function()
				taskObj:Destroy()
			end)
		end
	elseif t == "function" then
		taskObj()
	elseif t == "table" then
		if type(taskObj.Destroy) == "function" then
			taskObj:Destroy()
		elseif type(taskObj.Disconnect) == "function" then
			taskObj:Disconnect()
		elseif type(taskObj.Cancel) == "function" then
			taskObj:Cancel()
		end
	end
end

function Janitor:Cleanup()
	for i = #self._tasks, 1, -1 do
		local taskObj = self._tasks[i]
		self._tasks[i] = nil
		self:_cleanupSingle(taskObj)
	end
end

function Janitor:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true
	self:Cleanup()
end

return Janitor

end

__MODULES["Core/Signal"] = function(script, require)
-- Lightweight Signal implementation for UI events

local Signal = {}
Signal.__index = Signal

export type Connection = {
	Connected: boolean,
	Disconnect: (self: Connection) -> (),
}

export type SignalType<T...> = {
	Connect: (self: SignalType<T...>, fn: (T...) -> ()) -> Connection,
	Once: (self: SignalType<T...>, fn: (T...) -> ()) -> Connection,
	Fire: (self: SignalType<T...>, T...) -> (),
	Destroy: (self: SignalType<T...>) -> (),
}

function Signal.new<T...>(): SignalType<T...>
	local self = setmetatable({
		_listeners = {} :: { { fn: (...any) -> (), once: boolean, connected: boolean } },
	}, Signal)
	return (self :: any) :: SignalType<T...>
end

function Signal:Connect(fn: (...any) -> ()): Connection
	local entry = {
		fn = fn,
		once = false,
		connected = true,
	}
	table.insert(self._listeners, entry)

	local conn: Connection = {
		Connected = true,
		Disconnect = function(c)
			if not c.Connected then
				return
			end
			c.Connected = false
			entry.connected = false
			local idx = table.find(self._listeners, entry)
			if idx then
				table.remove(self._listeners, idx)
			end
		end,
	}
	return conn
end

function Signal:Once(fn: (...any) -> ()): Connection
	local conn: Connection
	conn = self:Connect(function(...: any)
		conn:Disconnect()
		fn(...)
	end)
	return conn
end

function Signal:Fire(...: any)
	-- Snapshot to allow safe disconnect during Fire
	local snapshot = table.clone(self._listeners)
	for _, entry in ipairs(snapshot) do
		if entry.connected then
			task.spawn(entry.fn, ...)
		end
	end
end

function Signal:Destroy()
	for _, entry in ipairs(self._listeners) do
		entry.connected = false
	end
	table.clear(self._listeners)
end

return Signal

end

__MODULES["Core/Sound"] = function(script, require)
-- Optional UI Sound controller for micro-interactions (Hover, Click, Toggle, Notify)

local SoundService = game:GetService("SoundService")

local SoundController = {}
SoundController.__index = SoundController

export type SoundPreset = "Hover" | "Click" | "ToggleOn" | "ToggleOff" | "Notify"

export type SoundControllerType = typeof(setmetatable({} :: {
	Enabled: boolean,
	Volume: number,
	Sounds: { [SoundPreset]: string },
}, SoundController))

local DEFAULT_SOUNDS: { [SoundPreset]: string } = {
	Hover = "rbxassetid://6895079853",
	Click = "rbxassetid://6895079853",
	ToggleOn = "rbxassetid://6895079853",
	ToggleOff = "rbxassetid://6895079853",
	Notify = "rbxassetid://6895079853",
}

local PITCH_MAP: { [SoundPreset]: number } = {
	Hover = 1.25,
	Click = 1.0,
	ToggleOn = 1.15,
	ToggleOff = 0.85,
	Notify = 1.05,
}

function SoundController.new(enabled: boolean?): SoundControllerType
	return setmetatable({
		Enabled = if enabled == nil then true else enabled,
		Volume = 0.15,
		Sounds = table.clone(DEFAULT_SOUNDS),
	}, SoundController)
end

function SoundController:SetEnabled(enabled: boolean)
	self.Enabled = enabled
end

function SoundController:SetSoundId(preset: SoundPreset, assetId: string)
	self.Sounds[preset] = assetId
end

function SoundController:Play(preset: SoundPreset)
	if not self.Enabled then
		return
	end
	local assetId = self.Sounds[preset]
	if not assetId or assetId == "" then
		return
	end

	local sound = Instance.new("Sound")
	sound.SoundId = assetId
	sound.Volume = if preset == "Hover" then self.Volume * 0.45 else self.Volume
	sound.PlaybackSpeed = PITCH_MAP[preset] or 1.0
	sound.Parent = SoundService
	sound:Play()
	sound.Ended:Once(function()
		sound:Destroy()
	end)
	-- Fallback cleanup in case Ended doesn't fire
	task.delay(2, function()
		if sound.Parent then
			sound:Destroy()
		end
	end)
end

return SoundController

end

__MODULES["Elements/BaseElement"] = function(script, require)
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

end

__MODULES["Elements/Button"] = function(script, require)
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

end

__MODULES["Elements/Colorpicker"] = function(script, require)
-- Fluent Colorpicker Element (HSV Pad + Hue Slider + Hex Input + Optional Transparency)

local UserInputService = game:GetService("UserInputService")
local Creator = require(script.Parent.Parent.Core.Creator)
local Signal = require(script.Parent.Parent.Core.Signal)
local Sound = require(script.Parent.Parent.Core.Sound)
local BaseElement = require(script.Parent.BaseElement)
local Types = require(script.Parent.Parent.Types)

type ColorpickerOptions = Types.ColorpickerOptions

local Colorpicker = {}

local function colorToHex(c: Color3): string
	return string.format("#%02X%02X%02X", math.round(c.R * 255), math.round(c.G * 255), math.round(c.B * 255))
end

function Colorpicker.new(
	parent: Instance,
	themeReg: Creator.ThemeRegistry,
	sound: Sound.SoundControllerType,
	options: ColorpickerOptions
)
	local card = BaseElement.CreateCard(parent, themeReg, options, 56)
	local value: Color3 = options.Default or Color3.fromRGB(96, 205, 255)
	local transparency: number? = options.Transparency
	local h, s, v = value:ToHSV()
	local isOpen = false

	local changedSignal = Signal.new()
	card.Janitor:Add(changedSignal)

	local swatch = Creator.Create("TextButton", {
		Name = "ColorSwatch",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 44, 0, 24),
		BackgroundColor3 = value,
		Text = "",
		AutoButtonColor = false,
		Selectable = true,
		Parent = card.ControlHolder,
	}, {
		Creator.Corner(6),
	}) :: TextButton
	local swatchStroke = Creator.Stroke(themeReg.Theme.ElementBorder, 1, 0.15)
	swatchStroke.Parent = swatch
	themeReg:Bind(swatchStroke, "Color", "ElementBorder")

	-- Expandable Picker Drawer
	local drawer = Creator.Create("Frame", {
		Name = "ColorDrawer",
		Position = UDim2.new(0, 0, 0, 40),
		Size = UDim2.new(1, 0, 0, 0),
		ClipsDescendants = true,
		Visible = false,
		Parent = card.Frame,
	}, {
		Creator.Corner(6),
		Creator.Padding(8, 8, 8, 8),
	}) :: Frame
	local drawerStroke = Creator.Stroke(themeReg.Theme.ElementBorder, 1, 0.3)
	drawerStroke.Parent = drawer
	themeReg:Bind(drawer, "BackgroundColor3", "InputBackground")
	themeReg:Bind(drawerStroke, "Color", "ElementBorder")

	-- Saturation / Value Box
	local svBox = Creator.Create("TextButton", {
		Name = "SVBox",
		Size = UDim2.new(1, -28, 0, 108),
		BackgroundColor3 = Color3.fromHSV(h, 1, 1),
		Text = "",
		AutoButtonColor = false,
		Parent = drawer,
	}, {
		Creator.Corner(5),
	}) :: TextButton

	-- White horizontal gradient (Saturation)
	local satOverlay = Creator.Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Parent = svBox,
	}, {
		Creator.Corner(5),
		Creator.Create("UIGradient", {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 1),
			}),
		}),
	}) :: Frame
	local _ = satOverlay

	-- Black vertical gradient (Value)
	local valOverlay = Creator.Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		ZIndex = 2,
		Parent = svBox,
	}, {
		Creator.Corner(5),
		Creator.Create("UIGradient", {
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(1, 0),
			}),
		}),
	}) :: Frame
	local _2 = valOverlay

	local svCursor = Creator.Create("Frame", {
		Name = "Cursor",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(s, 0, 1 - v, 0),
		Size = UDim2.new(0, 12, 0, 12),
		BackgroundTransparency = 1,
		ZIndex = 4,
		Parent = svBox,
	}, {
		Creator.Corner(6),
		Creator.Stroke(Color3.fromRGB(255, 255, 255), 2, 0),
	}) :: Frame

	-- Vertical Hue Bar
	local hueBar = Creator.Create("TextButton", {
		Name = "HueBar",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0, 18, 0, 108),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Text = "",
		AutoButtonColor = false,
		Parent = drawer,
	}, {
		Creator.Corner(5),
		Creator.Create("UIGradient", {
			Rotation = 90,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0.00, Color3.fromHSV(0.00, 1, 1)),
				ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
				ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
				ColorSequenceKeypoint.new(0.50, Color3.fromHSV(0.50, 1, 1)),
				ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
				ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
				ColorSequenceKeypoint.new(1.00, Color3.fromHSV(1.00, 1, 1)),
			}),
		}),
	}) :: TextButton

	local hueCursor = Creator.Create("Frame", {
		Name = "HueCursor",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, h, 0),
		Size = UDim2.new(1, 4, 0, 6),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		ZIndex = 3,
		Parent = hueBar,
	}, {
		Creator.Corner(3),
	}) :: Frame

	local hexLabel = Creator.Create("TextLabel", {
		Name = "HexReadout",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 114),
		Size = UDim2.new(1, 0, 0, 18),
		Text = colorToHex(value),
		TextSize = 12,
		FontFace = Creator.BoldFont,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = drawer,
	}) :: TextLabel
	themeReg:Bind(hexLabel, "TextColor3", "SubText")

	local handle: any
	local function updateVisuals()
		swatch.BackgroundColor3 = value
		svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		svCursor.Position = UDim2.new(s, 0, 1 - v, 0)
		hueCursor.Position = UDim2.new(0.5, 0, h, 0)
		hexLabel.Text = colorToHex(value)
	end

	local function applyColor(silent: boolean?)
		value = Color3.fromHSV(h, s, v)
		handle.Value = value
		handle.Transparency = transparency
		updateVisuals()
		if not silent then
			if options.Callback then
				task.spawn(options.Callback, value, transparency)
			end
			changedSignal:Fire(value, transparency)
		end
	end

	local dragMode: ("sv" | "hue")? = nil

	local function handleInputPos(pos: Vector3)
		if dragMode == "sv" then
			local rx = math.clamp((pos.X - svBox.AbsolutePosition.X) / math.max(svBox.AbsoluteSize.X, 1), 0, 1)
			local ry = math.clamp((pos.Y - svBox.AbsolutePosition.Y) / math.max(svBox.AbsoluteSize.Y, 1), 0, 1)
			s = rx
			v = 1 - ry
			applyColor(false)
		elseif dragMode == "hue" then
			local ry = math.clamp((pos.Y - hueBar.AbsolutePosition.Y) / math.max(hueBar.AbsoluteSize.Y, 1), 0, 1)
			h = ry
			applyColor(false)
		end
	end

	card.Janitor:Add(svBox.InputBegan:Connect(function(input: InputObject)
		if card.Disabled then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragMode = "sv"
			handleInputPos(input.Position)
		end
	end))

	card.Janitor:Add(hueBar.InputBegan:Connect(function(input: InputObject)
		if card.Disabled then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragMode = "hue"
			handleInputPos(input.Position)
		end
	end))

	card.Janitor:Add(UserInputService.InputChanged:Connect(function(input: InputObject)
		if not dragMode then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			handleInputPos(input.Position)
		end
	end))

	card.Janitor:Add(UserInputService.InputEnded:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragMode = nil
		end
	end))

	card.Janitor:Add(swatch.Activated:Connect(function()
		if card.Disabled then
			return
		end
		sound:Play("Click")
		isOpen = not isOpen
		if isOpen then
			local topOffset = math.max(card.TextArea.AbsoluteSize.Y + 8, 36)
			drawer.Position = UDim2.new(0, 0, 0, topOffset)
			drawer.Visible = true
			Creator.Tween(drawer, 0.18, { Size = UDim2.new(1, 0, 0, 150) })
			card.ControlHolder.AnchorPoint = Vector2.new(1, 0)
			card.ControlHolder.Position = UDim2.new(1, 0, 0, 2)
		else
			local tw = Creator.Tween(drawer, 0.14, { Size = UDim2.new(1, 0, 0, 0) })
			tw.Completed:Once(function()
				if not isOpen then
					drawer.Visible = false
					card.ControlHolder.AnchorPoint = Vector2.new(1, 0.5)
					card.ControlHolder.Position = UDim2.new(1, 0, 0.5, 0)
				end
			end)
		end
	end))

	handle = setmetatable({
		Type = "Colorpicker",
		Value = value,
		Transparency = transparency,
		Default = value,
		Saveable = if options.Saveable == nil then true else options.Saveable,
		OnChanged = function(_, fn: (col: Color3, trans: number?) -> ())
			return changedSignal:Connect(fn)
		end,
		SetValue = function(_, newColor: Color3, newTrans: number?, silent: boolean?)
			if typeof(newColor) ~= "Color3" then
				return
			end
			h, s, v = newColor:ToHSV()
			if newTrans ~= nil then
				transparency = newTrans
			end
			applyColor(silent)
		end,
		GetValue = function(): Color3
			return value
		end,
	}, { __index = card })

	return handle
end

return Colorpicker

end

__MODULES["Elements/Divider"] = function(script, require)
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

end

__MODULES["Elements/Dropdown"] = function(script, require)
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

end

__MODULES["Elements/Image"] = function(script, require)
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

end

__MODULES["Elements/Input"] = function(script, require)
-- Fluent Text Input Element (Numeric, Finished-only, MaxLength, Silent SetValue)

local Creator = require(script.Parent.Parent.Core.Creator)
local Signal = require(script.Parent.Parent.Core.Signal)
local Sound = require(script.Parent.Parent.Core.Sound)
local BaseElement = require(script.Parent.BaseElement)
local Types = require(script.Parent.Parent.Types)

type InputOptions = Types.InputOptions

local Input = {}

function Input.new(
	parent: Instance,
	themeReg: Creator.ThemeRegistry,
	sound: Sound.SoundControllerType,
	options: InputOptions
)
	local card = BaseElement.CreateCard(parent, themeReg, options, 160)
	local value = options.Default or ""
	local numeric = options.Numeric == true
	local finishedOnly = options.Finished == true
	local maxLength = options.MaxLength

	local changedSignal = Signal.new()
	card.Janitor:Add(changedSignal)

	local boxWrap = Creator.Create("Frame", {
		Name = "InputWrap",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0, 28),
		Parent = card.ControlHolder,
	}, {
		Creator.Corner(6),
		Creator.Padding(0, 8, 0, 8),
	}) :: Frame

	local boxStroke = Creator.Stroke(themeReg.Theme.ElementBorder, 1, 0.2)
	boxStroke.Parent = boxWrap
	themeReg:Bind(boxWrap, "BackgroundColor3", "InputBackground")
	themeReg:Bind(boxStroke, "Color", "ElementBorder")

	local textBox = Creator.Create("TextBox", {
		Name = "TextBox",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Text = value,
		PlaceholderText = options.Placeholder or "Type here...",
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		ClipsDescendants = true,
		Selectable = true,
		Parent = boxWrap,
	}) :: TextBox
	themeReg:Bind(textBox, "TextColor3", "Text")
	themeReg:Bind(textBox, "PlaceholderColor3", "MutedText")

	local handle: any
	local isSettingInternally = false

	local function sanitize(raw: string): string
		local out = raw
		if numeric then
			out = string.gsub(out, "[^%d%.%-]", "")
		end
		if maxLength and #out > maxLength then
			out = string.sub(out, 1, maxLength)
		end
		return out
	end

	local function applyValue(newVal: string, silent: boolean?)
		local clean = sanitize(newVal)
		if textBox.Text ~= clean then
			isSettingInternally = true
			textBox.Text = clean
			isSettingInternally = false
		end
		if clean == value then
			return
		end
		value = clean
		handle.Value = value
		if not silent then
			if options.Callback then
				task.spawn(options.Callback, value)
			end
			changedSignal:Fire(value)
		end
	end

	card.Janitor:Add(textBox.Focused:Connect(function()
		if card.Disabled then
			textBox:ReleaseFocus()
			return
		end
		sound:Play("Click")
		Creator.Tween(boxStroke, 0.14, { Color = themeReg.Theme.Accent })
	end))

	card.Janitor:Add(textBox.FocusLost:Connect(function()
		Creator.Tween(boxStroke, 0.14, { Color = themeReg.Theme.ElementBorder })
		applyValue(textBox.Text, false)
	end))

	card.Janitor:Add(textBox:GetPropertyChangedSignal("Text"):Connect(function()
		if isSettingInternally then
			return
		end
		local clean = sanitize(textBox.Text)
		if clean ~= textBox.Text then
			isSettingInternally = true
			textBox.Text = clean
			isSettingInternally = false
		end
		if not finishedOnly then
			applyValue(clean, false)
		end
	end))

	handle = setmetatable({
		Type = "Input",
		Value = value,
		Default = value,
		Saveable = if options.Saveable == nil then true else options.Saveable,
		OnChanged = function(_, fn: (val: string) -> ())
			return changedSignal:Connect(fn)
		end,
		SetValue = function(_, newVal: string, silent: boolean?)
			applyValue(tostring(newVal or ""), silent)
		end,
		GetValue = function(): string
			return value
		end,
	}, { __index = card })

	return handle
end

return Input

end

__MODULES["Elements/Keybind"] = function(script, require)
-- Fluent Keybind Element (Toggle / Hold / Always modes + Interactive Recorder)

local UserInputService = game:GetService("UserInputService")
local Creator = require(script.Parent.Parent.Core.Creator)
local Signal = require(script.Parent.Parent.Core.Signal)
local Sound = require(script.Parent.Parent.Core.Sound)
local BaseElement = require(script.Parent.BaseElement)
local Types = require(script.Parent.Parent.Types)

type KeybindOptions = Types.KeybindOptions
type KeybindMode = Types.KeybindMode

local Keybind = {}

local function resolveKeyCode(key: (Enum.KeyCode | string)?): Enum.KeyCode
	if typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode then
		return key :: Enum.KeyCode
	elseif type(key) == "string" then
		local found = (Enum.KeyCode :: any)[key]
		if found then
			return found
		end
	end
	return Enum.KeyCode.Unknown
end

function Keybind.new(
	parent: Instance,
	themeReg: Creator.ThemeRegistry,
	sound: Sound.SoundControllerType,
	options: KeybindOptions
)
	local card = BaseElement.CreateCard(parent, themeReg, options, 96)
	local currentKey: Enum.KeyCode = resolveKeyCode(options.Default)
	local mode: KeybindMode = options.Mode or "Toggle"
	local active = (mode == "Always")
	local listening = false

	local stateSignal = Signal.new()
	local keyChangedSignal = Signal.new()
	card.Janitor:Add(stateSignal)
	card.Janitor:Add(keyChangedSignal)

	local bindBtn = Creator.Create("TextButton", {
		Name = "KeybindButton",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 88, 0, 26),
		Text = if currentKey == Enum.KeyCode.Unknown then "None" else currentKey.Name,
		TextSize = 12,
		FontFace = Creator.BoldFont,
		AutoButtonColor = false,
		Selectable = true,
		Parent = card.ControlHolder,
	}, {
		Creator.Corner(6),
	}) :: TextButton

	local bindStroke = Creator.Stroke(themeReg.Theme.ElementBorder, 1, 0.2)
	bindStroke.Parent = bindBtn
	themeReg:Bind(bindBtn, "BackgroundColor3", "InputBackground")
	themeReg:Bind(bindBtn, "TextColor3", "Text")
	themeReg:Bind(bindStroke, "Color", "ElementBorder")

	local handle: any

	local function setKey(newKey: Enum.KeyCode, silent: boolean?)
		currentKey = newKey
		handle.Value = currentKey
		bindBtn.Text = if currentKey == Enum.KeyCode.Unknown then "None" else currentKey.Name
		if not silent then
			if options.ChangedCallback then
				task.spawn(options.ChangedCallback, currentKey)
			end
			keyChangedSignal:Fire(currentKey)
		end
	end

	local function setActive(newActive: boolean)
		if active == newActive then
			return
		end
		active = newActive
		if options.Callback then
			task.spawn(options.Callback, active)
		end
		stateSignal:Fire(active)
	end

	card.Janitor:Add(bindBtn.Activated:Connect(function()
		if card.Disabled or listening then
			return
		end
		sound:Play("Click")
		listening = true
		bindBtn.Text = "..."
		Creator.Tween(bindStroke, 0.12, { Color = themeReg.Theme.Accent })
	end))

	card.Janitor:Add(UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
		if listening then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				listening = false
				Creator.Tween(bindStroke, 0.12, { Color = themeReg.Theme.ElementBorder })
				if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
					setKey(Enum.KeyCode.Unknown, false)
				else
					setKey(input.KeyCode, false)
				end
			end
			return
		end

		if gameProcessed or card.Disabled or currentKey == Enum.KeyCode.Unknown then
			return
		end

		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
			if mode == "Toggle" then
				setActive(not active)
			elseif mode == "Hold" then
				setActive(true)
			end
		end
	end))

	card.Janitor:Add(UserInputService.InputEnded:Connect(function(input: InputObject)
		if mode == "Hold" and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
			setActive(false)
		end
	end))

	handle = setmetatable({
		Type = "Keybind",
		Value = currentKey,
		Default = currentKey,
		Mode = mode,
		Saveable = if options.Saveable == nil then true else options.Saveable,
		GetState = function(): boolean
			if mode == "Always" then
				return true
			end
			return active
		end,
		OnChanged = function(_, fn: (newKey: Enum.KeyCode) -> ())
			return keyChangedSignal:Connect(fn)
		end,
		OnStateChanged = function(_, fn: (isActive: boolean) -> ())
			return stateSignal:Connect(fn)
		end,
		SetValue = function(_, newKey: Enum.KeyCode | string, silent: boolean?)
			setKey(resolveKeyCode(newKey), silent)
		end,
		GetValue = function(): Enum.KeyCode
			return currentKey
		end,
	}, { __index = card })

	return handle
end

return Keybind

end

__MODULES["Elements/Paragraph"] = function(script, require)
-- Fluent Paragraph Element (Multi-line Thai-friendly info card)

local Creator = require(script.Parent.Parent.Core.Creator)
local BaseElement = require(script.Parent.BaseElement)
local Types = require(script.Parent.Parent.Types)

type ParagraphOptions = Types.ParagraphOptions

local Paragraph = {}

function Paragraph.new(
	parent: Instance,
	themeReg: Creator.ThemeRegistry,
	options: ParagraphOptions
)
	local card = BaseElement.CreateCard(parent, themeReg, {
		Id = options.Id,
		Title = options.Title,
		Description = options.Content,
		Visible = options.Visible,
		Saveable = false,
	}, 0)

	card.TextArea.Size = UDim2.new(1, 0, 0, 0)
	card.ControlHolder.Visible = false

	local handle = setmetatable({
		Type = "Paragraph",
		SetContent = function(self, content: string)
			self:SetDescription(content)
		end,
	}, { __index = card })

	return handle
end

return Paragraph

end

__MODULES["Elements/ProgressBar"] = function(script, require)
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

end

__MODULES["Elements/RangeSlider"] = function(script, require)
-- Fluent Range Slider Element (Dual-thumb Min-Max for Mouse + Touch)

local UserInputService = game:GetService("UserInputService")
local Creator = require(script.Parent.Parent.Core.Creator)
local Signal = require(script.Parent.Parent.Core.Signal)
local Sound = require(script.Parent.Parent.Core.Sound)
local BaseElement = require(script.Parent.BaseElement)
local Types = require(script.Parent.Parent.Types)

type RangeSliderOptions = Types.RangeSliderOptions

local RangeSlider = {}

local function roundNum(val: number, decimals: number): number
	local mult = 10 ^ decimals
	return math.floor(val * mult + 0.5) / mult
end

function RangeSlider.new(
	parent: Instance,
	themeReg: Creator.ThemeRegistry,
	sound: Sound.SoundControllerType,
	options: RangeSliderOptions
)
	local card = BaseElement.CreateCard(parent, themeReg, options, 195)
	local minLimit = options.Min
	local maxLimit = math.max(options.Max, minLimit + 0.001)
	local rounding = options.Rounding or 0
	local suffix = options.Suffix or ""

	local low = roundNum(math.clamp(options.DefaultMin or minLimit, minLimit, maxLimit), rounding)
	local high = roundNum(math.clamp(options.DefaultMax or maxLimit, low, maxLimit), rounding)

	local changedSignal = Signal.new()
	card.Janitor:Add(changedSignal)

	local valueLabel = Creator.Create("TextLabel", {
		Name = "ValueLabel",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 68, 0, 20),
		Text = string.format("%s - %s%s", tostring(low), tostring(high), suffix),
		TextSize = 11,
		FontFace = Creator.BoldFont,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = card.ControlHolder,
	}) :: TextLabel
	themeReg:Bind(valueLabel, "TextColor3", "SubText")

	local hitArea = Creator.Create("TextButton", {
		Name = "RangeHitArea",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, -74, 0, 26),
		Text = "",
		AutoButtonColor = false,
		Selectable = true,
		Parent = card.ControlHolder,
	}) :: TextButton

	local rail = Creator.Create("Frame", {
		Name = "Rail",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0, 5),
		Parent = hitArea,
	}, {
		Creator.Corner(3),
	}) :: Frame
	themeReg:Bind(rail, "BackgroundColor3", "InputBackground")

	local fill = Creator.Create("Frame", {
		Name = "Fill",
		Size = UDim2.new(1, 0, 1, 0),
		Parent = rail,
	}, {
		Creator.Corner(3),
	}) :: Frame
	themeReg:Bind(fill, "BackgroundColor3", "Accent")

	local function createThumb(name: string): Frame
		local thumb = Creator.Create("Frame", {
			Name = name,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(0, 13, 0, 13),
			ZIndex = 3,
			Parent = rail,
		}, {
			Creator.Corner(7),
		}) :: Frame
		themeReg:Bind(thumb, "BackgroundColor3", "Text")
		local st = Creator.Stroke(themeReg.Theme.Accent, 2, 0)
		st.Parent = thumb
		themeReg:Bind(st, "Color", "Accent")
		return thumb
	end

	local thumbLow = createThumb("ThumbLow")
	local thumbHigh = createThumb("ThumbHigh")

	local function updateVisuals()
		local aLow = math.clamp((low - minLimit) / (maxLimit - minLimit), 0, 1)
		local aHigh = math.clamp((high - minLimit) / (maxLimit - minLimit), 0, 1)
		valueLabel.Text = string.format("%s - %s%s", tostring(low), tostring(high), suffix)
		fill.Position = UDim2.new(aLow, 0, 0, 0)
		fill.Size = UDim2.new(math.max(0, aHigh - aLow), 0, 1, 0)
		thumbLow.Position = UDim2.new(aLow, 0, 0.5, 0)
		thumbHigh.Position = UDim2.new(aHigh, 0, 0.5, 0)
	end

	updateVisuals()

	local handle: any
	local function setValue(newLow: number, newHigh: number, silent: boolean?)
		local cLow = roundNum(math.clamp(newLow, minLimit, maxLimit), rounding)
		local cHigh = roundNum(math.clamp(newHigh, minLimit, maxLimit), rounding)
		if cLow > cHigh then
			cLow, cHigh = cHigh, cLow
		end
		if cLow == low and cHigh == high then
			return
		end
		low = cLow
		high = cHigh
		handle.Value = { Min = low, Max = high }
		updateVisuals()

		if not silent then
			if options.Callback then
				task.spawn(options.Callback, low, high)
			end
			changedSignal:Fire(low, high)
		end
	end

	local activeThumb: ("low" | "high")? = nil

	local function updateFromX(inputX: number)
		local absPos = rail.AbsolutePosition.X
		local absSize = rail.AbsoluteSize.X
		if absSize <= 0 then
			return
		end
		local alpha = math.clamp((inputX - absPos) / absSize, 0, 1)
		local raw = roundNum(minLimit + (maxLimit - minLimit) * alpha, rounding)

		if activeThumb == "low" then
			setValue(math.min(raw, high), high, false)
		elseif activeThumb == "high" then
			setValue(low, math.max(raw, low), false)
		end
	end

	card.Janitor:Add(hitArea.InputBegan:Connect(function(input: InputObject)
		if card.Disabled then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local distLow = math.abs(input.Position.X - thumbLow.AbsolutePosition.X)
			local distHigh = math.abs(input.Position.X - thumbHigh.AbsolutePosition.X)
			activeThumb = if distLow <= distHigh then "low" else "high"
			sound:Play("Click")
			updateFromX(input.Position.X)
		end
	end))

	card.Janitor:Add(UserInputService.InputChanged:Connect(function(input: InputObject)
		if not activeThumb then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			updateFromX(input.Position.X)
		end
	end))

	card.Janitor:Add(UserInputService.InputEnded:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			activeThumb = nil
		end
	end))

	handle = setmetatable({
		Type = "RangeSlider",
		Value = { Min = low, Max = high },
		Default = { Min = low, Max = high },
		Saveable = if options.Saveable == nil then true else options.Saveable,
		OnChanged = function(_, fn: (minVal: number, maxVal: number) -> ())
			return changedSignal:Connect(fn)
		end,
		SetValue = function(_, arg1: any, arg2: any, arg3: boolean?)
			if type(arg1) == "table" then
				setValue(arg1.Min or minLimit, arg1.Max or maxLimit, arg2)
			else
				setValue(arg1, arg2, arg3)
			end
		end,
		GetValue = function(): { Min: number, Max: number }
			return { Min = low, Max = high }
		end,
	}, { __index = card })

	return handle
end

return RangeSlider

end

__MODULES["Elements/Slider"] = function(script, require)
-- Fluent Slider Element (Mouse + Touch friendly, Rounding, Suffix, Silent SetValue)

local UserInputService = game:GetService("UserInputService")
local Creator = require(script.Parent.Parent.Core.Creator)
local Signal = require(script.Parent.Parent.Core.Signal)
local Sound = require(script.Parent.Parent.Core.Sound)
local BaseElement = require(script.Parent.BaseElement)
local Types = require(script.Parent.Parent.Types)

type SliderOptions = Types.SliderOptions

local Slider = {}

local function roundNumber(val: number, decimals: number): number
	local mult = 10 ^ decimals
	return math.floor(val * mult + 0.5) / mult
end

function Slider.new(
	parent: Instance,
	themeReg: Creator.ThemeRegistry,
	sound: Sound.SoundControllerType,
	options: SliderOptions
)
	local card = BaseElement.CreateCard(parent, themeReg, options, 175)
	local minVal = options.Min
	local maxVal = math.max(options.Max, minVal + 0.001)
	local rounding = options.Rounding or 0
	local suffix = options.Suffix or ""
	local value = roundNumber(math.clamp(options.Default or minVal, minVal, maxVal), rounding)

	local changedSignal = Signal.new()
	card.Janitor:Add(changedSignal)

	local valueLabel = Creator.Create("TextLabel", {
		Name = "ValueLabel",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 46, 0, 20),
		Text = tostring(value) .. suffix,
		TextSize = 12,
		FontFace = Creator.BoldFont,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = card.ControlHolder,
	}) :: TextLabel
	themeReg:Bind(valueLabel, "TextColor3", "SubText")

	-- Larger invisible hitbox for easier Touch / Mobile dragging
	local hitArea = Creator.Create("TextButton", {
		Name = "SliderHitArea",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, -52, 0, 26),
		Text = "",
		AutoButtonColor = false,
		Selectable = true,
		Parent = card.ControlHolder,
	}) :: TextButton

	local rail = Creator.Create("Frame", {
		Name = "Rail",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0, 5),
		Parent = hitArea,
	}, {
		Creator.Corner(3),
	}) :: Frame
	themeReg:Bind(rail, "BackgroundColor3", "InputBackground")

	local fill = Creator.Create("Frame", {
		Name = "Fill",
		Size = UDim2.new(0, 0, 1, 0),
		Parent = rail,
	}, {
		Creator.Corner(3),
	}) :: Frame
	themeReg:Bind(fill, "BackgroundColor3", "Accent")

	local thumb = Creator.Create("Frame", {
		Name = "Thumb",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 14, 0, 14),
		ZIndex = 3,
		Parent = rail,
	}, {
		Creator.Corner(7),
	}) :: Frame
	themeReg:Bind(thumb, "BackgroundColor3", "Text")

	local thumbStroke = Creator.Stroke(themeReg.Theme.Accent, 2, 0)
	thumbStroke.Parent = thumb
	themeReg:Bind(thumbStroke, "Color", "Accent")

	local function updateVisuals(animate: boolean)
		local alpha = math.clamp((value - minVal) / (maxVal - minVal), 0, 1)
		valueLabel.Text = tostring(value) .. suffix
		if animate then
			Creator.Tween(fill, 0.08, { Size = UDim2.new(alpha, 0, 1, 0) })
			Creator.Tween(thumb, 0.08, { Position = UDim2.new(alpha, 0, 0.5, 0) })
		else
			fill.Size = UDim2.new(alpha, 0, 1, 0)
			thumb.Position = UDim2.new(alpha, 0, 0.5, 0)
		end
	end

	updateVisuals(false)

	local handle: any
	local function setValue(newVal: number, silent: boolean?)
		local clamped = roundNumber(math.clamp(newVal, minVal, maxVal), rounding)
		if clamped == value then
			updateVisuals(true)
			return
		end
		value = clamped
		handle.Value = value
		updateVisuals(true)

		if not silent then
			if options.Callback then
				task.spawn(options.Callback, value)
			end
			changedSignal:Fire(value)
		end
	end

	local dragging = false
	local function updateFromX(inputX: number)
		local absPos = rail.AbsolutePosition.X
		local absSize = rail.AbsoluteSize.X
		if absSize <= 0 then
			return
		end
		local alpha = math.clamp((inputX - absPos) / absSize, 0, 1)
		local raw = minVal + (maxVal - minVal) * alpha
		setValue(raw, false)
	end

	card.Janitor:Add(hitArea.InputBegan:Connect(function(input: InputObject)
		if card.Disabled then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			sound:Play("Click")
			updateFromX(input.Position.X)
		end
	end))

	card.Janitor:Add(UserInputService.InputChanged:Connect(function(input: InputObject)
		if not dragging then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			updateFromX(input.Position.X)
		end
	end))

	card.Janitor:Add(UserInputService.InputEnded:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end))

	handle = setmetatable({
		Type = "Slider",
		Value = value,
		Default = value,
		Saveable = if options.Saveable == nil then true else options.Saveable,
		OnChanged = function(_, fn: (val: number) -> ())
			return changedSignal:Connect(fn)
		end,
		SetValue = function(_, newVal: number, silent: boolean?)
			setValue(newVal, silent)
		end,
		GetValue = function(): number
			return value
		end,
	}, { __index = card })

	return handle
end

return Slider

end

__MODULES["Elements/Toggle"] = function(script, require)
-- Fluent Toggle Switch Element (supports Silent SetValue for DataStore sync)

local Creator = require(script.Parent.Parent.Core.Creator)
local Signal = require(script.Parent.Parent.Core.Signal)
local Sound = require(script.Parent.Parent.Core.Sound)
local BaseElement = require(script.Parent.BaseElement)
local Types = require(script.Parent.Parent.Types)

type ToggleOptions = Types.ToggleOptions

local Toggle = {}

function Toggle.new(
	parent: Instance,
	themeReg: Creator.ThemeRegistry,
	sound: Sound.SoundControllerType,
	options: ToggleOptions
)
	local card = BaseElement.CreateCard(parent, themeReg, options, 52)
	local value = options.Default == true
	local changedSignal = Signal.new()
	card.Janitor:Add(changedSignal)

	local track = Creator.Create("TextButton", {
		Name = "ToggleTrack",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 44, 0, 22),
		Text = "",
		AutoButtonColor = false,
		Selectable = true,
		Parent = card.ControlHolder,
	}, {
		Creator.Corner(11),
	}) :: TextButton

	local trackStroke = Creator.Stroke(themeReg.Theme.ElementBorder, 1, 0.2)
	trackStroke.Parent = track

	local knob = Creator.Create("Frame", {
		Name = "Knob",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.new(0, 16, 0, 16),
		Parent = track,
	}, {
		Creator.Corner(8),
	}) :: Frame

	local function render(animate: boolean)
		local theme = themeReg.Theme
		local targetBg = if value then theme.Accent else theme.InputBackground
		local targetKnobColor = if value then Color3.fromRGB(255, 255, 255) else theme.SubText
		local targetPos = if value then UDim2.new(1, -19, 0.5, 0) else UDim2.new(0, 3, 0.5, 0)
		local targetStroke = if value then theme.Accent else theme.ElementBorder

		if animate then
			Creator.Tween(track, 0.16, { BackgroundColor3 = targetBg })
			Creator.Tween(trackStroke, 0.16, { Color = targetStroke })
			Creator.Tween(knob, 0.16, { Position = targetPos, BackgroundColor3 = targetKnobColor })
		else
			track.BackgroundColor3 = targetBg
			trackStroke.Color = targetStroke
			knob.Position = targetPos
			knob.BackgroundColor3 = targetKnobColor
		end
	end

	render(false)
	themeReg:OnThemeChanged(function()
		render(true)
	end)

	local handle: any
	local function setValue(newVal: boolean, silent: boolean?)
		local boolVal = newVal == true
		if boolVal == value then
			return
		end
		value = boolVal
		handle.Value = value
		render(true)

		if not silent then
			sound:Play(if value then "ToggleOn" else "ToggleOff")
			if options.Callback then
				task.spawn(options.Callback, value)
			end
			changedSignal:Fire(value)
		end
	end

	card.Janitor:Add(track.Activated:Connect(function()
		if card.Disabled then
			return
		end
		setValue(not value, false)
	end))

	handle = setmetatable({
		Type = "Toggle",
		Value = value,
		Default = options.Default == true,
		Saveable = if options.Saveable == nil then true else options.Saveable,
		OnChanged = function(_, fn: (val: boolean) -> ())
			return changedSignal:Connect(fn)
		end,
		SetValue = function(_, newVal: boolean, silent: boolean?)
			setValue(newVal, silent)
		end,
		GetValue = function(): boolean
			return value
		end,
	}, { __index = card })

	return handle
end

return Toggle

end

__MODULES["Icons/init"] = function(script, require)
-- Flexible Icon Resolver: supports named Lucide/common icons, custom registered icons, and direct rbxassetid:// URLs

local Icons = {}

local IconMap: { [string]: string } = {
	-- Common UI icons (Lucide-style Roblox uploaded icon IDs)
	home = "rbxassetid://10723407389",
	settings = "rbxassetid://10734950309",
	sliders = "rbxassetid://10734963400",
	search = "rbxassetid://10734943674",
	user = "rbxassetid://10747373176",
	users = "rbxassetid://10747373426",
	shield = "rbxassetid://10734951847",
	lock = "rbxassetid://10723434711",
	unlock = "rbxassetid://10747366027",
	bell = "rbxassetid://10709775704",
	star = "rbxassetid://10734966248",
	heart = "rbxassetid://10723406885",
	check = "rbxassetid://10709790644",
	x = "rbxassetid://10747384394",
	minus = "rbxassetid://10734896206",
	plus = "rbxassetid://10734924532",
	["chevron-down"] = "rbxassetid://10709790948",
	["chevron-right"] = "rbxassetid://10709791437",
	["chevron-up"] = "rbxassetid://10709791523",
	palette = "rbxassetid://10734910430",
	save = "rbxassetid://10734941499",
	folder = "rbxassetid://10723387563",
	file = "rbxassetid://10723374641",
	code = "rbxassetid://10709810463",
	terminal = "rbxassetid://10734982144",
	gamepad = "rbxassetid://10723395457",
	volume = "rbxassetid://10747376008",
	image = "rbxassetid://10723415040",
	eye = "rbxassetid://10723346959",
	["eye-off"] = "rbxassetid://10723346871",
	zap = "rbxassetid://10747384775",
	wrench = "rbxassetid://10747383470",
	info = "rbxassetid://10723415903",
	["alert-triangle"] = "rbxassetid://10709753149",
	menu = "rbxassetid://10734887784",
	sparkles = "rbxassetid://10734965070",
	layers = "rbxassetid://10723424505",
	globe = "rbxassetid://10723404337",
	keyboard = "rbxassetid://10723421808",
}

function Icons.Resolve(icon: string?): string
	if not icon or icon == "" then
		return ""
	end
	if string.sub(icon, 1, 13) == "rbxassetid://" or string.sub(icon, 1, 11) == "rbxasset://" then
		return icon
	end
	if tonumber(icon) then
		return "rbxassetid://" .. icon
	end
	local lower = string.lower(icon)
	return IconMap[lower] or ""
end

function Icons.Register(name: string, assetId: string)
	IconMap[string.lower(name)] = assetId
end

function Icons.RegisterBatch(map: { [string]: string })
	for k, v in pairs(map) do
		IconMap[string.lower(k)] = v
	end
end

return Icons

end

__MODULES["Managers/ConfigManager"] = function(script, require)
-- Roblox-Native Config Adapter (DataStore / ProfileStore ready)
-- Serializes & deserializes UI element values safely without executor file I/O

local HttpService = game:GetService("HttpService")
local Types = require(script.Parent.Parent.Types)

type ConfigData = Types.ConfigData

local ConfigManager = {}
ConfigManager.__index = ConfigManager

export type RegisteredEntry = {
	Id: string,
	Type: string,
	GetValue: () -> any,
	SetValue: (value: any, silent: boolean?) -> (),
	Default: any,
}

export type ConfigManagerType = typeof(setmetatable({} :: {
	_entries: { [string]: RegisteredEntry },
}, ConfigManager))

local function serializeValue(val: any): any
	local t = typeof(val)
	if t == "Color3" then
		return { __type = "Color3", r = val.R, g = val.G, b = val.B }
	elseif t == "EnumItem" then
		return { __type = "EnumItem", enum = tostring(val.EnumType), name = val.Name }
	elseif t == "table" then
		local out = {}
		for k, v in pairs(val) do
			out[k] = serializeValue(v)
		end
		return out
	end
	return val
end

local function deserializeValue(val: any): any
	if type(val) == "table" then
		if val.__type == "Color3" and type(val.r) == "number" and type(val.g) == "number" and type(val.b) == "number" then
			return Color3.new(val.r, val.g, val.b)
		elseif val.__type == "EnumItem" and type(val.enum) == "string" and type(val.name) == "string" then
			local enumType = (Enum :: any)[val.enum]
			if enumType and enumType[val.name] then
				return enumType[val.name]
			end
			return nil
		else
			local out = {}
			for k, v in pairs(val) do
				out[k] = deserializeValue(v)
			end
			return out
		end
	end
	return val
end

function ConfigManager.new(): ConfigManagerType
	return setmetatable({
		_entries = {},
	}, ConfigManager)
end

function ConfigManager:Register(entry: RegisteredEntry)
	self._entries[entry.Id] = entry
end

function ConfigManager:Unregister(id: string)
	self._entries[id] = nil
end

function ConfigManager:Export(): ConfigData
	local data: ConfigData = {}
	for id, entry in pairs(self._entries) do
		data[id] = serializeValue(entry.GetValue())
	end
	return data
end

function ConfigManager:Import(data: ConfigData, silent: boolean?)
	if type(data) ~= "table" then
		return
	end
	for id, rawVal in pairs(data) do
		local entry = self._entries[id]
		if entry then
			local decoded = deserializeValue(rawVal)
			if decoded ~= nil then
				entry.SetValue(decoded, silent)
			end
		end
	end
end

function ConfigManager:ExportJSON(): string
	return HttpService:JSONEncode(self:Export())
end

function ConfigManager:ImportJSON(jsonString: string, silent: boolean?): boolean
	local ok, decoded = pcall(function()
		return HttpService:JSONDecode(jsonString)
	end)
	if not ok or type(decoded) ~= "table" then
		return false
	end
	self:Import(decoded, silent)
	return true
end

function ConfigManager:ResetDefaults(silent: boolean?)
	for _, entry in pairs(self._entries) do
		if entry.Default ~= nil then
			entry.SetValue(entry.Default, silent)
		end
	end
end

function ConfigManager:Destroy()
	table.clear(self._entries)
end

return ConfigManager

end

__MODULES["Themes/init"] = function(script, require)
-- FluentStudio Themes (Dark, Light, Amethyst, Aqua, Rose) + Custom Theme Builder

local Types = require(script.Parent.Types)
type ThemePalette = Types.ThemePalette

local Themes = {}

local Registry: { [string]: ThemePalette } = {
	Dark = {
		Name = "Dark",
		Accent = Color3.fromRGB(96, 205, 255),
		AccentHover = Color3.fromRGB(122, 214, 255),
		Background = Color3.fromRGB(24, 24, 28),
		BackgroundTransparency = 0.08,
		Sidebar = Color3.fromRGB(20, 20, 24),
		SidebarTransparency = 0.05,
		Surface = Color3.fromRGB(34, 34, 40),
		SurfaceHover = Color3.fromRGB(44, 44, 52),
		SurfaceActive = Color3.fromRGB(52, 52, 62),
		Element = Color3.fromRGB(38, 38, 45),
		ElementHover = Color3.fromRGB(48, 48, 57),
		ElementBorder = Color3.fromRGB(62, 62, 74),
		Border = Color3.fromRGB(60, 60, 72),
		Text = Color3.fromRGB(245, 245, 248),
		SubText = Color3.fromRGB(185, 185, 198),
		MutedText = Color3.fromRGB(130, 130, 145),
		DisabledText = Color3.fromRGB(95, 95, 108),
		InputBackground = Color3.fromRGB(26, 26, 32),
		Shadow = Color3.fromRGB(0, 0, 0),
		Success = Color3.fromRGB(74, 222, 128),
		Warning = Color3.fromRGB(251, 191, 36),
		Danger = Color3.fromRGB(248, 113, 113),
	},

	Light = {
		Name = "Light",
		Accent = Color3.fromRGB(0, 103, 192),
		AccentHover = Color3.fromRGB(20, 120, 208),
		Background = Color3.fromRGB(243, 244, 248),
		BackgroundTransparency = 0.06,
		Sidebar = Color3.fromRGB(234, 236, 242),
		SidebarTransparency = 0.04,
		Surface = Color3.fromRGB(255, 255, 255),
		SurfaceHover = Color3.fromRGB(246, 247, 251),
		SurfaceActive = Color3.fromRGB(232, 236, 244),
		Element = Color3.fromRGB(255, 255, 255),
		ElementHover = Color3.fromRGB(244, 246, 250),
		ElementBorder = Color3.fromRGB(214, 218, 228),
		Border = Color3.fromRGB(208, 212, 222),
		Text = Color3.fromRGB(24, 26, 32),
		SubText = Color3.fromRGB(88, 94, 108),
		MutedText = Color3.fromRGB(132, 138, 152),
		DisabledText = Color3.fromRGB(168, 172, 182),
		InputBackground = Color3.fromRGB(248, 249, 252),
		Shadow = Color3.fromRGB(20, 24, 36),
		Success = Color3.fromRGB(22, 163, 74),
		Warning = Color3.fromRGB(217, 119, 6),
		Danger = Color3.fromRGB(220, 38, 38),
	},

	Amethyst = {
		Name = "Amethyst",
		Accent = Color3.fromRGB(168, 130, 255),
		AccentHover = Color3.fromRGB(186, 154, 255),
		Background = Color3.fromRGB(24, 20, 34),
		BackgroundTransparency = 0.08,
		Sidebar = Color3.fromRGB(19, 16, 28),
		SidebarTransparency = 0.05,
		Surface = Color3.fromRGB(35, 30, 50),
		SurfaceHover = Color3.fromRGB(46, 40, 66),
		SurfaceActive = Color3.fromRGB(56, 48, 80),
		Element = Color3.fromRGB(39, 34, 56),
		ElementHover = Color3.fromRGB(50, 44, 72),
		ElementBorder = Color3.fromRGB(78, 66, 112),
		Border = Color3.fromRGB(72, 60, 104),
		Text = Color3.fromRGB(246, 244, 252),
		SubText = Color3.fromRGB(192, 184, 216),
		MutedText = Color3.fromRGB(138, 128, 166),
		DisabledText = Color3.fromRGB(98, 90, 122),
		InputBackground = Color3.fromRGB(26, 22, 38),
		Shadow = Color3.fromRGB(0, 0, 0),
		Success = Color3.fromRGB(74, 222, 128),
		Warning = Color3.fromRGB(251, 191, 36),
		Danger = Color3.fromRGB(248, 113, 113),
	},

	Aqua = {
		Name = "Aqua",
		Accent = Color3.fromRGB(56, 224, 212),
		AccentHover = Color3.fromRGB(92, 236, 226),
		Background = Color3.fromRGB(18, 28, 32),
		BackgroundTransparency = 0.08,
		Sidebar = Color3.fromRGB(14, 23, 27),
		SidebarTransparency = 0.05,
		Surface = Color3.fromRGB(26, 40, 46),
		SurfaceHover = Color3.fromRGB(34, 52, 60),
		SurfaceActive = Color3.fromRGB(42, 64, 74),
		Element = Color3.fromRGB(30, 45, 52),
		ElementHover = Color3.fromRGB(38, 57, 66),
		ElementBorder = Color3.fromRGB(56, 86, 98),
		Border = Color3.fromRGB(50, 78, 90),
		Text = Color3.fromRGB(240, 250, 252),
		SubText = Color3.fromRGB(174, 206, 214),
		MutedText = Color3.fromRGB(118, 152, 162),
		DisabledText = Color3.fromRGB(84, 112, 120),
		InputBackground = Color3.fromRGB(20, 32, 37),
		Shadow = Color3.fromRGB(0, 0, 0),
		Success = Color3.fromRGB(74, 222, 128),
		Warning = Color3.fromRGB(251, 191, 36),
		Danger = Color3.fromRGB(248, 113, 113),
	},

	Rose = {
		Name = "Rose",
		Accent = Color3.fromRGB(251, 113, 133),
		AccentHover = Color3.fromRGB(253, 142, 158),
		Background = Color3.fromRGB(30, 20, 24),
		BackgroundTransparency = 0.08,
		Sidebar = Color3.fromRGB(24, 16, 20),
		SidebarTransparency = 0.05,
		Surface = Color3.fromRGB(44, 30, 36),
		SurfaceHover = Color3.fromRGB(56, 38, 46),
		SurfaceActive = Color3.fromRGB(68, 46, 56),
		Element = Color3.fromRGB(48, 34, 40),
		ElementHover = Color3.fromRGB(62, 44, 52),
		ElementBorder = Color3.fromRGB(94, 62, 74),
		Border = Color3.fromRGB(86, 56, 68),
		Text = Color3.fromRGB(252, 244, 246),
		SubText = Color3.fromRGB(214, 184, 194),
		MutedText = Color3.fromRGB(158, 126, 136),
		DisabledText = Color3.fromRGB(114, 88, 96),
		InputBackground = Color3.fromRGB(34, 22, 27),
		Shadow = Color3.fromRGB(0, 0, 0),
		Success = Color3.fromRGB(74, 222, 128),
		Warning = Color3.fromRGB(251, 191, 36),
		Danger = Color3.fromRGB(248, 113, 113),
	},
}

function Themes.Get(name: string): ThemePalette
	return Registry[name] or Registry.Dark
end

function Themes.List(): { string }
	local names = {}
	for k in pairs(Registry) do
		table.insert(names, k)
	end
	table.sort(names)
	return names
end

function Themes.Register(name: string, palette: ThemePalette)
	palette.Name = name
	Registry[name] = palette
end

-- Auto-generate a full palette from a single Accent color on top of Dark or Light base
function Themes.CreateFromAccent(name: string, accent: Color3, baseMode: ("Dark" | "Light")?): ThemePalette
	local base = table.clone(Registry[baseMode or "Dark"]) :: ThemePalette
	local h, s, v = accent:ToHSV()
	base.Name = name
	base.Accent = accent
	base.AccentHover = Color3.fromHSV(h, math.clamp(s * 0.85, 0, 1), math.clamp(v + 0.1, 0, 1))
	Registry[name] = base
	return base
end

return Themes

end

__MODULES["Types"] = function(script, require)
-- FluentStudio Types Definition

export type ThemePalette = {
	Name: string,
	Accent: Color3,
	AccentHover: Color3,
	Background: Color3,
	BackgroundTransparency: number,
	Sidebar: Color3,
	SidebarTransparency: number,
	Surface: Color3,
	SurfaceHover: Color3,
	SurfaceActive: Color3,
	Element: Color3,
	ElementHover: Color3,
	ElementBorder: Color3,
	Border: Color3,
	Text: Color3,
	SubText: Color3,
	MutedText: Color3,
	DisabledText: Color3,
	InputBackground: Color3,
	Shadow: Color3,
	Success: Color3,
	Warning: Color3,
	Danger: Color3,
}

export type WindowOptions = {
	Title: string,
	SubTitle: string?,
	Size: UDim2?,
	MinSize: Vector2?,
	TabWidth: number?,
	Theme: string?,
	MinimizeKey: Enum.KeyCode?,
	DisplayOrder: number?,
	AcrylicBlur: boolean?,
	Resizable: boolean?,
	SearchBar: boolean?,
	SoundEnabled: boolean?,
	MobileToggleButton: boolean?,
	Parent: Instance?,
}

export type TabOptions = {
	Title: string,
	Icon: string?,
	Columns: number?, -- 1 or 2
}

export type SectionOptions = {
	Title: string,
	Collapsible: boolean?,
	DefaultOpen: boolean?,
	Column: number?, -- 1 or 2 (when Tab Columns == 2)
}

export type BaseElementOptions = {
	Id: string?,
	Title: string,
	Description: string?,
	Visible: boolean?,
	Disabled: boolean?,
	LockedText: string?,
	Saveable: boolean?,
}

export type ButtonOptions = BaseElementOptions & {
	ButtonText: string?,
	Callback: (() -> ())?,
}

export type ToggleOptions = BaseElementOptions & {
	Default: boolean?,
	Callback: ((value: boolean) -> ())?,
}

export type SliderOptions = BaseElementOptions & {
	Min: number,
	Max: number,
	Default: number?,
	Rounding: number?,
	Suffix: string?,
	Callback: ((value: number) -> ())?,
}

export type RangeSliderOptions = BaseElementOptions & {
	Min: number,
	Max: number,
	DefaultMin: number?,
	DefaultMax: number?,
	Rounding: number?,
	Suffix: string?,
	Callback: ((minVal: number, maxVal: number) -> ())?,
}

export type DropdownOptions = BaseElementOptions & {
	Values: { string },
	Default: (string | { string })?,
	Multi: boolean?,
	Searchable: boolean?,
	AllowNull: boolean?,
	Callback: ((value: any) -> ())?,
}

export type InputOptions = BaseElementOptions & {
	Default: string?,
	Placeholder: string?,
	Numeric: boolean?,
	Finished: boolean?,
	MaxLength: number?,
	Callback: ((value: string) -> ())?,
}

export type KeybindMode = "Toggle" | "Hold" | "Always"

export type KeybindOptions = BaseElementOptions & {
	Default: (Enum.KeyCode | string)?,
	Mode: KeybindMode?,
	Callback: ((active: boolean) -> ())?,
	ChangedCallback: ((newKey: Enum.KeyCode) -> ())?,
}

export type ColorpickerOptions = BaseElementOptions & {
	Default: Color3?,
	Transparency: number?,
	Callback: ((color: Color3, transparency: number?) -> ())?,
}

export type ParagraphOptions = {
	Id: string?,
	Title: string,
	Content: string,
	Visible: boolean?,
}

export type DividerOptions = {
	Text: string?,
	Visible: boolean?,
}

export type ProgressBarOptions = BaseElementOptions & {
	Value: number?,
	Max: number?,
	ShowPercent: boolean?,
}

export type ImageOptions = {
	Id: string?,
	Title: string?,
	Image: string,
	Height: number?,
	Caption: string?,
	ScaleType: Enum.ScaleType?,
	Visible: boolean?,
}

export type NotifyAction = {
	Title: string,
	Primary: boolean?,
	Callback: (() -> ())?,
}

export type NotifyOptions = {
	Title: string,
	Content: string,
	SubContent: string?,
	Duration: number?,
	Icon: string?,
	Actions: { NotifyAction }?,
}

export type DialogButton = {
	Title: string,
	Primary: boolean?,
	Callback: (() -> ())?,
}

export type DialogOptions = {
	Title: string,
	Content: string,
	Buttons: { DialogButton }?,
}

export type ConfigData = { [string]: any }

export type ElementHandle = {
	Id: string,
	Type: string,
	Frame: Frame,
	SetVisible: (self: any, visible: boolean) -> (),
	SetDisabled: (self: any, disabled: boolean, lockedText: string?) -> (),
	SetTitle: (self: any, title: string) -> (),
	SetDescription: (self: any, desc: string?) -> (),
	MatchesSearch: (self: any, query: string) -> boolean,
	Destroy: (self: any) -> (),
}

return {}

end

__MODULES["init"] = function(script, require)
-- FluentStudio: Modern Windows 11 Fluent UI Library built natively for Roblox Studio
-- Inspired by dawid-scripts/Fluent, rewritten from scratch for PlayerGui, Strict Luau, Mobile & Gamepad.

local Window = require(script.Components.Window)
local Themes = require(script.Themes)
local Icons = require(script.Icons)
local Types = require(script.Types)

export type ThemePalette = Types.ThemePalette
export type WindowOptions = Types.WindowOptions
export type TabOptions = Types.TabOptions
export type SectionOptions = Types.SectionOptions
export type ButtonOptions = Types.ButtonOptions
export type ToggleOptions = Types.ToggleOptions
export type SliderOptions = Types.SliderOptions
export type RangeSliderOptions = Types.RangeSliderOptions
export type DropdownOptions = Types.DropdownOptions
export type InputOptions = Types.InputOptions
export type KeybindOptions = Types.KeybindOptions
export type ColorpickerOptions = Types.ColorpickerOptions
export type ParagraphOptions = Types.ParagraphOptions
export type DividerOptions = Types.DividerOptions
export type ProgressBarOptions = Types.ProgressBarOptions
export type ImageOptions = Types.ImageOptions
export type NotifyOptions = Types.NotifyOptions
export type DialogOptions = Types.DialogOptions
export type ConfigData = Types.ConfigData

local FluentStudio = {
	Version = "1.0.0",
	Themes = Themes,
	Icons = Icons,
}

local activeWindows: { any } = {}

function FluentStudio.CreateWindow(options: WindowOptions)
	local win = Window.new(options)
	table.insert(activeWindows, win)
	return win
end

function FluentStudio.RegisterTheme(name: string, palette: ThemePalette)
	Themes.Register(name, palette)
end

function FluentStudio.CreateAccentTheme(name: string, accent: Color3, baseMode: ("Dark" | "Light")?): ThemePalette
	return Themes.CreateFromAccent(name, accent, baseMode)
end

function FluentStudio.GetThemes(): { string }
	return Themes.List()
end

function FluentStudio.RegisterIcon(name: string, assetId: string)
	Icons.Register(name, assetId)
end

function FluentStudio.DestroyAll()
	for _, win in ipairs(activeWindows) do
		win:Destroy()
	end
	table.clear(activeWindows)
end

return FluentStudio

end

return __require(__makeNode('init'))