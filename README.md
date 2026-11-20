# FluentStudio

**UI Library สไตล์ Windows 11 Fluent Design ที่เขียนขึ้นใหม่ทั้งหมดด้วย `--!strict` Luau สำหรับเกม Roblox Studio โดยเฉพาะ**  
Modern **Windows 11 Fluent Design** UI Library written from scratch in `--!strict` Luau for **Roblox Studio** games (เมนูตั้งค่า, Admin/Dev Panel, หรือ UI เสริมภายในเกม).

ได้รับแรงบันดาลใจจาก `dawid-scripts/Fluent` แต่ยกเครื่องใหม่ทั้งหมดให้ทำงานบน `PlayerGui` อย่างถูกต้อง รองรับมือถือ (Touch), จอย (Gamepad), ภาษาไทย และระบบ Config ที่พร้อมเชื่อมกับ `DataStoreService`

---

## จุดเด่น (Features)

- **ออกแบบมาเพื่อ Roblox Studio โดยเฉพาะ (`PlayerGui`)**: ใช้ `ScreenGui` (`ResetOnSpawn = false`, `ZIndexBehavior.Sibling`, `IgnoreGuiInset = true`) ไม่มีโค้ดหรือ API นอกมาตรฐาน
- **รองรับครบทุกแพลตฟอร์ม (PC + Mobile + Gamepad)**:
  - มี `UIScale` ย่อขยายอัตโนมัติตามขนาดหน้าจอมือถือ/แท็บเล็ต
  - มี **ปุ่มลอย (Floating Toggle Button)** ลากย้ายตำแหน่งได้สำหรับเปิด-ปิด UI บนมือถือ
  - ขยายพื้นที่สัมผัส (Hitbox) ของ Slider และแถบลากหน้าต่างให้ใช้งานลื่นบนจอสัมผัส
  - รองรับการเลื่อนเลือกด้วยจอย (`Selectable` / `GuiService.SelectedObject`)
- **รองรับภาษาไทยเต็มรูปแบบ**: ใช้ `AutomaticSize`, `TextWrapped`, `LineHeight = 1.15` และ `AutoLocalize = true` เพื่อไม่ให้สระ/วรรณยุกต์ภาษาไทยโดนตัด
- **ระบบค้นหา (Global Search & Dropdown Search)**: พิมพ์ค้นหา Element ข้ามทุก Tab และค้นหาตัวเลือกภายใน Dropdown ได้แบบเรียลไทม์
- **Layout ยืดหยุ่น**: รองรับทั้งแบบ 1 คอลัมน์, 2 คอลัมน์ และกล่องหมวดหมู่พับเก็บได้ (**Collapsible Section / Accordion**)
- **Components ครบครัน**:
  - `Button`, `Toggle`, `Slider`, `RangeSlider` (สไลเดอร์ 2 หัว Min–Max), `Dropdown` (เลือกเดี่ยว/เลือกหลายข้อ + ค้นหา), `Input` (รองรับตัวเลขล้วน / จำกัดความยาว / ยิงค่าเมื่อพิมพ์เสร็จ), `Keybind` (`Toggle` / `Hold` / `Always`), `Colorpicker` (HSV + Hex), `Paragraph`, `Divider`, `ProgressBar`, `Image`
- **ฟีเจอร์สำหรับเกมจริง (Production Ready)**:
  - **Silent Update**: `SetValue(value, true)` อัปเดตค่าจาก DataStore เข้า UI โดยไม่ยิง Callback ซ้ำกลับไปหา Server
  - **Role / Gamepass Lock**: `SetDisabled(true, "Admin Only")` ล็อก Element พร้อมป้ายแจ้งเตือน (ฝั่ง Server ยังต้องตรวจสอบสิทธิ์จริงเสมอ)
  - **Config Adapter (DataStore Ready)**: `ExportConfig()` / `ImportConfig(tbl, silent)` และ `ExportJSON()` / `ImportJSON()` พร้อม Addon `Addons/DataStoreAdapter.luau`
  - **ระบบ Theme ครบวงจร**: มี 5 ธีมสำเร็จรูป (`Dark`, `Light`, `Amethyst`, `Aqua`, `Rose`) + สร้างธีมจากสีเดียวได้ทันทีด้วย `CreateAccentTheme()` หรือกำหนดเองด้วย `RegisterTheme()`
  - **Optional Blur & UI SFX**: ปิด `BlurEffect` เป็นค่าเริ่มต้นเพื่อไม่ให้ชนกับแสงในเกม และปรับเปิด-ปิดเสียง Hover/Click/Toggle ได้
  - **จัดการ Memory สะอาด**: มี `Janitor` เคลียร์ Connection และ Instance ทั้งหมดเมื่อเรียก `Window:Destroy()`

---

## โครงสร้างโปรเจกต์ (Project Structure)

