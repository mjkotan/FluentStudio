--!strict
-- Optional UI Sound controller for micro-interactions (Hover, Click, Toggle, Notify)

local SoundService = game:GetService("SoundService")

local SoundController = {}
SoundController.__index = SoundController

export type SoundPreset = "Hover" | "Click" | "ToggleOn" | "ToggleOff" | "Notify"

export type SoundControllerType = typeof(setmetatable({} :: {
	Enabled: boolean,
	Volume: number,
	Sounds: { [SoundPreset]: string },
}, SoundController))

local DEFAULT_SOUNDS: { [SoundPreset]: string } = {
	Hover = "rbxassetid://6895079853",
	Click = "rbxassetid://6895079853",
	ToggleOn = "rbxassetid://6895079853",
	ToggleOff = "rbxassetid://6895079853",
	Notify = "rbxassetid://6895079853",
}

local PITCH_MAP: { [SoundPreset]: number } = {
	Hover = 1.25,
	Click = 1.0,
	ToggleOn = 1.15,
	ToggleOff = 0.85,
	Notify = 1.05,
}

function SoundController.new(enabled: boolean?): SoundControllerType
	return setmetatable({
		Enabled = if enabled == nil then true else enabled,
		Volume = 0.15,
		Sounds = table.clone(DEFAULT_SOUNDS),
	}, SoundController)
end

function SoundController:SetEnabled(enabled: boolean)
	self.Enabled = enabled
end

function SoundController:SetSoundId(preset: SoundPreset, assetId: string)
	self.Sounds[preset] = assetId
end

function SoundController:Play(preset: SoundPreset)
	if not self.Enabled then
		return
	end
	local assetId = self.Sounds[preset]
	if not assetId or assetId == "" then
		return
	end

	local sound = Instance.new("Sound")
	sound.SoundId = assetId
	sound.Volume = if preset == "Hover" then self.Volume * 0.45 else self.Volume
	sound.PlaybackSpeed = PITCH_MAP[preset] or 1.0
	sound.Parent = SoundService
	sound:Play()
	sound.Ended:Once(function()
		sound:Destroy()
	end)
	-- Fallback cleanup in case Ended doesn't fire
	task.delay(2, function()
		if sound.Parent then
			sound:Destroy()
		end
	end)
end

return SoundController
