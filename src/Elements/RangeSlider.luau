--!strict
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
