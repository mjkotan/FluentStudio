--!strict
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
