--!strict
-- FluentStudio Showcase Demo (Place in StarterPlayerScripts)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FluentStudio = require(ReplicatedStorage:WaitForChild("FluentStudio"))

-- Create a custom accent theme at runtime
FluentStudio.CreateAccentTheme("Emerald", Color3.fromRGB(52, 211, 153), "Dark")

local Window = FluentStudio.CreateWindow({
	Title = "FluentStudio",
	SubTitle = "v1.0 • Roblox Studio UI",
	Size = UDim2.fromOffset(640, 450),
	Theme = "Dark",
	MinimizeKey = Enum.KeyCode.RightControl,
	AcrylicBlur = false, -- Optional, OFF by default to not interfere with game Lighting
	Resizable = true,
	SearchBar = true,
	SoundEnabled = true,
	MobileToggleButton = true,
})

-- ============================================
-- Tab 1: General Settings (2-Column Layout)
-- ============================================
local GeneralTab = Window:AddTab({
	Title = "การตั้งค่า",
	Icon = "settings",
	Columns = 2,
})

local GraphicsSection = GeneralTab:AddSection({
	Title = "กราฟิกและเสียง",
	Collapsible = true,
	DefaultOpen = true,
	Column = 1,
})

GraphicsSection:AddToggle({
	Id = "ShadowsEnabled",
	Title = "เปิดเงา (Global Shadows)",
	Description = "ปิดเพื่อเพิ่ม FPS บนมือถือและเครื่องสเปกต่ำ",
	Default = true,
	Callback = function(val)
		print("[Settings] Shadows:", val)
	end,
})

GraphicsSection:AddSlider({
	Id = "MasterVolume",
	Title = "ระดับเสียงหลัก",
	Description = "ปรับความดังเสียงทั้งหมดในเกม",
	Min = 0,
	Max = 100,
	Default = 75,
	Rounding = 0,
	Suffix = "%",
	Callback = function(val)
		print("[Settings] Volume:", val)
	end,
})

GraphicsSection:AddRangeSlider({
	Id = "RenderDistance",
	Title = "ระยะการมองเห็น (Min–Max)",
	Min = 50,
	Max = 1000,
	DefaultMin = 150,
	DefaultMax = 650,
	Rounding = 0,
	Suffix = "m",
	Callback = function(minV, maxV)
		print("[Settings] Render Distance:", minV, "to", maxV)
	end,
})

local ControlsSection = GeneralTab:AddSection({
	Title = "การควบคุม",
	Collapsible = true,
	DefaultOpen = true,
	Column = 2,
})

ControlsSection:AddDropdown({
	Id = "QualityPreset",
	Title = "โหมดคุณภาพ",
	Values = { "Low", "Medium", "High", "Ultra" },
	Default = "High",
	Searchable = false,
	Callback = function(val)
		print("[Settings] Preset:", val)
	end,
})

ControlsSection:AddDropdown({
	Id = "EnabledNotifications",
	Title = "ประเภทแจ้งเตือน (เลือกหลายข้อ)",
	Values = { "Quest", "Trade", "Party", "System", "Shop", "Achievement" },
	Default = { "Quest", "System" },
	Multi = true,
	Searchable = true,
	Callback = function(list)
		print("[Settings] Notifications:", table.concat(list, ", "))
	end,
})

ControlsSection:AddKeybind({
	Id = "SprintKey",
	Title = "ปุ่มวิ่งเร็ว (Sprint)",
	Default = Enum.KeyCode.LeftShift,
	Mode = "Hold",
	Callback = function(active)
		print("[Controls] Sprint active:", active)
	end,
})

-- ============================================
-- Tab 2: Components & Role Lock Demo
-- ============================================
local DemoTab = Window:AddTab({
	Title = "Components",
	Icon = "layers",
})

DemoTab:AddParagraph({
	Title = "ยินดีต้อนรับสู่ FluentStudio",
	Content = "UI Library ที่ออกแบบมาเพื่อเกม Roblox Studio โดยเฉพาะ รองรับภาษาไทยเต็มรูปแบบ, มือถือ (Touch), จอย (Gamepad) และระบบ Export/Import Config สำหรับ DataStore",
})

local xpBar = DemoTab:AddProgressBar({
	Title = "Level Progress",
	Description = "ตัวอย่าง ProgressBar แบบอัปเดตเรียลไทม์",
	Value = 65,
	Max = 100,
	ShowPercent = true,
})

DemoTab:AddButton({
	Title = "เพิ่ม XP +15%",
	Description = "ทดสอบการอัปเดต ProgressBar และ Notification",
	ButtonText = "Add XP",
	Callback = function()
		xpBar:SetValue(math.random(20, 100), 100)
		Window:Notify({
			Title = "อัปเดตสำเร็จ",
			Content = "ค่า ProgressBar ถูกอัปเดตเรียบร้อยแล้ว",
			Duration = 3.5,
			Icon = "sparkles",
		})
	end,
})

