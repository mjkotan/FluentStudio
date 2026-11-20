--!strict
-- Flexible Icon Resolver: supports named Lucide/common icons, custom registered icons, and direct rbxassetid:// URLs

local Icons = {}

local IconMap: { [string]: string } = {
	-- Common UI icons (Lucide-style Roblox uploaded icon IDs)
	home = "rbxassetid://10723407389",
	settings = "rbxassetid://10734950309",
	sliders = "rbxassetid://10734963400",
	search = "rbxassetid://10734943674",
	user = "rbxassetid://10747373176",
	users = "rbxassetid://10747373426",
	shield = "rbxassetid://10734951847",
	lock = "rbxassetid://10723434711",
	unlock = "rbxassetid://10747366027",
	bell = "rbxassetid://10709775704",
	star = "rbxassetid://10734966248",
	heart = "rbxassetid://10723406885",
	check = "rbxassetid://10709790644",
	x = "rbxassetid://10747384394",
	minus = "rbxassetid://10734896206",
	plus = "rbxassetid://10734924532",
	["chevron-down"] = "rbxassetid://10709790948",
	["chevron-right"] = "rbxassetid://10709791437",
	["chevron-up"] = "rbxassetid://10709791523",
	palette = "rbxassetid://10734910430",
	save = "rbxassetid://10734941499",
	folder = "rbxassetid://10723387563",
	file = "rbxassetid://10723374641",
	code = "rbxassetid://10709810463",
	terminal = "rbxassetid://10734982144",
	gamepad = "rbxassetid://10723395457",
	volume = "rbxassetid://10747376008",
	image = "rbxassetid://10723415040",
	eye = "rbxassetid://10723346959",
	["eye-off"] = "rbxassetid://10723346871",
	zap = "rbxassetid://10747384775",
	wrench = "rbxassetid://10747383470",
	info = "rbxassetid://10723415903",
	["alert-triangle"] = "rbxassetid://10709753149",
	menu = "rbxassetid://10734887784",
	sparkles = "rbxassetid://10734965070",
	layers = "rbxassetid://10723424505",
	globe = "rbxassetid://10723404337",
	keyboard = "rbxassetid://10723421808",
}

function Icons.Resolve(icon: string?): string
	if not icon or icon == "" then
		return ""
	end
	if string.sub(icon, 1, 13) == "rbxassetid://" or string.sub(icon, 1, 11) == "rbxasset://" then
		return icon
	end
	if tonumber(icon) then
		return "rbxassetid://" .. icon
	end
	local lower = string.lower(icon)
	return IconMap[lower] or ""
end

function Icons.Register(name: string, assetId: string)
	IconMap[string.lower(name)] = assetId
end

function Icons.RegisterBatch(map: { [string]: string })
	for k, v in pairs(map) do
		IconMap[string.lower(k)] = v
	end
end

return Icons
