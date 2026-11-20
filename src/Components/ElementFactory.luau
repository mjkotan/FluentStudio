--!strict
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