DemoTab:AddInput({
	Id = "PlayerBio",
	Title = "ข้อความโปรไฟล์",
	Placeholder = "พิมพ์ข้อความที่นี่...",
	Finished = true,
	MaxLength = 40,
	Callback = function(text)
		print("[Profile] Bio:", text)
	end,
})

DemoTab:AddColorpicker({
	Id = "AuraColor",
	Title = "สีเอฟเฟกต์ตัวละคร",
	Default = Color3.fromRGB(96, 205, 255),
	Callback = function(color)
		print("[Cosmetic] Color:", color)
	end,
})

DemoTab:AddDivider({ Text = "Role Gating" })

local adminBtn = DemoTab:AddButton({
	Title = "รีเซ็ตเซิร์ฟเวอร์ (Admin Only)",
	Description = "ตัวอย่าง Element ที่ถูกล็อกตาม Role/Gamepass",
	ButtonText = "Reset",
	Disabled = true,
	LockedText = "Admin Only",
	Callback = function()
		Window:Dialog({
			Title = "ยืนยันการรีเซ็ต?",
			Content = "การกระทำนี้จะส่งคำขอไปยัง Server (Server ต้องตรวจสอบสิทธิ์จริงอีกครั้ง)",
			Buttons = {
				{ Title = "ยกเลิก", Primary = false },
				{
					Title = "ยืนยัน",
					Primary = true,
					Callback = function()
						print("[Admin] Confirmed!")
					end,
				},
			},
		})
	end,
})

DemoTab:AddToggle({
	Title = "จำลองสิทธิ์ Admin",
	Description = "เปิดเพื่อปลดล็อกปุ่มด้านบน",
	Default = false,
	Saveable = false,
	Callback = function(isAdmin)
		adminBtn:SetDisabled(not isAdmin, "Admin Only")
	end,
})

-- ============================================
-- Tab 3: Theme & Config (DataStore Adapter)
-- ============================================
local ThemeTab = Window:AddTab({
	Title = "ธีม & Config",
	Icon = "palette",
})

ThemeTab:AddDropdown({
	Id = "UITheme",
	Title = "เลือกธีมสี (Theme)",
	Values = FluentStudio.GetThemes(),
	Default = "Dark",
	Searchable = false,
	Callback = function(themeName)
		Window:SetTheme(themeName)
	end,
})

ThemeTab:AddToggle({
	Id = "AcrylicBlur",
	Title = "เปิดเอฟเฟกต์เบลอพื้นหลัง (Blur)",
	Description = "เปิดใช้ Lighting.BlurEffect ขณะหน้าต่างแสดงอยู่",
	Default = false,
	Callback = function(val)
		Window:SetAcrylicBlur(val)
	end,
})

ThemeTab:AddToggle({
	Id = "UISound",
	Title = "เสียงประกอบ UI (SFX)",
	Default = true,
	Callback = function(val)
		Window:SetSoundEnabled(val)
	end,
})

ThemeTab:AddDivider({ Text = "DataStore Config Adapter" })

local savedSnapshot: string = ""

ThemeTab:AddButton({
	Title = "Export Config เป็น JSON",
	Description = "จำลองการดึงค่าทั้งหมดเพื่อส่งไปเก็บลง DataStore",
	ButtonText = "Export",
	Callback = function()
		savedSnapshot = Window:ExportJSON()
		print("[Config Exported]:", savedSnapshot)
		Window:Notify({
			Title = "Export สำเร็จ",
			Content = "บันทึกค่าตั้งค่าทั้งหมดเป็น JSON แล้ว (ดูใน Output)",
			Duration = 3,
			Icon = "save",
		})
	end,
})

ThemeTab:AddButton({
	Title = "Import Config (Silent Update)",
	Description = "โหลดค่ากลับเข้า UI โดยไม่ยิง Callback ซ้ำ",
	ButtonText = "Import",
	Callback = function()
		if savedSnapshot ~= "" then
			Window:ImportJSON(savedSnapshot, true)
			Window:Notify({
				Title = "Import สำเร็จ",
				Content = "โหลดค่ากลับเข้า UI แบบ Silent เรียบร้อย",
				Duration = 3,
				Icon = "check",
			})
		else
			Window:Notify({
				Title = "ยังไม่มีข้อมูล",
				Content = "กรุณากด Export Config ก่อน",
				Duration = 3,
				Icon = "alert-triangle",
			})
		end
	end,
})

Window:Notify({
	Title = "FluentStudio Ready",
	Content = "กด RightControl หรือปุ่มลอยเพื่อเปิด-ปิดหน้าต่าง",
	Duration = 5,
	Icon = "sparkles",
})