```text
FluentStudio/
├── .github/workflows/ci.yml   # ตรวจ Syntax Luau อัตโนมัติด้วย Lune
├── Addons/
│   └── DataStoreAdapter.luau  # ตัวช่วยเชื่อม Config กับ RemoteEvent / DataStore
├── build/
│   ├── bundle.luau            # สคริปต์รวมไฟล์ (lune run build/bundle.luau)
│   └── FluentStudio.luau      # ไฟล์รวมตัวเดียว (วางเป็น ModuleScript เดียวใน Studio ได้เลย)
├── src/
│   ├── init.luau              # จุดเริ่มต้นหลักของ Library
│   ├── Types.luau             # Strict Luau Types ทั้งหมด
│   ├── Core/                  # Creator, Janitor, Signal, Sound
│   ├── Themes/                # ธีมสีและการสร้างธีมจาก Accent
│   ├── Icons/                 # ระบบแปลงชื่อไอคอนและ rbxassetid://
│   ├── Managers/              # ConfigManager (Export/Import Table & JSON)
│   ├── Components/            # Window, Tab, Section, Notification, Dialog
│   └── Elements/              # UI Elements ทั้งหมด 12 ชนิด
├── examples/
│   └── Demo.client.luau       # ตัวอย่างการใช้งานครบทุกฟีเจอร์
├── Example.client.luau        # ตัวอย่างเริ่มต้นแบบสั้น
├── default.project.json       # ไฟล์ตั้งค่าสำหรับ Rojo
└── tests/
    └── syntax_check.luau      # สคริปต์ตรวจ Syntax ด้วย Lune
```

---

## วิธีติดตั้ง (Installation)

### วิธีที่ 1: ใช้ไฟล์รวมตัวเดียว (ง่ายที่สุดสำหรับ Roblox Studio)
1. เปิดไฟล์ [build/FluentStudio.luau](build/FluentStudio.luau) แล้วคัดลอกโค้ดทั้งหมด
2. ใน Roblox Studio สร้าง `ModuleScript` ชื่อ `FluentStudio` ไว้ใน `ReplicatedStorage`
3. วางโค้ดลงไป จากนั้น `require(game.ReplicatedStorage.FluentStudio)` จาก `LocalScript` ได้ทันที

### วิธีที่ 2: ใช้ Rojo (แนะนำสำหรับงานโปรเจกต์จริง)
1. Clone repository นี้ลงเครื่อง
2. รันคำสั่ง:
   ```bash
   rojo serve default.project.json
   ```
3. กด Connect ผ่านปลั๊กอิน Rojo ใน Roblox Studio (ระบบจะซิงก์ `src/` เข้า `ReplicatedStorage.FluentStudio` และตัวอย่างเข้า `StarterPlayerScripts` ให้อัตโนมัติ)

---

## ตัวอย่างการใช้งานเบื้องต้น (Quick Start)

```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FluentStudio = require(ReplicatedStorage:WaitForChild("FluentStudio"))

-- สร้างธีมใหม่จากสี Accent เดียว (เลือกฐาน "Dark" หรือ "Light")
FluentStudio.CreateAccentTheme("Emerald", Color3.fromRGB(52, 211, 153), "Dark")

local Window = FluentStudio.CreateWindow({
	Title = "ตั้งค่าเกม",
	SubTitle = "v1.0.0",
	Theme = "Dark",
	MinimizeKey = Enum.KeyCode.RightControl,
	SearchBar = true,
	MobileToggleButton = true,
})

local MainTab = Window:AddTab({
	Title = "ทั่วไป",
	Icon = "settings",
	Columns = 2, -- แบ่ง 2 คอลัมน์
})

local Graphics = MainTab:AddSection({
	Title = "กราฟิก",
	Collapsible = true,
	Column = 1,
})

Graphics:AddToggle({
	Id = "GlobalShadows",
	Title = "เปิดเงา (Global Shadows)",
	Description = "ปิดเพื่อช่วยเพิ่ม FPS บนมือถือ",
	Default = true,
	Callback = function(enabled)
		print("Shadows:", enabled)
	end,
})

Graphics:AddSlider({
	Id = "MasterVolume",
	Title = "ระดับเสียงหลัก",
	Min = 0,
	Max = 100,
	Default = 80,
	Suffix = "%",
	Callback = function(val)
		print("Volume:", val)
	end,
})

-- ตัวอย่างซิงก์ค่ากับ DataStore โดยไม่ยิง Callback ซ้ำ (silent = true)
local savedTable = Window:ExportConfig()
Window:ImportConfig(savedTable, true)

-- แจ้งเตือนพร้อมแถบเวลา
Window:Notify({
	Title = "พร้อมใช้งาน",
	Content = "กด RightControl หรือปุ่มลอยเพื่อเปิด-ปิดหน้าต่าง",
	Duration = 4,
})
```

ดูตัวอย่างครบทุก Component ได้ที่ [examples/Demo.client.luau](examples/Demo.client.luau)

---

## การพัฒนาต่อและ Build (Development)

หากแก้ไขไฟล์ใน `src/` สามารถตรวจ Syntax และสร้างไฟล์รวม `build/FluentStudio.luau` ใหม่ได้ด้วย [Lune](https://lune-org.github.io/docs/):

```bash
# ตรวจ Syntax ทุกไฟล์
lune run tests/syntax_check.luau

# สร้างไฟล์รวมตัวเดียวใหม่
lune run build/bundle.luau
```

---

## License

MIT License — ดูรายละเอียดเพิ่มเติมในไฟล์ [LICENSE](LICENSE)
