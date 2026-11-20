--!strict
-- FluentStudio Quick Example (LocalScript in StarterPlayerScripts)
-- See examples/Demo.client.luau for the full showcase

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FluentStudio = require(ReplicatedStorage:WaitForChild("FluentStudio"))

local Window = FluentStudio.CreateWindow({
	Title = "FluentStudio",
	SubTitle = "v1.0.0",
	Theme = "Dark",
	MinimizeKey = Enum.KeyCode.RightControl,
})

local MainTab = Window:AddTab({
	Title = "Main",
	Icon = "home",
})

MainTab:AddParagraph({
	Title = "FluentStudio",
	Content = "Modern Windows 11 Fluent UI Library built natively for Roblox Studio.",
})

MainTab:AddToggle({
	Id = "ExampleToggle",
	Title = "Enable Feature",
	Default = true,
	Callback = function(value)
		print("Toggle:", value)
	end,
})

MainTab:AddSlider({
	Id = "ExampleSlider",
	Title = "WalkSpeed",
	Min = 16,
	Max = 100,
	Default = 16,
	Rounding = 0,
	Callback = function(value)
		print("Slider:", value)
	end,
})

Window:Notify({
	Title = "Loaded",
	Content = "Press RightControl to toggle the window.",
	Duration = 4,
})
