-- Lune syntax verification script for all .luau files in src/ and examples/
local fs = require("@lune/fs")
local luau = require("@lune/luau")
local process = require("@lune/process")

local checked = 0
local failed = 0

local function scan(dir: string)
	for _, entry in ipairs(fs.readDir(dir)) do
		local full = dir .. "/" .. entry
		if fs.isDir(full) then
			scan(full)
		elseif string.sub(entry, -5) == ".luau" then
			checked += 1
			local source = fs.readFile(full)
			local ok, err = pcall(function()
				luau.compile(source)
			end)
			if not ok then
				failed += 1
				print("[FAIL] " .. full .. " -> " .. tostring(err))
			else
				print("[OK]   " .. full)
			end
		end
	end
end

scan("src")
scan("examples")

print(string.format("\nSummary: %d checked, %d failed", checked, failed))
if failed > 0 then
	process.exit(1)
end
