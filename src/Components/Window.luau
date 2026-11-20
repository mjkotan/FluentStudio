--!strict
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

local function detectMobile(): boolean
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled
end

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

	local isMobile = detectMobile()
	local minSize = options.MinSize or Vector2.new(440, 320)
	local tabWidth = options.TabWidth or 165
	local minimizeKey = options.MinimizeKey or Enum.KeyCode.RightControl
	local resizable = if options.Resizable == nil then true else options.Resizable
	local showSearch = if options.SearchBar == nil then true else options.SearchBar
	local showMobileToggle: boolean
	if options.MobileToggleButton == nil or options.MobileToggleButton == "Auto" then
		showMobileToggle = isMobile
	else
		showMobileToggle = options.MobileToggleButton == true
	end

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
		IsMobile = isMobile,
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
