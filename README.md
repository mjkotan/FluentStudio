# FluentStudio

Modern **Windows 11 Fluent Design** UI Library written from scratch in `--!strict` Luau for **Roblox Studio** games (Settings menus, Admin/Dev panels, In-game utilities).

Inspired by `dawid-scripts/Fluent`, redesigned natively for `PlayerGui`, Mobile/Touch, Gamepad, Thai/Localization support, and DataStore-ready configuration.

---

## Features

- **Roblox Studio Native (`PlayerGui`)**: Uses `ScreenGui` (`ResetOnSpawn = false`, `ZIndexBehavior.Sibling`, `IgnoreGuiInset = true`) with zero unsafe/executor dependencies.
- **PC + Mobile + Gamepad Ready**:
  - Automatic responsive `UIScale` for small screens.
  - Draggable **Floating Toggle Button** for mobile.
  - Touch-friendly hitboxes for sliders & window dragging.
  - `Selectable` navigation support for Gamepads.
- **Global Search & Dropdown Search**: Filter tabs and elements in real time.
- **1-Column & 2-Column Layouts + Collapsible Sections (Accordion)**.
- **Rich Elements**:
  - `Button`, `Toggle`, `Slider`, `RangeSlider` (Min–Max), `Dropdown` (Single & Multi + Search), `Input` (Numeric / Finished / MaxLength), `Keybind` (Toggle / Hold / Always), `Colorpicker` (HSV + Hex), `Paragraph`, `Divider`, `ProgressBar`, `Image`.
- **In-Game Production Utilities**:
  - **Silent Update**: `SetValue(val, true)` updates UI from DataStore without re-firing callbacks.
  - **Role / Gamepass Lock Overlay**: `SetDisabled(true, "Admin Only")` on any element.
  - **Config Adapter**: `ExportConfig()` / `ImportConfig(tbl, silent)` & `ExportJSON()` / `ImportJSON()` ready for `DataStoreService` / ProfileStore.
  - **Theme Engine**: 5 built-in themes (`Dark`, `Light`, `Amethyst`, `Aqua`, `Rose`) + `CreateAccentTheme()` + `RegisterTheme()`.
  - **Optional Blur & UI SFX**: Off-by-default `BlurEffect` so it never clashes with game lighting, plus configurable Hover/Click/Toggle sounds.
  - **Deterministic Cleanup**: Built-in `Janitor` cleans up all Connections and Instances on `Window:Destroy()`.

---

## Project Structure

```text
FluentStudio/
├── default.project.json       # Rojo project config
├── src/
│   ├── init.luau              # Main module entry point
│   ├── Types.luau             # Strict Luau type definitions
│   ├── Core/
│   │   ├── Creator.luau       # Instance builder, Tween & live Theme registry
│   │   ├── Janitor.luau       # Lifecycle & memory cleanup
│   │   ├── Signal.luau        # Lightweight typed events
│   │   └── Sound.luau         # Optional micro-interaction SFX
│   ├── Themes/
│   │   └── init.luau          # Built-in themes & Accent generator
│   ├── Icons/
│   │   └── init.luau          # Named Lucide icons & rbxassetid:// resolver
│   ├── Managers/
│   │   └── ConfigManager.luau # DataStore-ready Export/Import adapter
│   ├── Components/
│   │   ├── Window.luau        # Main window, drag/resize, search, mobile toggle
│   │   ├── Tab.luau           # 1 or 2-column tab pages
│   │   ├── Section.luau       # Collapsible accordion sections
│   │   ├── ElementFactory.luau
│   │   ├── Notification.luau  # Stackable notifications with progress bar & actions
│   │   └── Dialog.luau        # Modal confirmation dialogs
│   └── Elements/
│       ├── BaseElement.luau
│       ├── Button.luau
│       ├── Toggle.luau
│       ├── Slider.luau
│       ├── RangeSlider.luau
│       ├── Dropdown.luau
│       ├── Input.luau
│       ├── Keybind.luau
│       ├── Colorpicker.luau
│       ├── Paragraph.luau
│       ├── Divider.luau
│       ├── ProgressBar.luau
│       └── Image.luau
└── examples/
    └── Demo.client.luau       # Full showcase LocalScript
```

---

## Installation

### Option 1: Rojo (Recommended)
1. Clone this repository.
2. Run `rojo serve default.project.json`.
3. Connect from Roblox Studio via the Rojo plugin.

### Option 2: Manual
Copy the `src/` folder into `ReplicatedStorage` as a `ModuleScript` named `FluentStudio` (with `init.luau` as the module's source and subfolders as child `Folder`/`ModuleScript` instances).

---

## Quick Start

```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FluentStudio = require(ReplicatedStorage:WaitForChild("FluentStudio"))

local Window = FluentStudio.CreateWindow({
	Title = "Game Settings",
	SubTitle = "v1.0",
	Theme = "Dark",
	MinimizeKey = Enum.KeyCode.RightControl,
})

local MainTab = Window:AddTab({
	Title = "General",
	Icon = "settings",
	Columns = 2,
})

local Graphics = MainTab:AddSection({
	Title = "Graphics",
	Collapsible = true,
	Column = 1,
})

Graphics:AddToggle({
	Id = "Shadows",
	Title = "Global Shadows",
	Default = true,
	Callback = function(enabled)
		print("Shadows:", enabled)
	end,
})

-- Sync with DataStore (Server-authoritative)
local savedTable = Window:ExportConfig()
Window:ImportConfig(savedTable, true) -- silent = true avoids re-firing callbacks
```

---

## License

MIT License — see [LICENSE](LICENSE).
