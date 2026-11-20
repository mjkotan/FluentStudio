--!strict
-- FluentStudio Addon: DataStore Config Adapter (Server-Authoritative Pattern)
-- Bridges Window:ExportConfig() / Window:ImportConfig() with a RemoteFunction/RemoteEvent

local DataStoreAdapter = {}
DataStoreAdapter.__index = DataStoreAdapter

export type AdapterOptions = {
	Window: any,
	LoadRemote: RemoteFunction?,
	SaveRemote: RemoteEvent?,
	AutoLoad: boolean?,
}

function DataStoreAdapter.new(options: AdapterOptions)
	local self = setmetatable({
		_window = options.Window,
		_loadRemote = options.LoadRemote,
		_saveRemote = options.SaveRemote,
	}, DataStoreAdapter)

	if options.AutoLoad and options.LoadRemote then
		task.spawn(function()
			self:Load(true)
		end)
	end

	return self
end

function DataStoreAdapter:Load(silent: boolean?): boolean
	if not self._loadRemote then
		return false
	end
	local ok, data = pcall(function()
		return self._loadRemote:InvokeServer()
	end)
	if ok and type(data) == "table" then
		self._window:ImportConfig(data, if silent == nil then true else silent)
		return true
	end
	return false
end

function DataStoreAdapter:Save(): boolean
	if not self._saveRemote then
		return false
	end
	local payload = self._window:ExportConfig()
	self._saveRemote:FireServer(payload)
	return true
end

function DataStoreAdapter:Reset(silent: boolean?)
	self._window:ResetConfig(silent)
end

return DataStoreAdapter
