--!strict
-- Roblox-Native Config Adapter (DataStore / ProfileStore ready)
-- Serializes & deserializes UI element values safely without executor file I/O

local HttpService = game:GetService("HttpService")
local Types = require(script.Parent.Parent.Types)

type ConfigData = Types.ConfigData

local ConfigManager = {}
ConfigManager.__index = ConfigManager

export type RegisteredEntry = {
	Id: string,
	Type: string,
	GetValue: () -> any,
	SetValue: (value: any, silent: boolean?) -> (),
	Default: any,
}

export type ConfigManagerType = typeof(setmetatable({} :: {
	_entries: { [string]: RegisteredEntry },
}, ConfigManager))

local function serializeValue(val: any): any
	local t = typeof(val)
	if t == "Color3" then
		return { __type = "Color3", r = val.R, g = val.G, b = val.B }
	elseif t == "EnumItem" then
		return { __type = "EnumItem", enum = tostring(val.EnumType), name = val.Name }
	elseif t == "table" then
		local out = {}
		for k, v in pairs(val) do
			out[k] = serializeValue(v)
		end
		return out
	end
	return val
end

local function deserializeValue(val: any): any
	if type(val) == "table" then
		if val.__type == "Color3" and type(val.r) == "number" and type(val.g) == "number" and type(val.b) == "number" then
			return Color3.new(val.r, val.g, val.b)
		elseif val.__type == "EnumItem" and type(val.enum) == "string" and type(val.name) == "string" then
			local enumType = (Enum :: any)[val.enum]
			if enumType and enumType[val.name] then
				return enumType[val.name]
			end
			return nil
		else
			local out = {}
			for k, v in pairs(val) do
				out[k] = deserializeValue(v)
			end
			return out
		end
	end
	return val
end

function ConfigManager.new(): ConfigManagerType
	return setmetatable({
		_entries = {},
	}, ConfigManager)
end

function ConfigManager:Register(entry: RegisteredEntry)
	self._entries[entry.Id] = entry
end

function ConfigManager:Unregister(id: string)
	self._entries[id] = nil
end

function ConfigManager:Export(): ConfigData
	local data: ConfigData = {}
	for id, entry in pairs(self._entries) do
		data[id] = serializeValue(entry.GetValue())
	end
	return data
end

function ConfigManager:Import(data: ConfigData, silent: boolean?)
	if type(data) ~= "table" then
		return
	end
	for id, rawVal in pairs(data) do
		local entry = self._entries[id]
		if entry then
			local decoded = deserializeValue(rawVal)
			if decoded ~= nil then
				entry.SetValue(decoded, silent)
			end
		end
	end
end

function ConfigManager:ExportJSON(): string
	return HttpService:JSONEncode(self:Export())
end

function ConfigManager:ImportJSON(jsonString: string, silent: boolean?): boolean
	local ok, decoded = pcall(function()
		return HttpService:JSONDecode(jsonString)
	end)
	if not ok or type(decoded) ~= "table" then
		return false
	end
	self:Import(decoded, silent)
	return true
end

function ConfigManager:ResetDefaults(silent: boolean?)
	for _, entry in pairs(self._entries) do
		if entry.Default ~= nil then
			entry.SetValue(entry.Default, silent)
		end
	end
end

function ConfigManager:Destroy()
	table.clear(self._entries)
end

return ConfigManager
