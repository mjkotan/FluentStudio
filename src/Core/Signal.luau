--!strict
-- Lightweight Signal implementation for UI events

local Signal = {}
Signal.__index = Signal

export type Connection = {
	Connected: boolean,
	Disconnect: (self: Connection) -> (),
}

export type SignalType<T...> = {
	Connect: (self: SignalType<T...>, fn: (T...) -> ()) -> Connection,
	Once: (self: SignalType<T...>, fn: (T...) -> ()) -> Connection,
	Fire: (self: SignalType<T...>, T...) -> (),
	Destroy: (self: SignalType<T...>) -> (),
}

function Signal.new<T...>(): SignalType<T...>
	local self = setmetatable({
		_listeners = {} :: { { fn: (...any) -> (), once: boolean, connected: boolean } },
	}, Signal)
	return (self :: any) :: SignalType<T...>
end

function Signal:Connect(fn: (...any) -> ()): Connection
	local entry = {
		fn = fn,
		once = false,
		connected = true,
	}
	table.insert(self._listeners, entry)

	local conn: Connection = {
		Connected = true,
		Disconnect = function(c)
			if not c.Connected then
				return
			end
			c.Connected = false
			entry.connected = false
			local idx = table.find(self._listeners, entry)
			if idx then
				table.remove(self._listeners, idx)
			end
		end,
	}
	return conn
end

function Signal:Once(fn: (...any) -> ()): Connection
	local conn: Connection
	conn = self:Connect(function(...: any)
		conn:Disconnect()
		fn(...)
	end)
	return conn
end

function Signal:Fire(...: any)
	-- Snapshot to allow safe disconnect during Fire
	local snapshot = table.clone(self._listeners)
	for _, entry in ipairs(snapshot) do
		if entry.connected then
			task.spawn(entry.fn, ...)
		end
	end
end

function Signal:Destroy()
	for _, entry in ipairs(self._listeners) do
		entry.connected = false
	end
	table.clear(self._listeners)
end

return Signal
