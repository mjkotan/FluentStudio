--!strict
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
