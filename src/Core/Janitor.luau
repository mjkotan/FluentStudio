--!strict
-- Lightweight Janitor for deterministic cleanup of Instances, RBXScriptConnections, Tweens, and callbacks

local Janitor = {}
Janitor.__index = Janitor

export type Cleanable = RBXScriptConnection | Instance | Tween | () -> () | { Destroy: (any) -> () } | { Disconnect: (any) -> () }

export type JanitorType = typeof(setmetatable({} :: {
	_tasks: { any },
	_destroyed: boolean,
}, Janitor))

function Janitor.new(): JanitorType
	return setmetatable({
		_tasks = {},
		_destroyed = false,
	}, Janitor)
end

function Janitor:Add<T>(taskObj: T): T
	if self._destroyed then
		self:_cleanupSingle(taskObj)
		return taskObj
	end
	table.insert(self._tasks, taskObj)
	return taskObj
end

function Janitor:_cleanupSingle(taskObj: any)
	local t = typeof(taskObj)
	if t == "RBXScriptConnection" then
		if taskObj.Connected then
			taskObj:Disconnect()
		end
	elseif t == "Instance" then
		if taskObj.Parent ~= nil then
			taskObj:Destroy()
		else
			pcall(function()
				taskObj:Destroy()
			end)
		end
	elseif t == "function" then
		taskObj()
	elseif t == "table" then
		if type(taskObj.Destroy) == "function" then
			taskObj:Destroy()
		elseif type(taskObj.Disconnect) == "function" then
			taskObj:Disconnect()
		elseif type(taskObj.Cancel) == "function" then
			taskObj:Cancel()
		end
	end
end

function Janitor:Cleanup()
	for i = #self._tasks, 1, -1 do
		local taskObj = self._tasks[i]
		self._tasks[i] = nil
		self:_cleanupSingle(taskObj)
	end
end

function Janitor:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true
	self:Cleanup()
end

return Janitor
