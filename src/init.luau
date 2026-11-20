--!strict
-- FluentStudio: Modern Windows 11 Fluent UI Library built natively for Roblox Studio
-- Inspired by dawid-scripts/Fluent, rewritten from scratch for PlayerGui, Strict Luau, Mobile & Gamepad.

local UserInputService = game:GetService("UserInputService")
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

function FluentStudio.IsMobile(): boolean
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled
end

function FluentStudio.DestroyAll()
	for _, win in ipairs(activeWindows) do
		win:Destroy()
	end
	table.clear(activeWindows)
end

return FluentStudio
