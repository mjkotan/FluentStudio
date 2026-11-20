--!strict
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
	MobileToggleButton: ("Auto" | boolean)?,
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
